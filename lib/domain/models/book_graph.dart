/// Legacy page model for BookGraph (backward compatibility)
/// The new system uses StoryPage from story_page.dart via PagedBook
class LegacyPage {
  final String id;
  final String title;
  final String content;
  final int displayOrder;
  final bool isPlaceholder;

  const LegacyPage({
    required this.id,
    required this.title,
    required this.content,
    required this.displayOrder,
    this.isPlaceholder = false,
  });
}

/// Represents the entire story as a graph of pages
/// Legacy structure - new readers use PagedBook instead
class BookGraph {
  final String id;
  final String title;
  final String author;
  final Map<String, LegacyPage> pages;
  final String startPageId;

  const BookGraph({
    required this.id,
    required this.title,
    required this.author,
    required this.pages,
    required this.startPageId,
  });

  /// Get a page by its ID
  LegacyPage? getPage(String pageId) => pages[pageId];

  /// Get the starting page
  LegacyPage? get startPage => pages[startPageId];

  /// Get total number of pages
  int get totalPages => pages.length;

  /// Get next page in linear order (by displayOrder)
  LegacyPage? getNextLinearPage(String currentPageId) {
    final currentPage = pages[currentPageId];
    if (currentPage == null) return null;

    final nextOrder = currentPage.displayOrder + 1;
    try {
      return pages.values.firstWhere(
        (page) => page.displayOrder == nextOrder,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get previous page in linear order
  LegacyPage? getPreviousLinearPage(String currentPageId) {
    final currentPage = pages[currentPageId];
    if (currentPage == null) return null;

    final prevOrder = currentPage.displayOrder - 1;
    if (prevOrder < 1) return null;

    try {
      return pages.values.firstWhere(
        (page) => page.displayOrder == prevOrder,
      );
    } catch (e) {
      return null;
    }
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
    Map<String, LegacyPage>? pages,
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
