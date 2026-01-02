import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/page_analyzer.dart';
import '../../../core/services/hyphenator_service.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/story_page.dart';
import 'book_provider.dart';

/// Provider for the HyphenatorService (singleton)
/// Provides German text hyphenation for improved justified text layout
final hyphenatorServiceProvider = Provider<HyphenatorService>((ref) {
  final service = HyphenatorService();
  // Initialize asynchronously - will be ready by the time stories are loaded
  service.initialize();
  return service;
});

/// Provider for the PageAnalyzer instance with configurable font and size
final pageAnalyzerProvider = Provider.family<PageAnalyzer, ({String fontFamily, double fontSize})>((ref, params) {
  return PageAnalyzer(config: PageLayoutConfig(
    fontFamily: params.fontFamily,
    fontSize: params.fontSize,
  ));
});

/// Parameters for page analysis
class PageAnalysisParams {
  final String bookId;
  final double viewportWidth;
  final double viewportHeight;
  final String fontFamily;
  final double fontSize;
  
  const PageAnalysisParams({
    required this.bookId,
    required this.viewportWidth,
    required this.viewportHeight,
    this.fontFamily = 'EBGaramond',
    this.fontSize = 18.0,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageAnalysisParams &&
           other.bookId == bookId &&
           other.viewportWidth == viewportWidth &&
           other.viewportHeight == viewportHeight &&
           other.fontFamily == fontFamily &&
           other.fontSize == fontSize;
  }
  
  @override
  int get hashCode => Object.hash(bookId, viewportWidth, viewportHeight, fontFamily, fontSize);
}

/// Data class for pre-calculated book result
class PreCalculatedBook {
  final PagedBook book;
  final PageAnalysisParams params;
  
  const PreCalculatedBook({
    required this.book,
    required this.params,
  });
}

/// Persistent state for pre-calculated book (survives navigation!)
/// This is set by HomePage after calculation and read by InkReaderPage
/// Using StateProvider (not autoDispose) so data persists during navigation
final preCalculatedBookProvider = StateProvider<PreCalculatedBook?>((ref) => null);

/// Provider for pre-analyzed paged book
/// This calculates all pages when needed and recalculates on book reload
/// Uses autoDispose to ensure fresh calculations when book is reloaded
final pagedBookProvider = FutureProvider.family.autoDispose<PagedBook, PageAnalysisParams>((ref, params) async {
  print('📐 [PageAnalyzer] Starting page calculation for ${params.bookId}');
  print('   Viewport: ${params.viewportWidth.toInt()}x${params.viewportHeight.toInt()}');
  print('   Font: ${params.fontFamily}, Size: ${params.fontSize}');
  
  final analyzer = ref.watch(pageAnalyzerProvider((fontFamily: params.fontFamily, fontSize: params.fontSize)));
  final repository = ref.watch(bookRepositoryProvider);
  final hyphenator = ref.watch(hyphenatorServiceProvider);
  final format = repository.getStoryFormat(params.bookId);
  
  // Ensure hyphenator is initialized
  if (!hyphenator.isInitialized) {
    await hyphenator.initialize();
  }
  
  if (format == StoryFormat.ink) {
    // Ink story
    final story = await repository.getInkStory(params.bookId);
    final result = await analyzer.analyzeInkStory(
      story: story,
      bookId: params.bookId,
      viewportWidth: params.viewportWidth,
      viewportHeight: params.viewportHeight,
      hyphenator: hyphenator,
    );
    print('✅ [PageAnalyzer] Completed! Generated ${result.totalPages} pages');
    print('   Hyphenation: ${hyphenator.getCacheStats()}');
    return result;
  } else {
    // DOCX story
    final bookIndex = await repository.getBookIndex(params.bookId);
    final chapters = <({String title, String content})>[];
    
    for (int i = 0; i < bookIndex.chapterCount; i++) {
      final chapter = await repository.getChapterContent(params.bookId, i);
      chapters.add((title: chapter.title, content: chapter.content));
    }
    
    final result = await analyzer.analyzeDocxStory(
      bookId: params.bookId,
      title: bookIndex.title,
      chapters: chapters,
      viewportWidth: params.viewportWidth,
      viewportHeight: params.viewportHeight,
    );
    print('✅ [PageAnalyzer] Completed! Generated ${result.totalPages} pages');
    return result;
  }
});

/// Current page index (0-based)
final currentPageIndexProvider = StateProvider<int>((ref) => 0);

/// Current page (derived from pagedBook and currentPageIndex)
final currentPageProvider = Provider.family<StoryPage?, PageAnalysisParams>((ref, params) {
  final pagedBookAsync = ref.watch(pagedBookProvider(params));
  final pageIndex = ref.watch(currentPageIndexProvider);
  
  return pagedBookAsync.whenOrNull(
    data: (pagedBook) {
      if (pageIndex < 0 || pageIndex >= pagedBook.pages.length) return null;
      return pagedBook.pages[pageIndex];
    },
  );
});

/// Navigate to next page
void goToNextPage(WidgetRef ref) {
  final pageIndex = ref.read(currentPageIndexProvider);
  ref.read(currentPageIndexProvider.notifier).state = pageIndex + 1;
}

/// Navigate to previous page
void goToPreviousPage(WidgetRef ref) {
  final pageIndex = ref.read(currentPageIndexProvider);
  if (pageIndex > 0) {
    ref.read(currentPageIndexProvider.notifier).state = pageIndex - 1;
  }
}

/// Navigate to a specific scene (for choices or chapter overview)
void goToScene(WidgetRef ref, PageAnalysisParams params, String sceneId) {
  final pagedBookAsync = ref.read(pagedBookProvider(params));
  
  pagedBookAsync.whenData((pagedBook) {
    final pageIndex = pagedBook.getPageIndexForScene(sceneId);
    if (pageIndex != null) {
      ref.read(currentPageIndexProvider.notifier).state = pageIndex;
    }
  });
}

/// Invalidate the paged book cache to force recalculation
/// Call this when book changes or when layout needs to be recalculated
void invalidatePagedBook(WidgetRef ref, PageAnalysisParams params) {
  ref.invalidate(pagedBookProvider(params));
}

/// State notifier for more complex reading state
class ReadingStateNotifier extends StateNotifier<ReadingState> {
  ReadingStateNotifier() : super(const ReadingState());
  
