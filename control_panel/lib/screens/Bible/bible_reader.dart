import 'package:flutter/material.dart';
import 'add_to_queue.dart'; // Accesses the static preview container layout

class BibleVerseListView extends StatelessWidget {
  final List<Map<String, dynamic>> verses;
  final String? selectedBookName;
  final int selectedChapter;

  const BibleVerseListView({
    super.key,
    required this.verses,
    required this.selectedBookName,
    required this.selectedChapter,
  });

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) {
      return const Center(child: Text('No verses found'));
    }

    return ListView.builder(
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text('${verse['verse']}. ${verse['text']}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_to_queue') {
                  final referenceText =
                      '${selectedBookName ?? ''} $selectedChapter:${verse['verse']}:\n \n${verse['text']}';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VerseSlidePreviewPage(verseText: referenceText , verse:'${selectedBookName ?? ''} $selectedChapter:${verse['verse']}'),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'add_to_queue',
                  child: Row(
                    children: [
                      Icon(Icons.queue, size: 20),
                      SizedBox(width: 8),
                      Text('Add to Queue'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
