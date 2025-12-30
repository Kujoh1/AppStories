import '../../domain/models/book_graph.dart';
import '../../domain/models/story_page.dart';
import '../../domain/models/chapter_info.dart';
import '../../core/services/story_parser.dart';

/// Repository interface for accessing book data
abstract class BookRepository {
  /// Get list of all available books (metadata only)
  Future<List<BookGraph>> getBooks();
  
  /// Get full book (legacy - loads everything)
  Future<BookGraph> getBook(String bookId);
  
  /// Get page by ID
  Future<StoryPage?> getPage(String bookId, String pageId);
  
  /// STAGE 1: Get book index (structure only) - FAST
  Future<BookIndex> getBookIndex(String bookId);
  
  /// STAGE 2: Get specific chapter content - ON DEMAND
  Future<ChapterContent> getChapterContent(String bookId, int chapterIndex);
}

/// Repository that loads stories from Word documents
class DocxBookRepository implements BookRepository {
  // Cache raw text per book (loaded once)
  final Map<String, String> _rawTextCache = {};
  
  // Cache chapter index per book (derived from raw text)
  final Map<String, List<ChapterInfo>> _chapterIndexCache = {};
  
  static const Map<String, Map<String, String>> _bookMetadata = {
    'zwischen_den_gleisen': {
      'title': 'Zwischen den Gleisen',
      'author': 'Autor',
      'path': 'assets/stories/Zwischen den Gleisen.docx',
    },
    'moby_dick': {
      'title': 'Moby Dick',
      'author': 'Herman Melville',
      'path': 'assets/stories/Moby Dick.docx',
    },
  };

  @override
  Future<List<BookGraph>> getBooks() async {
    final List<BookGraph> books = [];
    for (final entry in _bookMetadata.entries) {
      final bookId = entry.key;
      final metadata = entry.value;
      
      books.add(
        BookGraph(
          id: bookId,
          title: metadata['title']!,
          author: metadata['author']!,
          startPageId: 'page_1',
          pages: {},
        ),
      );
    }
    return books;
  }
  
  /// STAGE 1: Get book index - loads raw text and extracts chapter structure
  /// This is FAST because it only scans for chapter markers
  @override
  Future<BookIndex> getBookIndex(String bookId) async {
    final metadata = _bookMetadata[bookId];
    if (metadata == null) {
      throw Exception('Book with ID $bookId not found');
    }
    
    // Load raw text if not cached
    if (!_rawTextCache.containsKey(bookId)) {
      _rawTextCache[bookId] = await StoryParser.loadRawTextFromAsset(metadata['path']!);
    }
    
    // Extract chapter index if not cached
    if (!_chapterIndexCache.containsKey(bookId)) {
      _chapterIndexCache[bookId] = StoryParser.extractChapterIndex(_rawTextCache[bookId]!);
    }
    
    final chapters = _chapterIndexCache[bookId]!;
    
    return BookIndex(
      id: bookId,
      title: metadata['title']!,
      author: metadata['author']!,
      chapters: chapters,
      totalLength: _rawTextCache[bookId]!.length,
    );
  }
  
  /// STAGE 2: Get specific chapter content - loads only what's needed
  @override
  Future<ChapterContent> getChapterContent(String bookId, int chapterIndex) async {
    // Ensure we have raw text and chapter index loaded
    await getBookIndex(bookId);
    
    final rawText = _rawTextCache[bookId]!;
    final chapters = _chapterIndexCache[bookId]!;
    
    final content = StoryParser.extractChapter(rawText, chapterIndex, chapters);
    
    if (content == null) {
      throw Exception('Chapter $chapterIndex not found in book $bookId');
    }
    
    return content;
  }
  
  /// Legacy: Get full book (loads everything)
  @override
  Future<BookGraph> getBook(String bookId) async {
    final metadata = _bookMetadata[bookId];
    if (metadata == null) {
      throw Exception('Book with ID $bookId not found');
    }

    // Use cached raw text
    if (!_rawTextCache.containsKey(bookId)) {
      _rawTextCache[bookId] = await StoryParser.loadRawTextFromAsset(metadata['path']!);
    }
    
    final content = _rawTextCache[bookId]!;
    
    return BookGraph(
      id: bookId,
      title: metadata['title']!,
      author: metadata['author']!,
      startPageId: 'page_1',
      pages: {
        'page_1': StoryPage(
          id: 'page_1',
          title: metadata['title']!,
          content: content,
          displayOrder: 1,
          isPlaceholder: false,
        ),
      },
    );
  }
  
  @override
  Future<StoryPage?> getPage(String bookId, String pageId) async {
    final book = await getBook(bookId);
    return book.getPage(pageId);
  }
}
