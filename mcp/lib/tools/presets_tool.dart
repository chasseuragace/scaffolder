import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../base/tool.dart';

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
        final doc = loadYaml(entity.readAsStringSync());
        final featuresNode = (doc is YamlMap) ? doc['features'] : null;
        final features = (featuresNode is YamlMap)
            ? <String, dynamic>{
                for (final e in featuresNode.entries)
                  e.key.toString(): e.value,
              }
            : <String, dynamic>{};
        presets[name] = {'features': features};
      }
    }

    return jsonEncode({'presets': presets});
  }
}
