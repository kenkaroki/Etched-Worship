import 'package:control_pannel/models/queue_models.dart';
import 'package:flutter/foundation.dart';

class QueueManager {
  static final Map<String, List<SlideItem>> queues = {};

  // Home (and anything else) can listen to this
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static void _notify() => notifier.value++;

  // CREATE QUEUE
  static void createQueue(String name) {
    queues.putIfAbsent(name, () => []);
    _notify();
  }

  // ADD SLIDE
  static void addSlide(String queueName, SlideItem item) {
    queues.putIfAbsent(queueName, () => []);
    queues[queueName]!.add(item);
    _notify();
  }

  // REMOVE SLIDE
  static void removeSlide(String queueName, int index) {
    queues[queueName]?.removeAt(index);
    _notify();
  }

  // GET QUEUE
  static List<SlideItem> getQueue(String name) {
    return queues[name] ?? [];
  }

  // GET ALL QUEUE NAMES
  static List<String> getQueueNames() {
    return queues.keys.toList();
  }
}
