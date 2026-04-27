import 'dart:convert';
import 'dart:io';

import '../base/path_safety.dart';
import '../base/tool.dart';

/// Generates a Flutter feature (Clean Architecture: domain / data /
/// presentation) and registers it in the working project's feature
/// registry.
///
/// Two roots are involved and kept distinct on purpose:
///   - `generatorRoot` is auto-detected at server startup. It's where the
///     templates and the CLI script live. Callers do not specify this.
///   - `output_dir` (per-call) or [defaultWorkingRoot] (server fallback)
///     is the *working* Flutter project where files get written.
///
/// **Side effects:** writes files under `lib/features/<name>/` and
/// `test/features/<name>/`, and idempotently edits
/// `lib/core/routing/feature_registry.dart`.
class GeneratorTool implements MCPTool {
  GeneratorTool({
    required this.generatorRoot,
    required this.defaultWorkingRoot,
    required this.defaultPackageName,
    PathSafety? pathSafety,
  }) : _pathSafety = pathSafety ?? PathSafety();

  /// Where the templates and CLI script live. Auto-detected.
  final String generatorRoot;

  /// Default working project (where output goes) when `output_dir` is omitted.
  final String defaultWorkingRoot;

  final String defaultPackageName;
  final PathSafety _pathSafety;

  String get _cliScript => '$generatorRoot/bin/generate.dart';
  String get _templatesDir => '$generatorRoot/templates';

  @override
  String get name => 'generate_feature';

  @override
  String get description =>
      'Scaffold a CRUD feature (Clean Architecture: domain/data/presentation). '
      'Supports both Flutter and React via the templates parameter. '
      'Writes files into the *working project* (output_dir or PROJECT_ROOT) '
      'using templates from the generator\'s install location. '
      'Creates files under lib/features/<name>/ or src/features/<name>/, '
      'and registers the feature in the feature registry. '
      'Use dry_run=true to preview without writing. '
      'Use overwrite=true to replace existing files (clobbers hand-edits). '
      'Use templates="templates_react" for React projects.';

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
                'feature_registry is preserved regardless. Default false.',
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
                'The *working* project root to scaffold into. Defaults to '
                'the server\'s PROJECT_ROOT env var. Must exist, be a '
                'directory, contain pubspec.yaml or package.json, and (if ALLOWED_ROOT is '
                'set) reside under it. NOT the generator\'s install '
                'location — that is auto-detected.',
          },
          'package_name': {
            'type': 'string',
            'description':
                'Package name of the working project. Defaults to '
                'the server\'s PACKAGE_NAME env var (typically `flutter_project`).',
          },
          'templates': {
            'type': 'string',
            'description':
                'Templates directory to use. Relative to generator root. '
                'Default "templates" for Flutter. Use "templates_react" for React projects.',
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

    final workingRoot = _resolveWorkingRoot(arguments);
    final packageName =
        (arguments['package_name'] as String?) ?? defaultPackageName;
    final templatesArg = arguments['templates'] as String?;
    // For React templates, pass absolute path to generator root + templates_react
    // For Flutter (default), use the existing _templatesDir which is already absolute
    final templatesDir = templatesArg != null
        ? Directory('$generatorRoot/$templatesArg').absolute.path
        : _templatesDir;

    final cliArgs = <String>['run', _cliScript, '--json'];
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

    cliArgs.addAll(['--out', workingRoot]);
    cliArgs.addAll(['--templates', templatesDir]);
    cliArgs.addAll(['--package', packageName]);

    final process = await Process.run(
      'dart',
      cliArgs,
      // Run in the working project so any relative behaviour the CLI has
      // (e.g. Directory.current) lines up with where files are written.
      workingDirectory: workingRoot,
    );

    final stdoutText = process.stdout.toString().trim();
    final stderrText = process.stderr.toString().trim();

    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(stdoutText) as Map<String, dynamic>;
    } catch (_) {
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
      'working_root': workingRoot,
      'generator_root': generatorRoot,
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

  String _resolveWorkingRoot(Map<String, dynamic> arguments) {
    final raw = arguments['output_dir'] as String?;
    if (raw == null || raw.isEmpty) return defaultWorkingRoot;
    return _pathSafety.validate(raw);
  }
}
