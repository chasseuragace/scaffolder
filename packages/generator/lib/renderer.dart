/// Template renderer.
///
/// Two responsibilities:
///   1. Apply mustache-style substitutions: `{{Module}}`, `{{module}}`,
///      `{{module_snake}}`, `{{MODULE_UPPER}}`, `{{module-kebab}}`.
///   2. Honour line-based conditional regions:
///        // #if features.foo
///        ... kept when foo is true ...
///        // #else
///        ... kept when foo is false ...
///        // #endif
///
/// The marker lines themselves are stripped from the output. Conditional
/// regions do not nest in v1 — a nested `// #if` inside a region is treated
/// as content (and reported as an error if encountered, to fail loudly).
library;

class RenderError implements Exception {
  RenderError(this.message, {this.line});
  final String message;
  final int? line;
  @override
  String toString() =>
      line == null ? 'RenderError: $message' : 'RenderError(line $line): $message';
}

String render(
  String template, {
  required Map<String, String> substitutions,
  required Map<String, bool> features,
}) {
  final afterConditionals = _applyConditionals(template, features);
  return _applySubstitutions(afterConditionals, substitutions);
}

String _applySubstitutions(String input, Map<String, String> subs) {
  return input.replaceAllMapped(
      RegExp(r'\{\{([A-Za-z][A-Za-z0-9_\-]*)\}\}'), (m) {
    final key = m.group(1)!;
    final value = subs[key];
    if (value == null) {
      throw RenderError('unknown placeholder: {{$key}}');
    }
    return value;
  });
}

enum _State { outside, insideTrue, insideFalse }

String _applyConditionals(String input, Map<String, bool> features) {
  final lines = input.split('\n');
  final out = StringBuffer();
  var state = _State.outside;
  String? activeFlag;
  bool? activeValue;

  final ifRe = RegExp(r'^\s*//\s*#if\s+features\.(\w+)\s*$');
  final elseRe = RegExp(r'^\s*//\s*#else\s*$');
  final endifRe = RegExp(r'^\s*//\s*#endif\s*$');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final ifMatch = ifRe.firstMatch(line);
    if (ifMatch != null) {
      if (state != _State.outside) {
        throw RenderError('nested #if not supported', line: i + 1);
      }
      activeFlag = ifMatch.group(1);
      activeValue = features[activeFlag];
      if (activeValue == null) {
        throw RenderError('unknown flag in #if: $activeFlag', line: i + 1);
      }
      state = activeValue ? _State.insideTrue : _State.insideFalse;
      continue;
    }
    if (elseRe.hasMatch(line)) {
      if (state == _State.outside) {
        throw RenderError('#else without #if', line: i + 1);
      }
      state = state == _State.insideTrue ? _State.insideFalse : _State.insideTrue;
      continue;
    }
    if (endifRe.hasMatch(line)) {
      if (state == _State.outside) {
        throw RenderError('#endif without #if', line: i + 1);
      }
      state = _State.outside;
      activeFlag = null;
      activeValue = null;
      continue;
    }
    final keep = state == _State.outside || state == _State.insideTrue;
    if (keep) out.writeln(line);
  }

  if (state != _State.outside) {
    throw RenderError('unterminated #if (flag: $activeFlag)');
  }

  // Collapse 3+ consecutive blank lines down to 2 — common after stripping
  // gated regions.
  final collapsed =
      out.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
  return '$collapsed\n';
}
