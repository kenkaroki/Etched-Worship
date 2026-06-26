import 'dart:io';
import 'package:path/path.dart' as p;

final exeDir = File(Platform.resolvedExecutable).parent.path;

final stack_file = p.join(
  exeDir,
  '..',
  'packagefiles',
  'stack_controller.ecw.stc',
);
