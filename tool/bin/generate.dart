import 'dart:convert';
import 'dart:io';

import '../src/generator.dart';

const _usage = '''
Flutter feature generator.

Two distinct roots are involved and kept separate on purpose:
  - generator root: where the templates + this script live (auto-detected
                    from the script location; override with --templates)
  - working root:   where files are written (defaults to the current
                    directory; override with --out / --root)

Usage:
  dart run tool/bin/generate.dart <ModuleName> [options]
  dart run tool/bin/generate.dart --core-only [options]

Options:
  --preset <name>          Preset to use (simple|standard|enterprise). Default: standard.
  --feature <name>=<bool>  Override a flag. Repeatable.
  --overwrite              Overwrite existing files (incl. one-shot core files).
  --dry-run                Report what would be written without touching the filesystem.
  --json                   Emit a structured JSON report on stdout (for tools/IDEs).
  --templates <path>       Templates directory. Default: auto-detected from script location.
  --out <path>             Working project root (where files are written). Default: current directory.
  --root <path>            Alias for --out.
  --package <name>         Flutter package name of the working project. Default: flutter_project.
  --core-only              Generate only one-shot core files; skip per-feature.
  -h, --help               Show this message.

Examples:
  dart run tool/bin/generate.dart User
  dart run tool/bin/generate.dart Order --preset enterprise
  dart run tool/bin/generate.dart Product --feature pagination=false --out /path/to/my-app
  dart run tool/bin/generate.dart --core-only --out /path/to/new-project
  dart run tool/bin/generate.dart Invoice --dry-run --json
''';

/// Walks up from the script location until a directory containing
/// `templates/schema.yaml` is found. That directory is the generator root.
/// Returns the templates path, or null if it can't be located.
String? _autoDetectTemplatesDir() {
  try {
    var dir = File.fromUri(Platform.script).parent;
    for (var i = 0; i < 8; i++) {
      final candidate = '${dir.path}/templates/schema.yaml';
      if (File(candidate).existsSync()) return '${dir.path}/templates';
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  } catch (_) {}
  return null;
}

void main(List<String> argv) {
  String? moduleInput;
  var preset = 'standard';
  var overwrite = false;
  var coreOnly = false;
  var dryRun = false;
  var jsonOutput = false;
  String? templatesDir;
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
      case '--dry-run':
        dryRun = true;
      case '--json':
        jsonOutput = true;
      case '--templates':
        templatesDir = next();
      case '--out':
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

  // Resolve the templates dir. Order: explicit --templates flag > auto-detect
  // from the script location > relative `templates/` under the working dir
  // (the legacy self-hosted layout).
  final String resolvedTemplatesDir;
  if (templatesDir != null) {
    resolvedTemplatesDir = templatesDir.startsWith('/')
        ? templatesDir
        : '$projectRoot/$templatesDir';
  } else {
    resolvedTemplatesDir =
        _autoDetectTemplatesDir() ?? '$projectRoot/templates';
  }

  final gen = Generator(
    projectRoot: projectRoot,
    templatesDir: resolvedTemplatesDir,
    packageName: packageName,
  );

  try {
    final result = gen.run(
      moduleInput: moduleInput,
      presetName: preset,
      overrides: overrides,
      overwrite: overwrite,
      dryRun: dryRun,
    );
    if (jsonOutput) {
      stdout.writeln(jsonEncode({
        'success': true,
        'dry_run': dryRun,
        'module': moduleInput,
        'preset': preset,
        'created': result.created,
        'overwritten': result.overwritten,
        'skipped': result.skipped,
      }));
      return;
    }
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
      '\nDone${dryRun ? " (dry run)" : ""}. '
      'created=${result.created.length} '
      'overwritten=${result.overwritten.length} '
      'skipped=${result.skipped.length}',
    );
  } on StateError catch (e) {
    if (jsonOutput) {
      stdout.writeln(jsonEncode({'success': false, 'error': e.message}));
    } else {
      stderr.writeln(e.message);
    }
    exit(1);
  } on ArgumentError catch (e) {
    if (jsonOutput) {
      stdout.writeln(jsonEncode({'success': false, 'error': e.message}));
    } else {
      stderr.writeln(e.message);
    }
    exit(2);
  }
}
