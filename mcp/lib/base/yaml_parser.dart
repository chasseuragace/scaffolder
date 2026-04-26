/// A minimal YAML reader for the small, well-shaped config files this
/// generator uses (schema.yaml, manifest.yaml, presets/*.yaml).
///
/// We deliberately do not pull in `package:yaml` here — the schema is
/// small and predictable, and a hand-written parser keeps this MCP server
/// dependency-free and trivially auditable.
///
/// Supports:
///   - top-level mappings
///   - nested mappings under known keys
///   - scalar values: bool, int, string (quoted or bare)
///   - inline lists `[a, b]`
///   - block lists with `- ` items (mappings or scalars)
///   - comments (`#` to end of line)
///
/// Does **not** support: anchors, aliases, multi-line strings, complex
/// flow style, or anything fancy. If we ever need those, switch to
/// `package:yaml`.
library;

class _Line {
  _Line(this.indent, this.text);
  final int indent;
  final String text;
}

dynamic parseYaml(String input) {
  final lines = <_Line>[];
  for (final raw in input.split('\n')) {
    var line = raw;
    final hash = _findCommentStart(line);
    if (hash >= 0) line = line.substring(0, hash);
    if (line.trim().isEmpty) continue;
    final indent = line.length - line.trimLeft().length;
    lines.add(_Line(indent, line.trim()));
  }
  if (lines.isEmpty) return <String, dynamic>{};
  final result = _parseBlock(lines, 0, lines.length, 0);
  return result.value;
}

class _ParsedBlock {
  _ParsedBlock(this.value);
  final dynamic value;
}

_ParsedBlock _parseBlock(
  List<_Line> lines,
  int start,
  int end,
  int baseIndent,
) {
  if (start >= end) return _ParsedBlock(<String, dynamic>{});
  final first = lines[start];
  if (first.text.startsWith('- ')) {
    return _parseList(lines, start, end, baseIndent);
  }
  return _parseMap(lines, start, end, baseIndent);
}

_ParsedBlock _parseMap(
  List<_Line> lines,
  int start,
  int end,
  int baseIndent,
) {
  final out = <String, dynamic>{};
  var i = start;
  while (i < end) {
    final line = lines[i];
    if (line.indent < baseIndent) break;
    if (line.indent > baseIndent) {
      // Misaligned content — let outer parser handle.
      break;
    }
    final colon = _findKeyColon(line.text);
    if (colon < 0) break;
    final key = line.text.substring(0, colon).trim();
    final rest = line.text.substring(colon + 1).trim();
    if (rest.isNotEmpty) {
      out[key] = _parseScalarOrInline(rest);
      i++;
      continue;
    }
    // Value continues on the next indented line(s).
    final childStart = i + 1;
    var childEnd = childStart;
    while (childEnd < end && lines[childEnd].indent > baseIndent) {
      childEnd++;
    }
    if (childStart == childEnd) {
      out[key] = null;
      i++;
      continue;
    }
    final childIndent = lines[childStart].indent;
    final block = _parseBlock(lines, childStart, childEnd, childIndent);
    out[key] = block.value;
    i = childEnd;
  }
  return _ParsedBlock(out);
}

