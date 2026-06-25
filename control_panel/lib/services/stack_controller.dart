import 'dart:io';

import 'package:control_pannel/controllers/files.dart';

final stack = File(stack_file);

void write_to_stack(content) async {
  try {
    
    await stack.writeAsString(content);
    print('stack updated successfully.');
  } catch (e) {
    print('Error updating stack: $e');
  }
}
