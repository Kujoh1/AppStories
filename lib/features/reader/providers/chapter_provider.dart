import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/chapter_info.dart';
import 'book_provider.dart';

/// Provider for the book index (structure only) - STAGE 1
/// This loads fast because it only scans for chapter markers
final bookIndexProvider = FutureProvider.family<BookIndex, String>((ref, bookId) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBookIndex(bookId);
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

