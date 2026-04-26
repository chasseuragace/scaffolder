import 'dart:io';
import 'package:yaml/yaml.dart';

/// Loads a preset YAML file and returns its `features:` map.
///
/// Presets only override flags; unknown flags trigger an error here so users
/// see typos early.
Map<String, bool> loadPreset(String path, Set<String> knownFlags) {
  final file = File(path);
  if (!file.existsSync()) {
    throw _PresetError('preset not found: $path');
  }
  final doc = loadYaml(file.readAsStringSync());
  if (doc is! YamlMap) throw _PresetError('preset root must be a map: $path');
  final features = doc['features'];
  if (features is! YamlMap) {
    throw _PresetError('preset `features` must be a map: $path');
  }

  final out = <String, bool>{};
  features.forEach((k, v) {
    if (k is! String) {
      throw _PresetError('preset flag name must be a string: $path');
    }
    if (v is! bool) {
      throw _PresetError('preset flag "$k" must be bool: $path');
    }
    if (!knownFlags.contains(k)) {
      throw _PresetError(
        'preset "$path" sets unknown flag "$k" '
        '(known: ${knownFlags.join(", ")})',
      );
    }
    out[k] = v;
  });
  return out;
}

class _PresetError implements Exception {
  _PresetError(this.message);
  final String message;
  @override
  String toString() => 'PresetError: $message';
}
