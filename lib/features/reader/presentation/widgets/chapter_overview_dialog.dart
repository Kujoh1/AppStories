import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/story_page.dart';

/// Hierarchical page/chapter navigation dialog
/// Shows chapters/scenes with their pages, allowing navigation to any page
class PageOverviewDialog extends ConsumerStatefulWidget {
  final PagedBook pagedBook;
  final int currentPageIndex;
  final void Function(int pageIndex) onNavigate;
  final bool isInkStory;

  const PageOverviewDialog({
    super.key,
    required this.pagedBook,
    required this.currentPageIndex,
    required this.onNavigate,
    this.isInkStory = false,
  });

  static Future<void> show(
    BuildContext context, {
    required PagedBook pagedBook,
    required int currentPageIndex,
    required void Function(int pageIndex) onNavigate,
    bool isInkStory = false,
  }) {
    // Clamp the index to valid range
    final safeIndex = currentPageIndex.clamp(0, pagedBook.pages.length - 1);
    
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PageOverviewDialog(
        pagedBook: pagedBook,
        currentPageIndex: safeIndex,
        onNavigate: onNavigate,
        isInkStory: isInkStory,
      ),
    );
  }

  @override
  ConsumerState<PageOverviewDialog> createState() => _PageOverviewDialogState();
}

class _PageOverviewDialogState extends ConsumerState<PageOverviewDialog> {
  // Track which scenes are expanded
  final Set<String> _expandedScenes = {};
  final ScrollController _scrollController = ScrollController();
  late List<_SceneInfo> _scenes;
  late int _safeCurrentIndex;
  late StoryPage _currentPage;
  late int _totalPages;
  
  // Terminology helpers
  String get _chapterLabel => widget.isInkStory ? 'Szene' : 'Kapitel';
  String get _chapterLabelPlural => widget.isInkStory ? 'Szenen' : 'Kapitel';

