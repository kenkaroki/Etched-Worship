import 'dart:io';

import 'package:canvas/controllers/file.dart';

final File stackFile = File(stack_file);

Future<String> readStack() async {
  try {
    if (await stackFile.exists()) {
      List<String> lines = await stackFile.readAsLines();
      return lines.isNotEmpty ? lines.first : "";
    }

    return "";
  } catch (e) {
    print("Error reading file: $e");
    return "";
  }
}
