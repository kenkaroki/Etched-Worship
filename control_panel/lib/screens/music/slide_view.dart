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
  final void Function(int index, Map<String, dynamic> slide) onEditSlide;
  final void Function(int index)? onDeleteSlide;

  const SlideView({
    super.key,
    required this.slides,
    required this.onAddSlide,
    required this.onEditSlide,
    this.onDeleteSlide,
  });

  void _showContextMenu(
    BuildContext context,
    Offset position,
    int index,
    Map<String, dynamic> slide,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(
          value: "edit",
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text("Edit Slide"),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == "edit") onEditSlide(index, slide);
    });
  }

  void _showSlideOptionsDialog(
    BuildContext context,
    int index,
    Map<String, dynamic> slide,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text("Slide Options"),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              onEditSlide(index, slide);
            },
            child: const Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 10),
                Text("Edit Slide"),
              ],
            ),
          ),
          if (onDeleteSlide != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmDelete(context, index);
              },
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Delete Slide", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Slide"),
        content: const Text("Are you sure you want to delete this slide?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDeleteSlide?.call(index);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) {
          final slide = Map<String, dynamic>.from(slides[index]);
          final decoded = decodeSlideText(slide["text"] ?? "");

          return GestureDetector(
            onSecondaryTapDown: (details) =>
                _showContextMenu(context, details.globalPosition, index, slide),
            onDoubleTap: () => onEditSlide(index, slide),
            child: Container(
              height: 100,
              margin: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: buildBackground(
                      slide["background"] ?? "color:#cccccc",
                    ),
                  ),
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
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showSlideOptionsDialog(context, index, slide),
                      ),
                    ),
                  ),
                ],
              ),
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
