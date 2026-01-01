import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/book_graph.dart';
import '../../../core/services/ink_parser.dart';

/// Provider for the book repository
/// Using DocxBookRepository to load from Word documents
/// This is a singleton to ensure caching works properly
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DocxBookRepository();
});

/// Provider for story format of selected book
final storyFormatProvider = Provider<StoryFormat>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  final bookId = ref.watch(selectedBookIdProvider);
  return repository.getStoryFormat(bookId);
});

/// Provider for Ink story (only for Ink format books)
final inkStoryProvider = FutureProvider<InkStory>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  final bookId = ref.watch(selectedBookIdProvider);
  return repository.getInkStory(bookId);
});

/// Provider for Ink runtime state
final inkRuntimeProvider = StateNotifierProvider<InkRuntimeNotifier, InkRuntime?>((ref) {
  return InkRuntimeNotifier();
});

/// Notifier for managing Ink runtime state
class InkRuntimeNotifier extends StateNotifier<InkRuntime?> {
  InkRuntimeNotifier() : super(null);
  
  void initialize(InkStory story) {
    state = InkRuntime(story);
  }
  
  void makeChoice(int choiceIndex) {
    if (state != null) {
      state!.makeChoice(choiceIndex);
      // Trigger rebuild by creating new reference with same state
      final current = state!;
      state = null;
      state = current;
    }
  }
  
  void continueStory() {
    if (state != null) {
      state!.continueStory();
      // Trigger rebuild by creating new reference with same state
      final current = state!;
      state = null;
      state = current;
    }
  }

  void goBack() {
    if (state != null && state!.canGoBack) {
      state!.goBack();
      // Trigger rebuild
      final current = state!;
      state = null;
      state = current;
    }
  }
  
  void reset() {
    if (state != null) {
      state!.reset();
      // Trigger rebuild
      final current = state!;
      state = null;
      state = current;
    }
  }

  void navigateToKnot(String knotName) {
    if (state != null) {
      state!.navigateToKnot(knotName);
      // Trigger rebuild
      final current = state!;
      state = null;
      state = current;
    }
  }
}

/// Provider for the list of all available books
final booksProvider = FutureProvider<List<BookGraph>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBooks();
});

/// Provider for the currently selected book ID
final selectedBookIdProvider = StateProvider<String>((ref) {
  return 'zwischen_den_gleisen'; // Default book
});

/// Provider for the current book
final bookProvider = FutureProvider<BookGraph>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  final bookId = ref.watch(selectedBookIdProvider);
  return repository.getBook(bookId);
});

/// Provider for the current book (synchronous access after loaded)
final bookStateProvider = StateProvider<BookGraph?>((ref) {
  return null;
});


