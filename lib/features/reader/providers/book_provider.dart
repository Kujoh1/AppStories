import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/book_graph.dart';

/// Provider for the book repository
/// Using DocxBookRepository to load from Word documents
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return DocxBookRepository();
});

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


