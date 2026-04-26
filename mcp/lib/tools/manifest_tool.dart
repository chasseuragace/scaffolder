import 'dart:convert';
import 'dart:io';

import '../base/tool.dart';
import '../base/yaml_parser.dart';

/// Returns the template manifest (which templates write to which paths,
/// and under which flag-gates) as structured JSON.
///
/// Agents can use this to predict the file shape of a generation, or to
/// answer questions like "does enabling 'search' add a search delegate?"
class ManifestTool implements MCPTool {
  ManifestTool({required this.projectRoot});
  final String projectRoot;

  @override
  String get name => 'get_manifest';

  @override
  String get description =>
      'Return the template manifest as structured JSON: a list of '
      '{template, output, when?, once?, preserve?} entries grouped into '
      '`core` (one-shot) and `feature` (per-module). Use this to predict '
      'what a generation will produce.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final path = '$projectRoot/templates/manifest.yaml';
    final file = File(path);
    if (!file.existsSync()) {
      throw ToolFailure('manifest.yaml not found at $path');
    }
    final doc = parseYaml(file.readAsStringSync());
    if (doc is! Map) {
      throw ToolFailure('manifest.yaml is not a mapping at the root');
    }

    List<Map<String, dynamic>> normalize(dynamic node) {
      if (node is! List) return const [];
      return node.whereType<Map>().map((m) {
        return {
          'template': m['template'],
          'output': m['output'],
          if (m.containsKey('when')) 'when': m['when'],
          if (m.containsKey('once')) 'once': m['once'],
          if (m.containsKey('preserve')) 'preserve': m['preserve'],
        };
      }).toList(growable: false);
    }

    return jsonEncode({
      'core': normalize(doc['core']),
      'feature': normalize(doc['feature']),
    });
  }
}
