import 'dart:io';
import 'package:control_pannel/screens/Bible/bible.dart';
import 'package:control_pannel/screens/create_display/create_display.dart';
import 'package:control_pannel/screens/defaultLftPanel/defaultleftpanelscreen.dart';
import 'package:control_pannel/screens/music/music_page.dart';
import 'package:control_pannel/services/audio_sync_settings_service.dart';
import 'package:control_pannel/services/stack_controller.dart';
import 'package:control_pannel/services/syncronizer.dart';
import 'package:control_pannel/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:control_pannel/services/queue_manager.dart';
import 'package:control_pannel/models/queue_models.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  TabController? _tabController;

  String? _activeQueueName;
  int _activeSlideIndex = -1;

  String? _activeLeftPanelMode;

  WhisperSlideSyncService? _slideSync;
  String? _syncQueueName;

  List<String> get queueNames => QueueManager.queues.keys.toList();

  // ================= CONTROLLER =================

  void _buildController({int initialIndex = 0}) {
    _tabController?.dispose();
    if (queueNames.isEmpty) return;

    _tabController = TabController(
      length: queueNames.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, queueNames.length - 1),
    );
  }

  void _refreshControllerAfterFrame({int? index}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _buildController(initialIndex: index ?? _tabController?.index ?? 0);
      setState(() {});
    });
  }

  void _onQueueChanged() {
    _refreshControllerAfterFrame();
  }

  void _onAudioSyncSettingChanged() {
    if (!AudioSyncSettingsService.isEnabled) {
      if (_syncQueueName != null) _stopSync();
      _slideSync = null;
    }
    setState(() {});
  }

  // ================= QUEUE ACTIONS =================

  void _addQueue(String name) {
    if (name.trim().isEmpty) return;
    QueueManager.createQueue(name.trim());
    setState(() {});
  }

  void _removeSlide(String queueName, int index) {
    setState(() {
      QueueManager.removeSlide(queueName, index);

      if (_activeQueueName == queueName && _activeSlideIndex == index) {
        _activeQueueName = null;
        _activeSlideIndex = -1;
      } else if (_activeQueueName == queueName && index < _activeSlideIndex) {
        _activeSlideIndex--;
      }
    });
  }

  void _jumpToSlide(String queueName, int index) {
    setState(() {
      _activeQueueName = queueName;
      _activeSlideIndex = index;
    });
    final Activeslide = _activeSlide;
    String stackContentFormart = "";
    String content = Activeslide?.content.trim() ?? '';
    List contentSplits = content.split(':');
    if (contentSplits[0].toLowerCase() == 'text' ||
        contentSplits[0].toLowerCase() == 'lyrics') {
      if (contentSplits[0].toLowerCase() == 'lyrics') {
        stackContentFormart = "Text:${content.split('lyrics:')[1]}".replaceAll(
          '\n',
          "<|!&%&!|>",
        );
      } else {
        stackContentFormart = "Text:${content.split('text:')[1]}".replaceAll(
          '\n',
          "<|!&%&!|>",
        );
      }
    } else if (contentSplits[0].toLowerCase() == 'image') {
      stackContentFormart = "Image:${content.split("image:")[1]}";
      stackContentFormart = stackContentFormart.replaceAll('\\', '/');
    } else {
      stackContentFormart = "";
    }

    String Background = Activeslide?.background.trim() ?? '';
    String stackFormart = "$stackContentFormart|||Background:$Background";

    write_to_stack(stackFormart);
  }

  // ================= VOICE SYNC ACTIONS =================

  String _extractSyncText(SlideItem item) {
    String content = item.content.trim();
    List contentSplits = content.split(':');
    String prefix = contentSplits.isNotEmpty
        ? contentSplits[0].toLowerCase()
        : '';

    String rawText;
    if (prefix == 'lyrics') {
      rawText = content.split('lyrics:').length > 1
          ? content.split('lyrics:')[1]
          : '';
    } else if (prefix == 'text') {
      rawText = content.split('text:').length > 1
          ? content.split('text:')[1]
          : '';
    } else {
      rawText = item
          .title; // Fallback to slide title if text/lyrics format isn't explicit
    }

    final colorRegex = RegExp(r'<\|\|COLOR:(.*?)\|\|>');
    rawText = rawText.replaceAll(colorRegex, '').trim();

    return rawText;
  }

  Future<WhisperSlideSyncService> _getOrCreateSlideSync() async {
    if (_slideSync != null) return _slideSync!;

    final binaryPath = await AudioSyncSettingsService.resolveBinaryPath();
    final modelFile = await AudioSyncSettingsService.modelFile;

    _slideSync = WhisperSlideSyncService(
      whisperBinaryPath: binaryPath,
      modelPath: modelFile.path,
    );
    return _slideSync!;
  }

  Future<void> _startSyncForQueue(String queueName) async {
    final queue = QueueManager.queues[queueName] ?? [];
    final slides = queue.map(_extractSyncText).toList();

    setState(() => _syncQueueName = queueName);

    try {
      final sync = await _getOrCreateSlideSync();

      await sync.start(
        slides: slides,
        onSlideChanged: (index, confidence) {
          if (_syncQueueName == queueName) {
            print(
              "[Sync:$queueName] Instantly activating Slide $index (Confidence: $confidence)",
            );
            _jumpToSlide(queueName, index);
          }
        },
        onHeard: (heardText) {
          print("[Sync:$queueName] Heard: \"$heardText\"");
        },
      );
    } catch (e) {
      print("Failed to start slide sync: $e");
      if (mounted) {
        setState(() {
          if (_syncQueueName == queueName) _syncQueueName = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't start voice sync: $e")),
        );
      }
    }
  }

  void _stopSync() {
    _slideSync?.stop();
    setState(() => _syncQueueName = null);
  }

  void _onQueueSyncToggled(String queueName, bool? value) {
    if (!AudioSyncSettingsService.isEnabled) return;

    final enabled = value ?? false;

    if (!enabled) {
      if (_syncQueueName == queueName) _stopSync();
      return;
    }

    if (_syncQueueName != null && _syncQueueName != queueName) {
      _slideSync?.stop();
    }

    _startSyncForQueue(queueName);
  }

  // ================= INIT & DISPOSE =================

  @override
  void initState() {
    super.initState();
    QueueManager.notifier.addListener(_onQueueChanged);
    AudioSyncSettingsService.enabledNotifier.addListener(
      _onAudioSyncSettingChanged,
    );

    if (QueueManager.queues.isEmpty) {
      QueueManager.createQueue("Default Queue");
      QueueManager.addSlide(
        "Default Queue",
        SlideItem(
          title: "Etched Worship",
          content: "text:Etched Worship<||COLOR:#50C878||>",
          background: "color:#000000",
        ),
      );
    }

    _refreshControllerAfterFrame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _jumpToSlide("Default Queue", 0);
      }
    });
  }

  @override
  void dispose() {
    _slideSync?.stop();
    QueueManager.notifier.removeListener(_onQueueChanged);
    AudioSyncSettingsService.enabledNotifier.removeListener(
      _onAudioSyncSettingChanged,
    );
    _tabController?.dispose();
    super.dispose();
  }

  // ================= DIALOG =================

  void _showCreateQueueDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Queue"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Queue Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addQueue(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // ================= ACTIVE SLIDE CALCULATOR =================

  SlideItem? get _activeSlide {
    if (_activeQueueName == null || _activeSlideIndex < 0) return null;
    final queue = QueueManager.queues[_activeQueueName] ?? [];
    if (_activeSlideIndex >= queue.length) return null;
    return queue[_activeSlideIndex];
  }

  // ================= PREVIEW DECORATION PARSER =================

  Widget _buildDynamicBackground(SlideItem slide) {
    final bgString = slide.background.trim();

    if (bgString.startsWith('color:')) {
      final hexColor = bgString
          .replaceAll('color:', '')
          .replaceAll('#', '')
          .trim();
      Color parsedColor = Colors.black;

      try {
        if (hexColor.length == 6) {
          parsedColor = Color(int.parse("0xFF$hexColor"));
        } else if (hexColor.length == 8) {
          parsedColor = Color(int.parse("0x$hexColor"));
        }
      } catch (_) {}
      return Container(color: parsedColor);
    }

    if (bgString.startsWith('image:')) {
      final filePath = bgString.replaceFirst('image:', '').trim();
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white30, size: 30),
            ),
          );
        },
      );
    }

    return Container(color: Colors.white);
  }

  Color _parseTextColor(String rawColorString) {
    try {
      String clean = rawColorString.trim();

      if (clean.contains('#')) {
        clean = clean.replaceAll('#', '');
        if (clean.length == 6) return Color(int.parse("0xFF$clean"));
        if (clean.length == 8) return Color(int.parse("0x$clean"));
      }

      final valueMatch = RegExp(r'0x[0-9a-fA-F]+').firstMatch(clean);
      if (valueMatch != null) {
        return Color(int.parse(valueMatch.group(0)!));
      }
    } catch (_) {}

    return Colors.white;
  }

  Widget _buildSlideContentWidget(SlideItem slide) {
    final content = slide.content.trim();

    if (content.toLowerCase().startsWith('image:')) {
      final filePath = content.substring(6).trim();
      return Positioned.fill(
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white30, size: 30),
          ),
        ),
      );
    }

    String rawText = "";
    if (content.toLowerCase().startsWith('text:')) {
      rawText = content.substring(5).trim();
    } else if (content.toLowerCase().startsWith('lyrics:')) {
      rawText = content.substring(7).trim();
    } else {
      rawText = content;
    }

    Color textColor = Colors.white;

    final colorRegex = RegExp(r'<\|\|COLOR:(.*?)\|\|>');
    final match = colorRegex.firstMatch(rawText);

    if (match != null) {
      final colorString = match.group(1);
      if (colorString != null) {
        textColor = _parseTextColor(colorString);
      }
      rawText = rawText.replaceAll(colorRegex, '').trim();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          rawText,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.w500,
            height: 1.3,
            shadows: const [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black87,
                offset: Offset(1.5, 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanelLivePreview(SlideItem? slide, String currentTabName) {
    if (slide == null) {
      return Container(
        color: AppColors.primaryDark,
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white30, size: 40),
        ),
      );
    }

    return Stack(
      key: ValueKey('mini_${_activeQueueName}_$_activeSlideIndex'),
      children: [
        Positioned.fill(child: _buildDynamicBackground(slide)),
        _buildSlideContentWidget(slide),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "LIVE PREVIEW",
              style: TextStyle(
                color: Colors.green,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(String queueName, int index, SlideItem item) {
    final isActive =
        _activeQueueName == queueName && _activeSlideIndex == index;

    return GestureDetector(
      onTap: () => _jumpToSlide(queueName, index),
      child: Container(
        color: isActive ? AppColors.primaryExtraLight : Colors.transparent,
        child: ListTile(
          leading: isActive
              ? Icon(Icons.play_arrow, color: AppColors.primary)
              : const Icon(Icons.blur_circular_rounded),
          title: Text(
            item.title,
            style: isActive
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  )
                : TextStyle(color: AppColors.tertiary),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'jump') _jumpToSlide(queueName, index);
              if (value == 'remove') _removeSlide(queueName, index);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'jump',
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Jump To", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Remove", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBanner(String queueName) {
    final isSyncing = _syncQueueName == queueName;

    return Container(
      width: double.infinity,
      color: isSyncing ? AppColors.primaryExtraLight : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: isSyncing,
            activeColor: AppColors.primary,
            onChanged: (value) => _onQueueSyncToggled(queueName, value),
          ),
          Icon(
            isSyncing ? Icons.mic : Icons.mic_none,
            size: 18,
            color: isSyncing ? AppColors.primaryDark : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isSyncing
                  ? "Sync with AI — ON, listening for this queue"
                  : "Sync with AI",
              style: TextStyle(
                fontWeight: isSyncing ? FontWeight.bold : FontWeight.normal,
                color: isSyncing ? AppColors.primaryDark : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanelMainContent(TabController tab, SlideItem? slide) {
    if (_activeLeftPanelMode == 'new') return const AddMedia();
    if (_activeLeftPanelMode == 'music') return const MusicPage();
    if (_activeLeftPanelMode == 'Bible') return const BibleReaderPage();

    return const HomeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabController;
    final slide = _activeSlide;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            setState(() => _activeLeftPanelMode = 'home');
          },
        ),
        title: const Text("Etched Worship"),
        centerTitle: true,
      ),
      body: tab == null || queueNames.isEmpty
          ? const Center(child: Text("No Queues"))
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _activeLeftPanelMode = 'new'),
                              child: Text(
                                "New",
                                style: TextStyle(
                                  color: _activeLeftPanelMode == 'new'
                                      ? AppColors.primaryExtraLight
                                      : Colors.white,
                                  fontWeight: _activeLeftPanelMode == 'new'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: () => setState(
                                () => _activeLeftPanelMode = 'Bible',
                              ),
                              child: Text(
                                "Bible",
                                style: TextStyle(
                                  color: _activeLeftPanelMode == 'Bible'
                                      ? AppColors.primaryExtraLight
                                      : Colors.white,
                                  fontWeight: _activeLeftPanelMode == 'Bible'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: () => setState(
                                () => _activeLeftPanelMode = 'music',
                              ),
                              child: Text(
                                "Music",
                                style: TextStyle(
                                  color: _activeLeftPanelMode == 'music'
                                      ? AppColors.primaryExtraLight
                                      : Colors.white,
                                  fontWeight: _activeLeftPanelMode == 'music'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Spacer(),
                            ElevatedButton.icon(
                              onPressed: _showCreateQueueDialog,
                              icon: const Icon(Icons.add),
                              label: const Text("Queue"),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildLeftPanelMainContent(tab, slide)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(color: Colors.black),
                          child: _buildRightPanelLivePreview(
                            slide,
                            queueNames[tab.index],
                          ),
                        ),
                        const SizedBox(height: 10),
                        TabBar(
                          controller: tab,
                          isScrollable: true,
                          tabs: queueNames
                              .map((name) => Tab(text: name))
                              .toList(),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tab,
                            children: queueNames.map((name) {
                              final queue = QueueManager.queues[name] ?? [];
                              return Column(
                                children: [
                                  if (AudioSyncSettingsService.isEnabled)
                                    _buildSyncBanner(name),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: queue.length,
                                      itemBuilder: (context, index) {
                                        return _buildQueueItem(
                                          name,
                                          index,
                                          queue[index],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
