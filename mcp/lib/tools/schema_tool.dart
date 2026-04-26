import 'dart:convert';
import 'dart:io';

import '../base/tool.dart';
import '../base/yaml_parser.dart';

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

    final doc = parseYaml(file.readAsStringSync());
    if (doc is! Map) {
      throw ToolFailure('schema.yaml is not a mapping at the root');
    }

    final flagsNode = doc['flags'];
    final flags = <Map<String, dynamic>>[];
    if (flagsNode is Map) {
      flagsNode.forEach((name, def) {
        if (def is Map) {
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
    if (conflictsNode is List) {
      for (final entry in conflictsNode) {
        if (entry is Map) {
          conflicts.add(Map<String, dynamic>.from(entry));
        }
      }
    }

    return jsonEncode({'flags': flags, 'conflicts': conflicts});
  }
}
