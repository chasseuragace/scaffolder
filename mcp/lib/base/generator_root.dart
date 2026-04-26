import 'dart:io';

/// Locates the generator's install root — the directory that contains
/// `templates/schema.yaml` and `tool/bin/generate.dart`.
///
/// This is intentionally separate from the *working* project root that an
/// MCP caller specifies via `output_dir`. The generator root is where the
/// templates and the CLI script live; it should be auto-discoverable from
/// the MCP server's own location so the user never has to wire it up by
/// hand.
///
/// Resolution order:
///   1. The `GENERATOR_ROOT` env var, if set.
///   2. Walk up from `Platform.script` looking for `templates/schema.yaml`.
///
/// Throws if neither yields a usable directory — better to fail loud at
/// startup than to silently scaffold from the wrong templates.
String findGeneratorRoot() {
  final fromEnv = Platform.environment['GENERATOR_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    if (File('$fromEnv/templates/schema.yaml').existsSync()) return fromEnv;
    throw StateError(
      'GENERATOR_ROOT is set but does not contain templates/schema.yaml: '
      '$fromEnv',
    );
  }

  Directory dir;
  try {
    dir = File.fromUri(Platform.script).parent;
  } catch (e) {
    throw StateError(
      'cannot resolve Platform.script to find generator root: $e',
    );
  }

  for (var i = 0; i < 8; i++) {
    if (File('${dir.path}/templates/schema.yaml').existsSync() &&
        File('${dir.path}/tool/bin/generate.dart').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  throw StateError(
    'could not auto-detect generator root from ${Platform.script}. '
    'Set the GENERATOR_ROOT env var to the directory that contains '
    'templates/ and tool/.',
  );
}
