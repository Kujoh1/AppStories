import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/book_graph.dart';
import '../../../core/constants/app_constants.dart';

/// Provider for the book repository
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return MockBookRepository();
});

/// Provider for the current book
final bookProvider = FutureProvider<BookGraph>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBook(AppConstants.defaultBookId);
});

/// Provider for the current book (synchronous access after loaded)
final bookStateProvider = StateProvider<BookGraph?>((ref) {
  return null;
});


