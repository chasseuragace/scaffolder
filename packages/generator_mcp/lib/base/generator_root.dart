import 'dart:io';

/// Locates the generator's install root — the directory that contains
/// `templates/schema.yaml` and `bin/generate.dart`.
///
/// This is intentionally separate from the *working* project root that an
/// MCP caller specifies via `output_dir`. The generator root is where the
/// templates and the CLI script live; it should be auto-discoverable from
/// the MCP server's own location so the user never has to wire it up by
/// hand.
///
/// Resolution order:
///   1. The `GENERATOR_ROOT` env var, if set.
///   2. Walk up from `Platform.script`. At each ancestor, check both:
///      - `<dir>/templates/schema.yaml` (self-hosted layout)
///      - `<dir>/packages/generator/templates/schema.yaml` (workspace layout)
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

  bool isGeneratorRoot(String path) =>
      File('$path/templates/schema.yaml').existsSync() &&
      File('$path/bin/generate.dart').existsSync();

  for (var i = 0; i < 8; i++) {
    // Self-hosted layout: this directory IS the generator root.
    if (isGeneratorRoot(dir.path)) return dir.path;
    // Workspace layout: a sibling `packages/generator/` is the generator root.
    final workspaceCandidate = '${dir.path}/packages/generator';
    if (isGeneratorRoot(workspaceCandidate)) return workspaceCandidate;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  throw StateError(
    'could not auto-detect generator root from ${Platform.script}. '
    'Set the GENERATOR_ROOT env var to the directory that contains '
    'templates/ and bin/.',
  );
}
