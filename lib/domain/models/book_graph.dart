import 'story_page.dart';

/// Represents the entire story as a graph of pages
/// Supports both linear and branching narratives
class BookGraph {
  final String id;
  final String title;
  final String author;
  final Map<String, StoryPage> pages;
  final String startPageId;

  const BookGraph({
    required this.id,
    required this.title,
    required this.author,
    required this.pages,
    required this.startPageId,
  });

  /// Get a page by its ID
  StoryPage? getPage(String pageId) => pages[pageId];

  /// Get the starting page
  StoryPage? get startPage => pages[startPageId];

  /// Get total number of pages
  int get totalPages => pages.length;

  /// Get next page in linear order (by displayOrder)
  StoryPage? getNextLinearPage(String currentPageId) {
    final currentPage = pages[currentPageId];
    if (currentPage == null) return null;

    final nextOrder = currentPage.displayOrder + 1;
    return pages.values.firstWhere(
      (page) => page.displayOrder == nextOrder,
      orElse: () => pages.values.first, // Fallback
    );
  }

  /// Get previous page in linear order
  StoryPage? getPreviousLinearPage(String currentPageId) {
    final currentPage = pages[currentPageId];
    if (currentPage == null) return null;

    final prevOrder = currentPage.displayOrder - 1;
    if (prevOrder < 1) return null;

    return pages.values.firstWhere(
      (page) => page.displayOrder == prevOrder,
      orElse: () => pages.values.first, // Fallback
    );
  }

  /// Check if there's a next page
  bool hasNextPage(String currentPageId) {
    return getNextLinearPage(currentPageId) != null;
  }

  /// Check if there's a previous page
  bool hasPreviousPage(String currentPageId) {
    return getPreviousLinearPage(currentPageId) != null;
  }

  BookGraph copyWith({
    String? id,
    String? title,
    String? author,
    Map<String, StoryPage>? pages,
    String? startPageId,
  }) {
    return BookGraph(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      pages: pages ?? this.pages,
      startPageId: startPageId ?? this.startPageId,
    );
  }
}


