import 'dart:io';

import 'package:yaml/yaml.dart';

/// Simple feature generator using `simpler_generator_folders.yaml` as template.
///
/// Usage:
///   dart run tool/generate_feature.dart ModuleName [--template path] [--out lib] [--overwrite]
///
/// Example:
///   dart run tool/generate_feature.dart User

String toPascalCase(String input) {
  final parts = input
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
      .toList();
  return parts.join();
}

String toSnakeCase(String input) {
  final s = input.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
  final cleaned = s.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
  final out = cleaned
      .replaceAll(RegExp(r'__+'), '_')
      .replaceAll(RegExp(r'^_'), '')
      .replaceAll(RegExp(r'_+$'), '');
  if (out.isEmpty) return input.toLowerCase();
  return out;
}

String toUpperSnake(String input) => toSnakeCase(input).toUpperCase();

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/generate_feature.dart ModuleName [--template path] [--out lib] [--overwrite]',
    );
    exit(2);
  }

  final moduleArg = args[0];
  String templatePath = 'simpler_generator_folders.yaml';
  String outBase = 'lib';
  bool overwrite = false;

  for (var i = 1; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--template' && i + 1 < args.length) {
      templatePath = args[++i];
    } else if (arg == '--out' && i + 1 < args.length) {
      outBase = args[++i];
    } else if (arg == '--overwrite') {
      overwrite = true;
    } else {
      stderr.writeln('Unknown argument: $arg');
      exit(2);
    }
  }

  final pascal = toPascalCase(moduleArg);
  final snake = toSnakeCase(moduleArg);
  final upper = toUpperSnake(moduleArg);

  final templateFile = File(templatePath);
  if (!await templateFile.exists()) {
    stderr.writeln('Template not found at: $templatePath');
    exit(2);
  }

  final yamlString = await templateFile.readAsString();
  final doc = loadYaml(yamlString);

  final generate = doc['generate'];
  if (generate == null || generate is! YamlList) {
    stderr.writeln('No `generate` list found in template.');
    exit(2);
  }

  int created = 0;
  int skipped = 0;

  // Process each top-level category
  for (final cat in generate) {
    final category = cat['category'] as String?;
    final contents = cat['contents'] as YamlList?;
    if (category == null || contents == null) continue;

    // base path for this category
    final basePath = Directory('$outBase/$category');

    // ensure category directory exists
    await basePath.create(recursive: true);

    // process contents recursively
    Future<void> processContents(YamlList items, Directory currentDir) async {
      for (final item in items) {
        if (item is YamlMap && item.containsKey('folder')) {
          var folderName = item['folder'] as String;
          // Replace placeholders in folder names if present
          folderName = folderName.replaceAll('ModuleName', pascal);
          folderName = folderName.replaceAll('module_name', snake);
          folderName = folderName.replaceAll('NAME', upper);

          final folderDir = Directory('${currentDir.path}/$folderName');
          await folderDir.create(recursive: true);
          final subContents = item['contents'] as YamlList?;
          if (subContents != null) {
            await processContents(subContents, folderDir);
          }
        } else if (item is YamlMap && item.containsKey('file')) {
          var fileName = item['file'] as String;
          // Replace placeholders in file names
          fileName = fileName.replaceAll('ModuleName', pascal);
          fileName = fileName.replaceAll('module_name', snake);
          fileName = fileName.replaceAll('NAME', upper);

          final code = item['code'] as String? ?? '';
          final targetPath = '${currentDir.path}/$fileName';

          // Replace placeholders
          var processed = code.replaceAll('ModuleName', pascal);
          processed = processed.replaceAll('module_name', snake);
          processed = processed.replaceAll('NAME', upper);

          final targetFile = File(targetPath);
          if (await targetFile.exists() && !overwrite) {
            stderr.writeln(
              'Skipping existing file: $targetPath (use --overwrite to replace)',
            );
            skipped++;
            continue;
          }

          await targetFile.writeAsString(processed);
          stdout.writeln('Created: $targetPath');
          created++;
        } else if (item is YamlMap && item.containsKey('file_path')) {
          // optional: custom path entry
          final filePath = item['file_path'] as String;
          final code = item['code'] as String? ?? '';
          final targetPath = filePath
              .replaceAll('ModuleName', pascal)
              .replaceAll('module_name', snake)
              .replaceAll('NAME', upper);
          final targetFile = File(targetPath);
          await targetFile.parent.create(recursive: true);
          if (await targetFile.exists() && !overwrite) {
            stderr.writeln(
              'Skipping existing file: $targetPath (use --overwrite to replace)',
            );
            skipped++;
            continue;
          }
          var processed = code.replaceAll('ModuleName', pascal);
          processed = processed.replaceAll('module_name', snake);
          processed = processed.replaceAll('NAME', upper);
          await targetFile.writeAsString(processed);
          stdout.writeln('Created: $targetPath');
          created++;
        }
      }
    }

    await processContents(contents, basePath);
  }

  stdout.writeln('\nDone. Created: $created files, Skipped: $skipped files.');
}
