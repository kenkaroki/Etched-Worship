import 'dart:io';
import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.replaceFirst("#", "");
  return Color(int.parse("FF$hex", radix: 16));
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

  const SlideView({
    super.key,
    required this.slides,
    required this.onAddSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) {
          final slide = slides[index];

          return Container(
            height: 100,
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: [
                buildBackground(slide["background"] ?? "color:#cccccc"),
                Center(
                  child: Text(
                    slide["text"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
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
