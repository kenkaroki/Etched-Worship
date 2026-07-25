import 'package:control_pannel/models/queue_models.dart';
import 'package:control_pannel/services/queue_manager.dart';
import 'package:flutter/material.dart';
import 'package:control_pannel/services/music_services.dart';
import 'folder_view.dart';
import 'slide_editor.dart';
import 'slide_view.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final MusicService _musicService = MusicService();

  List<Map<String, dynamic>> folders = [];
  Map<String, dynamic>? currentFolder;

  bool creatingSlide = false;

  // Tracks which slide is being edited (null when creating a new one).
  int? _editingSlideIndex;
  Map<String, dynamic>? _editingSlide;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ================= LOAD DATA =================

  Future<void> _loadData() async {
    final loadedFolders = await _musicService.loadData();

    setState(() {
      folders = loadedFolders;

      if (currentFolder != null) {
        final match = folders.firstWhere(
          (f) => f["name"] == currentFolder!["name"],
          orElse: () => <String, dynamic>{},
        );

        if (match.isNotEmpty) {
          currentFolder = match;
        } else {
          currentFolder = null;
        }
      }
    });
  }

  // ================= FOLDER ACTIONS =================

  void _openFolder(Map<String, dynamic> folder) {
    setState(() {
      currentFolder = folder;
      creatingSlide = false;
    });
  }

  void _createFolder() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Folder"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _createCustomFolder(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _createCustomFolder(String name) {
    setState(() {
      folders.add({"name": name, "slides": []});

      folders.sort(
        (a, b) => a["name"].toString().compareTo(b["name"].toString()),
      );
    });

    _musicService.saveData(folders);
  }

  // ================= QUEUE ACTION =================

  void _createSongQueue(Map<String, dynamic> folder) {
    if (folder.isEmpty) return;

    final folderName = folder["name"] as String;
    final slides = List<Map<String, dynamic>>.from(folder["slides"] ?? []);

    QueueManager.createQueue(folderName);

    for (final slide in slides) {
      final text = (slide["text"] ?? "").toString();
      debugPrint(text.split("<||COLOR")[0]);
      final title_text = text.split("<||COLOR")[0];
      QueueManager.addSlide(
        folderName,
        SlideItem(
          title: title_text
              .substring(0, title_text.length > 5 ? 10 : title_text.length)
              .padRight(3, '.....'),
          content: "lyrics:$text",
          background: slide["background"] ?? "color:#cccccc",
        ),
      );
    }
  }

  // ================= SLIDE ACTIONS =================

  void _handleBack() {
    setState(() {
      if (creatingSlide) {
        creatingSlide = false;
        _editingSlideIndex = null;
        _editingSlide = null;
      } else {
        currentFolder = null;
      }
    });
  }

  void _addSlide() {
    setState(() {
      creatingSlide = true;
      _editingSlideIndex = null;
      _editingSlide = null;
    });
  }

  void _editSlide(int index, Map<String, dynamic> slide) {
    setState(() {
      creatingSlide = true;
      _editingSlideIndex = index;
      _editingSlide = slide;
    });
  }

  void _saveSlide(String text, String? background) async {
    if (currentFolder == null) return;

    final slides = List<Map<String, dynamic>>.from(
      currentFolder!["slides"] ?? [],
    );

    if (_editingSlideIndex != null &&
        _editingSlideIndex! >= 0 &&
        _editingSlideIndex! < slides.length) {
      // Update existing slide in place, preserving its id.
      final existing = slides[_editingSlideIndex!];
      slides[_editingSlideIndex!] = {
        ...existing,
        "text": text,
        "background": background ?? "color:#cccccc",
      };
    } else {
      slides.add({
        "id": slides.length + 1,
        "text": text,
        "background": background ?? "color:#cccccc",
      });
    }

    setState(() {
      currentFolder!["slides"] = slides;
      creatingSlide = false;
      _editingSlideIndex = null;
      _editingSlide = null;
    });

    await _musicService.saveData(folders);
  }

  void _deleteSlide(int index) async {
    if (currentFolder == null) return;

    final slides = List<Map<String, dynamic>>.from(
      currentFolder!["slides"] ?? [],
    );

    if (index < 0 || index >= slides.length) return;

    setState(() {
      slides.removeAt(index);
      currentFolder!["slides"] = slides;
    });

    await _musicService.saveData(folders);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentFolder == null
              ? "Music Folders"
              : currentFolder!["name"] ?? "",
        ),
        leading: currentFolder != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBack,
              )
            : null,
      ),

      // FAB only shows on the folder list screen
      floatingActionButton: currentFolder == null
          ? FloatingActionButton(
              onPressed: _createFolder,
              tooltip: "Create Folder",
              child: const Icon(Icons.create_new_folder),
            )
          : null,

      body: currentFolder == null
          ? FolderView(
              folders: folders,
              onFolderTap: _openFolder,
              onCreateFolder: _createFolder,
              // Receives the right-clicked folder directly — no currentFolder needed
              onCreateSongQueue: (folder) => _createSongQueue(folder),
            )
          : (creatingSlide
                ? SlideEditor(
                    onSave: _saveSlide,
                    initialText: _editingSlide?["text"] as String?,
                    initialBackground: _editingSlide?["background"] as String?,
                  )
                : SlideView(
                    slides: currentFolder!["slides"] ?? [],
                    onAddSlide: _addSlide,
                    onEditSlide: _editSlide,
                    onDeleteSlide: _deleteSlide,
                  )),
    );
  }
}
