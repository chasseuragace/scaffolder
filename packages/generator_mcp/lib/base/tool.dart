/// Base interface for MCP tools exposed by this server.
///
/// Tools return a JSON-encoded string (the MCP protocol wraps it in a
/// `text` content block). When a tool needs to signal *failure*, it should
/// throw [ToolFailure] — the server translates that into a protocol-level
/// MCP error so the IDE can react accordingly. Returning a JSON object with
/// `{"success": false}` inside a successful response confuses clients and
/// is avoided here.
abstract class MCPTool {
  String get name;
  String get description;
  Map<String, dynamic> get inputSchema;
  Future<String> execute(Map<String, dynamic> arguments);
}

/// Throw to surface a tool-level failure as an MCP protocol error.
class ToolFailure implements Exception {
  ToolFailure(this.message, {this.code = -32000, this.data});
  final String message;
  final int code;
  final Map<String, dynamic>? data;

  @override
  String toString() => 'ToolFailure($code): $message';
}
