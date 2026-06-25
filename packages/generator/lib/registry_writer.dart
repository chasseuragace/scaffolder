import 'dart:io';

/// Idempotently registers a generated feature in
/// `lib/core/routing/feature_registry.dart`.
///
/// The registry file uses BEGIN/END marker pairs so that re-running the
/// generator does not duplicate entries:
///
///   // GENERATED:imports BEGIN
///   import 'package:flutter_project/features/user/user_module.dart';
///   // GENERATED:imports END
///
///   // GENERATED:entries BEGIN
///   UserModule.descriptor,
///   // GENERATED:entries END
///
/// Hand-written code outside the markers is preserved.
class RegistryWriter {
  RegistryWriter(this.path);
  final String path;

  static const _importBegin = '// GENERATED:imports BEGIN';
  static const _importEnd = '// GENERATED:imports END';
  static const _registrationBegin = '// GENERATED:registrations BEGIN';
  static const _registrationEnd = '// GENERATED:registrations END';
  static const _providersBegin = '// GENERATED:providers BEGIN';
  static const _providersEnd = '// GENERATED:providers END';
  static const _entryBegin = '// GENERATED:entries BEGIN';
  static const _entryEnd = '// GENERATED:entries END';

  /// Inserts an import for the module file and an entry for the descriptor,
  /// only if they are not already present.
  void register({
    required String packageName,
    required String moduleSnake,
    required String modulePascal,
    String? importFormat,
  }) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('feature_registry not found at $path');
    }
    var contents = file.readAsStringSync();

    final isTypeScript = importFormat == 'typescript';
    // React/TS feature files are written to kebab-case paths (see the
    // {{module-kebab}} outputs in the manifest), while Dart files use
    // snake_case. Single-word names coincide; multi-word names (e.g.
    // loyaltyCard -> loyalty-card vs loyalty_card) diverge, so the TS import
    // path must use kebab to match the files on disk.
    final moduleKebab = moduleSnake.replaceAll('_', '-');
    final importLine = isTypeScript
        ? "import { ${modulePascal}Routes, ${modulePascal}Descriptor, ${modulePascal}ModuleProvider } from '../../features/$moduleKebab/$moduleKebab.module';"
        : "import 'package:$packageName/features/$moduleSnake/${moduleSnake}_module.dart';";
    final entryLine = isTypeScript
        ? '...${modulePascal}Routes,'
        : '${modulePascal}Module.descriptor,';
    // Write a plain array item (e.g. `ProductDescriptor,`) so the registry
    // stays a static const — no side-effectful .register() at module load time.
    final registrationLine = isTypeScript
        ? '${modulePascal}Descriptor,'
        : '';
    // Contribute the feature's repository provider to `FeatureProviders`
    // (TS only). The app shell composes these once; adding a feature never
    // requires editing the shell.
    final providersLine = isTypeScript
        ? '${modulePascal}ModuleProvider,'
        : '';

    contents = _insertWithinMarkers(
      contents,
      beginMarker: _importBegin,
      endMarker: _importEnd,
      newLine: importLine,
      indent: '',
    );

    if (isTypeScript) {
      contents = _insertWithinMarkers(
        contents,
        beginMarker: _registrationBegin,
        endMarker: _registrationEnd,
        newLine: registrationLine,
        indent: '  ',
      );
      contents = _insertWithinMarkers(
        contents,
        beginMarker: _providersBegin,
        endMarker: _providersEnd,
        newLine: providersLine,
        indent: '  ',
      );
    }

    contents = _insertWithinMarkers(
      contents,
      beginMarker: _entryBegin,
      endMarker: _entryEnd,
      newLine: entryLine,
      indent: '    ',
    );

    file.writeAsStringSync(contents);
  }

  String _insertWithinMarkers(
    String contents, {
    required String beginMarker,
    required String endMarker,
    required String newLine,
    required String indent,
  }) {
    final beginIdx = contents.indexOf(beginMarker);
    final endIdx = contents.indexOf(endMarker);
    if (beginIdx < 0 || endIdx < 0 || endIdx <= beginIdx) {
      throw StateError('feature_registry markers missing or out of order');
    }
    final blockStart = contents.indexOf('\n', beginIdx) + 1;
    // Preserve the original indentation on the END marker line.
    final endLineStart = contents.lastIndexOf('\n', endIdx - 1) + 1;
    final block = contents.substring(blockStart, endLineStart);
    final existingLines = block
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (existingLines.contains(newLine.trim())) {
      return contents;
    }
    existingLines.add(newLine.trim());
    existingLines.sort();
    final rebuilt = existingLines.map((l) => '$indent$l').join('\n');
    final prefix = contents.substring(0, blockStart);
    final suffix = contents.substring(endLineStart);
    return '$prefix$rebuilt\n$suffix';
  }
}
