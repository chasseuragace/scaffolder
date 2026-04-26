@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// End-to-end test for the MCP server.
///
/// Spawns `dart run bin/main.dart` as a subprocess, pipes JSON-RPC over
/// stdin, asserts that the response shapes match the protocol contract.
///
/// Locks the contract that AI IDEs depend on:
///   - `initialize` returns serverInfo + protocolVersion
///   - `tools/list` returns the expected six tools
///   - `get_schema` / `get_presets` / `get_manifest` return structured JSON
///   - `generate_feature` with `dry_run: true` works without writing files
///   - tool failures surface as MCP protocol errors, not "success: false"
void main() {
  late _McpClient client;

  setUpAll(() async {
    client = await _McpClient.start();
  });

  tearDownAll(() async {
    await client.close();
  });

  test('initialize returns serverInfo + protocolVersion', () async {
    final r = await client.send('initialize', {});
    expect(r['result'], isA<Map>());
    expect(r['result']['protocolVersion'], '2024-11-05');
    expect(r['result']['serverInfo']['name'], 'flutter-generator-mcp');
    expect(r['result']['serverInfo']['version'], isA<String>());
  });

  test('tools/list returns the expected tool surface', () async {
    final r = await client.send('tools/list', {});
    final tools = (r['result']['tools'] as List).cast<Map>();
    final names = tools.map((t) => t['name']).toSet();
    expect(
      names,
      containsAll([
        'get_schema',
        'get_presets',
        'get_manifest',
        'list_features',
        'validate',
        'generate_feature',
      ]),
    );

    // Every tool must declare a description and an inputSchema.
    for (final t in tools) {
      expect(t['description'], isA<String>(),
          reason: '${t['name']} missing description');
      expect((t['description'] as String).length, greaterThan(40),
          reason: '${t['name']} description is too short for agent disambiguation');
      expect(t['inputSchema'], isA<Map>());
    }
  });

  test('get_schema returns structured JSON, not raw YAML', () async {
    final r = await client.send('tools/call', {
      'name': 'get_schema',
      'arguments': {},
    });
    final inner = _decodeContent(r);
    expect(inner['flags'], isA<List>());
    final flags = (inner['flags'] as List).cast<Map>();
    expect(flags, isNotEmpty);
    for (final f in flags) {
      expect(f['name'], isA<String>());
      expect(f['default'], isA<bool>());
      expect(f['description'], isA<String>());
    }
    final flagNames = flags.map((f) => f['name']).toSet();
    expect(flagNames, contains('pagination'));
    expect(flagNames, contains('search'));
  });

  test('get_presets returns each preset with a features map', () async {
    final r = await client.send('tools/call', {
      'name': 'get_presets',
      'arguments': {},
    });
    final inner = _decodeContent(r);
    final presets = (inner['presets'] as Map).cast<String, dynamic>();
    expect(presets.keys.toSet(),
        containsAll(['simple', 'standard', 'enterprise']));
    for (final entry in presets.entries) {
      final features = (entry.value as Map)['features'] as Map;
      expect(features, isNotEmpty,
          reason: 'preset ${entry.key} should declare features');
    }
  });

  test('get_manifest returns core + feature entry lists', () async {
    final r = await client.send('tools/call', {
      'name': 'get_manifest',
      'arguments': {},
    });
    final inner = _decodeContent(r);
    expect(inner['core'], isA<List>());
    expect(inner['feature'], isA<List>());
    final core = (inner['core'] as List).cast<Map>();
    expect(core, isNotEmpty);
    expect(core.first['template'], isA<String>());
    expect(core.first['output'], isA<String>());
  });

  test('generate_feature dry_run round-trips without writing files',
      () async {
    final scratch = Directory.systemTemp.createTempSync('mcp_int_');
    File('${scratch.path}/pubspec.yaml').writeAsStringSync('name: probe\n');
    try {
      final r = await client.send('tools/call', {
        'name': 'generate_feature',
        'arguments': {
          'module_name': 'Sample',
          'preset': 'standard',
          'dry_run': true,
          'output_dir': scratch.path,
          'package_name': 'probe',
        },
      });
      final inner = _decodeContent(r);
      expect(inner['module'], 'Sample');
      expect(inner['dry_run'], isTrue);
      expect(inner['working_root'], scratch.path);
      expect(inner['generator_root'], isNotNull);
      expect(inner['created'], isA<List>());
      expect((inner['created'] as List), isNotEmpty);
      // Critical: dry_run must not actually write.
      expect(Directory('${scratch.path}/lib/features').existsSync(), isFalse);
    } finally {
      scratch.deleteSync(recursive: true);
    }
  });

  test('generate_feature failures surface as protocol-level errors',
      () async {
    final r = await client.send('tools/call', {
      'name': 'generate_feature',
      'arguments': {
        'module_name': 'X',
        'output_dir': '/path/that/does/not/exist',
      },
    });
    expect(r.containsKey('error'), isTrue,
        reason: 'invalid output_dir should yield a JSON-RPC error, not a success body');
    expect(r['error']['message'], contains('output_dir'));
  });

  test('unknown tool name surfaces as JSON-RPC error', () async {
    final r = await client.send('tools/call', {
      'name': 'no_such_tool',
      'arguments': {},
    });
    expect(r['error'], isNotNull);
    expect(r['error']['code'], -32602);
  });
}

Map<String, dynamic> _decodeContent(Map<String, dynamic> response) {
  final content = (response['result']['content'] as List).first;
  return jsonDecode(content['text'] as String) as Map<String, dynamic>;
}

/// Drives the MCP server over stdin/stdout for integration testing.
class _McpClient {
  _McpClient._(this._proc) {
    _stdoutSub = _proc.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.trim().isEmpty) return;
      final msg = jsonDecode(line) as Map<String, dynamic>;
      final id = msg['id'];
      final pending = _pending.remove(id);
      pending?.complete(msg);
    });
    _stderrSub = _proc.stderr
        .transform(utf8.decoder)
        .listen(_stderrBuffer.write);
  }

  final Process _proc;
  late final StreamSubscription<String> _stdoutSub;
  late final StreamSubscription<String> _stderrSub;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _stderrBuffer = StringBuffer();
  int _nextId = 1;

  static Future<_McpClient> start() async {
    // We're running from <workspace>/packages/generator_mcp.
    // The generator package is the sibling at ../generator.
    final mcpRoot = Directory.current.path;
    final generatorRoot = Directory('$mcpRoot/../generator').absolute.path;

    final proc = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
      workingDirectory: mcpRoot,
      environment: {
        // Pin the generator root so the server doesn't have to rely on
        // walk-up detection from a test runner's Platform.script.
        'GENERATOR_ROOT': generatorRoot,
        'PROJECT_ROOT': generatorRoot,
      },
    );
    final client = _McpClient._(proc);
    // Drain initial startup banner from stderr; give the server a beat.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return client;
  }

  Future<Map<String, dynamic>> send(
    String method,
    Map<String, dynamic> params,
  ) async {
    final id = _nextId++;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    final request = jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    });
    _proc.stdin.writeln(request);
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw StateError(
        'MCP server did not respond to "$method" within 30s.\n'
        'Stderr:\n${_stderrBuffer.toString()}',
      ),
    );
  }

  Future<void> close() async {
    await _proc.stdin.close();
    await _stdoutSub.cancel();
    await _stderrSub.cancel();
    _proc.kill();
    await _proc.exitCode;
  }
}
