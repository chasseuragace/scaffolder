import 'dart:convert';
import 'dart:io';

import '../base/path_safety.dart';
import '../base/tool.dart';

/// Runs `flutter analyze` (and optionally `flutter test`) against the
/// project and returns a structured pass/fail report. This is the closing
/// half of an agent's generate→validate→fix loop.
class ValidateTool implements MCPTool {
  ValidateTool({
    required this.defaultProjectRoot,
    PathSafety? pathSafety,
  }) : _pathSafety = pathSafety ?? PathSafety();

  final String defaultProjectRoot;
  final PathSafety _pathSafety;

  @override
  String get name => 'validate';

  @override
  String get description =>
      'Run `flutter analyze` (and optionally `flutter test`) on the '
      'project and return a structured pass/fail report. Use after '
      'generate_feature to verify the result compiles.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'output_dir': {
            'type': 'string',
            'description':
                'Project root to validate. Defaults to PROJECT_ROOT env var.',
          },
          'run_tests': {
            'type': 'boolean',
            'description':
                'Also run `flutter test`. Default false (analyze only — much faster).',
          },
        },
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final raw = arguments['output_dir'] as String?;
    final projectRoot = (raw == null || raw.isEmpty)
        ? defaultProjectRoot
        : _pathSafety.validate(raw);
    final runTests = (arguments['run_tests'] as bool?) ?? false;

    final analyze = await Process.run(
      'flutter',
      ['analyze', '--no-pub'],
      workingDirectory: projectRoot,
    );

    final result = <String, dynamic>{
      'project_root': projectRoot,
      'analyze': {
        'exit_code': analyze.exitCode,
        'passed': analyze.exitCode == 0,
        'stdout': analyze.stdout.toString(),
        'stderr': analyze.stderr.toString(),
      },
    };

    if (runTests) {
      final test = await Process.run(
        'flutter',
        ['test', '--no-pub'],
        workingDirectory: projectRoot,
      );
      result['test'] = {
        'exit_code': test.exitCode,
        'passed': test.exitCode == 0,
        'stdout': _tail(test.stdout.toString(), 4000),
        'stderr': _tail(test.stderr.toString(), 2000),
      };
    }

    result['passed'] = (result['analyze'] as Map)['passed'] == true &&
        (runTests ? (result['test'] as Map)['passed'] == true : true);

    return jsonEncode(result);
  }

  String _tail(String s, int max) =>
      s.length <= max ? s : '...${s.substring(s.length - max)}';
}
