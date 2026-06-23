import 'package:control_pannel/themes/app_themes.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: onPickImage,
          child: const Text("Pick Image"),
        ),
        const SizedBox(height: 10),
        Text(
          pickedImagePath ?? "No image selected",
          style: TextStyle(color: AppThemes().colored_text_light),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onSend,
          child: const Text("Add to Defult Queue"),
        ),
      ],
    );
  }
}
