import 'dart:io';
import 'package:yaml/yaml.dart';

/// A single feature flag definition from `templates/schema.yaml`.
class FlagDef {
  FlagDef({required this.name, required this.defaultValue, required this.description});
  final String name;
  final bool defaultValue;
  final String description;
}

/// A logical conflict rule: when [when] holds, [then] must also hold.
class ConflictRule {
  ConflictRule({required this.message, required this.when, required this.then});
  final String message;
  final Map<String, bool> when;
  final Map<String, bool> then;

  /// Returns null if the rule is satisfied, or the violation message otherwise.
  String? check(Map<String, bool> flags) {
    final triggers = when.entries.every((e) => flags[e.key] == e.value);
    if (!triggers) return null;
    final ok = then.entries.every((e) => flags[e.key] == e.value);
    return ok ? null : message;
  }
}

class Schema {
  Schema({required this.flags, required this.conflicts, this.registryPath, this.importFormat});
  final List<FlagDef> flags;
  final List<ConflictRule> conflicts;
  final String? registryPath;
  final String? importFormat; // 'dart' or 'typescript'

  Set<String> get flagNames => flags.map((f) => f.name).toSet();

  Map<String, bool> get defaults =>
      {for (final f in flags) f.name: f.defaultValue};

  /// Loads and validates a schema YAML file.
  static Schema load(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw _SchemaError('schema file not found: $path');
    }
    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) throw _SchemaError('schema root must be a map');
    final flagsNode = doc['flags'];
    if (flagsNode is! YamlMap) throw _SchemaError('schema.flags must be a map');

    final flags = <FlagDef>[];
    flagsNode.forEach((key, value) {
      if (key is! String) throw _SchemaError('flag name must be a string');
      if (value is! YamlMap) {
        throw _SchemaError('flag "$key" must be a map');
      }
      final def = value['default'];
      if (def is! bool) {
        throw _SchemaError('flag "$key" missing boolean `default`');
      }
      final desc = value['description'];
      if (desc is! String) {
        throw _SchemaError('flag "$key" missing string `description`');
      }
      flags.add(FlagDef(name: key, defaultValue: def, description: desc));
    });

    final conflicts = <ConflictRule>[];
    final conflictsNode = doc['conflicts'];
    if (conflictsNode is YamlList) {
      for (final entry in conflictsNode) {
        if (entry is! YamlMap) {
          throw _SchemaError('conflict entries must be maps');
        }
        final msg = entry['message'];
        final whenNode = entry['when'];
        final thenNode = entry['then'];
        if (msg is! String || whenNode is! YamlMap || thenNode is! YamlMap) {
          throw _SchemaError('conflict requires message, when, then');
        }
        conflicts.add(ConflictRule(
          message: msg,
          when: _flagMap(whenNode),
          then: _flagMap(thenNode),
        ));
      }
    }

    final registryPath = doc['registry_path'] as String?;
    final importFormat = doc['import_format'] as String?;

    return Schema(flags: flags, conflicts: conflicts, registryPath: registryPath, importFormat: importFormat);
  }

  static Map<String, bool> _flagMap(YamlMap node) {
    final out = <String, bool>{};
    node.forEach((k, v) {
      if (k is! String || v is! bool) {
        throw _SchemaError('flag map values must be string -> bool');
      }
      out[k] = v;
    });
    return out;
  }
}

class _SchemaError implements Exception {
  _SchemaError(this.message);
  final String message;
  @override
  String toString() => 'SchemaError: $message';
}
