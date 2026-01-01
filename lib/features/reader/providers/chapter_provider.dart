import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/chapter_info.dart';
import 'book_provider.dart';

/// Provider for the book index (structure only) - STAGE 1
/// This loads fast because it only scans for chapter markers
final bookIndexProvider = FutureProvider.family<BookIndex, String>((ref, bookId) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBookIndex(bookId);
});

/// Provider for all book indexes (cached for library display)
/// This loads all book indexes once and caches them
final allBookIndexesProvider = FutureProvider<Map<String, BookIndex>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  final books = await ref.watch(booksProvider.future);
  
  final Map<String, BookIndex> indexes = {};
  
  // Load all book indexes in parallel
  final futures = books.map((book) async {
    try {
      final index = await repository.getBookIndex(book.id);
      indexes[book.id] = index;
    } catch (e) {
      print('Error loading index for ${book.id}: $e');
      // Create a fallback index
      indexes[book.id] = BookIndex(
        id: book.id,
        title: book.title,
        author: book.author,
        chapters: [],
        totalLength: 0,
      );
    }
  });
  
  await Future.wait(futures);
  return indexes;
});

/// Provider for current chapter index
final currentChapterIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for chapter content - STAGE 2
/// This loads the actual chapter content on-demand
final chapterContentProvider = FutureProvider.family<ChapterContent, ({String bookId, int chapterIndex})>((ref, params) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getChapterContent(params.bookId, params.chapterIndex);
});

/// Provider for current chapter content (convenience)
final currentChapterProvider = FutureProvider<ChapterContent>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapterIndex = ref.watch(currentChapterIndexProvider);
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getChapterContent(bookId, chapterIndex);
});

/// Provider for preloading next chapter in background
final preloadNextChapterProvider = FutureProvider<ChapterContent?>((ref) async {
  final bookId = ref.watch(selectedBookIdProvider);
  final chapterIndex = ref.watch(currentChapterIndexProvider);
  final bookIndex = await ref.watch(bookIndexProvider(bookId).future);
  
  // If there's a next chapter, preload it
  final nextChapter = chapterIndex + 1;
  if (nextChapter < bookIndex.chapterCount) {
    final repository = ref.watch(bookRepositoryProvider);
    return repository.getChapterContent(bookId, nextChapter);
  }
  
  return null;
});

