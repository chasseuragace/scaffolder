import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../base/tool.dart';

/// Returns the canonical feature-flag schema as structured JSON.
///
/// AI agents use this to know which flags exist before composing a
/// `generate_feature` call. Returning structured JSON (rather than raw
/// YAML) means the agent doesn't need to parse YAML and can't hallucinate
/// flag names.
class SchemaTool implements MCPTool {
  SchemaTool({required this.projectRoot});
  final String projectRoot;

  @override
  String get name => 'get_schema';

  @override
  String get description =>
      'Return the canonical feature-flag schema (flag name, default, '
      'description, and conflict rules) as structured JSON. Call this '
      'before generate_feature to learn what flags exist.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final path = '$projectRoot/templates/schema.yaml';
    final file = File(path);
    if (!file.existsSync()) {
      throw ToolFailure('schema.yaml not found at $path');
    }

    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) {
      throw ToolFailure('schema.yaml is not a mapping at the root');
    }

    final flagsNode = doc['flags'];
    final flags = <Map<String, dynamic>>[];
    if (flagsNode is YamlMap) {
      flagsNode.forEach((name, def) {
        if (def is YamlMap) {
          flags.add({
            'name': name,
            'default': def['default'],
            'description': def['description'],
          });
        }
      });
    }

    final conflicts = <Map<String, dynamic>>[];
    final conflictsNode = doc['conflicts'];
    if (conflictsNode is YamlList) {
      for (final entry in conflictsNode) {
        if (entry is YamlMap) {
          conflicts.add(_yamlToJson(entry) as Map<String, dynamic>);
        }
      }
    }

    return jsonEncode({'flags': flags, 'conflicts': conflicts});
  }
}

/// Recursively converts YamlMap/YamlList to plain `Map<String, dynamic>` /
/// `List` so the result survives `jsonEncode`.
dynamic _yamlToJson(dynamic node) {
  if (node is YamlMap) {
    return {
      for (final entry in node.entries)
        entry.key.toString(): _yamlToJson(entry.value),
    };
  }
  if (node is YamlList) {
    return [for (final item in node) _yamlToJson(item)];
  }
  return node;
}
