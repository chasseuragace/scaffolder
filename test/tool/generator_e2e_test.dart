import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/generator.dart';

/// End-to-end: copy the project's templates into a scratch dir, generate
/// core + a feature into it, and assert the expected file shape exists.
void main() {
  late Directory scratch;

  setUp(() {
    scratch = Directory.systemTemp.createTempSync('gen_e2e_');
    // Pre-create a feature_registry.dart with the expected markers — the
    // generator's `core` pass will skip-over it (one-shot) but the writer
    // needs a target.
    Directory('${scratch.path}/lib/core/routing').createSync(recursive: true);
    File('${scratch.path}/lib/core/routing/feature_registry.dart')
        .writeAsStringSync(_registrySeed);
  });

  tearDown(() => scratch.deleteSync(recursive: true));

  test('generates a feature into lib/features/<name>/ and registers it', () {
    final gen = Generator(
      projectRoot: scratch.path,
      templatesDir: '${Directory.current.path}/templates',
      packageName: 'flutter_project',
    );
    final result = gen.run(moduleInput: 'CustomerProfile');

    expect(result.created, isNotEmpty);

    bool exists(String relative) =>
        File('${scratch.path}/$relative').existsSync();

    expect(exists('lib/features/customer_profile/domain/entities/customer_profile_entity.dart'), isTrue);
    expect(exists('lib/features/customer_profile/data/models/customer_profile_model.dart'), isTrue);
    expect(exists('lib/features/customer_profile/presentation/providers/customer_profile_providers.dart'), isTrue);
    expect(exists('lib/features/customer_profile/customer_profile_module.dart'), isTrue);

    final reg =
        File('${scratch.path}/lib/core/routing/feature_registry.dart')
            .readAsStringSync();
    expect(reg, contains('CustomerProfileModule.descriptor'));
    expect(
      reg,
      contains(
        "import 'package:flutter_project/features/customer_profile/customer_profile_module.dart'",
      ),
    );
  });

  test('--core-only generates only one-shot files', () {
    final gen = Generator(
      projectRoot: scratch.path,
      templatesDir: '${Directory.current.path}/templates',
      packageName: 'flutter_project',
    );
    final result = gen.run();
    final ranAnyFeature = result.created.any((p) => p.contains('features/'));
    expect(ranAnyFeature, isFalse);
    expect(result.created.where((p) => p.startsWith('lib/core/')), isNotEmpty);
  });

  test('preserve: feature_registry survives --overwrite', () {
    final gen = Generator(
      projectRoot: scratch.path,
      templatesDir: '${Directory.current.path}/templates',
      packageName: 'flutter_project',
    );
    gen.run(moduleInput: 'Alpha');
    gen.run(moduleInput: 'Beta');

    // Snapshot the registry — both features should be present.
    final regAfterTwo =
        File('${scratch.path}/lib/core/routing/feature_registry.dart')
            .readAsStringSync();
    expect(regAfterTwo, contains('AlphaModule.descriptor'));
    expect(regAfterTwo, contains('BetaModule.descriptor'));

    // Now overwrite Alpha — registry must NOT lose Beta.
    gen.run(moduleInput: 'Alpha', overwrite: true);
    final regAfterRegen =
        File('${scratch.path}/lib/core/routing/feature_registry.dart')
            .readAsStringSync();
    expect(regAfterRegen, contains('AlphaModule.descriptor'));
    expect(regAfterRegen, contains('BetaModule.descriptor'));
  });

  test('preset overrides drop gated files', () {
    final gen = Generator(
      projectRoot: scratch.path,
      templatesDir: '${Directory.current.path}/templates',
      packageName: 'flutter_project',
    );
    final result = gen.run(
      moduleInput: 'Item',
      presetName: 'simple',
    );
    // simple preset disables search and shimmer_loading and unit_tests.
    final hasSearch = result.created.any((p) => p.contains('search_delegate'));
    final hasTest = result.created.any((p) => p.startsWith('test/'));
    expect(hasSearch, isFalse);
    expect(hasTest, isFalse);
  });
}

const _registrySeed = '''
import 'package:flutter/material.dart';

// GENERATED:imports BEGIN
// GENERATED:imports END

class FeatureDescriptor {
  const FeatureDescriptor({
    required this.id,
    required this.title,
    required this.routeName,
    required this.icon,
    required this.builder,
  });
  final String id;
  final String title;
  final String routeName;
  final IconData icon;
  final WidgetBuilder builder;
}

class FeatureRegistry {
  static const List<FeatureDescriptor> all = <FeatureDescriptor>[
    // GENERATED:entries BEGIN
    // GENERATED:entries END
  ];
}
''';
