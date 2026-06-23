import 'dart:io';

final File stackFile = File("stack.ecw.stc");

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
