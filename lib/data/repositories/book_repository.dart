import '../../domain/models/book_graph.dart';
import '../../domain/models/chapter_info.dart';
import '../../domain/models/series_metadata.dart';
import '../../core/services/story_parser.dart';
import '../../core/services/ink_parser.dart';

/// Story format types
enum StoryFormat { docx, ink }

/// Repository interface for accessing book data
abstract class BookRepository {
  /// Get list of all available books (metadata only)
  Future<List<BookGraph>> getBooks();
  
  /// Get full book (legacy - loads everything)
  Future<BookGraph> getBook(String bookId);
  
  /// Get page by ID (legacy)
  Future<LegacyPage?> getPage(String bookId, String pageId);
  
  /// STAGE 1: Get book index (structure only) - FAST
  Future<BookIndex> getBookIndex(String bookId);
  
  /// STAGE 2: Get specific chapter content - ON DEMAND
  Future<ChapterContent> getChapterContent(String bookId, int chapterIndex);
  
  /// Get story format for a book
  StoryFormat getStoryFormat(String bookId);
  
  /// Load Ink story (for Ink format books)
  Future<InkStory> getInkStory(String bookId);
  
  // ==================== SERIES SUPPORT ====================
  
  /// Check if a book is a series (has episodes)
  bool isSeriesBook(String bookId);
  
  /// Get series metadata (returns null if not a series)
  SeriesMetadata? getSeriesMetadata(String bookId);
  
  /// Load Ink story for a specific episode
  Future<InkStory> getEpisodeStory(String seriesId, int episodeNumber);
}

/// Repository that loads stories from various formats
class DocxBookRepository implements BookRepository {
  // Cache raw text per book (loaded once)
  final Map<String, String> _rawTextCache = {};
  
  // Cache chapter index per book (derived from raw text)
  final Map<String, List<ChapterInfo>> _chapterIndexCache = {};
  
  // Cache for Ink stories
  final Map<String, InkStory> _inkStoryCache = {};
  
  // Cache for episode stories (keyed by "seriesId_episodeNumber")
  final Map<String, InkStory> _episodeStoryCache = {};
  
  // Series metadata - books that have episodes
  // Note: Episode files should be properly formatted Ink stories
  // Each episode needs its own complete Ink file with VAR declarations
  static final Map<String, SeriesMetadata> _seriesMetadata = {
    'echoes_first_dawn': SeriesMetadata(
      seriesId: 'echoes_first_dawn',
      title: 'Echoes of the First Dawn',
      author: 'AppStories',
      episodes: [
        const EpisodeInfo(
          number: 1,
          title: 'Der Schneesturm',
          filePath: 'assets/stories/ink/Story_05_episode_01.md',
          description: 'Die Antarktis birgt ein Geheimnis, das älter ist als die Menschheit.',
          estimatedMinutes: 35,
        ),
        const EpisodeInfo(
          number: 2,
          title: 'Die Stadt der Ersten',
          filePath: 'assets/stories/ink/Story_05_episode_02.md',
          description: 'Die Jagd nach den zwölf Schlüsseln beginnt.',
          estimatedMinutes: 40,
        ),
        const EpisodeInfo(
          number: 3,
          title: 'Die Dunkelheit erwacht',
          filePath: 'assets/stories/ink/Story_05_episode_03.md',
          description: 'Die wahre Natur der Bedrohung offenbart sich.',
          estimatedMinutes: 50,
        ),
        const EpisodeInfo(
          number: 4,
          title: 'Die Konfrontation',
          filePath: 'assets/stories/ink/Story_05_episode_04.md',
          description: 'Verbündete und Feinde treffen aufeinander.',
          estimatedMinutes: 45,
        ),
        const EpisodeInfo(
          number: 5,
          title: 'Der Abstieg',
          filePath: 'assets/stories/ink/Story_05_episode_05.md',
          description: 'Der Weg zum Kern der Dunkelheit.',
          estimatedMinutes: 35,
        ),
        const EpisodeInfo(
          number: 6,
          title: 'Das Vermächtnis',
          filePath: 'assets/stories/ink/Story_05_episode_06.md',
          description: 'Die finale Entscheidung über das Schicksal der Menschheit.',
          estimatedMinutes: 40,
        ),
      ],
    ),
  };
  
  static const Map<String, Map<String, dynamic>> _bookMetadata = {
    'zwischen_den_gleisen': {
      'title': 'Zwischen den Gleisen',
      'author': 'Autor',
      'path': 'assets/stories/Zwischen den Gleisen.docx',
      'format': StoryFormat.docx,
    },
    'hk2045_death_row': {
      'title': 'Hongkong 2045 — Der Korridor der Wahrheit',
      'author': 'AppStories Studio',
      'path': 'assets/stories/ink/Story_02.md',
      'format': StoryFormat.ink,
    },
    'die_regeln_des_taeters': {
      'title': 'Die Regeln des Täters',
      'author': 'AppStories',
      'path': 'assets/stories/ink/Story_03.md',
      'format': StoryFormat.ink,
    },
    'frankfurt_komplex': {
      'title': 'Der Frankfurt-Komplex',
      'author': 'AppStories',
      'path': 'assets/stories/ink/Story_04.md',
      'format': StoryFormat.ink,
    },
    'echoes_first_dawn': {
      'title': 'Echoes of the First Dawn',
      'author': 'AppStories',
      'path': 'assets/stories/ink/Story_05_final.md',
      'format': StoryFormat.ink,
    },
  };

  @override
  StoryFormat getStoryFormat(String bookId) {
    return _bookMetadata[bookId]?['format'] as StoryFormat? ?? StoryFormat.docx;
  }

