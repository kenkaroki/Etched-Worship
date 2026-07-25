import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class BackgroundManager {
  static const List<String> _validImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'bmp',
    'webp',
  ];

  static Future<String?> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _validImageExtensions,
      dialogTitle: "Select a background image",
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final path = result.files.single.path!;

    final extension = p.extension(path).replaceFirst(".", "").toLowerCase();

    if (!_validImageExtensions.contains(extension)) {
      throw Exception("Unsupported image type: $extension");
    }

    return path;
  }

  static Future<String?> addBackground({
    required String selectedFilePath,
    required String destinationFolder,
    required String configFilePath,
    required String fileName,
  }) async {
    final sourceExt = p
        .extension(selectedFilePath)
        .replaceFirst(".", "")
        .toLowerCase();

    String cleanName = fileName.trim();

    if (cleanName.isEmpty) {
      throw Exception("Filename cannot be empty");
    }

    if (p.extension(cleanName).isNotEmpty) {
      cleanName = p.basenameWithoutExtension(cleanName);
    }

    final finalName = "$cleanName.$sourceExt";

    final directory = Directory(destinationFolder);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final destinationPath = p.join(destinationFolder, finalName);

    final sourceFile = File(selectedFilePath);

    final copiedFile = await sourceFile.copy(destinationPath);

    await _updateConfig(configFilePath, copiedFile.path);

    return copiedFile.path;
  }

  static Future<void> _updateConfig(
    String configFilePath,
    String newPath,
  ) async {
    final file = File(configFilePath);

    Map<String, dynamic> data;

    if (await file.exists()) {
      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        data = {"custom_backgrounds": []};
      } else {
        data = jsonDecode(content) as Map<String, dynamic>;
      }
    } else {
      await file.create(recursive: true);

      data = {"custom_backgrounds": []};
    }

    final List<dynamic> backgrounds =
        (data["custom_backgrounds"] as List<dynamic>?) ?? [];

    if (!backgrounds.contains(newPath)) {
      backgrounds.add(newPath);
    }

    data["custom_backgrounds"] = backgrounds;

    await file.writeAsString(const JsonEncoder.withIndent("  ").convert(data));
  }
}
