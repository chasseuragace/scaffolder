import 'dart:io';

import 'package:test/test.dart';

import 'package:flutter_generator_mcp/base/path_safety.dart';
import 'package:flutter_generator_mcp/base/tool.dart';

void main() {
  late Directory tmp;
  late Directory homeProject;
  late Directory volumeProject;
  late Directory orphanProject;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('path_safety_');
    homeProject = Directory('${tmp.path}/home/projects/app_a')
      ..createSync(recursive: true);
    volumeProject = Directory('${tmp.path}/Volumes/shared/app_b')
      ..createSync(recursive: true);
    orphanProject = Directory('${tmp.path}/elsewhere/app_c')
      ..createSync(recursive: true);
    for (final d in [homeProject, volumeProject, orphanProject]) {
      File('${d.path}/pubspec.yaml').writeAsStringSync('name: probe\n');
    }
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('without ALLOWED_ROOT, any pubspec-bearing dir is allowed', () {
    final s = PathSafety(allowedRoots: '');
    expect(s.validate(homeProject.path), isNotEmpty);
    expect(s.validate(volumeProject.path), isNotEmpty);
    expect(s.validate(orphanProject.path), isNotEmpty);
  });

  test('rejects a non-existent path', () {
    final s = PathSafety(allowedRoots: '');
    expect(
      () => s.validate('${tmp.path}/nope'),
      throwsA(isA<ToolFailure>()),
    );
  });

  test('rejects a directory without pubspec.yaml', () {
    final s = PathSafety(allowedRoots: '');
    final empty = Directory('${tmp.path}/empty')..createSync();
    expect(
      () => s.validate(empty.path),
      throwsA(isA<ToolFailure>()),
    );
  });

  test('single-root ALLOWED_ROOT confines to that subtree', () {
    final s = PathSafety(allowedRoots: '${tmp.path}/home');
    expect(s.validate(homeProject.path), isNotEmpty);
    expect(
      () => s.validate(volumeProject.path),
      throwsA(isA<ToolFailure>()),
    );
  });

  test('comma-separated ALLOWED_ROOT permits any of the listed roots', () {
    final s = PathSafety(
      allowedRoots: '${tmp.path}/home, ${tmp.path}/Volumes/shared',
    );
    expect(s.validate(homeProject.path), isNotEmpty);
    expect(s.validate(volumeProject.path), isNotEmpty);
    // Anything outside both still fails.
    expect(
      () => s.validate(orphanProject.path),
      throwsA(isA<ToolFailure>()),
    );
  });

  test('whitespace and empty entries in the list are tolerated', () {
    final s = PathSafety(
      allowedRoots: ' ${tmp.path}/home ,, ${tmp.path}/Volumes/shared ,',
    );
    expect(s.allowedRoots, hasLength(2));
  });

  test('allowedRoots exposes canonicalised absolute paths for the banner',
      () {
    final s = PathSafety(allowedRoots: '${tmp.path}/home');
    expect(s.allowedRoots, hasLength(1));
    expect(s.allowedRoots.first, contains('home'));
    // Path is absolute (starts with `/` on posix).
    expect(s.allowedRoots.first.startsWith(Platform.pathSeparator), isTrue);
  });
}
