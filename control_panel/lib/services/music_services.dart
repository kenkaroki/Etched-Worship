import 'dart:convert';
import 'dart:io';

import 'package:control_pannel/controllers/files.dart';

class MusicService {
  final File _jsonFile = File(songs_json);

  Future<void> initFile() async {
    if (!await _jsonFile.exists()) {
      await _jsonFile.writeAsString(jsonEncode({"folders": []}));
    }
  }

  Future<List<Map<String, dynamic>>> loadData() async {
    await initFile();
    final content = await _jsonFile.readAsString();
    final data = jsonDecode(content);
    return List<Map<String, dynamic>>.from(data["folders"] ?? []);
  }

  Future<void> saveData(List<Map<String, dynamic>> folders) async {
    await _jsonFile.writeAsString(jsonEncode({"folders": folders}));
  }
}
