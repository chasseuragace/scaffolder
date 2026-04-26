import 'dart:io';

import 'package:flutter_generator_mcp/server.dart';

/// Configuration from environment or command line
class MCPConfig {
  final String name;
  final String version;
  final String projectRoot;
  final String templatesDir;
  final String packageName;

  MCPConfig({
    required this.name,
    required this.version,
    required this.projectRoot,
    required this.templatesDir,
    required this.packageName,
  });

  factory MCPConfig.fromEnvironment() {
    final projectRoot = Platform.environment['PROJECT_ROOT'] ?? 
        Directory.current.parent.path;
    final templatesDir = Platform.environment['TEMPLATES_DIR'] ?? 
        '$projectRoot/templates';
    final packageName = Platform.environment['PACKAGE_NAME'] ?? 
        'flutter_project';

    return MCPConfig(
      name: 'flutter-generator-mcp',
      version: '1.0.0',
      projectRoot: projectRoot,
      templatesDir: templatesDir,
      packageName: packageName,
    );
  }

  factory MCPConfig.fromArgs(List<String> args) {
    String projectRoot = Directory.current.parent.path;
    String templatesDir = '$projectRoot/templates';
    String packageName = 'flutter_project';

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--project-root':
          if (i + 1 < args.length) projectRoot = args[++i];
          break;
        case '--templates-dir':
          if (i + 1 < args.length) templatesDir = args[++i];
          break;
        case '--package-name':
          if (i + 1 < args.length) packageName = args[++i];
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
      }
    }

    return MCPConfig(
      name: 'flutter-generator-mcp',
      version: '1.0.0',
      projectRoot: projectRoot,
      templatesDir: templatesDir,
      packageName: packageName,
    );
  }

  static void _printUsage() {
    stderr.writeln('''
flutter-generator-mcp — MCP server for the Flutter feature generator

Usage:
  dart run flutter_generator_mcp [options]

Options:
  --project-root <path>   Default project to scaffold into (env: PROJECT_ROOT)
  --templates-dir <path>  Templates directory (env: TEMPLATES_DIR)
  --package-name <name>   Flutter package name (env: PACKAGE_NAME)
  -h, --help              This message

Environment:
  PROJECT_ROOT           Default project root for tool calls
  TEMPLATES_DIR          Templates directory; defaults to <project-root>/templates
  PACKAGE_NAME           Flutter package name (default: flutter_project)
  ALLOWED_ROOT           If set, output_dir overrides must reside under this path.
                         Strongly recommended in shared / multi-project setups.
''');
  }
}

Future<void> main(List<String> args) async {
  final config = args.isNotEmpty ? MCPConfig.fromArgs(args) : MCPConfig.fromEnvironment();

  final server = FlutterGeneratorMCPServer(
    name: config.name,
    version: config.version,
    projectRoot: config.projectRoot,
    templatesDir: config.templatesDir,
    packageName: config.packageName,
  );

  await server.start();
}
