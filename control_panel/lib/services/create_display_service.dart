import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class DisplayService {
  final File _jsonFile = File("display_slide.json");

  Future<void> initFile() async {
    if (!await _jsonFile.exists()) {
      await _jsonFile.writeAsString(jsonEncode({}));
    }
  }

  Future<String?> pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    }
    return null;
  }

  Future<void> saveSlideData({
    required String? slideType,
    required String text,
    required String? pickedImagePath,
    required String? selectedBackgroundHex,
    String? selectedBackgroundImagePath,
  }) async {
    await initFile();
    final data = {
      "slideType": slideType,
      "text": text,
      "pickedImagePath": pickedImagePath,
      "selectedBackgroundHex": selectedBackgroundHex,
      "selectedBackgroundImagePath": selectedBackgroundImagePath,
      "updatedAt": DateTime.now().toIso8601String(),
    };
    await _jsonFile.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>> loadSlideData() async {
    await initFile();
    final content = await _jsonFile.readAsString();
    if (content.trim().isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(content));
  }
}
