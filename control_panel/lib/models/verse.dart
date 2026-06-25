class Verse {
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  Verse({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      bookId: map['book_id'],
      bookName: map['book_name'],
      chapter: map['chapter'],
      verse: map['verse'],
      text: map['text'],
    );
  }
}
