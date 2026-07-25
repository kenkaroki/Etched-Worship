import 'dart:io';
import 'package:flutter/material.dart';
import 'package:control_pannel/services/addcustombackground.dart';
import 'package:control_pannel/controllers/files.dart';

class CustomBackgroundUploadPage extends StatefulWidget {
  const CustomBackgroundUploadPage({super.key});

  @override
  State<CustomBackgroundUploadPage> createState() =>
      _CustomBackgroundUploadPageState();
}

class _CustomBackgroundUploadPageState
    extends State<CustomBackgroundUploadPage> {
  bool _isSaving = false;
  String? _errorMessage;
  String? _selectedImagePath;

  Future<String?> _showFileNameDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Name this background"),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 250,
                      height: 180,
                      child: Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  "Enter a name for this background:",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Example: Sunday Worship",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("Add Background"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Background Added"),
          content: const Text(
            "The background was added successfully.\n\nWhat would you like to do next?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, "back");
              },
              child: const Text("Go Back"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "upload");
              },
              child: const Text("Upload Another Background"),
            ),
          ],
        );
      },
    );

    if (action == "back") {
      Navigator.pop(context);
    }

    if (action == "upload") {
      setState(() {
        _selectedImagePath = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickAndSaveBackground() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _selectedImagePath = null;
    });

    try {
      final selected = await BackgroundManager.pickImage();

      if (selected == null) {
        setState(() {
          _isSaving = false;
        });
        return;
      }

      setState(() {
        _selectedImagePath = selected;
      });

      final fileName = await _showFileNameDialog();

      if (fileName == null || fileName.isEmpty) {
        setState(() {
          _isSaving = false;
          _selectedImagePath = null;
        });
        return;
      }

      await BackgroundManager.addBackground(
        selectedFilePath: selected,
        destinationFolder: custom_backgrounds,
        configFilePath: custom_slides_backgrounds_json,
        fileName: fileName,
      );

      setState(() {
        _isSaving = false;
        _selectedImagePath = null;
      });

      await _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
        _selectedImagePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Custom Background")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Select an image to add as a custom background.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _pickAndSaveBackground,
                icon: const Icon(Icons.image),
                label: Text(_isSaving ? "Saving..." : "Choose Image"),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
