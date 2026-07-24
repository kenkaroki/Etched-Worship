import 'dart:io';
import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.replaceFirst("#", "");
  return Color(int.parse("FF$hex", radix: 16));
}

// Matches a trailing "<||COLOR: #rrggbb||>" tag appended to slide text.
final RegExp _colorTagPattern = RegExp(
  r'<\|\|COLOR:\s*(#[0-9a-fA-F]{6})\|\|>$',
);

/// Encodes [text] with [color] into the storage format:
/// "text<||COLOR: #rrggbb||>"
String encodeSlideText(String text, Color color) {
  final hex = "#${color.value.toRadixString(16).substring(2)}";
  return "$text<||COLOR: $hex||>";
}

/// Decodes a stored slide string back into its raw text and Color.
/// Falls back to white if no color tag is present.
({String text, Color color}) decodeSlideText(String raw) {
  final match = _colorTagPattern.firstMatch(raw);
  if (match == null) {
    return (text: raw, color: Colors.white);
  }
  final hex = match.group(1)!;
  final cleanText = raw.substring(0, match.start);
  return (text: cleanText, color: hexToColor(hex));
}

Widget buildBackground(String bg) {
  if (bg.startsWith("color:")) {
    final hex = bg.replaceFirst("color:", "");
    return Container(color: hexToColor(hex));
  }

  if (bg.startsWith("image:")) {
    final path = bg.replaceFirst("image:", "");
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
      ),
    );
  }

  return Container(color: Colors.grey);
}

class SlideView extends StatelessWidget {
  final List<dynamic> slides;
  final VoidCallback onAddSlide;

  const SlideView({super.key, required this.slides, required this.onAddSlide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) {
          final slide = slides[index];
          final decoded = decodeSlideText(slide["text"] ?? "");

          return Container(
            height: 100,
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: [
                buildBackground(slide["background"] ?? "color:#cccccc"),
                Center(
                  child: Text(
                    decoded.text,
                    style: TextStyle(
                      color: decoded.color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddSlide,
        child: const Icon(Icons.add),
      ),
    );
  }
}