  @override
  Future<List<BookGraph>> getBooks() async {
    final List<BookGraph> books = [];
    for (final entry in _bookMetadata.entries) {
      final bookId = entry.key;
      final metadata = entry.value;
      
      books.add(
        BookGraph(
          id: bookId,
          title: metadata['title'] as String,
          author: metadata['author'] as String,
          startPageId: 'page_1',
          pages: {},
        ),
      );
    }
    return books;
  }
  
  @override
  Future<InkStory> getInkStory(String bookId) async {
    if (_inkStoryCache.containsKey(bookId)) {
      return _inkStoryCache[bookId]!;
    }
    
    final metadata = _bookMetadata[bookId];
    if (metadata == null) {
      throw Exception('Book with ID $bookId not found');
    }
    
    final path = metadata['path'] as String;
    final story = await InkParser.loadFromAsset(path);
    _inkStoryCache[bookId] = story;
    
    return story;
  }
  
  /// STAGE 1: Get book index - loads structure only
  @override
  Future<BookIndex> getBookIndex(String bookId) async {
    final metadata = _bookMetadata[bookId];
    if (metadata == null) {
      throw Exception('Book with ID $bookId not found');
    }
    
    final format = metadata['format'] as StoryFormat;
    final title = metadata['title'] as String;
    final author = metadata['author'] as String;
    final path = metadata['path'] as String;
    
    if (format == StoryFormat.ink) {
      // For Ink stories, each knot is a "chapter"
      final story = await getInkStory(bookId);
      final chapters = story.knots.entries.map((e) => ChapterInfo(
        index: story.knots.keys.toList().indexOf(e.key),
        title: e.key,
        startCharIndex: 0,
        endCharIndex: e.value.content.length,
      )).toList();
      
      return BookIndex(
        id: bookId,
        title: title,
        author: author,
        chapters: chapters,
        totalLength: story.knots.length,
      );
    }
    
    // DOCX format
    if (!_rawTextCache.containsKey(bookId)) {
      _rawTextCache[bookId] = await StoryParser.loadRawTextFromAsset(path);
    }
    
    if (!_chapterIndexCache.containsKey(bookId)) {
      _chapterIndexCache[bookId] = StoryParser.extractChapterIndex(_rawTextCache[bookId]!);
    }
    
    final chapters = _chapterIndexCache[bookId]!;
    
    return BookIndex(
      id: bookId,
      title: title,
      author: author,
      chapters: chapters,
      totalLength: _rawTextCache[bookId]!.length,
    );
  }
  
  /// STAGE 2: Get specific chapter content
  @override
  Future<ChapterContent> getChapterContent(String bookId, int chapterIndex) async {
    final metadata = _bookMetadata[bookId];
    if (metadata == null) {
      throw Exception('Book with ID $bookId not found');
    }
    
    final format = metadata['format'] as StoryFormat;
    
    if (format == StoryFormat.ink) {
      final story = await getInkStory(bookId);
      final knotName = story.knots.keys.elementAt(chapterIndex);
      final knot = story.knots[knotName]!;
      
      return ChapterContent(
        chapterIndex: chapterIndex,
        title: knotName,
        content: knot.content,
      );
    }
    
    // DOCX format
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

    final format = metadata['format'] as StoryFormat;
    final title = metadata['title'] as String;
    final author = metadata['author'] as String;
    
    if (format == StoryFormat.ink) {
      final story = await getInkStory(bookId);
      // For Ink, return first knot content
      final firstKnot = story.knots[story.startKnot];
      
      return BookGraph(
        id: bookId,
        title: title,
        author: author,
        startPageId: 'page_1',
        pages: {
          'page_1': LegacyPage(
            id: 'page_1',
            title: title,
            content: firstKnot?.content ?? '',
            displayOrder: 1,
            isPlaceholder: false,
          ),
        },
      );
    }

    // DOCX format
    final path = metadata['path'] as String;
    if (!_rawTextCache.containsKey(bookId)) {
      _rawTextCache[bookId] = await StoryParser.loadRawTextFromAsset(path);
    }
    
    final content = _rawTextCache[bookId]!;
    
    return BookGraph(
      id: bookId,
      title: title,
      author: author,
      startPageId: 'page_1',
      pages: {
        'page_1': LegacyPage(
          id: 'page_1',
          title: title,
          content: content,
          displayOrder: 1,
          isPlaceholder: false,
        ),
      },
    );
  }
  
  @override
  Future<LegacyPage?> getPage(String bookId, String pageId) async {
    final book = await getBook(bookId);
    return book.getPage(pageId);
  }
  
  // ==================== SERIES IMPLEMENTATION ====================
  
  @override
  bool isSeriesBook(String bookId) {
    return _seriesMetadata.containsKey(bookId);
  }
  
  @override
  SeriesMetadata? getSeriesMetadata(String bookId) {
    return _seriesMetadata[bookId];
  }
  
  @override
  Future<InkStory> getEpisodeStory(String seriesId, int episodeNumber) async {
    final cacheKey = '${seriesId}_episode_$episodeNumber';
    
    if (_episodeStoryCache.containsKey(cacheKey)) {
      return _episodeStoryCache[cacheKey]!;
    }
    
    final series = _seriesMetadata[seriesId];
    if (series == null) {
      throw Exception('Series with ID $seriesId not found');
    }
    
    final episode = series.episodes.firstWhere(
      (e) => e.number == episodeNumber,
      orElse: () => throw Exception('Episode $episodeNumber not found in series $seriesId'),
    );
    
    final story = await InkParser.loadFromAsset(episode.filePath);
    _episodeStoryCache[cacheKey] = story;
    
    return story;
  }
  
  /// Clear episode cache (useful when switching episodes)
  void clearEpisodeCache() {
    _episodeStoryCache.clear();
  }
}
