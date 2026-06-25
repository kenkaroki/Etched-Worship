import 'dart:io';

import 'package:flutter/material.dart';
import 'package:control_pannel/models/queue_models.dart';
import 'package:control_pannel/services/backgrounds.dart';
import 'package:control_pannel/services/queue_manager.dart';

Color hexToColor(String hex) {
  hex = hex.replaceFirst("#", "");
  return Color(int.parse("FF$hex", radix: 16));
}

class VerseSlidePreviewPage extends StatefulWidget {
  final String verseText;
  final String verse;

  const VerseSlidePreviewPage({
    super.key,
    required this.verseText,
    required this.verse,
  });

  @override
  State<VerseSlidePreviewPage> createState() => _VerseSlidePreviewPageState();
}

class _VerseSlidePreviewPageState extends State<VerseSlidePreviewPage> {
  final BackgroundsService _backgroundsService = BackgroundsService();

  List<List<dynamic>> solidBackgrounds = [];
  List<String> imageBackgrounds = [];

  String? selectedBackground;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  Future<void> _loadBackgrounds() async {
    await _backgroundsService.loadBackgrounds();

    if (!mounted) return;

    setState(() {
      solidBackgrounds = _backgroundsService.solidColorNames
          .map((name) => [name, BackgroundsService.stringToColor(name)])
          .toList();

      imageBackgrounds = _backgroundsService.imagePaths;
    });
  }

  Widget _buildPreview() {
    Widget background;

    if (selectedBackground != null) {
      if (selectedBackground!.startsWith("color:")) {
        final hex = selectedBackground!.replaceFirst("color:", "");

        background = Container(color: hexToColor(hex));
      } else if (selectedBackground!.startsWith("image:")) {
        final path = selectedBackground!.replaceFirst("image:", "");

        background = Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        background = Container(color: Colors.black);
      }
    } else {
      background = Container(color: Colors.black);
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: background),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.verseText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundSelector() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (solidBackgrounds.isNotEmpty) ...[
            const Text(
              "Solid Colors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: solidBackgrounds.map((bg) {
                final hex =
                    "#${(bg[1] as Color).value.toRadixString(16).padLeft(8, '0').substring(2)}";

                final isSelected = selectedBackground == "color:$hex";

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBackground = "color:$hex";
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bg[1],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],

          if (imageBackgrounds.isNotEmpty) ...[
            const Text(
              "Images",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imageBackgrounds.map((path) {
                final isSelected = selectedBackground == "image:$path";

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBackground = "image:$path";
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Preview Verse Slide")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Preview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            _buildPreview(),

            const SizedBox(height: 24),

            Text(
              "Slide Background",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(child: _buildBackgroundSelector()),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save to Queue"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SaveDialog(
                      tile: widget.verse,
                      text: widget.verseText,
                      background: selectedBackground ?? "",
                    ),
                  ).then((_) {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveDialog extends StatefulWidget {
  final String tile;
  final String text;
  final String? background;

  const SaveDialog({super.key, required this.text, required this.background , required this.tile});

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  late TextEditingController titleController;

  List<String> get queueNames => QueueManager.getQueueNames();

  String? selectedQueue;

  @override
  void initState() {
    super.initState();

    selectedQueue = queueNames.isNotEmpty ? queueNames[0] : null;

    titleController = TextEditingController(text: widget.tile);
  }

  void save() {
    if (selectedQueue == null) return;

    QueueManager.addSlide(
      selectedQueue!,
      SlideItem(
        title: titleController.text,
        content: "text:${widget.text}",
        background: widget.background ?? "",
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Slide"),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Slide Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedQueue,
              decoration: const InputDecoration(
                labelText: "Queue",
                border: OutlineInputBorder(),
              ),
              items: queueNames.map((queue) {
                return DropdownMenuItem(value: queue, child: Text(queue));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedQueue = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: save, child: const Text("Save")),
      ],
    );
  }
}
