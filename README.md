mockable_filesystem
===================

 Provides a FileSystem factory class for allocating File, Directory and Link
 objects, with two implementations - one which in turn returns the real
 objects from dart:io, and one which returns mock versions. This allows 
 tests to be written that make use of files and directories without
 having to create them on disk.
 The mock File/Directory/Link classes are not complete, but have sufficient
 functionality to work in most cases.
 The ultimate aim is to have complete mock implementations, as well as the 
 ability to mock Windows file systems on Linux/Mac and vice-versa, to help 
 with testing code for cross-platform correctness.

Installing
----------

1. Depend on it

   Add this to your package's pubspec.yaml file:

   ```YAML
   dependencies:
     mockable_filesystem: any
   ```

   If your package is an application package you should use any as the version constraint.

2. Install it

   If you're using the Dart Editor, choose:

   ```
   Menu > Tools > Pub Install
   ```

   Or if you want to install from the command line, run:

   ```
   $ pub install
   ```

3. Import it

   Now in your Dart code, you can use:

   ```Dart
   import 'package:mockable_filesystem/filesystem.dart';
   ```

   or:

   ```Dart
   import 'package:mockable_filesystem/mock_filesystem.dart';
   ```

