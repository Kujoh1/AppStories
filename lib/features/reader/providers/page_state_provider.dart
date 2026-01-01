import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/page_analyzer.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/story_page.dart';
import 'book_provider.dart';

/// Provider for the PageAnalyzer instance
final pageAnalyzerProvider = Provider<PageAnalyzer>((ref) {
  return const PageAnalyzer();
});

/// Parameters for page analysis
class PageAnalysisParams {
  final String bookId;
  final double viewportWidth;
  final double viewportHeight;
  
  const PageAnalysisParams({
    required this.bookId,
    required this.viewportWidth,
    required this.viewportHeight,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageAnalysisParams &&
           other.bookId == bookId &&
           other.viewportWidth == viewportWidth &&
           other.viewportHeight == viewportHeight;
  }
  
  @override
  int get hashCode => Object.hash(bookId, viewportWidth, viewportHeight);
}

/// Provider for pre-analyzed paged book
/// This calculates all pages ONCE before reading starts
final pagedBookProvider = FutureProvider.family<PagedBook, PageAnalysisParams>((ref, params) async {
  final analyzer = ref.watch(pageAnalyzerProvider);
  final repository = ref.watch(bookRepositoryProvider);
  final format = repository.getStoryFormat(params.bookId);
  
  if (format == StoryFormat.ink) {
    // Ink story
    final story = await repository.getInkStory(params.bookId);
    return analyzer.analyzeInkStory(
      story: story,
      bookId: params.bookId,
      viewportWidth: params.viewportWidth,
      viewportHeight: params.viewportHeight,
    );
  } else {
    // DOCX story
    final bookIndex = await repository.getBookIndex(params.bookId);
    final chapters = <({String title, String content})>[];
    
    for (int i = 0; i < bookIndex.chapterCount; i++) {
      final chapter = await repository.getChapterContent(params.bookId, i);
      chapters.add((title: chapter.title, content: chapter.content));
    }
    
    return analyzer.analyzeDocxStory(
      bookId: params.bookId,
      title: bookIndex.title,
      chapters: chapters,
      viewportWidth: params.viewportWidth,
      viewportHeight: params.viewportHeight,
    );
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

