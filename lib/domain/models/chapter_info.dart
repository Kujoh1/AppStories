/// Lightweight chapter metadata - used for indexing without loading full content
class ChapterInfo {
  final int index;
  final String title;
  final int startCharIndex;
  final int endCharIndex;
  
  const ChapterInfo({
    required this.index,
    required this.title,
    required this.startCharIndex,
    required this.endCharIndex,
  });
  
  /// Approximate length of this chapter
  int get length => endCharIndex - startCharIndex;
  
  @override
  String toString() => 'Chapter $index: $title ($startCharIndex-$endCharIndex)';
}

/// Book index - contains structure/metadata without full content
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
  
  /// Get chapter info by index
  ChapterInfo? getChapter(int index) {
    if (index < 0 || index >= chapters.length) return null;
    return chapters[index];
  }
}

/// Loaded chapter content - the actual text for reading
class ChapterContent {
  final int chapterIndex;
  final String title;
  final String content;
  
  const ChapterContent({
    required this.chapterIndex,
    required this.title,
    required this.content,
  });
}


