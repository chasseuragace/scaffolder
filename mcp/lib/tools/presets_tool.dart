import 'dart:convert';
import 'dart:io';

import '../base/tool.dart';
import '../base/yaml_parser.dart';

/// Returns available presets and the flag values each one sets — as
/// structured JSON so an AI agent can pick the closest preset to a
/// requested feature shape without parsing YAML.
class PresetsTool implements MCPTool {
  PresetsTool({required this.projectRoot});
  final String projectRoot;

  @override
  String get name => 'get_presets';

  @override
  String get description =>
      'Return the available presets and the flag values each one sets, as '
      'structured JSON. Use this to pick the closest preset to a requested '
      'feature shape, then add per-flag overrides if needed.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final dir = Directory('$projectRoot/templates/presets');
    if (!dir.existsSync()) {
      throw ToolFailure('presets directory not found at ${dir.path}');
    }

    final presets = <String, dynamic>{};
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.yaml')) {
        final name = entity.uri.pathSegments.last.replaceAll('.yaml', '');
        final doc = parseYaml(entity.readAsStringSync());
        final features = (doc is Map && doc['features'] is Map)
            ? Map<String, dynamic>.from(doc['features'] as Map)
            : <String, dynamic>{};
        presets[name] = {'features': features};
      }
    }

    return jsonEncode({'presets': presets});
  }
}
