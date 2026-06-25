import 'dart:io';
import 'package:control_pannel/screens/Bible/bible.dart';
import 'package:control_pannel/screens/create_display/create_display.dart';
import 'package:control_pannel/screens/music/music_page.dart';
import 'package:control_pannel/services/stack_controller.dart';
import 'package:control_pannel/themes/app_themes.dart'; // AppColors lives here
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

  // Tracks the currently active (jumped-to) slide
  String? _activeQueueName;
  int _activeSlideIndex = -1;

  // Tracks what to show in the main content area of the LEFT panel
  String? _activeLeftPanelMode;

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

  // ================= QUEUE CHANGED =================

  void _onQueueChanged() {
    _refreshControllerAfterFrame();
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
    if (contentSplits[0].toLowerCase() == 'text') {
      stackContentFormart = "Text:${content.split('text:')[1]}";
    } else if (contentSplits[0].toLowerCase() == 'image') {
      stackContentFormart = "Image:${content.split("image:")[1]}";
      stackContentFormart = stackContentFormart.replaceAll('\\', '/');
    } else {
      stackContentFormart = "";
    }

    print(stackContentFormart);

    String Background = Activeslide?.background.trim() ?? '';
    String stackFormart = "$stackContentFormart,Background:$Background";

    write_to_stack(stackFormart);
  }

  // ================= INIT & DISPOSE =================

  @override
  void initState() {
    super.initState();
    QueueManager.notifier.addListener(_onQueueChanged);

    if (QueueManager.queues.isEmpty) {
      QueueManager.createQueue("Default Queue");
      QueueManager.addSlide(
        "Default Queue",
        SlideItem(
          title: "Etched Worship",
          content: "text:Etched Worship",
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
    QueueManager.notifier.removeListener(_onQueueChanged);
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

    return Container(color: Colors.black);
  }

  // ================= SLIDE CONTENT RENDERER =================

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

    if (content.toLowerCase().startsWith('text:')) {
      final content_ = content.substring(5).trim();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            content_,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.3,
              shadows: [
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          content,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            height: 1.3,
            shadows: [
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

  // ================= MINI PREVIEW COMPONENT =================

  Widget _buildRightPanelLivePreview(SlideItem? slide, String currentTabName) {
    if (slide == null) {
      // No active slide — show branded placeholder using primary dark green
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

  // ================= QUEUE ITEM =================

  Widget _buildQueueItem(String queueName, int index, SlideItem item) {
    final isActive =
        _activeQueueName == queueName && _activeSlideIndex == index;

    return GestureDetector(
      onTap: () => _jumpToSlide(queueName, index),
      child: Container(
        // Active row gets a soft green tint; inactive rows are transparent
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
                    // Dark green text pops on the light-green active background
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

  // ================= LEFT PANEL SWITCH ENGINE =================

  Widget _buildLeftPanelMainContent(TabController tab, SlideItem? slide) {
    if (_activeLeftPanelMode == 'new') return const AddMedia();
    if (_activeLeftPanelMode == 'music') return const MusicPage();
    if (_activeLeftPanelMode == 'Bible') return const BibleReaderPage();

    // 'home' mode and the default fallback share the same splash screen
    return SizedBox(
      width: double.infinity,

      // Subtle light-green surface keeps the panel on-theme without being loud
      child: Center(
        child: Text(
          "Etched Worship",
          style: TextStyle(
            fontSize: 48,
            // Primary green makes the brand name stand out
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ================= MAIN BUILD =================

  @override
  Widget build(BuildContext context) {
    final tab = _tabController;
    final slide = _activeSlide;
    // Pull the live colour scheme so selected-tab indicators, dividers,
    // and any Material widgets automatically adapt to light/dark mode.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // AppBar colours (green bg, white fg) come from AppBarTheme in
        // AppThemes.lightTheme — no manual colour props needed here.
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
                // ================= LEFT PANEL =================
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // ── Top nav toolbar ──────────────────────
                      Container(
                        height: 60,
                        // Solid primary green matches the AppBar
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
                                  // Extra-light green = selected; white = idle
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
                            const Spacer(),
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

                // ================= RIGHT PANEL =================
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      // Subtle green-tinted surface for the queue panel
                      // color: AppColors.lightSurfaceVariant,
                      border: Border(
                        left: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      children: [
                        // ── Live preview thumbnail ────────────────
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
                        // ── Queue tabs ────────────────────────────
                        TabBar(
                          controller: tab,
                          isScrollable: true,
                          // Tab colours come from TabBarTheme in AppThemes
                          tabs: queueNames
                              .map((name) => Tab(text: name))
                              .toList(),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tab,
                            children: queueNames.map((name) {
                              final queue = QueueManager.queues[name] ?? [];
                              return ListView.builder(
                                itemCount: queue.length,
                                itemBuilder: (context, index) {
                                  return _buildQueueItem(
                                    name,
                                    index,
                                    queue[index],
                                  );
                                },
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


