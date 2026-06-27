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

  @override
  Widget build(BuildContext context) {
    if (content.startsWith("Text:")) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AutoSizeText(
            content.substring(5).replaceAll("<|!&%&!|>", "\n"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
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
