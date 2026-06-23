import 'package:flutter/material.dart';

class TextSlideEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const TextSlideEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Slide Text",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: 400,
          maxLines: 6,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter slide text here...",
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onSend,
          child: const Text("Add to Default Queue"),
        ),
      ],
    );
  }
}
