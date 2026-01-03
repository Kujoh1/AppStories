import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/device_service.dart';
import '../../../../data/repositories/book_repository.dart';
import '../../../../domain/models/series_metadata.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../diamonds/presentation/widgets/diamond_balance_widget.dart';
import '../../../diamonds/presentation/pages/diamond_purchase_page.dart';
import '../../../admin/presentation/pages/admin_page.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';
import '../../providers/reading_progress_provider.dart';
import '../../providers/page_state_provider.dart';
import '../widgets/continue_reading_sheet.dart';
import '../widgets/episode_selection_sheet.dart';
import '../widgets/book_card.dart';

/// Home page / landing page of the app
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;
  String _loadingMessage = '';
  double _loadingProgress = 0.0;
  
  // Episode-specific state
  int? _selectedEpisodeNumber;

  Future<void> _startBook() async {
    final selectedBookId = ref.read(selectedBookIdProvider);
    final repository = ref.read(bookRepositoryProvider);
    
    // Check if this is a series book
    if (repository.isSeriesBook(selectedBookId)) {
      final series = repository.getSeriesMetadata(selectedBookId);
      if (series != null) {
        // Show episode selection sheet
        final selectedEpisode = await EpisodeSelectionSheet.show(
          context,
          series: series,
        );
        
        if (selectedEpisode == null || !mounted) return;
        
        // Store selected episode and start loading
        _selectedEpisodeNumber = selectedEpisode.number;
        await _startEpisode(series, selectedEpisode);
        return;
      }
    }
    
    // Non-series book - continue with normal flow
    await _startNonSeriesBook();
  }
  
  Future<void> _startEpisode(SeriesMetadata series, EpisodeInfo episode) async {
    // Short delay after selection to prevent visual stutter
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    
    // Show loading UI
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Lade Episode ${episode.number}...';
      _loadingProgress = 0.0;
    });
    
    // Wait for UI to render smoothly
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    
    final progressService = ref.read(readingProgressServiceProvider);
    
    // Check for saved progress for this specific episode
    final savedProgress = await progressService.getEpisodeProgress(series.seriesId, episode.number);
    
    if (savedProgress != null && savedProgress.pageIndex > 0 && mounted) {
      // Hide loading temporarily for sheet
      setState(() {
        _isLoading = false;
      });
      
      // Show continue reading sheet with saved total pages
      final shouldContinue = await ContinueReadingSheet.show(
        context,
        bookTitle: '${series.title} - Ep. ${episode.number}',
        savedPageIndex: savedProgress.pageIndex,
        totalPages: savedProgress.totalPages,
      );
      
      if (!mounted) return;
      
      if (shouldContinue == null) {
        // User dismissed the sheet
        return;
      }
      
      // Show loading UI again after sheet closes
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Lade Episode ${episode.number}...';
        _loadingProgress = 0.0;
      });
      
      // Wait for UI to render properly
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      
      if (shouldContinue) {
        // Continue from saved position
        await _loadEpisode(series, episode, startFromPage: savedProgress.pageIndex);
      } else {
        // Start from beginning - clear progress async
        progressService.clearEpisodeProgress(series.seriesId, episode.number);
        await _loadEpisode(series, episode, startFromPage: 0);
      }
    } else {
      // No saved progress - start episode
      await _loadEpisode(series, episode, startFromPage: 0);
    }
  }
  
  Future<void> _startNonSeriesBook() async {
    // Short delay after button release to prevent visual stutter
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    
    // Show loading UI
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Lade Geschichte...';
      _loadingProgress = 0.0;
    });
    
    // Wait for UI to render smoothly
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    
    final selectedBookId = ref.read(selectedBookIdProvider);
    final progressService = ref.read(readingProgressServiceProvider);
    
    // Check for saved progress
    final savedProgress = await progressService.getProgress(selectedBookId);
    
    if (savedProgress != null && savedProgress.pageIndex > 0 && mounted) {
      // Get book info for the sheet
      final books = await ref.read(booksProvider.future);
      final book = books.firstWhere((b) => b.id == selectedBookId);
      
      if (!mounted) return;
      
      // Hide loading temporarily for sheet
      setState(() {
        _isLoading = false;
      });
      
      // Show continue reading sheet with saved total pages
      final shouldContinue = await ContinueReadingSheet.show(
        context,
        bookTitle: book.title,
        savedPageIndex: savedProgress.pageIndex,
        totalPages: savedProgress.totalPages,
      );
      
      if (!mounted) return;
      
      if (shouldContinue == null) {
        // User dismissed the sheet
        return;
      }
      
      // Show loading UI again after sheet closes
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Lade Geschichte...';
        _loadingProgress = 0.0;
      });
      
      // Wait for UI to render properly
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      
      if (shouldContinue) {
        // Continue from saved position
        await _loadBook(startFromPage: savedProgress.pageIndex);
      } else {
        // Start from beginning - clear progress async
        progressService.clearProgress(selectedBookId);
        await _loadBook(startFromPage: 0);
      }
    } else {
      // No saved progress - loading UI already shown, start loading
      await _loadBook(startFromPage: 0);
    }
  }
  
  Timer? _progressTimer;
  
  /// Load a specific episode from a series
  Future<void> _loadEpisode(SeriesMetadata series, EpisodeInfo episode, {required int startFromPage}) async {
    final repository = ref.read(bookRepositoryProvider);
    final settings = ref.read(settingsProvider);
    final progressService = ref.read(readingProgressServiceProvider);
    
    // Clear any previous pre-calculated data
    ref.read(preCalculatedBookProvider.notifier).state = null;
    
    // Set current episode
    await progressService.setCurrentEpisode(series.seriesId, episode.number);

    try {
      // Step 1: Load Episode Ink story file (0% -> 15%)
      setState(() {
        _loadingMessage = 'Lade Episode ${episode.number}...';
        _loadingProgress = 0.05;
      });
      
      final story = await repository.getEpisodeStory(series.seriesId, episode.number);
      
      if (!mounted) return;
      
      setState(() {
        _loadingProgress = 0.15;
      });
      
      // Step 2: Calculate viewport size
      final mediaQuery = MediaQuery.of(context);
      final screenSize = mediaQuery.size;
      final contentHeight = screenSize.height 
          - mediaQuery.padding.top    // SafeArea top
          - 56                        // AppBar height
          - mediaQuery.padding.bottom; // SafeArea bottom
      
      // Use episode-specific bookId for page analysis
      final episodeBookId = '${series.seriesId}_episode_${episode.number}';
      
      final params = PageAnalysisParams(
        bookId: episodeBookId,
        viewportWidth: screenSize.width,
        viewportHeight: contentHeight,
        fontFamily: settings.fontFamily,
        fontSize: settings.fontSizeValue,
      );
      
      // Step 3: Pre-calculate all pages
      bool calculationComplete = false;
      
      setState(() {
        _loadingMessage = 'Seiten werden berechnet...';
        _loadingProgress = 0.2;
      });
      
      // Important: Let UI render before starting heavy calculation
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (!mounted) return;
      
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || calculationComplete) {
          timer.cancel();
          return;
        }
        
        setState(() {
          final remaining = 0.85 - _loadingProgress;
          final increment = remaining * 0.03;
          _loadingProgress = (_loadingProgress + increment).clamp(0.2, 0.85);
          
          if (_loadingProgress < 0.45) {
            _loadingMessage = 'Seiten werden berechnet...';
          } else if (_loadingProgress < 0.65) {
            _loadingMessage = 'Layouts werden optimiert...';
          } else {
            _loadingMessage = 'Fast fertig...';
          }
        });
      });
      
      // Actually do the calculation
      final pagedBook = await ref.read(pagedBookProvider(params).future);
      calculationComplete = true;
      _progressTimer?.cancel();
      
      if (!mounted) return;
      
      // Store the result in persistent provider
      ref.read(preCalculatedBookProvider.notifier).state = PreCalculatedBook(
        book: pagedBook,
        params: params,
      );
      
      // Store episode info for the reader
      ref.read(currentEpisodeInfoProvider.notifier).state = (
        seriesId: series.seriesId,
        episodeNumber: episode.number,
        totalEpisodes: series.episodeCount,
      );
      
      // Set start page
      ref.read(currentPageIndexProvider.notifier).state = startFromPage;
      
      setState(() {
        _loadingMessage = 'Bereit!';
        _loadingProgress = 1.0;
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;
      
      // Navigate to Ink reader
      context.goToInkReader();
    } catch (e) {
      _progressTimer?.cancel();
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadBook({required int startFromPage}) async {
    final selectedBookId = ref.read(selectedBookIdProvider);
    final repository = ref.read(bookRepositoryProvider);
    final format = repository.getStoryFormat(selectedBookId);
    final settings = ref.read(settingsProvider);
    
    // Clear any previous pre-calculated data
    ref.read(preCalculatedBookProvider.notifier).state = null;

    try {
      if (format == StoryFormat.ink) {
        // Step 1: Load Ink story file (0% -> 15%)
        setState(() {
          _loadingMessage = 'Lade interaktive Geschichte...';
          _loadingProgress = 0.05;
        });
        
        await ref.read(inkStoryProvider.future);
        
        if (!mounted) return;
        
        setState(() {
          _loadingProgress = 0.15;
        });
        
        // Step 2: Calculate viewport size
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final contentHeight = screenSize.height 
            - mediaQuery.padding.top    // SafeArea top
            - 56                        // AppBar height
            - mediaQuery.padding.bottom; // SafeArea bottom
        
        final params = PageAnalysisParams(
          bookId: selectedBookId,
          viewportWidth: screenSize.width,
          viewportHeight: contentHeight,
          fontFamily: settings.fontFamily,
          fontSize: settings.fontSizeValue,
        );
        
        // Step 3: Pre-calculate all pages (this is the slow part!)
        // Start progress timer that slowly advances from 15% to 85%
        bool calculationComplete = false;
        
        setState(() {
          _loadingMessage = 'Seiten werden berechnet...';
          _loadingProgress = 0.2;
        });
        
        // Important: Let UI render before starting heavy calculation
        await Future.delayed(const Duration(milliseconds: 50));
        
        if (!mounted) return;
        
        _progressTimer?.cancel();
        _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (!mounted || calculationComplete) {
            timer.cancel();
            return;
          }
          
          setState(() {
            // Slowly advance progress, slowing down as we approach 85%
            final remaining = 0.85 - _loadingProgress;
            final increment = remaining * 0.03; // 3% of remaining distance
            _loadingProgress = (_loadingProgress + increment).clamp(0.2, 0.85);
            
            // Update message based on progress
            if (_loadingProgress < 0.45) {
              _loadingMessage = 'Seiten werden berechnet...';
            } else if (_loadingProgress < 0.65) {
              _loadingMessage = 'Layouts werden optimiert...';
            } else {
              _loadingMessage = 'Fast fertig...';
            }
          });
        });
        
        // Actually do the calculation (yields to UI every 5 knots)
        final pagedBook = await ref.read(pagedBookProvider(params).future);
        calculationComplete = true;
        _progressTimer?.cancel();
        
        if (!mounted) return;
        
        // Store the result in persistent provider!
        ref.read(preCalculatedBookProvider.notifier).state = PreCalculatedBook(
          book: pagedBook,
          params: params,
        );
        
        // Set start page
        ref.read(currentPageIndexProvider.notifier).state = startFromPage;
        
        // Animate to 100%
        setState(() {
          _loadingMessage = 'Bereit!';
          _loadingProgress = 1.0;
        });
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted) return;
        
        // Navigate to Ink reader (pages are already calculated and cached!)
        context.goToInkReader();
      } else {
        // Load regular story (DOCX)
        final bookIndex = await ref.read(bookIndexProvider(selectedBookId).future);
        
        if (!mounted) return;
        
        setState(() {
          _loadingMessage = 'Lade Kapitel...';
          _loadingProgress = 0.5;
        });
        
        // Set start page
        ref.read(currentPageIndexProvider.notifier).state = startFromPage;
        ref.read(currentChapterIndexProvider.notifier).state = 0;
        await ref.read(currentChapterProvider.future);
        
        if (!mounted) return;
        
        setState(() {
          _loadingMessage = 'Bereit!';
          _loadingProgress = 1.0;
        });
        
        await Future.delayed(const Duration(milliseconds: 150));
        
        if (!mounted) return;
        
        // Navigate to regular reader
        context.goToReader();
      }
    } catch (e) {
      _progressTimer?.cancel();
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use sorted books: new books first, then by last read time
    final booksAsync = ref.watch(sortedBooksProvider);
    final selectedBookId = ref.watch(selectedBookIdProvider);
    final repository = ref.watch(bookRepositoryProvider);
    final theme = Theme.of(context);
    
    // Watch book index for selected book to show chapter count
    final bookIndexAsync = ref.watch(bookIndexProvider(selectedBookId));

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Top bar with admin button (if admin) and diamond balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Admin button (only visible for admin device)
                          Consumer(
                            builder: (context, ref, _) {
                              final isAdminAsync = ref.watch(isAdminDeviceProvider);
                              return isAdminAsync.when(
                                data: (isAdmin) => isAdmin
                                    ? GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AdminPage(),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.admin_panel_settings,
                                            color: Color(0xFF4ECDC4),
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                          ),
                          // Diamond balance
                          DiamondBalanceWidget(
                            compact: true,
                            onTap: () => DiamondPurchasePage.show(context),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // App Icon/Logo
                      Icon(
                        Icons.auto_stories,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // App Title
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: 'Mynerve',
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),

                      // Subtitle
                      Text(
                        'Deine Bibliothek der interaktiven Geschichten',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),

                      Text(
                        booksAsync.when(
                          data: (books) => 'Verfügbare Stories (${books.length})',
                          loading: () => 'Verfügbare Stories',
                          error: (_, __) => 'Verfügbare Stories',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Books list
                      Expanded(
                        child: booksAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: AppConstants.paddingMedium),
                                Text('Fehler beim Laden: $error'),
                              ],
                            ),
                          ),
                          data: (books) {
                            // Watch all book indexes once
                            final allIndexesAsync = ref.watch(allBookIndexesProvider);
                            
                            return ListView.builder(
                              itemCount: books.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index) {
                                final book = books[index];
                                final isSelected = selectedBookId == book.id;
                                
                                // Check if this is a series book
                                final isSeries = repository.isSeriesBook(book.id);
                                final seriesMetadata = isSeries ? repository.getSeriesMetadata(book.id) : null;
                                
                                // Get chapter count from cached indexes
                                final chapterCount = allIndexesAsync.whenOrNull(
                                  data: (indexes) => indexes[book.id]?.chapterCount ?? 0,
                                ) ?? 0;
                                final isLoadingChapters = allIndexesAsync.isLoading;
                              
                                return BookCard(
                                  book: book,
                                  isSelected: isSelected,
                                  isSeries: isSeries,
                                  seriesMetadata: seriesMetadata,
                                  chapterCount: chapterCount,
                                  isLoadingChapters: isLoadingChapters,
                                  onTap: _isLoading ? () {} : () {
                                    ref.read(selectedBookIdProvider.notifier).state = book.id;
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Start button - only enabled when a story is selected
                      FilledButton.icon(
                        onPressed: (_isLoading || selectedBookId.isEmpty) ? null : _startBook,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Story starten'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.paddingMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Loading overlay with blur and progress
        if (_isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated book icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  size: 56,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        
                        // Loading message
                        Text(
                          _loadingMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFDF0FF),
                            fontFamily: 'Mynerve',
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Progress bar
                        SizedBox(
                          width: 220,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _loadingProgress,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  color: theme.colorScheme.primary,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${(_loadingProgress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'Mynerve',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get appropriate chapter display text based on loading state and format
  String _getChapterDisplayText(bool isInk, int chapterCount, bool isLoadingChapters) {
    if (isLoadingChapters) {
      return isInk ? 'Szenen werden geladen...' : 'Kapitel werden geladen...';
    }
    
    if (chapterCount > 0) {
      return isInk ? '$chapterCount Szenen' : '$chapterCount Kapitel';
    }
    
    // Fallback for when count is 0 (shouldn't happen normally)
    return isInk ? 'Interaktive Geschichte' : 'Klassische Geschichte';
  }
}

/// Widget to display series progress asynchronously
class _SeriesProgressText extends ConsumerWidget {
  final String seriesId;
  final int totalEpisodes;

  const _SeriesProgressText({
    required this.seriesId,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(
      seriesProgressProvider((seriesId: seriesId, totalEpisodes: totalEpisodes)),
    );
    final theme = Theme.of(context);

    return progressAsync.when(
      loading: () => Text(
        '$totalEpisodes Episoden',
        style: theme.textTheme.bodySmall,
      ),
      error: (_, __) => Text(
        '$totalEpisodes Episoden',
        style: theme.textTheme.bodySmall,
      ),
      data: (progress) {
        final completed = progress.completed;
        if (completed == 0) {
          return Text(
            '$totalEpisodes Episoden',
            style: theme.textTheme.bodySmall,
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$completed/$totalEpisodes Episoden',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            // Mini progress indicator
            SizedBox(
              width: 40,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: completed / totalEpisodes,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
