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
      _buildController(initialIndex: index ?? 0);
      setState(() {});
    });
  }

  // ================= QUEUE CHANGED =================

  void _onQueueChanged() {
    _refreshControllerAfterFrame(
      index: queueNames.isEmpty ? 0 : queueNames.length - 1,
    );
  }

  // ================= QUEUE =================

  void _addQueue(String name) {
    if (name.trim().isEmpty) return;
    QueueManager.createQueue(name.trim());
  }

  void _removeSlide(String queueName, int index) {
    setState(() {
      QueueManager.removeSlide(queueName, index);

      // Clear active if the removed slide was active
      if (_activeQueueName == queueName && _activeSlideIndex == index) {
        _activeQueueName = null;
        _activeSlideIndex = -1;
      }
      // Shift active index down if a slide before it was removed
      else if (_activeQueueName == queueName && index < _activeSlideIndex) {
        _activeSlideIndex--;
      }
    });
  }

  void _jumpToSlide(String queueName, int index) {
    setState(() {
      _activeQueueName = queueName;
      _activeSlideIndex = index;
    });
  }

  // ================= MENUS =================

  void _showSlideMenu(
    BuildContext context,
    Offset position,
    String queueName,
    int index,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text("Jump To", style: TextStyle(color: Colors.green)),
            ],
          ),
          onTap: () => _jumpToSlide(queueName, index),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Remove", style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _removeSlide(queueName, index),
        ),
      ],
    );
  }

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    QueueManager.notifier.addListener(_onQueueChanged);

    if (QueueManager.queues.isEmpty) {
      QueueManager.createQueue("Default Queue");
    }

    _refreshControllerAfterFrame();
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

  // ================= ACTIVE SLIDE CONTENT =================

  // Returns the currently jumped-to slide, or null if none
  SlideItem? get _activeSlide {
    if (_activeQueueName == null || _activeSlideIndex < 0) return null;
    final queue = QueueManager.queues[_activeQueueName] ?? [];
    if (_activeSlideIndex >= queue.length) return null;
    return queue[_activeSlideIndex];
  }

  // ================= QUEUE ITEM =================

  Widget _buildQueueItem(String queueName, int index, SlideItem item) {
    final isActive =
        _activeQueueName == queueName && _activeSlideIndex == index;

    return GestureDetector(
      onSecondaryTapDown: (d) =>
          _showSlideMenu(context, d.globalPosition, queueName, index),
      child: Container(
        // Highlight the active slide
        color: isActive ? Colors.green.withOpacity(0.15) : Colors.transparent,
        child: ListTile(
          leading: isActive
              ? const Icon(Icons.play_arrow, color: Colors.green)
              : const Icon(Icons.queue_music),
          title: Text(
            item.title,
            style: isActive
                ? const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final tab = _tabController;
    final slide = _activeSlide;

    return Scaffold(
      appBar: AppBar(title: const Text("Etched Worship"), centerTitle: true),

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
                        color: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/AddDisplay');
                              },
                              child: const Text(
                                "New",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Bible",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/Music');
                              },
                              child: const Text(
                                "Music",
                                style: TextStyle(color: Colors.white),
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

                      // Main display — shows the jumped-to slide or a placeholder
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.black,
                          child: slide == null
                              ? Center(
                                  child: Text(
                                    "Current Queue: ${queueNames[tab.index]}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      slide.content,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= RIGHT PANEL =================
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(
                            queueNames[tab.index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.black12,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.first_page),
                            Icon(Icons.arrow_back),
                            Icon(Icons.arrow_forward),
                            Icon(Icons.last_page),
                          ],
                        ),
                      ),

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
              ],
            ),
    );
  }
}
