import 'dart:io';
import 'package:control_pannel/models/queue_models.dart';
import 'package:control_pannel/services/queue_manager.dart';
import 'package:control_pannel/themes/app_themes.dart'; // AppColors lives here
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
  // null  = type selector
  // "text"  = text editor mode
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
  // used for saving image slides without a name
  int imgcount = 0;

  bool save_to_diffrent_queue = false;
  String queue_to_save_to = "";
  String Slide_name = "";

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
    await showDialog(
      context: context,
      builder: (_) => SaveDialog(
        slideType: slideType!,
        text: textController.text,
        imagePath: pickedImagePath,
        background: selectedBackground,
        imageCount: imgcount,
        onImageSaved: () {
          setState(() {
            imgcount++;
          });
        },
      ),
    );

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
        // Fallback: subtle green-tinted surface from the theme palette
        background = Container(color: AppColors.lightSurfaceVariant);
      }
    } else {
      background = Container(color: AppColors.lightSurfaceVariant);
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
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: background),
            Center(child: content),
          ],
        ),
      ),
    );
  }

  // ================= TYPE SELECT SCREEN =================
  Widget buildTypeSelector() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── TEXT card ─────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => slideType = "text"),
            child: Container(
              width: 180,
              height: 140,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Primary green for the text-slide option
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.text_fields, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "TEXT SLIDE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── IMAGE card ────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => slideType = "image"),
            child: Container(
              width: 180,
              height: 140,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Slightly darker green distinguishes the two cards
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "IMAGE SLIDE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                  onTap: () =>
                      setState(() => selectedBackground = "color:$hex"),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bg[1],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        // Primary green selection ring; neutral outline otherwise
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightOutline,
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
                  onTap: () =>
                      setState(() => selectedBackground = "image:$path"),
                  child: Container(
                    width: 80,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightOutline,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.grey300),
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
        // AppBar styling (green bg, white fg) is handled by AppBarTheme
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
                        // ── LEFT: editor ─────────────────────────
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
                        // ── RIGHT: background picker ──────────────
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
                              Expanded(child: buildBackgroundSelector()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── PREVIEW ──────────────────────────────────────
                  buildPreview(),
                ],
              ),
            ),
    );
  }
}

class SaveDialog extends StatefulWidget {
  final String slideType;
  final String text;
  final String? imagePath;
  final String? background;
  final int imageCount;
  final VoidCallback onImageSaved;

  const SaveDialog({
    super.key,
    required this.slideType,
    required this.text,
    required this.imagePath,
    required this.background,
    required this.imageCount,
    required this.onImageSaved,
  });

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  late TextEditingController titleController;

  List<String> get queueNames => QueueManager.queues.keys.toList();

  String? selectedQueue;

  @override
  void initState() {
    super.initState();

    selectedQueue = queueNames.isNotEmpty ? queueNames[0] : null;

    String defaultTitle;

    if (widget.slideType == "text") {
      defaultTitle = widget.text.length > 7
          ? "${widget.text.substring(0, 7)}..."
          : widget.text;
    } else {
      defaultTitle = "Image${widget.imageCount + 1}";
    }

    titleController = TextEditingController(text: defaultTitle);
  }

  void save() {
    if (selectedQueue == null) return;

    if (widget.slideType == "text") {
      QueueManager.addSlide(
        selectedQueue!,
        SlideItem(
          title: titleController.text,
          content: "text:${widget.text}",
          background: widget.background ?? "",
        ),
      );
    } else {
      QueueManager.addSlide(
        selectedQueue!,
        SlideItem(
          title: titleController.text,
          content: "image:${widget.imagePath}",
          background: widget.background ?? "",
        ),
      );

      widget.onImageSaved();
    }

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
              initialValue: selectedQueue,
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
