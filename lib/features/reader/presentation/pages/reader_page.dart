import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/story_constants.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';
import '../widgets/reader_app_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/animated_story_text.dart';
import '../widgets/chapter_overview_dialog.dart';
import '../../../settings/presentation/settings_dialog.dart';

/// Main reader screen for displaying story chapters
class ReaderPage extends ConsumerStatefulWidget {
  final String initialPageId;

  const ReaderPage({
    super.key,
    this.initialPageId = 'page_1',
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _isPaused = false;
  bool _isLoadingNextChapter = false;
  bool _showSwipeHint = false;
  Timer? _swipeHintTimer;

  @override
  void initState() {
    super.initState();
    
    // Preload next chapter in background
    _preloadNextChapter();
    
    // Start swipe hint timer
    _startSwipeHintTimer();
  }
  
  @override
  void dispose() {
    _swipeHintTimer?.cancel();
    super.dispose();
  }
  
  void _startSwipeHintTimer() {
    _swipeHintTimer?.cancel();
    _swipeHintTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showSwipeHint = true;
        });
        // Hide hint after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showSwipeHint = false;
            });
          }
        });
      }
    });
  }
  
  void _hideSwipeHint() {
    _swipeHintTimer?.cancel();
    setState(() {
      _showSwipeHint = false;
    });
  }
  
  void _preloadNextChapter() {
    // Trigger preload of next chapter in background
    Future.microtask(() {
      ref.read(preloadNextChapterProvider);
    });
  }
  
  void _onPauseChanged(bool isPaused) {
    setState(() {
      _isPaused = isPaused;
    });
    // No UI changes - pause only affects text animation
  }

  Future<void> _handleNextChapter() async {
    final bookId = ref.read(selectedBookIdProvider);
    final currentIndex = ref.read(currentChapterIndexProvider);
    final bookIndex = await ref.read(bookIndexProvider(bookId).future);
    
    if (currentIndex + 1 < bookIndex.chapterCount) {
      setState(() => _isLoadingNextChapter = true);
      
      // Load next chapter
      ref.read(currentChapterIndexProvider.notifier).state = currentIndex + 1;
      await ref.read(currentChapterProvider.future);
      
      if (mounted) {
        setState(() => _isLoadingNextChapter = false);
        // Preload the chapter after that
        _preloadNextChapter();
      }
    }
  }

  Future<void> _handlePreviousChapter() async {
    final currentIndex = ref.read(currentChapterIndexProvider);
    
    if (currentIndex > 0) {
      setState(() => _isLoadingNextChapter = true);
      
      ref.read(currentChapterIndexProvider.notifier).state = currentIndex - 1;
      await ref.read(currentChapterProvider.future);
      
      if (mounted) {
        setState(() => _isLoadingNextChapter = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = ref.watch(selectedBookIdProvider);
    final chapterIndex = ref.watch(currentChapterIndexProvider);
    final chapterAsync = ref.watch(currentChapterProvider);
    final bookIndexAsync = ref.watch(bookIndexProvider(bookId));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0806), // Match ink reader background
      body: chapterAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
        data: (chapter) {
          final bookIndex = bookIndexAsync.valueOrNull;
          final totalChapters = bookIndex?.chapterCount ?? 1;
          final hasNext = chapterIndex + 1 < totalChapters;
          final hasPrevious = chapterIndex > 0;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Dark overlay for readability (matching ink reader)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar (always visible for normal books)
                    _buildUnifiedAppBar(chapter.title, chapterIndex + 1, totalChapters),

                    // Story content with chapter navigation
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: (_) {
                          _hideSwipeHint();
                        },
                        onHorizontalDragEnd: (details) {
                          // Swipe left (negative velocity) = next chapter
                          // Swipe right (positive velocity) = previous chapter
                          final velocity = details.primaryVelocity ?? 0;
                          const threshold = 500.0; // Minimum swipe velocity
                          
                          if (velocity < -threshold && hasNext) {
                            _handleNextChapter();
                          } else if (velocity > threshold && hasPrevious) {
                            _handlePreviousChapter();
                          }
                        },
                        onTap: () {
                          _hideSwipeHint();
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: StoryConstants.canvasMinWidth,
                              maxWidth: StoryConstants.canvasMaxWidth,
                            ),
                            child: DecorativeStoryText(
                              key: ValueKey('chapter_$chapterIndex'),
                              text: chapter.content,
                              onPauseChanged: _onPauseChanged,
                              // Don't auto-advance chapters - let user control navigation
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // No UI changes during pause - pause only affects text animation
              
              // Loading overlay for chapter transitions
              if (_isLoadingNextChapter)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Lade nächstes Kapitel...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Swipe hint overlay
              if (_showSwipeHint && (hasNext || hasPrevious))
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFE8DCC0).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasPrevious) ...[
                            const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFFE8DCC0),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Vorheriges',
                              style: TextStyle(
                                color: Color(0xFFE8DCC0),
                                fontSize: 12,
                                fontFamily: 'Mynerve',
                              ),
                            ),
                          ],
                          if (hasPrevious && hasNext) ...[
                            const SizedBox(width: 16),
                            Container(
                              width: 1,
                              height: 16,
                              color: const Color(0xFFE8DCC0).withOpacity(0.3),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (hasNext) ...[
                            const Text(
                              'Nächstes',
                              style: TextStyle(
                                color: Color(0xFFE8DCC0),
                                fontSize: 12,
                                fontFamily: 'Mynerve',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFFE8DCC0),
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Lade Kapitel...'),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Fehler beim Laden: $error'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(currentChapterProvider),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  /// Build unified app bar matching the ink reader
  Widget _buildUnifiedAppBar(String title, int currentPage, int totalPages) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white38,
              size: 22,
            ),
            onPressed: () => _showChapterOverview(context),
            tooltip: 'Kapitel-Übersicht',
          ),

          // Chapter indicator
          Expanded(
            child: Text(
              '$title ($currentPage/$totalPages)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white24,
                letterSpacing: 1.5,
                fontFamily: 'Mynerve',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white38, size: 20),
            onPressed: () => SettingsDialog.show(context),
            tooltip: 'Einstellungen',
          ),

          // Home button (matching ink reader)
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white38, size: 20),
            onPressed: () => context.go('/'),
            tooltip: 'Zum Startbildschirm',
          ),
        ],
      ),
    );
  }

  void _showChapterOverview(BuildContext context) {
    final chapterIndex = ref.read(currentChapterIndexProvider);
    ChapterOverviewDialog.show(
      context,
      isInkStory: false,
      currentChapterName: 'Kapitel ${chapterIndex + 1}',
      currentChapterIndex: chapterIndex,
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leseeinstellungen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                'Weitere Optionen kommen bald...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }
}
