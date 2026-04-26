import 'dart:io';

import 'package:flutter_generator_mcp/base/generator_root.dart';
import 'package:flutter_generator_mcp/server.dart';

/// CLI entry. Distinguishes the *generator root* (auto-detected — where
/// the templates and CLI live) from the *default working root* (where
/// scaffolded files go when the caller doesn't override per-call).
class MCPConfig {
  MCPConfig({
    required this.name,
    required this.version,
    required this.generatorRoot,
    required this.defaultWorkingRoot,
    required this.packageName,
  });

  final String name;
  final String version;
  final String generatorRoot;
  final String defaultWorkingRoot;
  final String packageName;

  factory MCPConfig.resolve(List<String> args) {
    String? generatorRoot;
    String? workingRoot;
    String packageName =
        Platform.environment['PACKAGE_NAME'] ?? 'flutter_project';

    for (var i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--generator-root':
          if (i + 1 < args.length) generatorRoot = args[++i];
        case '--project-root':
        case '--working-root':
          if (i + 1 < args.length) workingRoot = args[++i];
        case '--package-name':
          if (i + 1 < args.length) packageName = args[++i];
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
      }
    }

    // Generator root: explicit flag > GENERATOR_ROOT env > auto-detect.
    generatorRoot ??= Platform.environment['GENERATOR_ROOT'];
    generatorRoot ??= findGeneratorRoot();

    // Working root: explicit flag > PROJECT_ROOT env > current dir.
    workingRoot ??= Platform.environment['PROJECT_ROOT'];
    workingRoot ??= Directory.current.path;

    return MCPConfig(
      name: 'flutter-generator-mcp',
      version: '1.0.0',
      generatorRoot: generatorRoot,
      defaultWorkingRoot: workingRoot,
      packageName: packageName,
    );
  }

  static void _printUsage() {
    stderr.writeln('''
flutter-generator-mcp — MCP server for the Flutter feature generator

Two roots are kept distinct on purpose:
  - generator root: where the templates + CLI live. Auto-detected from this
                    server's install location; rarely needs to be specified.
  - working root:   where scaffolded files are written. Defaults to PROJECT_ROOT
                    or the current directory; per-call override via output_dir.

Usage:
  dart run flutter_generator_mcp [options]

Options:
  --generator-root <path>  Override generator install root (templates + CLI live here)
                           Env: GENERATOR_ROOT
  --working-root <path>    Default working project; per-call output_dir overrides this
                           Env: PROJECT_ROOT
  --project-root <path>    Alias for --working-root.
  --package-name <name>    Flutter package name of the working project (default: flutter_project)
                           Env: PACKAGE_NAME
  -h, --help               This message

Environment:
  GENERATOR_ROOT     Skip auto-detection; pin the templates + CLI location.
  PROJECT_ROOT       Default working project. Per-call output_dir overrides it.
  PACKAGE_NAME       Default Flutter package name.
  ALLOWED_ROOT       If set, every output_dir override must reside under this path.
                     Strongly recommended in shared / multi-project setups.
''');
  }
}

Future<void> main(List<String> args) async {
  final config = MCPConfig.resolve(args);
  final server = FlutterGeneratorMCPServer(
    name: config.name,
    version: config.version,
    generatorRoot: config.generatorRoot,
    defaultWorkingRoot: config.defaultWorkingRoot,
    packageName: config.packageName,
  );
  await server.start();
}
