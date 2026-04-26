import 'dart:io';

import 'tool.dart';

/// Validates an output directory before any generator writes to it.
///
/// The wrapper is, in effect, a remote-write capability — an AI agent
/// supplying `output_dir` could otherwise scaffold files anywhere on the
/// host machine. These checks turn that into a bounded, auditable surface.
///
/// Rules enforced:
///   1. The path resolves to an existing directory.
///   2. The directory contains a `pubspec.yaml` (sanity: it's a Dart/Flutter
///      project, not `~/Downloads` or `/etc`).
///   3. If `ALLOWED_ROOT` is set in the environment, the resolved path must
///      be a descendant of it (or equal to it).
class PathSafety {
  PathSafety({String? allowedRoot})
      : _allowedRoot =
            allowedRoot ?? Platform.environment['ALLOWED_ROOT'];

  final String? _allowedRoot;

  /// Returns the canonicalised absolute path of [outputDir] if it passes
  /// every check; otherwise throws [ToolFailure] with a message the agent
  /// (or human reading the agent log) can act on.
  String validate(String outputDir) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      throw ToolFailure('output_dir does not exist: $outputDir');
    }
    final resolved = dir.absolute.path;

    final pubspec = File('$resolved/pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw ToolFailure(
        'output_dir has no pubspec.yaml — refusing to scaffold into a '
        'non-Dart/Flutter project: $resolved',
      );
    }

    final allowed = _allowedRoot;
    if (allowed != null && allowed.isNotEmpty) {
      final root = Directory(allowed).absolute.path;
      if (!_isWithin(resolved, root)) {
        throw ToolFailure(
          'output_dir is outside ALLOWED_ROOT. '
          'allowed=$root, requested=$resolved',
        );
      }
    }

    return resolved;
  }

  static bool _isWithin(String path, String root) {
    final p = _ensureTrailingSep(path);
    final r = _ensureTrailingSep(root);
    return p == r || p.startsWith(r);
  }

  static String _ensureTrailingSep(String s) =>
      s.endsWith(Platform.pathSeparator) ? s : '$s${Platform.pathSeparator}';
}
