import 'package:test/test.dart';

import 'package:flutter_feature_generator/renderer.dart';

void main() {
  group('substitutions', () {
    test('replaces simple placeholders', () {
      final out = render(
        'class {{Module}}Entity {}',
        substitutions: {'Module': 'User'},
        features: const {},
      );
      expect(out.trim(), 'class UserEntity {}');
    });

    test('does not consume adjacent braces', () {
      final out = render(
        'foo({{{Module}}Entity? e}) {}',
        substitutions: {'Module': 'User'},
        features: const {},
      );
      expect(out.trim(), 'foo({UserEntity? e}) {}');
    });

    test('throws on unknown placeholder', () {
      expect(
        () => render(
          '{{Unknown}}',
          substitutions: const {},
          features: const {},
        ),
        throwsA(isA<RenderError>()),
      );
    });
  });

  group('conditionals', () {
    const tmpl = '''
top
// #if features.show
visible
// #else
hidden
// #endif
bottom
''';

    test('keeps true branch', () {
      final out = render(tmpl,
          substitutions: const {}, features: const {'show': true});
      expect(out, contains('visible'));
      expect(out, isNot(contains('hidden')));
      expect(out, contains('top'));
      expect(out, contains('bottom'));
      // Marker lines themselves are stripped.
      expect(out, isNot(contains('#if')));
      expect(out, isNot(contains('#else')));
      expect(out, isNot(contains('#endif')));
    });

    test('keeps false branch', () {
      final out = render(tmpl,
          substitutions: const {}, features: const {'show': false});
      expect(out, contains('hidden'));
      expect(out, isNot(contains('visible')));
    });

    test('errors on unknown flag', () {
      expect(
        () => render(tmpl,
            substitutions: const {}, features: const {'other': true}),
        throwsA(isA<RenderError>()),
      );
    });

    test('errors on unterminated #if', () {
      expect(
        () => render('// #if features.x\nfoo\n',
            substitutions: const {}, features: const {'x': true}),
        throwsA(isA<RenderError>()),
      );
    });

    test('errors on nested #if', () {
      const nested = '''
// #if features.a
// #if features.b
inside
// #endif
// #endif
''';
      expect(
        () => render(nested,
            substitutions: const {},
            features: const {'a': true, 'b': true}),
        throwsA(isA<RenderError>()),
      );
    });
  });

  test('collapses runs of blank lines created by gating', () {
    const tmpl = '''
top


// #if features.x
gone
// #endif


bottom
''';
    final out = render(tmpl,
        substitutions: const {}, features: const {'x': false});
    // No more than two consecutive newlines.
    expect(out.contains('\n\n\n'), isFalse);
  });
}
