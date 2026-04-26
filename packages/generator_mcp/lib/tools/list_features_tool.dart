import 'dart:convert';
import 'dart:io';

import '../base/path_safety.dart';
import '../base/tool.dart';

/// Lists the features already scaffolded in a project.
///
/// Agents can use this to avoid suggesting duplicates, or to answer "what's
/// installed here?" without scanning the filesystem manually.
class ListFeaturesTool implements MCPTool {
  ListFeaturesTool({
    required this.defaultProjectRoot,
    PathSafety? pathSafety,
  }) : _pathSafety = pathSafety ?? PathSafety();

  final String defaultProjectRoot;
  final PathSafety _pathSafety;

  @override
  String get name => 'list_features';

  @override
  String get description =>
      'List the features already scaffolded in a project (read-only). '
      'Returns each feature\'s snake-case id, the path to its module file, '
      'and whether it appears in the registry. Useful for an agent to '
      'avoid duplicates or audit a codebase.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'output_dir': {
            'type': 'string',
            'description':
                'Project root to inspect. Defaults to PROJECT_ROOT env var.',
          },
        },
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final raw = arguments['output_dir'] as String?;
    final projectRoot =
        (raw == null || raw.isEmpty) ? defaultProjectRoot : _pathSafety.validate(raw);

    final featuresDir = Directory('$projectRoot/lib/features');
    final features = <Map<String, dynamic>>[];
    if (featuresDir.existsSync()) {
      for (final entity in featuresDir.listSync()) {
        if (entity is! Directory) continue;
        final id = entity.uri.pathSegments
            .where((s) => s.isNotEmpty)
            .last;
        final modulePath = '${entity.path}/${id}_module.dart';
        features.add({
          'id': id,
          'module_path':
              modulePath.replaceFirst('$projectRoot/', ''),
          'module_exists': File(modulePath).existsSync(),
        });
      }
      features.sort((a, b) =>
          (a['id'] as String).compareTo(b['id'] as String));
    }

    final registryFile =
        File('$projectRoot/lib/core/routing/feature_registry.dart');
    final registered = <String>{};
    if (registryFile.existsSync()) {
      final text = registryFile.readAsStringSync();
      final re = RegExp(r'(\w+)Module\.descriptor');
      for (final m in re.allMatches(text)) {
        registered.add(m.group(1)!);
      }
    }

    for (final f in features) {
      // The registry uses PascalCase module names; we have snake-case ids.
      // The simple test: replace underscores and title-case each part.
      final id = f['id'] as String;
      final pascal = id
          .split('_')
          .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
          .join();
      f['registered'] = registered.contains(pascal);
    }

    return jsonEncode({
      'project_root': projectRoot,
      'features': features,
      'count': features.length,
    });
  }
}
