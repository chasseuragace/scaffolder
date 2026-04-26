import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'base/path_safety.dart';
import 'base/tool.dart';
import 'tools/generator_tool.dart';
import 'tools/list_features_tool.dart';
import 'tools/manifest_tool.dart';
import 'tools/presets_tool.dart';
import 'tools/schema_tool.dart';
import 'tools/validate_tool.dart';

/// MCP server for the Flutter feature generator. Speaks JSON-RPC 2.0 over
/// stdin/stdout per the MCP protocol.
///
/// Two roots are tracked separately:
///   - [generatorRoot] — auto-detected; where templates + CLI live.
///   - [defaultWorkingRoot] — the *working* project where output goes
///                            when `output_dir` isn't supplied per call.
class FlutterGeneratorMCPServer {
  FlutterGeneratorMCPServer({
    required this.name,
    required this.version,
    required this.generatorRoot,
    required this.defaultWorkingRoot,
    required this.packageName,
  }) {
    final pathSafety = PathSafety();
    // Read-only schema/preset/manifest tools always read from the
    // generator root — the working project doesn't own these files.
    _tools['get_schema'] = SchemaTool(projectRoot: generatorRoot);
    _tools['get_presets'] = PresetsTool(projectRoot: generatorRoot);
    _tools['get_manifest'] = ManifestTool(projectRoot: generatorRoot);
    // Read-write tools operate on the working project.
    _tools['list_features'] = ListFeaturesTool(
      defaultProjectRoot: defaultWorkingRoot,
      pathSafety: pathSafety,
    );
    _tools['validate'] = ValidateTool(
      defaultProjectRoot: defaultWorkingRoot,
      pathSafety: pathSafety,
    );
    _tools['generate_feature'] = GeneratorTool(
      generatorRoot: generatorRoot,
      defaultWorkingRoot: defaultWorkingRoot,
      defaultPackageName: packageName,
      pathSafety: pathSafety,
    );
  }

  final String name;
  final String version;

  /// Where the generator's templates + CLI live. Auto-detected.
  final String generatorRoot;

  /// Where files get written when the caller doesn't override.
  final String defaultWorkingRoot;

  final String packageName;
  final Map<String, MCPTool> _tools = {};

  Future<void> start() async {
    stderr.writeln('flutter-generator-mcp v$version');
    stderr.writeln('  generator_root:      $generatorRoot   (auto-detected)');
    stderr.writeln('  default_working_root: $defaultWorkingRoot');
    stderr.writeln('  default_package:     $packageName');
    stderr.writeln('  tools:               ${_tools.keys.join(", ")}');
    final allowedRoots = PathSafety().allowedRoots;
    if (allowedRoots.isNotEmpty) {
      stderr.writeln('  allowed_roots:       ${allowedRoots.length}');
      for (final r in allowedRoots) {
        stderr.writeln('    - $r');
      }
    } else {
      stderr.writeln('  allowed_roots:       (unset — output_dir is '
          'unconstrained beyond pubspec.yaml sanity check)');
    }

    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_handleInputLine);
  }

  void _handleInputLine(String line) {
    if (line.trim().isEmpty) return;
    try {
      final message = jsonDecode(line) as Map<String, dynamic>;
      _handleMessage(message);
    } catch (e) {
      _sendError(-32700, 'Parse error: $e', null);
    }
  }

  Future<void> _handleMessage(Map<String, dynamic> message) async {
    final method = message['method'] as String?;
    final id = message['id'];
    final params = (message['params'] as Map<String, dynamic>?) ?? {};

    switch (method) {
      case 'initialize':
        _handleInitialize(id);
      case 'tools/list':
        _handleToolsList(id);
      case 'tools/call':
        await _handleToolCall(id, params);
      case 'resources/list':
        _sendResponse({'jsonrpc': '2.0', 'id': id, 'result': {'resources': []}});
      case 'notifications/initialized':
        // Nothing to do.
        break;
      default:
        _sendError(-32601, 'Method not found: $method', id);
    }
  }

  void _handleInitialize(dynamic id) {
    _sendResponse({
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'protocolVersion': '2024-11-05',
        'capabilities': {'tools': {}},
        'serverInfo': {'name': name, 'version': version},
      },
    });
  }

  void _handleToolsList(dynamic id) {
    final tools = _tools.values
        .map((t) => {
              'name': t.name,
              'description': t.description,
              'inputSchema': t.inputSchema,
            })
        .toList();
    _sendResponse({'jsonrpc': '2.0', 'id': id, 'result': {'tools': tools}});
  }

  Future<void> _handleToolCall(dynamic id, Map<String, dynamic> params) async {
    final toolName = params['name'] as String?;
    final arguments =
        (params['arguments'] as Map<String, dynamic>?) ?? const {};

    final tool = toolName == null ? null : _tools[toolName];
    if (tool == null) {
      _sendError(-32602, 'Tool not found: $toolName', id);
      return;
    }

    try {
      final result = await tool.execute(arguments);
      _sendResponse({
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'content': [
            {'type': 'text', 'text': result},
          ],
        },
      });
    } on ToolFailure catch (f) {
      _sendError(f.code, f.message, id, data: f.data);
    } catch (e, st) {
      _sendError(
        -32603,
        'Tool execution error: $e',
        id,
        data: {'stack': st.toString()},
      );
    }
  }

  void _sendResponse(Map<String, dynamic> response) {
    stdout.writeln(jsonEncode(response));
  }

  void _sendError(int code, String message, dynamic id,
      {Map<String, dynamic>? data}) {
    final err = <String, dynamic>{'code': code, 'message': message};
    if (data != null) err['data'] = data;
    stdout.writeln(jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'error': err,
    }));
  }
}
