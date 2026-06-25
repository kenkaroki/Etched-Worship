import 'package:flutter/material.dart';
import 'package:control_pannel/services/bible_database.dart';
import 'bible_reader.dart'; // Import the split reader component

class BibleReaderPage extends StatefulWidget {
  const BibleReaderPage({super.key});

  @override
  State<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends State<BibleReaderPage> {
  String? translationId;
  String testament = 'Old';
  bool loading = true;
  bool installed = false;
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> verses = [];
  int? selectedBookId;
  String? selectedBookName;
  int selectedChapter = 1;
  int chapterCount = 1;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      loading = true;
    });

    translationId = null;
    installed = false;
    books.clear();
    verses.clear();

    for (final translation in BibleDatabase.translations) {
      if (await BibleDatabase.instance.isInstalled(translation.id)) {
        translationId = translation.id;
        installed = true;
        break;
      }
    }

    if (installed && translationId != null) {
      await loadBooks();
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> installCurrentTranslation() async {
    if (translationId == null) return;

    setState(() {
      loading = true;
    });

    try {
      final translation = BibleDatabase.translations.firstWhere(
        (e) => e.id == translationId,
      );

      await BibleDatabase.instance.installTranslation(translation);
      installed = true;
      await loadBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${translation.name} installed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> rebuildDatabase() async {
    if (translationId == null) return;

    setState(() {
      loading = true;
    });

    try {
      await BibleDatabase.instance.rebuildDatabase(translationId!);
      await loadBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database rebuilt successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadBooks() async {
    if (translationId == null) return;

    books = await BibleDatabase.instance.getBooks(translationId!, testament);

    if (books.isNotEmpty) {
      selectedBookId = books.first['id'] as int;
      selectedBookName = books.first['name'] as String;
      selectedChapter = 1;
      chapterCount = await BibleDatabase.instance.getChapterCount(
        translationId!,
        selectedBookId!,
      );
      await loadVerses();
    } else {
      selectedBookId = null;
      selectedBookName = null;
      verses.clear();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadVerses() async {
    if (translationId == null || selectedBookId == null) {
      verses.clear();
      return;
    }

    verses = await BibleDatabase.instance.getVerses(
      translationId!,
      selectedBookId!,
      selectedChapter,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> changeTranslation(String id) async {
    translationId = id;
    installed = await BibleDatabase.instance.isInstalled(id);
    books.clear();
    verses.clear();
    selectedBookId = null;
    selectedBookName = null;

    if (installed) {
      await loadBooks();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> changeTestament(String value) async {
    testament = value;
    await loadBooks();
  }

  Future<void> changeBook(int bookId) async {
    selectedBookId = bookId;
    final book = books.firstWhere((e) => e['id'] == bookId);
    selectedBookName = book['name'] as String;
    selectedChapter = 1;
    chapterCount = await BibleDatabase.instance.getChapterCount(
      translationId!,
      bookId,
    );
    await loadVerses();
  }

  Future<void> changeChapter(int chapter) async {
    selectedChapter = chapter;
    await loadVerses();
  }

  Widget buildInstaller() {
    final selectedTranslation = translationId == null
        ? null
        : BibleDatabase.translations.firstWhere((e) => e.id == translationId);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'No Bible Installed',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose a translation and install it before reading.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: translationId,
                    decoration: const InputDecoration(
                      labelText: 'Translation',
                      border: OutlineInputBorder(),
                    ),
                    items: BibleDatabase.translations.map((translation) {
                      return DropdownMenuItem<String>(
                        value: translation.id,
                        child: Text(
                          '${translation.name} (${translation.language})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        translationId = value;
                      });
                    },
                  ),
                  if (selectedTranslation != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              selectedTranslation.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(selectedTranslation.language),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: translationId == null
                          ? null
                          : installCurrentTranslation,
                      icon: const Icon(Icons.download),
                      label: const Text('Download & Install'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildReaderControls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 280,
            child: DropdownButtonFormField<String>(
              value: translationId,
              decoration: const InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
              items: BibleDatabase.translations.map((translation) {
                return DropdownMenuItem<String>(
                  value: translation.id,
                  child: Text(translation.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                changeTranslation(value);
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: testament,
              decoration: const InputDecoration(
                labelText: 'Testament',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Old', child: Text('Old Testament')),
                DropdownMenuItem(value: 'New', child: Text('New Testament')),
              ],
              onChanged: (value) {
                if (value == null) return;
                changeTestament(value);
              },
            ),
          ),
          if (books.isNotEmpty)
            SizedBox(
              width: 250,
              child: DropdownButtonFormField<int>(
                value: selectedBookId,
                decoration: const InputDecoration(
                  labelText: 'Book',
                  border: OutlineInputBorder(),
                ),
                items: books.map((book) {
                  return DropdownMenuItem<int>(
                    value: book['id'] as int,
                    child: Text(book['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  changeBook(value);
                },
              ),
            ),
          if (books.isNotEmpty)
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<int>(
                value: selectedChapter,
                decoration: const InputDecoration(
                  labelText: 'Chapter',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(chapterCount, (i) => i + 1).map((chapter) {
                  return DropdownMenuItem<int>(
                    value: chapter,
                    child: Text(chapter.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  changeChapter(value);
                },
              ),
            ),
          ElevatedButton.icon(
            onPressed: rebuildDatabase,
            icon: const Icon(Icons.refresh),
            label: const Text('Rebuild DB'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (!installed) {
      body = buildInstaller();
    } else {
      body = Column(
        children: [
          buildReaderControls(),
          Expanded(
            child: BibleVerseListView(
              verses: verses,
              selectedBookName: selectedBookName,
              selectedChapter: selectedChapter,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bible Reader')),
      body: body,
    );
  }
}