  @override
  void initState() {
    super.initState();
    _initializeState();
    
    // Scroll to current scene after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentScene();
    });
  }

  void _initializeState() {
    // Ensure all values are valid
    _totalPages = widget.pagedBook.pages.length;
    _safeCurrentIndex = widget.currentPageIndex.clamp(0, _totalPages - 1);
    _currentPage = widget.pagedBook.pages[_safeCurrentIndex];
    _scenes = _buildSceneList();
    
    // Auto-expand current scene
    _expandedScenes.add(_currentPage.sceneId);
  }

  /// Build the scene list once, with all information
  List<_SceneInfo> _buildSceneList() {
    final scenes = <_SceneInfo>[];
    
    if (widget.pagedBook.pages.isEmpty) return scenes;
    
    String? currentSceneId;
    int sceneStartIndex = 0;
    List<StoryPage> scenePagesBuffer = [];
    
    for (int i = 0; i < widget.pagedBook.pages.length; i++) {
      final page = widget.pagedBook.pages[i];
      
      if (page.sceneId != currentSceneId) {
        // Save previous scene if exists
        if (currentSceneId != null && scenePagesBuffer.isNotEmpty) {
          scenes.add(_createSceneInfo(
            sceneId: currentSceneId,
            startIndex: sceneStartIndex,
            pages: scenePagesBuffer,
            sceneNumber: scenes.length + 1,
          ));
        }
        
        // Start new scene
        currentSceneId = page.sceneId;
        sceneStartIndex = i;
        scenePagesBuffer = [page];
      } else {
        scenePagesBuffer.add(page);
      }
    }
    
    // Add last scene
    if (currentSceneId != null && scenePagesBuffer.isNotEmpty) {
      scenes.add(_createSceneInfo(
        sceneId: currentSceneId,
        startIndex: sceneStartIndex,
        pages: scenePagesBuffer,
        sceneNumber: scenes.length + 1,
      ));
    }
    
    return scenes;
  }

  _SceneInfo _createSceneInfo({
    required String sceneId,
    required int startIndex,
    required List<StoryPage> pages,
    required int sceneNumber,
  }) {
    return _SceneInfo(
      sceneId: sceneId,
      sceneNumber: sceneNumber,
      startPageIndex: startIndex,
      endPageIndex: startIndex + pages.length - 1,
      pageCount: pages.length,
      title: pages.first.sceneTitle,
      hasChoices: pages.any((p) => p.hasChoices),
      hasImage: pages.any((p) => p.hasImage),
      // First page ID (1-based) for display
      firstPageId: pages.first.id,
      lastPageId: pages.last.id,
    );
  }

  void _scrollToCurrentScene() {
    final sceneIndex = _scenes.indexWhere((s) => s.sceneId == _currentPage.sceneId);
    
    if (sceneIndex > 0 && _scrollController.hasClients) {
      // Approximate scroll position (each scene tile is ~70px)
      final offset = (sceneIndex * 70.0).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate how many scenes are completed
  int get _completedSceneCount {
    int count = 0;
    for (final scene in _scenes) {
      if (scene.endPageIndex < _safeCurrentIndex) {
        count++;
      }
    }
    return count;
  }

  // Current scene number (1-based)
  int get _currentSceneNumber {
    for (int i = 0; i < _scenes.length; i++) {
      if (_scenes[i].sceneId == _currentPage.sceneId) {
        return i + 1;
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    // Progress based on 0-indexed position / total (clamped to 0-1)
    final progress = ((_safeCurrentIndex + 1) / _totalPages).clamp(0.0, 1.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
            Color(0xFF0A0A0A),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with progress
          _buildHeader(context, progress),

          // Scene/Page list
          Expanded(
            child: _scenes.isEmpty
                ? Center(child: Text('Keine $_chapterLabelPlural', style: const TextStyle(color: Colors.white54)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _scenes.length,
                    itemBuilder: (context, index) => _buildSceneTile(context, _scenes[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFE8DCC0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pagedBook.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8DCC0),
                        fontFamily: 'Mynerve',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white38, size: 20),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats row - clear and logical
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Current page / total pages
                _buildStatItem(
                  icon: Icons.article_outlined,
                  label: 'Seite',
                  value: '${_currentPage.id} / $_totalPages',
                ),
                Container(width: 1, height: 30, color: Colors.white12),
                // Current scene / total scenes
                _buildStatItem(
                  icon: Icons.folder_outlined,
                  label: _chapterLabel,
                  value: '$_currentSceneNumber / ${_scenes.length}',
                ),
                Container(width: 1, height: 30, color: Colors.white12),
                // Progress percentage
                _buildStatItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Fortschritt',
                  value: '${(progress * 100).round()}%',
                  highlight: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8DCC0), Color(0xFFFEFFE9)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: highlight ? const Color(0xFFE8DCC0) : Colors.white38,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlight ? const Color(0xFFE8DCC0) : Colors.white.withOpacity(0.87),
            fontFamily: 'Mynerve',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildSceneTile(BuildContext context, _SceneInfo scene) {
    final isExpanded = _expandedScenes.contains(scene.sceneId);
    final isCurrentScene = _currentPage.sceneId == scene.sceneId;
    final isCompleted = scene.endPageIndex < _safeCurrentIndex;
    final isLocked = scene.startPageIndex > _safeCurrentIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentScene 
            ? const Color(0xFFE8DCC0).withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentScene
              ? const Color(0xFFE8DCC0).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          width: isCurrentScene ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Scene header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedScenes.remove(scene.sceneId);
                  } else {
                    _expandedScenes.add(scene.sceneId);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Scene number badge
                    _buildSceneNumberBadge(scene.sceneNumber, isCurrentScene, isCompleted, isLocked),
                    const SizedBox(width: 12),
                    
                    // Scene info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  scene.title ?? '$_chapterLabel ${scene.sceneNumber}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrentScene ? FontWeight.w600 : FontWeight.w500,
                                    color: isLocked 
                                        ? Colors.white38 
                                        : isCurrentScene 
                                            ? const Color(0xFFE8DCC0)
                                            : Colors.white.withOpacity(0.87),
                                    fontFamily: 'Mynerve',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Badges
                              if (scene.hasImage) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.image_rounded, size: 14, 
                                     color: Colors.white.withOpacity(0.4)),
                              ],
                              if (scene.hasChoices) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.call_split_rounded, size: 14,
                                     color: const Color(0xFFE8DCC0).withOpacity(0.6)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Page info
                          Text(
                            scene.pageCount == 1 
                                ? '1 Seite (S. ${scene.firstPageId})'
                                : '${scene.pageCount} Seiten (S. ${scene.firstPageId}–${scene.lastPageId})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isLocked ? Colors.white24 : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status indicator
                    _buildSceneStatus(isCurrentScene, isCompleted, isLocked),
                    
                    const SizedBox(width: 8),
                    
                    // Expand/collapse arrow
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: isLocked ? Colors.white24 : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expanded page list
          if (isExpanded) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.white.withOpacity(0.08),
            ),
            _buildPageList(scene),
          ],
        ],
      ),
    );
  }

  Widget _buildSceneNumberBadge(int number, bool isCurrent, bool isCompleted, bool isLocked) {
    Color bgColor;
    Color textColor;

    if (isLocked) {
      bgColor = Colors.white.withOpacity(0.05);
      textColor = Colors.white24;
    } else if (isCurrent) {
      bgColor = const Color(0xFFE8DCC0);
      textColor = Colors.black;
    } else if (isCompleted) {
      bgColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
    } else {
      bgColor = Colors.white.withOpacity(0.08);
      textColor = Colors.white54;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: isCompleted && !isCurrent
            ? Icon(Icons.check, size: 16, color: textColor)
            : Text(
                '$number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildSceneStatus(bool isCurrent, bool isCompleted, bool isLocked) {
    if (isLocked) {
      return const Icon(Icons.lock_outline, size: 14, color: Colors.white24);
    }
    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE8DCC0).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'AKTUELL',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8DCC0),
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    if (isCompleted) {
      return const Icon(Icons.check_circle, size: 14, color: Colors.green);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPageList(_SceneInfo scene) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10, top: 6),
      child: Column(
        children: List.generate(scene.pageCount, (index) {
          final pageIndex = scene.startPageIndex + index;
          final page = widget.pagedBook.pages[pageIndex];
          final isCurrent = pageIndex == _safeCurrentIndex;
          final isCompleted = pageIndex < _safeCurrentIndex;
          final isLocked = pageIndex > _safeCurrentIndex;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isLocked ? null : () {
                Navigator.of(context).pop();
                widget.onNavigate(pageIndex);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? const Color(0xFFE8DCC0).withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Page number (1-based page.id)
                    Container(
                      width: 28,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? const Color(0xFFE8DCC0)
                            : isCompleted
                                ? Colors.green.withOpacity(0.2)
                                : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${page.id}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCurrent 
                                ? Colors.black
                                : isCompleted
                                    ? Colors.green
                                    : isLocked
                                        ? Colors.white24
                                        : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Page info with local page number
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Seite ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLocked 
                                  ? Colors.white24 
                                  : isCurrent
                                      ? const Color(0xFFE8DCC0)
                                      : Colors.white54,
                            ),
                          ),
                          if (page.hasImage) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.image_rounded, size: 12, 
                                 color: Colors.white.withOpacity(0.3)),
                          ],
                          if (page.hasChoices) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.call_split_rounded, size: 12,
                                 color: const Color(0xFFE8DCC0).withOpacity(0.5)),
                          ],
                        ],
                      ),
                    ),
                    
                    // Status
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8DCC0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HIER',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE8DCC0),
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (isCompleted)
                      const Icon(Icons.check, size: 14, color: Colors.green)
                    else if (isLocked)
                      Icon(Icons.lock_outline, size: 12, color: Colors.white.withOpacity(0.2)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Internal helper class for scene information
class _SceneInfo {
  final String sceneId;
  final int sceneNumber;
  final int startPageIndex;
  final int endPageIndex;
  final int pageCount;
  final String? title;
  final bool hasChoices;
  final bool hasImage;
  final int firstPageId;
  final int lastPageId;

  const _SceneInfo({
    required this.sceneId,
    required this.sceneNumber,
    required this.startPageIndex,
    required this.endPageIndex,
    required this.pageCount,
    required this.firstPageId,
    required this.lastPageId,
    this.title,
    this.hasChoices = false,
    this.hasImage = false,
  });
}
