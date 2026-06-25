import 'dart:convert';
import 'dart:io';
import 'package:control_pannel/controllers/files.dart';
import 'package:flutter/material.dart';

class BackgroundsService {
  final File _bgsFile = File(slide_backgrounds_json);

  List<String> solidColorNames = [];
  List<String> imagePaths = [];

  // Map of common color names to Flutter Color objects
  static const Map<String, Color> colorMap = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'black': Colors.black,
    'white': Colors.white,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'grey': Colors.grey,
    'pink': Colors.pink,
    'teal': Colors.teal,
    'amber': Colors.amber,
    'brown': Colors.brown,
    'cyan': Colors.cyan,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
  };

  // Convert a color name or hex code string to a Color object
  static Color stringToColor(String value) {
    final cleaned = value.trim().toLowerCase();
    
    // Check in colorMap
    if (colorMap.containsKey(cleaned)) {
      return colorMap[cleaned]!;
    }
    
    // Check if it's a hex code
    try {
      String hex = cleaned.replaceFirst("#", "");
      if (hex.length == 6) {
        hex = "FF$hex";
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      // Return a default color if parsing fails
      return Colors.grey;
    }
  }

  // Load the backgrounds from the slide_backgrounds.ecw.bgs.json file
  Future<void> loadBackgrounds() async {
    try {
      if (!await _bgsFile.exists()) {
        // Create a default backgrounds file with sample data if it doesn't exist
        final defaultData = {
          "solid": [
            "Blue",
            "Red",
            "Green",
            "Black",
            "Purple",
            "Orange",
            "Pink",
            "Lime",
            "Brown",
            "Teal",
            "Indigo",
          ],
          "image": []
        };
        await _bgsFile.writeAsString(jsonEncode(defaultData));
      }

      final content = await _bgsFile.readAsString();
      _parseContent(content);
    } catch (e) {
      print("Error loading backgrounds: $e");
      // Fallback defaults
      solidColorNames = ["Blue", "Red", "Green", "Black", "Purple", "Orange"];
      imagePaths = ["C:/Users/kenka/images/image1.jpg", "C:/Users/kenka/images/image2.jpg"];
    }
  }

  void _parseContent(String content) {
    solidColorNames.clear();
    imagePaths.clear();

    final data = jsonDecode(content);
    if (data is Map) {
      if (data["solid"] is List) {
        solidColorNames = List<String>.from(data["solid"]);
      }
      if (data["image"] is List) {
        imagePaths = List<String>.from(data["image"]);
      }
    }
  }
}
