/// Case conversion helpers for module/feature names.
///
/// Accepts any reasonable input — `User`, `userProfile`, `user_profile`,
/// `user-profile`, `User Profile` — and produces consistent forms.
library;

/// Splits an input identifier into lowercase word tokens.
///
/// Recognises camelCase / PascalCase boundaries, runs of uppercase letters
/// (e.g. `HTTPServer` -> [`http`, `server`]), digits, and any non-alphanumeric
/// separators (`_`, `-`, space, etc).
List<String> tokenize(String input) {
  if (input.isEmpty) return const [];
  // Insert a space before each uppercase that follows a lowercase or digit.
  var s = input.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  // Insert a space between a run of uppercase and the start of a new word
  // (e.g. HTTPServer -> HTTP Server).
  s = s.replaceAllMapped(
    RegExp(r'([A-Z]+)([A-Z][a-z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  return s
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((t) => t.isNotEmpty)
      .map((t) => t.toLowerCase())
      .toList();
}

/// `user_profile`
String toSnakeCase(String input) => tokenize(input).join('_');

/// `USER_PROFILE`
String toUpperSnakeCase(String input) => toSnakeCase(input).toUpperCase();

/// `UserProfile`
String toPascalCase(String input) =>
    tokenize(input).map(_capitalize).join();

/// `userProfile`
String toCamelCase(String input) {
  final tokens = tokenize(input);
  if (tokens.isEmpty) return '';
  return tokens.first + tokens.skip(1).map(_capitalize).join();
}

/// `user-profile`
String toKebabCase(String input) => tokenize(input).join('-');

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Standard substitution map for a given module name.
Map<String, String> substitutionsFor(String moduleInput) {
  return {
    'Module': toPascalCase(moduleInput),
    'module': toCamelCase(moduleInput),
    'module_snake': toSnakeCase(moduleInput),
    'MODULE_UPPER': toUpperSnakeCase(moduleInput),
    'module-kebab': toKebabCase(moduleInput),
  };
}
