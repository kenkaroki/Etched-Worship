import 'dart:io';

final stack = File('stack.ecw.stc');

void write_to_stack(content) async {
  try {
    
    await stack.writeAsString(content);
    print('stack updated successfully.');
  } catch (e) {
    print('Error updating stack: $e');
  }
}
