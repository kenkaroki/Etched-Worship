import 'package:flutter/material.dart';

class TextSlideEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final Color selectedTextColor;
  final ValueChanged<Color> onTextColorChanged;

  // Palette of quick-pick text colors.
  static const List<Color> _textColorOptions = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  const TextSlideEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.selectedTextColor,
    required this.onTextColorChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // ── Text input ─────────────────────────────────────────────────
        TextField(
          controller: controller,
          maxLength: 400,
          maxLines: 4,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: "Enter slide text here...",
          ),
        ),
        const SizedBox(height: 12),

        // ── Text Color Selector ─────────────────────────────────────────
        Text(
          "Text Color",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _textColorOptions.map((color) {
            final isSelected = selectedTextColor.value == color.value;

            return GestureDetector(
              onTap: () => onTextColorChanged(color),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),

        const Spacer(),

        // ── Add button ─────────────────────────────────────────────────
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
