import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:canvas/services/stack_reader.dart';

void main() {
  runApp(const EtchedWorshipCanvas());
}

class EtchedWorshipCanvas extends StatefulWidget {
  const EtchedWorshipCanvas({super.key});

  @override
  State<EtchedWorshipCanvas> createState() => _EtchedWorshipCanvasState();
}

class _EtchedWorshipCanvasState extends State<EtchedWorshipCanvas> {
  String _content = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadContent();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkForChanges(),
    );
  }

  Future<void> _loadContent() async {
    final content = await readStack();

    if (!mounted) return;

    setState(() {
      _content = content;
    });
  }

  Future<void> _checkForChanges() async {
    final latestContent = await readStack();

    if (latestContent != _content && mounted) {
      setState(() {
        _content = latestContent;
      });
    }
  }

  String get _slideContent => _content.split('|||')[0];
  String get _background => _content.contains('|||Background:')
      ? _content.split('|||Background:')[1]
      : 'color:#FFFFFF';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            BackgroundLayer(background: _background),
            Canvas(content: _slideContent),
          ],
        ),
      ),
    );
  }
}

class BackgroundLayer extends StatelessWidget {
  final String background;

  const BackgroundLayer({required this.background, super.key});

  @override
  Widget build(BuildContext context) {
    if (background.startsWith("image:")) {
      final path = background.substring(6).trim();
      return SizedBox.expand(child: Image.file(File(path), fit: BoxFit.cover));
    }

    if (background.startsWith("color:")) {
      final hex = background.substring(6).trim();
      return Container(color: _hexToColor(hex));
    }

    return Container(color: Colors.white);
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    return Color(int.parse("FF$hex", radix: 16));
  }
}

class Canvas extends StatelessWidget {
  final String content;

  const Canvas({required this.content, super.key});

  // Helper method to parse color strings (Hex or Flutter Color value strings)
  Color _parseTextColor(String rawColorString) {
    try {
      String clean = rawColorString.trim();

      // Handle hex colors (#FFFFFF or FFFFFF or 0xFFFFFFFF)
      if (clean.contains('#')) {
        clean = clean.replaceAll('#', '');
        if (clean.length == 6) return Color(int.parse("0xFF$clean"));
        if (clean.length == 8) return Color(int.parse("0x$clean"));
      }

      // Handle Flutter color string format e.g. Color(0xff4caf50)
      final valueMatch = RegExp(r'0x[0-9a-fA-F]+').firstMatch(clean);
      if (valueMatch != null) {
        return Color(int.parse(valueMatch.group(0)!));
      }
    } catch (_) {}

    return Colors.black; // Fallback text color if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    if (content.startsWith("Text:")) {
      String rawText = content.substring(5).replaceAll("<|!&%&!|>", "\n");
      Color textColor = Colors.black;

      // Regex to detect and extract <||COLOR:<color_value>||>
      final colorRegex = RegExp(r'<\|\|COLOR:(.*?)\|\|>');
      final match = colorRegex.firstMatch(rawText);

      if (match != null) {
        final colorString = match.group(1);
        if (colorString != null) {
          textColor = _parseTextColor(colorString);
        }
        // Strip out the color tag from the visible text output
        rawText = rawText.replaceAll(colorRegex, '').trim();
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AutoSizeText(
            rawText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            minFontSize: 10,
            maxLines: 20,
            wrapWords: true,
          ),
        ),
      );
    }

    if (content.startsWith("Image:")) {
      final path = content.substring(6).trim();
      return SizedBox.expand(
        child: Image.file(File(path), fit: BoxFit.contain),
      );
    }

    return const SizedBox.shrink();
  }
}
