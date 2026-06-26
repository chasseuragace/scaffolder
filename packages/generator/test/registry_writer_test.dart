import 'dart:io';

import 'package:test/test.dart';

import 'package:scaffolder/registry_writer.dart';

const _seed = '''
import 'package:flutter/material.dart';

// GENERATED:imports BEGIN
// GENERATED:imports END

class FeatureRegistry {
  static const List<Object> all = <Object>[
    // GENERATED:entries BEGIN
    // GENERATED:entries END
  ];
}
''';

void main() {
  late Directory tmp;
  late String regPath;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reg_writer_');
    regPath = '${tmp.path}/feature_registry.dart';
    File(regPath).writeAsStringSync(_seed);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('inserts a new feature inside the markers', () {
    RegistryWriter(regPath).register(
      packageName: 'app',
      moduleSnake: 'user',
      modulePascal: 'User',
    );
    final out = File(regPath).readAsStringSync();
    expect(out, contains("import 'package:app/features/user/user_module.dart';"));
    expect(out, contains('UserModule.descriptor,'));
    expect(out, contains('// GENERATED:imports END'));
    expect(out, contains('// GENERATED:entries END'));
  });

  test('is idempotent — re-registering the same feature is a no-op', () {
    final w = RegistryWriter(regPath);
    w.register(packageName: 'app', moduleSnake: 'user', modulePascal: 'User');
    final once = File(regPath).readAsStringSync();
    w.register(packageName: 'app', moduleSnake: 'user', modulePascal: 'User');
    final twice = File(regPath).readAsStringSync();
    expect(twice, equals(once));
  });

  test('keeps entries sorted', () {
    final w = RegistryWriter(regPath);
    w.register(packageName: 'app', moduleSnake: 'user', modulePascal: 'User');
    w.register(packageName: 'app', moduleSnake: 'order', modulePascal: 'Order');
    final out = File(regPath).readAsStringSync();
    final orderIdx = out.indexOf('OrderModule.descriptor');
    final userIdx = out.indexOf('UserModule.descriptor');
    expect(orderIdx, greaterThan(0));
    expect(userIdx, greaterThan(orderIdx));
  });

  test('preserves indentation on the END marker', () {
    RegistryWriter(regPath).register(
      packageName: 'app',
      moduleSnake: 'user',
      modulePascal: 'User',
    );
    final out = File(regPath).readAsStringSync();
    expect(out, contains('    // GENERATED:entries END'));
  });

  group('TypeScript registry (import_format: typescript)', () {
    late String tsPath;

    setUp(() {
      tsPath = '${tmp.path}/feature-registry.ts';
      File(tsPath).writeAsStringSync(_tsSeed);
    });

    test('emits register-free array items into all four marker regions', () {
      RegistryWriter(tsPath).register(
        packageName: 'example_react_app',
        moduleSnake: 'order',
        modulePascal: 'Order',
        importFormat: 'typescript',
      );
      final out = File(tsPath).readAsStringSync();

      // Import pulls routes, descriptor, AND the module provider.
      expect(
        out,
        contains(
          "import { OrderRoutes, OrderDescriptor, OrderModuleProvider } "
          "from '../../features/order/order.module';",
        ),
      );
      // Descriptor is a bare array item — NOT a FeatureRegistry.register() call.
      expect(out, contains('OrderDescriptor,'));
      expect(out, isNot(contains('FeatureRegistry.register')));
      // Provider is contributed to the FeatureProviders composition.
      expect(out, contains('OrderModuleProvider,'));
      // Route spread lands in the entries region.
      expect(out, contains('...OrderRoutes,'));
    });

    test('uses kebab-case paths for multi-word names (matches files on disk)',
        () {
      RegistryWriter(tsPath).register(
        packageName: 'example_react_app',
        moduleSnake: 'loyalty_card',
        modulePascal: 'LoyaltyCard',
        importFormat: 'typescript',
      );
      final out = File(tsPath).readAsStringSync();
      // Files are written to features/loyalty-card/loyalty-card.module — the
      // import path must be kebab, NOT snake (loyalty_card), or TS can't
      // resolve the module.
      expect(
        out,
        contains("from '../../features/loyalty-card/loyalty-card.module';"),
      );
      expect(out, isNot(contains('loyalty_card')));
      expect(out, contains('LoyaltyCardDescriptor,'));
      expect(out, contains('LoyaltyCardModuleProvider,'));
    });

    test('is idempotent across all TS marker regions', () {
      final w = RegistryWriter(tsPath);
      w.register(
        packageName: 'example_react_app',
        moduleSnake: 'order',
        modulePascal: 'Order',
        importFormat: 'typescript',
      );
      final once = File(tsPath).readAsStringSync();
      w.register(
        packageName: 'example_react_app',
        moduleSnake: 'order',
        modulePascal: 'Order',
        importFormat: 'typescript',
      );
      expect(File(tsPath).readAsStringSync(), equals(once));
    });
  });
}

const _tsSeed = '''
import { createElement, type ReactNode } from 'react';
import type { RouteObject } from 'react-router-dom';

// GENERATED:imports BEGIN
// GENERATED:imports END

export const allDescriptors = [
  // GENERATED:registrations BEGIN
  // GENERATED:registrations END
];

export const routes: RouteObject[] = [
  // GENERATED:entries BEGIN
  // GENERATED:entries END
];

const featureProviders = [
  // GENERATED:providers BEGIN
  // GENERATED:providers END
];

export function FeatureProviders({ children }: { children: ReactNode }) {
  return featureProviders.reduceRight<ReactNode>(
    (acc, Provider) => createElement(Provider, null, acc),
    children,
  );
}
''';