  void setPageIndex(int index) {
    state = state.copyWith(pageIndex: index);
  }
  
  void nextPage() {
    state = state.copyWith(pageIndex: state.pageIndex + 1);
  }
  
  void previousPage() {
    if (state.pageIndex > 0) {
      state = state.copyWith(pageIndex: state.pageIndex - 1);
    }
  }
  
  void goToScene(String sceneId, PagedBook book) {
    final pageIndex = book.getPageIndexForScene(sceneId);
    if (pageIndex != null) {
      state = state.copyWith(pageIndex: pageIndex);
    }
  }
  
  void recordChoice(String fromScene, String toScene, String choiceText) {
    final newHistory = List<ChoiceRecord>.from(state.choiceHistory);
    newHistory.add(ChoiceRecord(
      fromScene: fromScene,
      toScene: toScene,
      choiceText: choiceText,
      timestamp: DateTime.now(),
    ));
    state = state.copyWith(choiceHistory: newHistory);
  }
  
  void reset() {
    state = const ReadingState();
  }
}

/// Reading state
class ReadingState {
  final int pageIndex;
  final List<ChoiceRecord> choiceHistory;
  final bool isPaused;
  
  const ReadingState({
    this.pageIndex = 0,
    this.choiceHistory = const [],
    this.isPaused = false,
  });
  
  ReadingState copyWith({
    int? pageIndex,
    List<ChoiceRecord>? choiceHistory,
    bool? isPaused,
  }) {
    return ReadingState(
      pageIndex: pageIndex ?? this.pageIndex,
      choiceHistory: choiceHistory ?? this.choiceHistory,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// Record of a choice made by the user
class ChoiceRecord {
  final String fromScene;
  final String toScene;
  final String choiceText;
  final DateTime timestamp;
  
  const ChoiceRecord({
    required this.fromScene,
    required this.toScene,
    required this.choiceText,
    required this.timestamp,
  });
}

/// Provider for reading state
final readingStateProvider = StateNotifierProvider<ReadingStateNotifier, ReadingState>((ref) {
  return ReadingStateNotifier();
});

