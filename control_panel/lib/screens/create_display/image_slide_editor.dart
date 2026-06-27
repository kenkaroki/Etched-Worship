import 'package:control_pannel/themes/app_themes.dart'; // AppColors lives here
import 'package:flutter/material.dart';

class ImageSlideEditor extends StatelessWidget {
  final String? pickedImagePath;
  final VoidCallback onPickImage;
  final VoidCallback onSend;

  const ImageSlideEditor({
    super.key,
    required this.pickedImagePath,
    required this.onPickImage,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    // Pull the live colour scheme so this widget adapts to light/dark mode
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pick-image button (styled by ElevatedButtonTheme) ──────────
        ElevatedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.image_outlined),
          label: const Text("Pick Image"),
        ),
        const SizedBox(height: 10),
        // ── Selected path indicator ────────────────────────────────────
        Row(
          children: [
            Icon(
              pickedImagePath != null
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              size: 16,
              // Green when a file is chosen; muted grey otherwise
              color: pickedImagePath != null
                  ? colorScheme.primary
                  : AppColors.grey500,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                pickedImagePath ?? "No image selected",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // Primary green highlights the chosen path; grey for the placeholder
                  color: pickedImagePath != null
                      ? colorScheme.primary
                      : AppColors.grey500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        // ── Add button (styled by ElevatedButtonTheme) ─────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.add),
            label: const Text("Save"),
          ),
        ),
      ],
    );
  }
}
