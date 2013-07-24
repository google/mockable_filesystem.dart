library mock_filesystem_test;
import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:mockable_filesystem/mock_filesystem.dart';

main() {
  useVMConfiguration();

  var exceptionHandler = (error) {
    var trace = getAttachedStackTrace(error);
    String traceString = trace == null ? "" : trace.toString();
    if (error is TestFailure) {
      currentTestCase.fail(error.message, traceString);
    } else {
      currentTestCase.error("Unexpected error: ${error}", traceString);
    }
  };

  setUp(() {
    fileSystem = new MockFileSystem();
  });

  test('non-existent entity', () {
    var f = fileSystem.getFile('/foo/bar');
    expect(f, isNotNull);
    expect(f.existsSync(), isFalse);
    var d = fileSystem.getDirectory('/foo/bar');
    expect(d, isNotNull);
    expect(d.existsSync(), isFalse);
    var l = fileSystem.getLink('/foo/bar');
    expect(l, isNotNull);
    expect(l.existsSync(), isFalse);
  });

  test('create file at root', () {
    var f = fileSystem.getFile('/foo.txt');
    expect(f, isNotNull);
    expect(f.existsSync(), isFalse);
    f.writeAsStringSync('Hello world');
    expect(f.existsSync(), isTrue);
    expect(f.readAsStringSync(), 'Hello world');
  });

  test('create file at root with Futures', () {
    var f1 = fileSystem.getFile('/foo.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    return f1.writeAsString('Hello world').then((_) {
      var f2 = fileSystem.getFile('/foo.txt');
      expect(f2, isNotNull);
      expect(f2.existsSync(), isTrue);
      return f2.readAsString().then((contents) {
        expect(contents, 'Hello world');
      }).catchError(exceptionHandler);
    }).catchError(exceptionHandler);
  });

  test('create file in subdirectory', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    f1.writeAsStringSync('Hello world');
    var f2 = fileSystem.getFile('/foo/bar.txt');
    expect(f2.existsSync(), isTrue);
    expect(f2.readAsStringSync(), 'Hello world');
  });

  test('create file in non-existent subdirectory', () {
    var f1 = fileSystem.getFile('/foo/bar.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    expect(() => f1.writeAsStringSync('Hello world'), throwsException);
  });

  test('current directory', () {
    fileSystem.currentDirectory = '/foo/bar';
    expect(fileSystem.currentDirectory, '/foo/bar');
  });

  test('absolute path', () {
    fileSystem.currentDirectory = '/foo/bar';
    expect(fileSystem.currentDirectory, '/foo/bar');
    expect(absolutePath('test.txt'), '/foo/bar/test.txt');
  });

  test('fullPath', () {
    fileSystem.getDirectory('/foo').createSync();
    fileSystem.getDirectory('/foo/bar').createSync();
    fileSystem.currentDirectory = '/foo/bar';
    expect(fileSystem.currentDirectory, '/foo/bar');
    var f = fileSystem.getFile('test.txt');
    expect(f.fullPathSync(), null); // Is this really the desired result?
    f.writeAsStringSync('Hello world');
    expect(f.path, 'test.txt');
    expect(f.fullPathSync(), '/foo/bar/test.txt');
  });

  test('delete file', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    f1.writeAsStringSync('Hello world');
    var f2 = fileSystem.getFile('/foo/bar.txt');
    expect(f2.existsSync(), isTrue);
    expect(f2.readAsStringSync(), 'Hello world');
    f1.deleteSync();
    expect(f2.existsSync(), isFalse);
  });

  test('delete directory non-recursively', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    f1.writeAsStringSync('Hello world');
    var f2 = fileSystem.getFile('/foo/bar.txt');
    expect(f2.existsSync(), isTrue);
    expect(f2.readAsStringSync(), 'Hello world');
    expect(() => fileSystem.getDirectory('/foo').deleteSync(), throwsException);
  });

  test('delete directory recursively', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    f1.writeAsStringSync('Hello world');
    var f2 = fileSystem.getFile('/foo/bar.txt');
    expect(f2.existsSync(), isTrue);
    expect(f2.readAsStringSync(), 'Hello world');
    fileSystem.getDirectory('/foo').deleteSync(recursive: true);
    expect(f2.existsSync(), isFalse);
    expect(fileSystem.getDirectory('/foo').existsSync(), isFalse);
  });


  test('symlinks', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    f1.writeAsStringSync('Hello world');
    var l1 = fileSystem.getLink('/foo/link1');
    var l2 = fileSystem.getLink('/foo/link2');
    fileSystem.symlink('/foo/link1', '/foo/bar.txt');
    expect(l2.existsSync(), isFalse);
    expect(l1.existsSync(), isTrue);
    expect(l1.targetSync(), '/foo/bar.txt');
    l1.updateSync('/foo/bar2.txt');
    expect(l1.targetSync(), '/foo/bar2.txt');
    expect(() => l2.updateSync('../bar.txt'), throwsException);
    l1.deleteSync();
    expect(f1.existsSync(), isTrue);
    expect(l1.existsSync(), isFalse);
    expect(l2.existsSync(), isFalse);
  });

  // rename/renameSync not implemented yet.
  skip_test('rename', () {
    fileSystem.getDirectory('/foo').createSync();
    var f1 = fileSystem.getFile('/foo/bar.txt');
    var f2 = fileSystem.getFile('/foo/bar2.txt');
    expect(f1, isNotNull);
    expect(f1.existsSync(), isFalse);
    expect(f2, isNotNull);
    expect(f2.existsSync(), isFalse);
    f1.writeAsStringSync('Hello world');
    expect(f1.existsSync(), isTrue);
    expect(f2.existsSync(), isFalse);
    var f3 = f1.renameSync('/foo/bar2.txt');
    expect(f1.existsSync(), isFalse);
    expect(f2.existsSync(), isTrue);
    expect(f3.existsSync(), isTrue);
    expect(f2.readAsStringSync(), 'Hello world');
  });

  test('lastModified', () {
    var start = new DateTime.now();
    var d = fileSystem.getDirectory('/foo');
    return new Future.delayed(fileSystem.timeGranularity).then((_) {
      d.createSync();
      var f1 = fileSystem.getFile('/foo/bar.txt');
      f1.writeAsStringSync('Hello');
      expect(f1.lastModifiedSync().millisecondsSinceEpoch,
          greaterThan(start.millisecondsSinceEpoch));
    }).catchError(exceptionHandler);
  });
}

