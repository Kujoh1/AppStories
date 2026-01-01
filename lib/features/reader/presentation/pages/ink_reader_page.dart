import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../../domain/models/story_page.dart';
import '../../providers/book_provider.dart';
import '../../providers/page_state_provider.dart';
import '../../providers/reading_progress_provider.dart';
import '../widgets/page_view_widget.dart';
import '../widgets/chapter_overview_dialog.dart';
import '../../../settings/presentation/settings_dialog.dart';
import '../../../settings/providers/settings_provider.dart';

/// Reader page for Ink format stories with choices
/// Uses the new unified page model for consistent navigation
class InkReaderPage extends ConsumerStatefulWidget {
  const InkReaderPage({super.key});

  @override
  ConsumerState<InkReaderPage> createState() => _InkReaderPageState();
}

class _InkReaderPageState extends ConsumerState<InkReaderPage>
    with TickerProviderStateMixin {
  
  // Background animation
  late AnimationController _bgController;
  late Animation<double> _bgOpacity;
  static const double _backgroundMaxOpacity = 0.03;
  
  String? _currentBackground;
  String? _previousBackground;
  
  // Viewport size for page calculation
  Size? _viewportSize;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgOpacity = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );
    // Note: Page index is set by HomePage before navigation
    // Either to 0 (start from beginning) or to saved progress
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Store viewport size for page calculation
          _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
          
          return _buildContent(constraints);
        },
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final bookId = ref.watch(selectedBookIdProvider);
    
    if (_viewportSize == null) {
      return _buildLoadingScreen();
    }
    
    final params = PageAnalysisParams(
      bookId: bookId,
      viewportWidth: _viewportSize!.width,
      viewportHeight: _viewportSize!.height - 56 - MediaQuery.of(context).padding.top, // Subtract app bar
    );
    
    final pagedBookAsync = ref.watch(pagedBookProvider(params));
    
    return pagedBookAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
      data: (pagedBook) => _buildReader(pagedBook, params),
    );
  }

  Widget _buildReader(PagedBook pagedBook, PageAnalysisParams params) {
    final pageIndex = ref.watch(currentPageIndexProvider);
    final settings = ref.watch(settingsProvider);
    final bookId = ref.watch(selectedBookIdProvider);
    
    // Safety check
    if (pagedBook.pages.isEmpty) {
      return _buildEndScreen();
    }
    
    // Clamp page index
    final safePageIndex = pageIndex.clamp(0, pagedBook.pages.length - 1);
    if (safePageIndex != pageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentPageIndexProvider.notifier).state = safePageIndex;
      });
    }
    
    final currentPage = pagedBook.pages[safePageIndex];
    
    // Check for story end
    if (safePageIndex >= pagedBook.pages.length) {
      return _buildEndScreen();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        _buildBackgroundLayer(),

        // Dark overlay for readability
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
              // App bar
              _buildAppBar(currentPage, pagedBook),

              // Page view widget
              Expanded(
                child: PageViewWidget(
                  key: ValueKey(currentPage.id),
                  page: currentPage,
                  totalPages: pagedBook.totalPages,
                  skipAnimation: settings.skipAnimation,
                  speedMultiplier: settings.speedMultiplier,
                  onNext: () => _goToNextPage(pagedBook),
                  onPrevious: () => _goToPreviousPage(),
                  onChoiceSelected: (choice) => _handleChoice(choice, pagedBook, params),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToNextPage(PagedBook pagedBook) {
    final currentIndex = ref.read(currentPageIndexProvider);
    if (currentIndex < pagedBook.pages.length - 1) {
      final newIndex = currentIndex + 1;
      ref.read(currentPageIndexProvider.notifier).state = newIndex;
      // Save progress with total pages
      _saveProgress(newIndex, pagedBook.totalPages);
    } else {
      // End of book
      _showEndScreen();
    }
  }

  void _goToPreviousPage() {
    final currentIndex = ref.read(currentPageIndexProvider);
    if (currentIndex > 0) {
      ref.read(currentPageIndexProvider.notifier).state = currentIndex - 1;
    }
  }

  void _handleChoice(PageChoice choice, PagedBook pagedBook, PageAnalysisParams params) {
    // Record the choice
    final currentPage = pagedBook.pages[ref.read(currentPageIndexProvider)];
    ref.read(readingStateProvider.notifier).recordChoice(
      currentPage.sceneId,
      choice.targetSceneId,
      choice.text,
    );
    
    // Navigate to the target scene
    final targetPageIndex = pagedBook.getPageIndexForScene(choice.targetSceneId);
    if (targetPageIndex != null) {
      ref.read(currentPageIndexProvider.notifier).state = targetPageIndex;
      // Save progress with total pages
      _saveProgress(targetPageIndex, pagedBook.totalPages);
    }
  }
  
  void _saveProgress(int pageIndex, int totalPages) {
    if (pageIndex > 0) {
      final bookId = ref.read(selectedBookIdProvider);
      ref.read(readingProgressServiceProvider).saveProgress(bookId, pageIndex, totalPages);
    }
  }

  void _showEndScreen() {
    // Navigate to end screen or show completion dialog
    setState(() {});
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: _buildDefaultGradient(),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFE8DCC0),
            ),
            SizedBox(height: 16),
            Text(
              'Seiten werden berechnet...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontFamily: 'Mynerve',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    final bookId = ref.watch(selectedBookIdProvider);
    
    return Container(
      decoration: _buildDefaultGradient(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFE8DCC0),
              ),
              const SizedBox(height: 24),
              Text(
                'Fehler beim Laden',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFE8DCC0),
                  fontFamily: 'Mynerve',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  if (_viewportSize != null) {
                    ref.invalidate(pagedBookProvider(PageAnalysisParams(
                      bookId: bookId,
                      viewportWidth: _viewportSize!.width,
                      viewportHeight: _viewportSize!.height - 56,
                    )));
                  }
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient (always visible)
        Container(decoration: _buildDefaultGradient()),

        // Previous background (fading out)
        if (_previousBackground != null)
          Opacity(
            opacity: _backgroundMaxOpacity,
            child: SmartImage(
              key: ValueKey('bg_prev_$_previousBackground'),
              assetPath: _previousBackground!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallback: const SizedBox.shrink(),
            ),
          ),

        // Current background (fading in)
        if (_currentBackground != null)
          FadeTransition(
            opacity: _bgOpacity.drive(
              Tween<double>(begin: 0.0, end: _backgroundMaxOpacity),
            ),
            child: SmartImage(
              key: ValueKey('bg_curr_$_currentBackground'),
              assetPath: _currentBackground!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallback: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  BoxDecoration _buildDefaultGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0806),
          Color(0xFF12100C),
          Color(0xFF0A0806),
        ],
      ),
    );
  }

  Widget _buildAppBar(StoryPage currentPage, PagedBook pagedBook) {
    final canGoBack = ref.watch(currentPageIndexProvider) > 0;
    
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              canGoBack ? Icons.arrow_back_rounded : Icons.close_rounded,
              color: Colors.white38,
              size: 22,
            ),
            onPressed: () {
              if (canGoBack) {
                _goToPreviousPage();
              } else {
                context.go('/');
              }
            },
            tooltip: canGoBack ? 'Zurück' : 'Schließen',
          ),

          // Scene overview button
          IconButton(
            icon: const Icon(Icons.account_tree, color: Colors.white38, size: 20),
            onPressed: () => _showSceneOverview(pagedBook),
            tooltip: 'Szenen-Übersicht',
          ),

          // Page indicator
          Expanded(
            child: Text(
              '${currentPage.id} / ${pagedBook.totalPages}',
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

          // Home
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white38, size: 20),
            onPressed: () => context.go('/'),
            tooltip: 'Zum Startbildschirm',
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    final theme = Theme.of(context);

    return Container(
      decoration: _buildDefaultGradient(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 56,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Ende der Geschichte',
                style: TextStyle(
                  color: const Color(0xFFE8DCC0),
                  fontSize: 26,
                  fontFamily: 'Mynerve',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Du hast deine eigene Version geschrieben.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Mynerve',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetStory,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Nochmal spielen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.library_books_rounded, size: 18),
                    label: const Text('Bibliothek'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetStory() {
    _currentBackground = null;
    _previousBackground = null;
    ref.read(currentPageIndexProvider.notifier).state = 0;
    ref.read(readingStateProvider.notifier).reset();
  }

  void _showSceneOverview(PagedBook pagedBook) {
    final currentIndex = ref.read(currentPageIndexProvider);
    
    PageOverviewDialog.show(
      context,
      pagedBook: pagedBook,
      currentPageIndex: currentIndex.clamp(0, pagedBook.pages.length - 1),
      isInkStory: true,
      onNavigate: (pageIndex) {
        ref.read(currentPageIndexProvider.notifier).state = pageIndex;
      },
    );
  }
}
