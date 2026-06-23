import 'dart:io';
import 'package:control_pannel/models/queue_models.dart';
import 'package:control_pannel/services/queue_manager.dart';
import 'package:control_pannel/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:control_pannel/services/create_display_service.dart';
import 'package:control_pannel/services/backgrounds.dart';
import 'text_slide_editor.dart';
import 'image_slide_editor.dart';

Color hexToColor(String hex) {
  hex = hex.replaceFirst("#", "");
  return Color(int.parse("FF$hex", radix: 16));
}

class AddMedia extends StatefulWidget {
  const AddMedia({super.key});

  @override
  State<AddMedia> createState() => _AddMediaState();
}

class _AddMediaState extends State<AddMedia> {
  final DisplayService _displayService = DisplayService();

  // ================= STEP CONTROL =================
  // null = show only type selector
  // "text" = text editor mode
  // "image" = image editor mode
  String? slideType;

  // ================= TEXT =================
  final TextEditingController textController = TextEditingController();

  // ================= IMAGE =================
  String? pickedImagePath;

  // ================= BACKGROUND =================
  String? selectedBackground;

  final BackgroundsService _backgroundsService = BackgroundsService();
  List<List<dynamic>> solidBackgrounds = [];
  List<String> imageBackgrounds = [];

  int imgcount = 0;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  Future<void> _loadBackgrounds() async {
    await _backgroundsService.loadBackgrounds();
    if (mounted) {
      setState(() {
        solidBackgrounds = _backgroundsService.solidColorNames
            .map((name) => [name, BackgroundsService.stringToColor(name)])
            .toList();
        imageBackgrounds = _backgroundsService.imagePaths;
      });
    }
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final path = await _displayService.pickImage();
    if (path != null) {
      setState(() {
        pickedImagePath = path;
      });
    }
  }

  // ================= RESET (GO BACK) =================
  void reset() {
    setState(() {
      slideType = null;
      textController.clear();
      pickedImagePath = null;
      selectedBackground = null;
    });
  }

  // ================= SEND =================
  Future<void> add_to_que() async {
    print("TYPE: $slideType");
    print("TEXT: ${textController.text}");
    print("IMAGE: $pickedImagePath");
    print("BACKGROUND: $selectedBackground");

    if (slideType == 'text') {
      QueueManager.addSlide(
        "Default Queue",
        SlideItem(
          title: textController.text.length > 6
              ? '${textController.text.substring(0, 6)}...'
              : textController.text,
          content: 'text:${textController.text}',
          background: '$selectedBackground',
        ),
      );
    }
    if (slideType == 'image') {
      QueueManager.addSlide(
        "Default Queue",
        SlideItem(
          title: "Image${imgcount +1 }",
          content: 'image:${pickedImagePath}',
          background: '$selectedBackground',
        ),
      );
      setState(() {
        imgcount += 1;
      });
    }
  }

  // ================= PREVIEW =================
  Widget buildPreview() {
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
        background = Container(color: AppThemes().containers_cards_light);
      }
    } else {
      background = Container(color: AppThemes().containers_cards_light);
    }

    Widget content;

    if (slideType == "image" && pickedImagePath != null) {
      content = Image.file(File(pickedImagePath!), fit: BoxFit.contain);
    } else {
      content = Center(
        child: Text(
          textController.text.isEmpty ? "Preview" : textController.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 6, color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Stack(
        children: [
          background,
          Center(child: content),
        ],
      ),
    );
  }

  // ================= TYPE SELECT SCREEN =================
  Widget buildTypeSelector() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TEXT CARD
          GestureDetector(
            onTap: () {
              setState(() {
                slideType = "text";
              });
            },
            child: Container(
              width: 180,
              height: 140,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "TEXT SLIDE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // IMAGE CARD
          GestureDetector(
            onTap: () {
              setState(() {
                slideType = "image";
              });
            },
            child: Container(
              width: 180,
              height: 140,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "IMAGE SLIDE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BACKGROUND SELECTOR =================
  Widget buildBackgroundSelector() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (solidBackgrounds.isNotEmpty) ...[
            const Text(
              "Solid Colors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 5),
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
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        bg[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
          ],
          if (imageBackgrounds.isNotEmpty) ...[
            const Text(
              "Images",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 5),
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
                    width: 80,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            color: Colors.black54,
                            child: Text(
                              path.split(RegExp(r'[/\\]')).last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Media"),
        centerTitle: true,
        leading: slideType != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: reset)
            : null,
      ),
      body: slideType == null
          ? buildTypeSelector()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // LEFT
                        Expanded(
                          flex: 2,
                          child: slideType == "text"
                              ? TextSlideEditor(
                                  controller: textController,
                                  onChanged: (_) => setState(() {}),
                                  onSend: add_to_que,
                                )
                              : ImageSlideEditor(
                                  pickedImagePath: pickedImagePath,
                                  onPickImage: pickImage,
                                  onSend: add_to_que,
                                ),
                        ),
                        const SizedBox(width: 10),
                        // RIGHT
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Backgrounds",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildBackgroundSelector(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // PREVIEW
                  buildPreview(),
                ],
              ),
            ),
    );
  }
}
