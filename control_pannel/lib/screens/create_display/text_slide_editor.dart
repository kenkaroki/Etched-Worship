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
    // colorScheme gives us live access to the theme's green palette
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ──────────────────────────────────────────────
        Text(
          "Slide Text",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // onSurface keeps the label readable in both light and dark mode
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        // ── Text input ─────────────────────────────────────────────────
        // No explicit `border` override — the inputDecorationTheme in
        // AppThemes.lightTheme / darkTheme already sets enabledBorder,
        // focusedBorder, and errorBorder with rounded green styling.
        TextField(
          controller: controller,
          maxLength: 400,
          maxLines: 6,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: "Enter slide text here...",
          ),
        ),
        const Spacer(),
        // ── Add button (styled by ElevatedButtonTheme) ─────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.add),
            label: const Text("Add to Default Queue"),
          ),
        ),
      ],
    );
  }
}
