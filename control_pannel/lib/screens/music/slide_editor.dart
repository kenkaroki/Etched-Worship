import 'dart:io';

import 'package:flutter/material.dart';
import 'package:control_pannel/services/backgrounds.dart';
import 'slide_view.dart'; // import buildBackgroundWithTheme

class SlideEditor extends StatefulWidget {
  final Function(String text, String? background) onSave;

  const SlideEditor({super.key, required this.onSave});

  @override
  State<SlideEditor> createState() => _SlideEditorState();
}

class _SlideEditorState extends State<SlideEditor> {
  final TextEditingController _slideTextController = TextEditingController();
  String? _selectedBackground;

  final BackgroundsService _backgroundsService = BackgroundsService();
  List<Color> bgColors = [];
  List<String> bgImages = [];

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  Future<void> _loadBackgrounds() async {
    await _backgroundsService.loadBackgrounds();
    if (mounted) {
      setState(() {
        bgColors = _backgroundsService.solidColorNames
            .map((name) => BackgroundsService.stringToColor(name))
            .toList();
        bgImages = _backgroundsService.imagePaths;
      });
    }
  }

  @override
  void dispose() {
    _slideTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Create Slide",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: Row(
            children: [
              // TEXT
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _slideTextController,
                    maxLength: 400,
                    maxLines: null,
                    expands: true,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter lyrics...",
                    ),
                  ),
                ),
              ),

              // BACKGROUNDS
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Solid Colors", style: Theme.of(context).textTheme.bodyMedium),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: bgColors.map((c) {
                          final hex = "#${c.value.toRadixString(16).substring(2)}";

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBackground = "color:$hex";
                              });
                            },
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: c,
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 15),

                      Text("Images", style: Theme.of(context).textTheme.bodyMedium),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: bgImages.map((img) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBackground = "image:$img";
                              });
                            },
                            child: Container(
                              width: 90,
                              height: 60,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Image.file(File(img), fit: BoxFit.cover),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // PREVIEW 
        Center(
          child: Container(
            width: 260,
            height: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Stack(
              children: [
                if (_selectedBackground != null)
                  buildBackgroundWithTheme(context, _selectedBackground!)
                else
                  Container(color: Theme.of(context).cardColor),

                Center(
                  child: Text(
                    _slideTextController.text.isEmpty ? "Preview" : _slideTextController.text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 12),
          child: ElevatedButton(
            onPressed: () {
              widget.onSave(_slideTextController.text, _selectedBackground);
            },
            child: const Text("Save Slide"),
          ),
        ),
      ],
    );
  }
}
