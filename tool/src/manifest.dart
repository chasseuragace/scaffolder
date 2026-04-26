import 'dart:io';
import 'package:yaml/yaml.dart';

/// One entry in the manifest — either a one-shot core file or a per-feature file.
class ManifestEntry {
  ManifestEntry({
    required this.template,
    required this.output,
    required this.once,
    required this.preserve,
    required this.when,
  });
  final String template;
  final String output;
  final bool once;

  /// When true, an existing target file is never overwritten — even with
  /// `--overwrite`. Use for files the generator mutates idempotently
  /// elsewhere (e.g. `feature_registry.dart`).
  final bool preserve;

  /// Optional flag name; if non-null, the entry is skipped unless the flag
  /// resolves to true.
  final String? when;
}

class Manifest {
  Manifest({required this.core, required this.feature});
  final List<ManifestEntry> core;
  final List<ManifestEntry> feature;

  static Manifest load(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw _ManifestError('manifest not found: $path');
    }
    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) {
      throw _ManifestError('manifest root must be a map');
    }
    return Manifest(
      core: _parseList(doc['core'], 'core'),
      feature: _parseList(doc['feature'], 'feature'),
    );
  }

  static List<ManifestEntry> _parseList(dynamic node, String section) {
    if (node == null) return const [];
    if (node is! YamlList) {
      throw _ManifestError('manifest.$section must be a list');
    }
    final out = <ManifestEntry>[];
    for (final item in node) {
      if (item is! YamlMap) {
        throw _ManifestError('$section entries must be maps');
      }
      final tmpl = item['template'];
      final outp = item['output'];
      if (tmpl is! String || outp is! String) {
        throw _ManifestError('$section entry missing template/output');
      }
      final once = item['once'];
      final preserve = item['preserve'];
      final when = item['when'];
      out.add(ManifestEntry(
        template: tmpl,
        output: outp,
        once: once is bool ? once : false,
        preserve: preserve is bool ? preserve : false,
        when: when is String ? when : null,
      ));
    }
    return out;
  }
}

class _ManifestError implements Exception {
  _ManifestError(this.message);
  final String message;
  @override
  String toString() => 'ManifestError: $message';
}
