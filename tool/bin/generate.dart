import 'dart:io';

import '../src/generator.dart';

const _usage = '''
Flutter feature generator.

Usage:
  dart run tool/bin/generate.dart <ModuleName> [options]
  dart run tool/bin/generate.dart --core-only [options]

Options:
  --preset <name>          Preset to use (simple|standard|enterprise). Default: standard.
  --feature <name>=<bool>  Override a flag. Repeatable.
  --overwrite              Overwrite existing files (incl. one-shot core files).
  --templates <path>       Templates directory. Default: templates.
  --root <path>            Project root. Default: current directory.
  --package <name>         Package name. Default: flutter_project.
  --core-only              Generate only one-shot core files; skip per-feature.
  -h, --help               Show this message.

Examples:
  dart run tool/bin/generate.dart User
  dart run tool/bin/generate.dart Order --preset enterprise
  dart run tool/bin/generate.dart Product --feature pagination=false
  dart run tool/bin/generate.dart --core-only
''';

void main(List<String> argv) {
  String? moduleInput;
  var preset = 'standard';
  var overwrite = false;
  var coreOnly = false;
  var templatesDir = 'templates';
  var projectRoot = Directory.current.path;
  var packageName = 'flutter_project';
  final overrides = <String, bool>{};

  for (var i = 0; i < argv.length; i++) {
    final arg = argv[i];
    String next() {
      if (i + 1 >= argv.length) {
        stderr.writeln('error: $arg requires a value');
        exit(2);
      }
      return argv[++i];
    }

    switch (arg) {
      case '-h':
      case '--help':
        stdout.write(_usage);
        return;
      case '--preset':
        preset = next();
      case '--overwrite':
        overwrite = true;
      case '--core-only':
        coreOnly = true;
      case '--templates':
        templatesDir = next();
      case '--root':
        projectRoot = next();
      case '--package':
        packageName = next();
      case '--feature':
        final raw = next();
        final eq = raw.indexOf('=');
        if (eq < 0) {
          stderr.writeln('error: --feature expects name=true|false (got "$raw")');
          exit(2);
        }
        final name = raw.substring(0, eq);
        final value = raw.substring(eq + 1).toLowerCase();
        if (value != 'true' && value != 'false') {
          stderr.writeln('error: --feature value must be true or false');
          exit(2);
        }
        overrides[name] = value == 'true';
      default:
        if (arg.startsWith('-')) {
          stderr.writeln('error: unknown option $arg\n\n$_usage');
          exit(2);
        }
        if (moduleInput != null) {
          stderr.writeln('error: only one ModuleName is allowed');
          exit(2);
        }
        moduleInput = arg;
    }
  }

  if (moduleInput == null && !coreOnly) {
    stderr.writeln('error: ModuleName required (or pass --core-only)\n\n$_usage');
    exit(2);
  }

  final gen = Generator(
    projectRoot: projectRoot,
    templatesDir: '$projectRoot/$templatesDir',
    packageName: packageName,
  );

  try {
    final result = gen.run(
      moduleInput: moduleInput,
      presetName: preset,
      overrides: overrides,
      overwrite: overwrite,
    );
    for (final p in result.created) {
      stdout.writeln('  created    $p');
    }
    for (final p in result.overwritten) {
      stdout.writeln('  overwrote  $p');
    }
    for (final p in result.skipped) {
      stdout.writeln('  skipped    $p (exists; use --overwrite)');
    }
    stdout.writeln(
      '\nDone. created=${result.created.length} '
      'overwritten=${result.overwritten.length} '
      'skipped=${result.skipped.length}',
    );
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exit(1);
  } on ArgumentError catch (e) {
    stderr.writeln(e.message);
    exit(2);
  }
}
