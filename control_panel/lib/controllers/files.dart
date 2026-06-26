import 'dart:io';
import 'package:path/path.dart' as p;

final exeDir = File(Platform.resolvedExecutable).parent.path;

final stack_file = p.join(exeDir,  '..',  'packagefiles',  'stack_controller.ecw.stc',);
final songs_json = p.join(exeDir, '..', 'packagefiles', 'songs.ecw.json');
final slide_backgrounds_json = p.join(exeDir, '..','packagefiles','slide_backgrounds.ecw.bgs.json',);
final bibles_folder = p.join(exeDir, '..', 'packagefiles', 'Bible');
