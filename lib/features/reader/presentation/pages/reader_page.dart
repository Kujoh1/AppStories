import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/story_constants.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';
import '../widgets/reader_app_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/animated_story_text.dart';

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

class _ReaderPageState extends ConsumerState<ReaderPage> 
    with SingleTickerProviderStateMixin {
  bool _isPaused = false;
  bool _isLoadingNextChapter = false;
  late AnimationController _barsAnimationController;
  late Animation<double> _barsAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation for bars visibility
    _barsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _barsAnimation = CurvedAnimation(
      parent: _barsAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    // Preload next chapter in background
    _preloadNextChapter();
  }

  @override
  void dispose() {
    _barsAnimationController.dispose();
    super.dispose();
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
    if (isPaused) {
      _barsAnimationController.forward();
    } else {
      _barsAnimationController.reverse();
    }
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
      body: chapterAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
        data: (chapter) {
          final bookIndex = bookIndexAsync.valueOrNull;
          final totalChapters = bookIndex?.chapterCount ?? 1;
          final hasNext = chapterIndex + 1 < totalChapters;
          final hasPrevious = chapterIndex > 0;

          return Stack(
            children: [
              Scaffold(
                extendBodyBehindAppBar: true,
                appBar: _isPaused ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight + 4),
                  child: AnimatedBuilder(
                    animation: _barsAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -kToolbarHeight * (1 - _barsAnimation.value)),
                      child: Opacity(
                        opacity: _barsAnimation.value,
                        child: child,
                      ),
                    ),
                    child: ReaderAppBar(
                      title: chapter.title,
                      currentPage: chapterIndex + 1,
                      totalPages: totalChapters,
                      onBackTap: () => Navigator.of(context).pop(),
                      onSettingsTap: () => _showSettingsSheet(context),
                    ),
                  ),
                ) : null,
                body: Align(
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
                    ),
                  ),
                ),
                bottomNavigationBar: _isPaused ? AnimatedBuilder(
                  animation: _barsAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, 80 * (1 - _barsAnimation.value)),
                    child: Opacity(
                      opacity: _barsAnimation.value,
                      child: child,
                    ),
                  ),
                  child: PageNavigationBar(
                    canGoBack: hasPrevious,
                    canGoForward: hasNext,
                    onPreviousPressed: _handlePreviousChapter,
                    onNextPressed: _handleNextChapter,
                  ),
                ) : null,
              ),
              
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
