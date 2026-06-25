import 'package:flutter/material.dart';

class FolderView extends StatefulWidget {
  final List<Map<String, dynamic>> folders;
  final Function(Map<String, dynamic> folder) onFolderTap;

  final VoidCallback onCreateFolder;
  final Function(Map<String, dynamic> folder)
  onCreateSongQueue; // ← now receives the folder

  const FolderView({
    super.key,
    required this.folders,
    required this.onFolderTap,
    required this.onCreateFolder,
    required this.onCreateSongQueue,
  });

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return widget.folders;
    return widget.folders.where((f) {
      return f["name"].toString().toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  // Now takes the specific folder that was right-clicked
  void _showFolderMenu(Offset position, Map<String, dynamic> folder) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          child: const Text("Create Song Queue"),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 10),
              () => widget.onCreateSongQueue(folder), // ← pass folder directly
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search...",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        Expanded(
          child: ListView(
            children: _filtered.map((f) {
              return GestureDetector(
                // Right-click on this specific folder tile only
                onSecondaryTapDown: (d) => _showFolderMenu(d.globalPosition, f),
                onLongPressStart: (d) => _showFolderMenu(d.globalPosition, f),
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(f["name"] ?? ""),
                  onTap: () => widget.onFolderTap(f),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
