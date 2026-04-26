import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/case_helpers.dart';

void main() {
  group('tokenize', () {
    test('plain words', () {
      expect(tokenize('user'), ['user']);
      expect(tokenize(''), <String>[]);
    });

    test('camelCase boundaries', () {
      expect(tokenize('userProfile'), ['user', 'profile']);
      expect(tokenize('myAwesomeFeature'), ['my', 'awesome', 'feature']);
    });

    test('PascalCase boundaries', () {
      expect(tokenize('UserProfile'), ['user', 'profile']);
      expect(tokenize('OrderItem'), ['order', 'item']);
    });

    test('runs of uppercase', () {
      expect(tokenize('HTTPServer'), ['http', 'server']);
      expect(tokenize('parseHTMLString'), ['parse', 'html', 'string']);
    });

    test('separators', () {
      expect(tokenize('user_profile'), ['user', 'profile']);
      expect(tokenize('user-profile'), ['user', 'profile']);
      expect(tokenize('User Profile'), ['user', 'profile']);
      expect(tokenize('  multi   sep  '), ['multi', 'sep']);
    });

    test('digits', () {
      expect(tokenize('feature2'), ['feature2']);
      expect(tokenize('user2Profile'), ['user2', 'profile']);
    });
  });

  test('case conversions round-trip across input shapes', () {
    for (final input in const [
      'UserProfile',
      'userProfile',
      'user_profile',
      'user-profile',
      'User Profile',
      'USER_PROFILE',
    ]) {
      expect(toPascalCase(input), 'UserProfile', reason: 'pascal: $input');
      expect(toCamelCase(input), 'userProfile', reason: 'camel: $input');
      expect(toSnakeCase(input), 'user_profile', reason: 'snake: $input');
      expect(toKebabCase(input), 'user-profile', reason: 'kebab: $input');
      expect(toUpperSnakeCase(input), 'USER_PROFILE', reason: 'upper: $input');
    }
  });

  test('substitutionsFor produces all expected keys', () {
    final subs = substitutionsFor('userProfile');
    expect(subs['Module'], 'UserProfile');
    expect(subs['module'], 'userProfile');
    expect(subs['module_snake'], 'user_profile');
    expect(subs['MODULE_UPPER'], 'USER_PROFILE');
    expect(subs['module-kebab'], 'user-profile');
  });
}
