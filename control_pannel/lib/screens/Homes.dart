import 'dart:io';
import 'package:control_pannel/screens/create_display/create_display.dart';
import 'package:control_pannel/screens/music/music_page.dart';
import 'package:control_pannel/services/stack_controller.dart';
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
    String stack_content_formart = "";
    String content = Activeslide?.content.trim() ?? '';
    // print("Content:  "+content);
    List content_splits = content.split(':');
    if (content_splits[0].toLowerCase() == 'text') {
      stack_content_formart = "Text:${content.split('text:')[1]}";
    } else if (content_splits[0].toLowerCase() == 'image') {
      stack_content_formart = "Image:${content.split("image:")[1]}";
      //  change backslashes in windows to foward slashes
      stack_content_formart = stack_content_formart.replaceAll('\\', '/');
    } else {
      stack_content_formart = "";
    }

    print(stack_content_formart);

    String Background = Activeslide?.background.trim() ?? '';
    String Stack_formart = "$stack_content_formart,Background:$Background";

    write_to_stack(Stack_formart);
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

    // Automatically jump to first item in default queue
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
      final filePath = content.substring(6).trim(); // strip 'image:' prefix
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
      final content_ = content.substring(5).trim(); // strip 'image:' prefix
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

    // defult text
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
      return Container(
        color: AppThemes().appbar_light,
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white30, size: 40),
        ),
      );
    }

    return Stack(
      key: ValueKey('mini_${_activeQueueName}_$_activeSlideIndex'),
      children: [
        // Background layer (color or image)
        Positioned.fill(child: _buildDynamicBackground(slide)),
        // Content layer — text OR image depending on content prefix
        _buildSlideContentWidget(slide),
        // LIVE PREVIEW badge
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
        color: isActive ? AppThemes().appbar_light : Colors.transparent,
        child: ListTile(
          leading: isActive
              ? Icon(Icons.play_arrow, color: AppThemes().colored_icon_light)
              : const Icon(Icons.blur_circular_rounded),
          title: Text(
            item.title,
            style: isActive
                ?  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppThemes().Selected_text_light,
                  )
                : null,
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
    if (_activeLeftPanelMode == 'Bible')
      return const Center(child: Text("app"));
    if (_activeLeftPanelMode == 'home') {
      return Container(
        width: double.infinity,
        color: AppThemes().queue_light,
        child:  Center(
          child: Text(
            "Etched Worship",
            style: TextStyle(
              fontSize: 48,
              color: AppThemes().colored_text_light,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      color: AppThemes().queue_light,
      child: Center(
        child: Text(
          "Etched Worship",
          style: TextStyle(
            fontSize: 48,
            color: AppThemes().colored_text_light,
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
                // ================= LEFT PANEL =================
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: AppThemes().appbar_light,
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
                                      ? AppThemes().Selected_text_light
                                      : Colors.white,
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
                                      ? AppThemes().Selected_text_light
                                      : Colors.white,
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
                                      ? AppThemes().Selected_text_light
                                      : Colors.white,
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
                      color:  AppThemes().queue_light,
                      border: Border(left: BorderSide(color: Colors.black26)),
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
