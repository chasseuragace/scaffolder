import 'dart:io';

import 'package:test/test.dart';

import 'package:flutter_feature_generator/registry_writer.dart';

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
}
