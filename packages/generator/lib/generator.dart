import 'dart:io';

import 'case_helpers.dart';
import 'manifest.dart';
import 'preset.dart';
import 'registry_writer.dart';
import 'renderer.dart';
import 'schema.dart';

/// Result of a generation run.
class GenerateResult {
  GenerateResult({
    required this.created,
    required this.skipped,
    required this.overwritten,
  });
  final List<String> created;
  final List<String> skipped;
  final List<String> overwritten;

  bool get isEmpty => created.isEmpty && skipped.isEmpty && overwritten.isEmpty;
}

class Generator {
  Generator({
    required this.projectRoot,
    required this.templatesDir,
    required this.packageName,
  });

  final String projectRoot;
  final String templatesDir;
  final String packageName;

  /// Runs the generator for [moduleInput] using [presetName] (file in
  /// `templates/presets/<presetName>.yaml`), with optional [overrides] from
  /// CLI flags.
  ///
  /// If [moduleInput] is null, only `core` (one-shot) entries are generated —
  /// useful for bootstrapping a project without registering a feature.
  ///
  /// When [dryRun] is true, the result reports what would happen without
  /// writing any files or mutating the feature registry. Useful for previews
  /// from AI-driven tools.
  GenerateResult run({
    String? moduleInput,
    String presetName = 'standard',
    Map<String, bool> overrides = const {},
    bool overwrite = false,
    bool dryRun = false,
  }) {
    final schema = Schema.load(_path('schema.yaml'));
    final manifest = Manifest.load(_path('manifest.yaml'));

    // Resolve flags: defaults < preset < overrides.
    final flags = <String, bool>{...schema.defaults};
    final presetFlags = loadPreset(
      _path('presets/$presetName.yaml'),
      schema.flagNames,
    );
    flags.addAll(presetFlags);

    for (final entry in overrides.entries) {
      if (!schema.flagNames.contains(entry.key)) {
        throw ArgumentError(
          'unknown feature flag: ${entry.key} '
          '(known: ${schema.flagNames.join(", ")})',
        );
      }
      flags[entry.key] = entry.value;
    }

    // Validate conflicts.
    final violations = <String>[];
    for (final rule in schema.conflicts) {
      final v = rule.check(flags);
      if (v != null) violations.add(v);
    }
    if (violations.isNotEmpty) {
      throw StateError(
        'feature flag conflicts:\n  - ${violations.join("\n  - ")}',
      );
    }

    final result = GenerateResult(created: [], skipped: [], overwritten: []);

    // Substitutions only apply once we know the module name. Core-only runs
    // skip the per-feature entries entirely.
    final subs = moduleInput != null
        ? substitutionsFor(moduleInput)
        : <String, String>{};

    // Always generate core (one-shot) entries first; idempotent unless --overwrite.
    for (final entry in manifest.core) {
      _processEntry(
        entry: entry,
        subs: subs,
        flags: flags,
        overwrite: overwrite,
        forceOnceSemantics: true,
        dryRun: dryRun,
        result: result,
      );
    }

    if (moduleInput != null) {
      for (final entry in manifest.feature) {
        _processEntry(
          entry: entry,
          subs: subs,
          flags: flags,
          overwrite: overwrite,
          forceOnceSemantics: false,
          dryRun: dryRun,
          result: result,
        );
      }

      // Register the generated module in the feature registry.
      if (!dryRun) {
        RegistryWriter('$projectRoot/lib/core/routing/feature_registry.dart')
            .register(
          packageName: packageName,
          moduleSnake: subs['module_snake']!,
          modulePascal: subs['Module']!,
        );
      }
    }

    return result;
  }

  void _processEntry({
    required ManifestEntry entry,
    required Map<String, String> subs,
    required Map<String, bool> flags,
    required bool overwrite,
    required bool forceOnceSemantics,
    required bool dryRun,
    required GenerateResult result,
  }) {
    if (entry.when != null && flags[entry.when] != true) return;

    final templateFile = File('$templatesDir/${entry.template}');
    if (!templateFile.existsSync()) {
      throw StateError('template not found: ${templateFile.path}');
    }
    final raw = templateFile.readAsStringSync();
    final rendered = render(raw, substitutions: subs, features: flags);

    final outputPath = _interpolate(entry.output, subs);
    final outFile = File('$projectRoot/$outputPath');
    if (!dryRun) outFile.parent.createSync(recursive: true);

    if (outFile.existsSync()) {
      if (entry.preserve || !overwrite) {
        result.skipped.add(outputPath);
        return;
      }
      if (!dryRun) outFile.writeAsStringSync(rendered);
      result.overwritten.add(outputPath);
      return;
    }
    if (!dryRun) outFile.writeAsStringSync(rendered);
    result.created.add(outputPath);
  }

  String _path(String relative) => '$templatesDir/$relative';

  /// Cheap interpolation for output paths — only the small substitution set.
  String _interpolate(String input, Map<String, String> subs) {
    var s = input;
    subs.forEach((k, v) => s = s.replaceAll('{{$k}}', v));
    return s;
  }
}
