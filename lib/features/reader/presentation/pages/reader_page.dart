import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/story_constants.dart';
import '../../../../core/widgets/interactive_text_container.dart';
import '../../../../domain/models/choice.dart';
import '../../providers/book_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/reader_state_provider.dart';
import '../widgets/reader_app_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/choice_card.dart';
import '../widgets/animated_story_text.dart';

/// Main reader screen for displaying story pages
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
  late String _currentPageId;
  bool _isPaused = false;
  late AnimationController _barsAnimationController;
  late Animation<double> _barsAnimation;

  @override
  void initState() {
    super.initState();
    _currentPageId = widget.initialPageId;
    
    // Animation for bars visibility
    _barsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _barsAnimation = CurvedAnimation(
      parent: _barsAnimationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _barsAnimationController.dispose();
    super.dispose();
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

  void _navigateToPage(String pageId) {
    setState(() {
      _currentPageId = pageId;
    });
  }

  void _handleNextPage() {
    final navigation = ref.read(navigationProvider.notifier);
    final nextPage = navigation.getNextPage(_currentPageId);
    if (nextPage != null) {
      _navigateToPage(nextPage.id);
    }
  }

  void _handlePreviousPage() {
    final navigation = ref.read(navigationProvider.notifier);
    final previousPage = navigation.getPreviousPage(_currentPageId);
    if (previousPage != null) {
      _navigateToPage(previousPage.id);
    }
  }

  void _handleChoiceSelected(Choice choice) {
    _navigateToPage(choice.nextPageId);
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookProvider);
    final navigation = ref.watch(navigationProvider.notifier);
    final readerState = ref.watch(readerStateProvider(_currentPageId));

    return Scaffold(
      body: bookAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler beim Laden: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(bookProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
        data: (book) {
          final currentPage = book.getPage(_currentPageId);
          if (currentPage == null) {
            return const Center(
              child: Text('Seite nicht gefunden'),
            );
          }

          final (currentPageNum, totalPages) =
              navigation.getProgress(_currentPageId);
          final hasNext = navigation.hasNextPage(_currentPageId);
          final hasPrevious = navigation.hasPreviousPage(_currentPageId);

          return Scaffold(
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
                  title: currentPage.title,
                  currentPage: currentPageNum,
                  totalPages: totalPages,
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
                child: _buildPageContent(currentPage, readerState),
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
              child: currentPage.hasBranching
                  ? _buildChoicesSection(currentPage.choices)
                  : PageNavigationBar(
                      canGoBack: hasPrevious,
                      canGoForward: hasNext,
                      onPreviousPressed: _handlePreviousPage,
                      onNextPressed: _handleNextPage,
                    ),
            ) : null,
          );
        },
      ),
    );
  }

  Widget _buildPageContent(dynamic currentPage, ReaderState readerState) {
    // Use special animated text for page_1, regular for others
    if (_currentPageId == 'page_1') {
      return DecorativeStoryText(
        text: currentPage.content,
        onPauseChanged: _onPauseChanged,
      );
    }

    return InteractiveTextContainer(
      text: currentPage.content,
      textScale: readerState.textScale,
      zoom: readerState.zoom,
      fontFamily: readerState.fontFamily,
      baseTextStyle: Theme.of(context).textTheme.bodyLarge,
      onZoomChanged: (zoom) {
        ref.read(readerStateProvider(_currentPageId).notifier).setZoom(zoom);
      },
    );
  }

  Widget _buildMediaSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minWidth: StoryConstants.canvasMinWidth,
        maxWidth: StoryConstants.canvasMaxWidth,
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A1410).withOpacity(0.8)
            : const Color(0xFFF5F0E8).withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDark 
                ? const Color(0xFFD4AF37).withOpacity(0.3)
                : const Color(0xFF8B4513).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: isDark 
                  ? const Color(0xFFD4AF37).withOpacity(0.5)
                  : const Color(0xFF8B4513).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Medienbereich',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark 
                    ? const Color(0xFFE8DCC0).withOpacity(0.7)
                    : const Color(0xFF2C1810).withOpacity(0.7),
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platzhalter für Bilder & Interaktionen',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark 
                    ? const Color(0xFFE8DCC0).withOpacity(0.5)
                    : const Color(0xFF2C1810).withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesSection(List<dynamic> choices) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ChoicesList(
            choices: choices.cast<Choice>(),
            onChoiceSelected: _handleChoiceSelected,
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final readerNotifier = ref.read(readerStateProvider(_currentPageId).notifier);
    final readerState = ref.read(readerStateProvider(_currentPageId));

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
                'Textgröße: ${(readerState.textScale * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => readerNotifier.decreaseTextScale(),
                  ),
                  Expanded(
                    child: Slider(
                      value: readerState.textScale,
                      min: AppConstants.minTextScale,
                      max: AppConstants.maxTextScale,
                      divisions: 12,
                      label: '${(readerState.textScale * 100).toInt()}%',
                      onChanged: (value) => readerNotifier.setTextScale(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => readerNotifier.increaseTextScale(),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Center(
                child: FilledButton.icon(
                  onPressed: () {
                    readerNotifier.resetTextScale();
                    readerNotifier.resetZoom();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Zurücksetzen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


