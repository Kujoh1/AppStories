/// Information about a chapter or scene in a story
class ChapterInfo {
  final String title;
  final String? subtitle;
  final int index;
  final int startCharIndex;
  final int endCharIndex;
  final bool isCompleted;
  final bool isLocked;
  final String? imagePath;
  final int? wordCount;
  final String? choiceText; // The choice that led to this scene
  final bool wasVisitedByChoice; // Whether this scene was reached via choice

  const ChapterInfo({
    required this.title,
    this.subtitle,
    required this.index,
    required this.startCharIndex,
    required this.endCharIndex,
    this.isCompleted = false,
    this.isLocked = false,
    this.imagePath,
    this.wordCount,
    this.choiceText,
    this.wasVisitedByChoice = false,
  });

  ChapterInfo copyWith({
    String? title,
    String? subtitle,
    int? index,
    int? startCharIndex,
    int? endCharIndex,
    bool? isCompleted,
    bool? isLocked,
    String? imagePath,
    int? wordCount,
    String? choiceText,
    bool? wasVisitedByChoice,
  }) {
    return ChapterInfo(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      index: index ?? this.index,
      startCharIndex: startCharIndex ?? this.startCharIndex,
      endCharIndex: endCharIndex ?? this.endCharIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      imagePath: imagePath ?? this.imagePath,
      wordCount: wordCount ?? this.wordCount,
      choiceText: choiceText ?? this.choiceText,
      wasVisitedByChoice: wasVisitedByChoice ?? this.wasVisitedByChoice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterInfo &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.index == index &&
        other.startCharIndex == startCharIndex &&
        other.endCharIndex == endCharIndex &&
        other.isCompleted == isCompleted &&
        other.isLocked == isLocked &&
        other.imagePath == imagePath &&
        other.wordCount == wordCount &&
        other.choiceText == choiceText &&
        other.wasVisitedByChoice == wasVisitedByChoice;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      subtitle,
      index,
      startCharIndex,
      endCharIndex,
      isCompleted,
      isLocked,
      imagePath,
      wordCount,
      choiceText,
      wasVisitedByChoice,
    );
  }

  @override
  String toString() {
    return 'ChapterInfo(title: $title, index: $index, isCompleted: $isCompleted, isLocked: $isLocked)';
  }
}

/// Content of a specific chapter
class ChapterContent {
  final int chapterIndex;
  final String title;
  final String content;

  const ChapterContent({
    required this.chapterIndex,
    required this.title,
    required this.content,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterContent &&
        other.chapterIndex == chapterIndex &&
        other.title == title &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(chapterIndex, title, content);
  }

  @override
  String toString() {
    return 'ChapterContent(chapterIndex: $chapterIndex, title: $title, contentLength: ${content.length})';
  }
}

/// Index of all chapters/scenes in a book
class BookIndex {
  final String id;
  final String title;
  final String author;
  final List<ChapterInfo> chapters;
  final int totalLength;

  const BookIndex({
    required this.id,
    required this.title,
    required this.author,
    required this.chapters,
    required this.totalLength,
  });

  int get chapterCount => chapters.length;

  ChapterInfo? getChapter(int index) {
    if (index < 0 || index >= chapters.length) return null;
    return chapters[index];
  }

  ChapterInfo? findChapterByTitle(String title) {
    try {
      return chapters.firstWhere((chapter) => chapter.title == title);
    } catch (e) {
      return null;
    }
  }

  BookIndex copyWith({
    String? id,
    String? title,
    String? author,
    List<ChapterInfo>? chapters,
    int? totalLength,
  }) {
    return BookIndex(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      chapters: chapters ?? this.chapters,
      totalLength: totalLength ?? this.totalLength,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookIndex &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.chapters.length == chapters.length;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, author, chapters.length);
  }

  @override
  String toString() {
    return 'BookIndex(id: $id, title: $title, chapterCount: $chapterCount)';
  }
}