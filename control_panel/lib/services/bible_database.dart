import 'dart:convert';
import 'dart:io';

import 'package:control_pannel/controllers/files.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class BibleTranslation {
  final String id;
  final String name;
  final String language;
  final String url;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.language,
    required this.url,
  });
}

class BibleDatabase {
  BibleDatabase._();

  static final BibleDatabase instance = BibleDatabase._();

  /// Add more translations here.
  static const List<BibleTranslation> translations = [
    BibleTranslation(
      id: 'kjv',
      name: 'King James Version',
      language: 'English',
      url:
          'https://raw.githubusercontent.com/scrollmapper/bible_databases/master/sources/en/KJV/KJV.json',
    ),
    BibleTranslation(
      id: 'mkjv',
      name: 'Mordern King James Version',
      language: 'English',
      url:
          'https://raw.githubusercontent.com/scrollmapper/bible_databases/master/sources/en/MKJV/MKJV.json',
    ),
    BibleTranslation(
      id: 'asv',
      name: 'American Standard Version',
      language: 'English',
      url:
          'https://raw.githubusercontent.com/scrollmapper/bible_databases/master/sources/en/ASV/ASV.json',
    ),
  ];

  Future<Directory> getBibleDirectory() async {
    

    final dir = Directory(bibles_folder);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  Future<String> getJsonPath(String translationId) async {
    final dir = await getBibleDirectory();

    return p.join(dir.path, '$translationId.json');
  }

  Future<String> getDbPath(String translationId) async {
    final dir = await getBibleDirectory();

    return p.join(dir.path, '$translationId.db');
  }

  Future<List<BibleTranslation>> getInstalledTranslations() async {
    final installed = <BibleTranslation>[];

    for (final translation in translations) {
      if (await isInstalled(translation.id)) {
        installed.add(translation);
      }
    }

    return installed;
  }

  Future<bool> isInstalled(String translationId) async {
    final dbPath = await getDbPath(translationId);

    return File(dbPath).exists();
  }

  Future<void> downloadTranslation(BibleTranslation translation) async {
    final response = await http.get(Uri.parse(translation.url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download ${translation.name}');
    }

    final jsonPath = await getJsonPath(translation.id);

    final file = File(jsonPath);

    await file.writeAsBytes(response.bodyBytes);
  }

  Future<void> installTranslation(BibleTranslation translation) async {
    final jsonPath = await getJsonPath(translation.id);

    final jsonFile = File(jsonPath);

    if (!await jsonFile.exists()) {
      await downloadTranslation(translation);
    }

    await rebuildDatabase(translation.id);
  }

  Future<void> rebuildDatabase(String translationId) async {
    final jsonPath = await getJsonPath(translationId);

    final dbPath = await getDbPath(translationId);

    final jsonFile = File(jsonPath);

    if (!await jsonFile.exists()) {
      throw Exception('JSON file not found.');
    }

    final json = jsonDecode(await jsonFile.readAsString());

    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    final db = sqlite3.open(dbPath);

    try {
      db.execute('''
CREATE TABLE books(
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  testament TEXT NOT NULL
);
''');

      db.execute('''
CREATE TABLE verses(
  book_id INTEGER NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY(book_id, chapter, verse)
);
''');

      db.execute('''
CREATE INDEX idx_book_chapter
ON verses(book_id, chapter);
''');

      final books = json['books'] as List<dynamic>;

      db.execute('BEGIN TRANSACTION');

      final insertBook = db.prepare('''
INSERT INTO books(
  id,
  name,
  testament
)
VALUES(?, ?, ?)
''');

      final insertVerse = db.prepare('''
INSERT INTO verses(
  book_id,
  chapter,
  verse,
  text
)
VALUES(?, ?, ?, ?)
''');

      try {
        for (int i = 0; i < books.length; i++) {
          final book = books[i] as Map<String, dynamic>;

          final bookId = i + 1;

          final testament = bookId <= 39 ? 'Old' : 'New';

          insertBook.execute([bookId, book['name'], testament]);

          final chapters = book['chapters'] as List;

          for (final chapter in chapters) {
            final verses = chapter['verses'] as List;

            for (final verse in verses) {
              insertVerse.execute([
                bookId,
                verse['chapter'],
                verse['verse'],
                verse['text'],
              ]);
            }
          }
        }

        db.execute('COMMIT');
      } catch (_) {
        db.execute('ROLLBACK');
        rethrow;
      } finally {
        insertBook.dispose();
        insertVerse.dispose();
      }
    } finally {
      db.dispose();
    }
  }

  Future<Database> openBible(String translationId) async {
    final path = await getDbPath(translationId);

    return sqlite3.open(path);
  }

  Future<List<Map<String, dynamic>>> getBooks(
    String translationId,
    String testament,
  ) async {
    final db = await openBible(translationId);

    try {
      final result = db.select(
        '''
SELECT *
FROM books
WHERE testament = ?
ORDER BY id
''',
        [testament],
      );

      return result.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
    } finally {
      db.dispose();
    }
  }

  Future<List<Map<String, dynamic>>> getVerses(
    String translationId,
    int bookId,
    int chapter,
  ) async {
    final db = await openBible(translationId);

    try {
      final result = db.select(
        '''
SELECT *
FROM verses
WHERE book_id = ?
AND chapter = ?
ORDER BY verse
''',
        [bookId, chapter],
      );

      return result.map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
    } finally {
      db.dispose();
    }
  }

  Future<int> getChapterCount(String translationId, int bookId) async {
    final db = await openBible(translationId);

    try {
      final result = db.select(
        '''
SELECT MAX(chapter) AS max_chapter
FROM verses
WHERE book_id = ?
''',
        [bookId],
      );

      if (result.isEmpty) {
        return 1;
      }

      return result.first['max_chapter'] as int? ?? 1;
    } finally {
      db.dispose();
    }
  }
}