_ParsedBlock _parseList(
  List<_Line> lines,
  int start,
  int end,
  int baseIndent,
) {
  final out = <dynamic>[];
  var i = start;
  while (i < end) {
    final line = lines[i];
    if (line.indent != baseIndent) break;
    if (!line.text.startsWith('- ') && line.text != '-') break;
    final remainder = line.text == '-' ? '' : line.text.substring(2).trim();
    if (remainder.isEmpty) {
      // Block-style item: consume nested lines.
      final childStart = i + 1;
      var childEnd = childStart;
      while (childEnd < end && lines[childEnd].indent > baseIndent) {
        childEnd++;
      }
      if (childStart == childEnd) {
        out.add(null);
        i++;
        continue;
      }
      final childIndent = lines[childStart].indent;
      out.add(_parseBlock(lines, childStart, childEnd, childIndent).value);
      i = childEnd;
      continue;
    }
    final colon = _findKeyColon(remainder);
    if (colon < 0) {
      out.add(_parseScalarOrInline(remainder));
      i++;
      continue;
    }
    // The item is a mapping. Treat the rest of the line as its first key,
    // and any nested lines as further keys at indent = baseIndent + 2.
    final firstKey = remainder.substring(0, colon).trim();
    final firstRest = remainder.substring(colon + 1).trim();
    final mapping = <String, dynamic>{};
    if (firstRest.isNotEmpty) {
      mapping[firstKey] = _parseScalarOrInline(firstRest);
    } else {
      // First key has its value on subsequent indented lines (rare). Treat
      // as null for simplicity.
      mapping[firstKey] = null;
    }
    final childStart = i + 1;
    var childEnd = childStart;
    while (childEnd < end && lines[childEnd].indent > baseIndent) {
      childEnd++;
    }
    if (childStart < childEnd) {
      final nested = _parseMap(
        lines,
        childStart,
        childEnd,
        lines[childStart].indent,
      );
      if (nested.value is Map) {
        (nested.value as Map).forEach((k, v) => mapping[k as String] = v);
      }
    }
    out.add(mapping);
    i = childEnd;
  }
  return _ParsedBlock(out);
}

dynamic _parseScalarOrInline(String text) {
  if (text.startsWith('[') && text.endsWith(']')) {
    final inner = text.substring(1, text.length - 1).trim();
    if (inner.isEmpty) return <dynamic>[];
    return inner
        .split(',')
        .map((s) => _parseScalar(s.trim()))
        .toList(growable: false);
  }
  if (text.startsWith('{') && text.endsWith('}')) {
    final inner = text.substring(1, text.length - 1).trim();
    if (inner.isEmpty) return <String, dynamic>{};
    final out = <String, dynamic>{};
    for (final part in _splitTopLevelCommas(inner)) {
      final colon = _findKeyColon(part);
      if (colon < 0) continue;
      out[part.substring(0, colon).trim()] =
          _parseScalar(part.substring(colon + 1).trim());
    }
    return out;
  }
  return _parseScalar(text);
}

dynamic _parseScalar(String text) {
  if (text.isEmpty) return null;
  if (text == 'null' || text == '~') return null;
  if (text == 'true') return true;
  if (text == 'false') return false;
  final asInt = int.tryParse(text);
  if (asInt != null) return asInt;
  if (text.length >= 2 &&
      ((text.startsWith('"') && text.endsWith('"')) ||
          (text.startsWith("'") && text.endsWith("'")))) {
    return text.substring(1, text.length - 1);
  }
  return text;
}

int _findKeyColon(String s) {
  // Find the first ':' that isn't inside quotes or brackets.
  var inSingle = false;
  var inDouble = false;
  var bracket = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '"' && !inSingle) inDouble = !inDouble;
    if (c == "'" && !inDouble) inSingle = !inSingle;
    if (!inSingle && !inDouble) {
      if (c == '[' || c == '{') bracket++;
      if (c == ']' || c == '}') bracket--;
      if (c == ':' && bracket == 0) {
        // Must be followed by whitespace or end-of-string for key:value.
        if (i + 1 == s.length || s[i + 1] == ' ' || s[i + 1] == '\t') {
          return i;
        }
      }
    }
  }
  return -1;
}

int _findCommentStart(String s) {
  var inSingle = false;
  var inDouble = false;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '"' && !inSingle) inDouble = !inDouble;
    if (c == "'" && !inDouble) inSingle = !inSingle;
    if (c == '#' && !inSingle && !inDouble) {
      if (i == 0 || s[i - 1] == ' ' || s[i - 1] == '\t') return i;
    }
  }
  return -1;
}

List<String> _splitTopLevelCommas(String s) {
  final out = <String>[];
  var depth = 0;
  var inSingle = false;
  var inDouble = false;
  var start = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '"' && !inSingle) inDouble = !inDouble;
    if (c == "'" && !inDouble) inSingle = !inSingle;
    if (!inSingle && !inDouble) {
      if (c == '[' || c == '{') depth++;
      if (c == ']' || c == '}') depth--;
      if (c == ',' && depth == 0) {
        out.add(s.substring(start, i));
        start = i + 1;
      }
    }
  }
  out.add(s.substring(start));
  return out.where((p) => p.trim().isNotEmpty).toList();
}
