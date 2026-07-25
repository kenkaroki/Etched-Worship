import 'dart:convert';
import 'dart:io';
import 'package:control_pannel/controllers/files.dart';
import 'package:flutter/material.dart';

class BackgroundsService {
  final File _bgsFile = File(slide_backgrounds_json);
  final File _custombgsFile = File(custom_slides_backgrounds_json);

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
          "image": [],
        };
        if (!await _bgsFile.parent.exists()) {
          await _bgsFile.parent.create(recursive: true);
        }

        await _bgsFile.writeAsString(jsonEncode(defaultData));
      }

      if (!await _custombgsFile.exists()) {
        if (!await _custombgsFile.parent.exists()) {
          await _custombgsFile.parent.create(recursive: true);
        }
        await _custombgsFile.writeAsString(
          jsonEncode({"custom_backgrounds": []}),
        );
      }

      solidColorNames.clear();
      imagePaths.clear();

      // Load built-in backgrounds
      final builtIn =
          jsonDecode(await _bgsFile.readAsString()) as Map<String, dynamic>;

      if (builtIn["solid"] is List) {
        solidColorNames = List<String>.from(builtIn["solid"]);
      }

      if (builtIn["image"] is List) {
        imagePaths.addAll(List<String>.from(builtIn["image"]));
      }

      // Load custom backgrounds
      final custom =
          jsonDecode(await _custombgsFile.readAsString())
              as Map<String, dynamic>;

      if (custom["custom_backgrounds"] is List) {
        imagePaths.addAll(List<String>.from(custom["custom_backgrounds"]));
      }
    } catch (e) {
      print("Error loading backgrounds: $e");

      solidColorNames = ["Blue", "Red", "Green", "Black", "Purple", "Orange"];

      imagePaths = [];
    }
  }

//   void _parseContent(String content) {
//     solidColorNames.clear();
//     imagePaths.clear();

//     final data = jsonDecode(content);
//     if (data is Map) {
//       if (data["solid"] is List) {
//         solidColorNames = List<String>.from(data["solid"]);
//       }
//       if (data["image"] is List) {
//         imagePaths = List<String>.from(data["image"]);
//       }
//       if (data["custom_backgrounds"] is List) {
//         imagePaths = List<String>.from(data["custom_backgrounds"]);
//       }
//     }
//   }
}
