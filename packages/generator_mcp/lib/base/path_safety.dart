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
///      be a descendant of *one of* the configured roots. Multiple roots
///      can be supplied as a comma-separated list, e.g.
///      `ALLOWED_ROOT=/Users/me/code,/Volumes/shared_code`. This matches
///      the convention used by other MCP servers (e.g. `MCP_READ_PATHS`)
///      and supports the common case of a developer who keeps code on
///      both the home volume and an external mount.
class PathSafety {
  PathSafety({String? allowedRoots})
      : _allowedRoots = _parseRoots(
          allowedRoots ?? Platform.environment['ALLOWED_ROOT'],
        );

  /// Empty list means "no confinement" — `output_dir` is unrestricted
  /// beyond the pubspec.yaml sanity check.
  final List<String> _allowedRoots;

  /// Read-only view of the configured roots, after canonicalisation.
  /// Useful for the server startup banner.
  List<String> get allowedRoots => List.unmodifiable(_allowedRoots);

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

    if (_allowedRoots.isNotEmpty) {
      final allowed = _allowedRoots.any((root) => _isWithin(resolved, root));
      if (!allowed) {
        throw ToolFailure(
          'output_dir is outside the configured ALLOWED_ROOT(s). '
          'allowed=${_allowedRoots.join(", ")}, requested=$resolved',
        );
      }
    }

    return resolved;
  }

  static List<String> _parseRoots(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => Directory(s).absolute.path)
        .toList(growable: false);
  }

  static bool _isWithin(String path, String root) {
    final p = _ensureTrailingSep(path);
    final r = _ensureTrailingSep(root);
    return p == r || p.startsWith(r);
  }

  static String _ensureTrailingSep(String s) =>
      s.endsWith(Platform.pathSeparator) ? s : '$s${Platform.pathSeparator}';
}
