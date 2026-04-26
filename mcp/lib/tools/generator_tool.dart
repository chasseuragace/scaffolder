import 'dart:convert';
import 'dart:io';

import '../base/path_safety.dart';
import '../base/tool.dart';

/// Generates a Flutter feature (Clean Architecture: domain / data /
/// presentation) and registers it in the project's feature registry.
///
/// **Side effects:** creates files under `lib/features/<name>/` and
/// `test/features/<name>/`, may modify `lib/core/routing/feature_registry.dart`,
/// may overwrite existing files when `overwrite` is true.
///
/// Use `dry_run=true` to preview without touching the filesystem.
class GeneratorTool implements MCPTool {
  GeneratorTool({
    required this.defaultProjectRoot,
    required this.defaultTemplatesDir,
    required this.defaultPackageName,
    PathSafety? pathSafety,
  }) : _pathSafety = pathSafety ?? PathSafety();

  final String defaultProjectRoot;
  final String defaultTemplatesDir;
  final String defaultPackageName;
  final PathSafety _pathSafety;

  @override
  String get name => 'generate_feature';

  @override
  String get description =>
      'Scaffold a Flutter CRUD feature (domain/data/presentation). '
      'Creates files under lib/features/<name>/ and test/features/<name>/, '
      'and registers the feature in lib/core/routing/feature_registry.dart. '
      'Use dry_run=true to preview without writing. '
      'Use overwrite=true to replace existing files (clobbers hand-edits).';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'module_name': {
            'type': 'string',
            'description':
                'Feature name. Any case shape accepted ("User", "userProfile", '
                '"user_profile" — all normalise correctly).',
          },
          'preset': {
            'type': 'string',
            'enum': ['simple', 'standard', 'enterprise'],
            'description':
                'Preset bundle. Default "standard". Call get_presets to see what each enables.',
          },
          'features': {
            'type': 'object',
            'description':
                'Per-flag overrides on top of the preset. Call get_schema for valid flag names.',
            'additionalProperties': {'type': 'boolean'},
          },
          'overwrite': {
            'type': 'boolean',
            'description':
                'Replace existing files. Destructive — clobbers hand-edits. '
                'feature_registry.dart is preserved regardless. Default false.',
          },
          'dry_run': {
            'type': 'boolean',
            'description':
                'Preview only — return what would be created/skipped without '
                'touching the filesystem or registry. Default false.',
          },
          'output_dir': {
            'type': 'string',
            'description':
                'Project root to scaffold into. Defaults to the server\'s '
                'PROJECT_ROOT env var. Must exist, be a directory, contain '
                'pubspec.yaml, and (if ALLOWED_ROOT is set) reside under it.',
          },
        },
        'required': ['module_name'],
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final moduleName = arguments['module_name'] as String?;
    if (moduleName == null || moduleName.isEmpty) {
      throw ToolFailure('module_name is required');
    }

    final preset = (arguments['preset'] as String?) ?? 'standard';
    final overwrite = (arguments['overwrite'] as bool?) ?? false;
    final dryRun = (arguments['dry_run'] as bool?) ?? false;

    final projectRoot = _resolveProjectRoot(arguments);
    final templatesDir = _resolveTemplatesDir(arguments, projectRoot);
    final packageName =
        (arguments['package_name'] as String?) ?? defaultPackageName;

    final cliArgs = <String>['run', 'tool/bin/generate.dart', '--json'];
    cliArgs.addAll([moduleName, '--preset', preset]);
    if (overwrite) cliArgs.add('--overwrite');
    if (dryRun) cliArgs.add('--dry-run');

    final features = arguments['features'] as Map<String, dynamic>?;
    if (features != null) {
      for (final entry in features.entries) {
        if (entry.value is bool) {
          cliArgs.addAll(['--feature', '${entry.key}=${entry.value}']);
        }
      }
    }

    cliArgs.addAll(['--root', projectRoot]);
    cliArgs.addAll(['--templates', templatesDir]);
    cliArgs.addAll(['--package', packageName]);

    final process = await Process.run(
      'dart',
      cliArgs,
      workingDirectory: projectRoot,
    );

    final stdoutText = process.stdout.toString().trim();
    final stderrText = process.stderr.toString().trim();

    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(stdoutText) as Map<String, dynamic>;
    } catch (_) {
      // Generator didn't produce JSON (likely a startup failure before --json kicked in).
      throw ToolFailure(
        'generator did not produce JSON output (exit=${process.exitCode}): '
        '${stderrText.isEmpty ? stdoutText : stderrText}',
      );
    }

    if (parsed['success'] != true) {
      throw ToolFailure(
        parsed['error']?.toString() ?? 'unknown generator error',
        data: parsed,
      );
    }

    return jsonEncode({
      'module': parsed['module'],
      'preset': parsed['preset'],
      'dry_run': parsed['dry_run'],
      'project_root': projectRoot,
      'created': parsed['created'],
      'overwritten': parsed['overwritten'],
      'skipped': parsed['skipped'],
      'summary': {
        'created': (parsed['created'] as List).length,
        'overwritten': (parsed['overwritten'] as List).length,
        'skipped': (parsed['skipped'] as List).length,
      },
    });
  }

  String _resolveProjectRoot(Map<String, dynamic> arguments) {
    final raw = arguments['output_dir'] as String?;
    if (raw == null || raw.isEmpty) return defaultProjectRoot;
    return _pathSafety.validate(raw);
  }

  String _resolveTemplatesDir(
    Map<String, dynamic> arguments,
    String projectRoot,
  ) {
    final raw = arguments['templates_dir'] as String?;
    if (raw != null && raw.isNotEmpty) return raw;
    // If output_dir was overridden but templates_dir was not, default to
    // <output_dir>/templates so the agent doesn't need to know the layout.
    if (arguments.containsKey('output_dir')) return '$projectRoot/templates';
    return defaultTemplatesDir;
  }
}
