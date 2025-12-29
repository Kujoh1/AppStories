import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/story_page.dart';
import 'book_provider.dart';

/// Provider for navigation logic
class NavigationNotifier extends StateNotifier<void> {
  final Ref ref;

  NavigationNotifier(this.ref) : super(null);

  /// Navigate to next page (linear)
  StoryPage? getNextPage(String currentPageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) => book.getNextLinearPage(currentPageId),
      orElse: () => null,
    );
  }

  /// Navigate to previous page (linear)
  StoryPage? getPreviousPage(String currentPageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) => book.getPreviousLinearPage(currentPageId),
      orElse: () => null,
    );
  }

  /// Navigate to specific page by ID
  StoryPage? getPageById(String pageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) => book.getPage(pageId),
      orElse: () => null,
    );
  }

  /// Check if there's a next page
  bool hasNextPage(String currentPageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) => book.hasNextPage(currentPageId),
      orElse: () => false,
    );
  }

  /// Check if there's a previous page
  bool hasPreviousPage(String currentPageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) => book.hasPreviousPage(currentPageId),
      orElse: () => false,
    );
  }

  /// Get current page number and total
  (int current, int total) getProgress(String currentPageId) {
    final bookAsync = ref.read(bookProvider);
    return bookAsync.maybeWhen(
      data: (book) {
        final page = book.getPage(currentPageId);
        return (page?.displayOrder ?? 1, book.totalPages);
      },
      orElse: () => (1, 10),
    );
  }
}

/// Provider for navigation
final navigationProvider = StateNotifierProvider<NavigationNotifier, void>(
  (ref) => NavigationNotifier(ref),
);

