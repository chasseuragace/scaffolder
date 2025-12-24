import 'dart:io';

/// Interactive template selector for Flutter code generation
void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/select_template.dart ModuleName');
    exit(2);
  }

  final moduleName = args[0];
  
  print('🚀 Flutter Code Generator - Template Selector');
  print('=' * 50);
  print('Module: $moduleName');
  print('');
  
  print('Available templates:');
  print('1. Simple CRUD - Minimal files for basic operations');
  print('2. Enterprise - Full featured with all best practices');
  print('3. Mobile Optimized - Focused on great mobile UX');
  print('4. Custom - Use main template with custom flags');
  print('');
  
  stdout.write('Select template (1-4): ');
  final choice = stdin.readLineSync();
  
  String templatePath;
  List<String> extraArgs = [];
  
  switch (choice) {
    case '1':
      templatePath = 'templates/simple_crud.yaml';
      print('✓ Selected: Simple CRUD Template');
      break;
    case '2':
      templatePath = 'templates/enterprise.yaml';
      print('✓ Selected: Enterprise Template');
      break;
    case '3':
      templatePath = 'templates/mobile_optimized.yaml';
      print('✓ Selected: Mobile Optimized Template');
      break;
    case '4':
      templatePath = 'simpler_generator_folders.yaml';
      print('✓ Selected: Custom Template');
      print('');
      print('Available feature flags:');
      print('  simple_mode, clean_architecture, pagination, forms, filters');
      print('  optimistic_updates, inline_loading, retry_mechanisms');
      print('  mock_data_generation, advanced_error_handling');
      print('');
      stdout.write('Enter feature flags (e.g., simple_mode=true inline_loading=true): ');
      final flagsInput = stdin.readLineSync();
      if (flagsInput != null && flagsInput.isNotEmpty) {
        final flags = flagsInput.split(' ');
        for (final flag in flags) {
          if (flag.contains('=')) {
            extraArgs.addAll(['--feature', flag]);
          }
        }
      }
      break;
    default:
      print('❌ Invalid choice. Using default template.');
      templatePath = 'simpler_generator_folders.yaml';
  }
  
  print('');
  stdout.write('Overwrite existing files? (y/N): ');
  final overwrite = stdin.readLineSync()?.toLowerCase() == 'y';
  
  // Build command
  final command = [
    'dart',
    'run',
    'tool/generate_feature.dart',
    moduleName,
    '--template',
    templatePath,
    if (overwrite) '--overwrite',
    ...extraArgs,
  ];
  
  print('');
  print('🔧 Running: ${command.join(' ')}');
  print('');
  
  // Execute the generator
  final result = await Process.run(command.first, command.skip(1).toList());
  
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    stderr.write(result.stderr);
  }
  
  if (result.exitCode == 0) {
    print('');
    print('🎉 Code generation completed successfully!');
    print('');
    print('Next steps:');
    print('1. Review the generated files');
    print('2. Update dependencies in pubspec.yaml if needed');
    print('3. Run: flutter pub get');
    print('4. Start implementing your business logic');
  } else {
    print('');
    print('❌ Code generation failed with exit code: ${result.exitCode}');
  }
}