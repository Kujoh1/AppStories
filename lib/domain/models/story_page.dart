/// A single page in a story - the atomic unit of navigation
/// 
/// Each page has a unique numeric ID and contains exactly what fits on screen.
/// Navigation is simply: currentPageIndex++ or currentPageIndex--
class StoryPage {
  /// Unique numeric ID (1-based, sequential across entire book)
  final int id;
  
  /// Original scene/knot ID (e.g., "s01_a" for Ink, "chapter_1" for DOCX)
  final String sceneId;
  
  /// Page number within the scene (1, 2, 3...)
  final int pageInScene;
  
  /// Total pages in this scene
  final int totalPagesInScene;
  
  /// Text content for this page (already paginated to fit viewport)
  final String text;
  
  /// Optional image path (typically only on last page of scene)
  final String? imagePath;
  
  /// Choices (only on last page of scene, empty otherwise)
  final List<PageChoice> choices;
  
  /// Whether this is the last page of the current scene
  final bool isLastPageOfScene;
  
  /// Whether this page can continue to next (no choices blocking)
  final bool canContinue;
  
  /// Scene/chapter title (optional, shown on first page)
  final String? sceneTitle;
  
  /// Whether this page starts inside an open quote (for cross-page quote styling)
  final bool startsInQuote;

  const StoryPage({
    required this.id,
    required this.sceneId,
    required this.pageInScene,
    required this.totalPagesInScene,
    required this.text,
    this.imagePath,
    this.choices = const [],
    this.isLastPageOfScene = false,
    this.canContinue = true,
    this.sceneTitle,
    this.startsInQuote = false,
  });

  /// Whether this page has an image to display
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  
  /// Whether this page has choices to display
  bool get hasChoices => choices.isNotEmpty;
  
  /// Whether forward navigation is blocked (choices pending)
  bool get isBlocked => hasChoices;
  
  /// Display string for page indicator (e.g., "42 / 156")
  String pageIndicator(int totalPages) => '$id / $totalPages';
  
  /// Debug info for development
  String get debugInfo => 'Page $id ($sceneId:$pageInScene/$totalPagesInScene)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryPage && other.id == id && other.sceneId == sceneId;
  }

  @override
  int get hashCode => Object.hash(id, sceneId, pageInScene);

  @override
  String toString() => 'StoryPage($id: $sceneId p$pageInScene)';
}

/// A choice option on a page
class PageChoice {
  /// Display text for the choice
  final String text;
  
  /// Target scene ID when this choice is selected
  final String targetSceneId;
  
  /// Index of this choice (0-based)
  final int index;

  const PageChoice({
    required this.text,
    required this.targetSceneId,
    required this.index,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageChoice && 
           other.text == text && 
           other.targetSceneId == targetSceneId;
  }

  @override
  int get hashCode => Object.hash(text, targetSceneId);

  @override
  String toString() => 'PageChoice($text -> $targetSceneId)';
}

/// Result of pre-analyzing a book into pages
class PagedBook {
  /// Book identifier
  final String bookId;
  
  /// Book title
  final String title;
  
  /// All pages in reading order
  final List<StoryPage> pages;
  
  /// Map from scene ID to first page index for that scene
  final Map<String, int> sceneToPageIndex;
  
  /// Viewport size used for pagination
  final double viewportWidth;
  final double viewportHeight;

  const PagedBook({
    required this.bookId,
    required this.title,
    required this.pages,
    required this.sceneToPageIndex,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  /// Total number of pages
  int get totalPages => pages.length;
  
  /// Get page by 1-based ID
  StoryPage? getPage(int pageId) {
    if (pageId < 1 || pageId > pages.length) return null;
    return pages[pageId - 1];
  }
  
  /// Get page index (0-based) for a scene
  int? getPageIndexForScene(String sceneId) => sceneToPageIndex[sceneId];
  
  /// Get first page of a scene
  StoryPage? getFirstPageOfScene(String sceneId) {
    final index = sceneToPageIndex[sceneId];
    if (index == null || index >= pages.length) return null;
    return pages[index];
  }

  @override
  String toString() => 'PagedBook($bookId: $totalPages pages)';
}
