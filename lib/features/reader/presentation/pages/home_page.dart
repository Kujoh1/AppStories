import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/repositories/book_repository.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';
import '../../providers/reading_progress_provider.dart';
import '../../providers/page_state_provider.dart';
import '../widgets/continue_reading_sheet.dart';

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

  Future<void> _startBook() async {
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
      
      // Wait for UI to render
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      
      if (shouldContinue) {
        // Continue from saved position
        _loadBook(startFromPage: savedProgress.pageIndex);
      } else {
        // Start from beginning - clear progress async
        progressService.clearProgress(selectedBookId);
        _loadBook(startFromPage: 0);
      }
    } else {
      // No saved progress - loading UI already shown, start loading
      _loadBook(startFromPage: 0);
    }
  }
  
  Timer? _progressTimer;
  
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
                      const SizedBox(height: AppConstants.paddingXLarge),
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
                          data: (books) => 'Verfügbare Bücher (${books.length})',
                          loading: () => 'Verfügbare Bücher',
                          error: (_, __) => 'Verfügbare Bücher',
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
                              itemBuilder: (context, index) {
                                final book = books[index];
                                final isSelected = selectedBookId == book.id;
                                final format = repository.getStoryFormat(book.id);
                                final isInk = format == StoryFormat.ink;
                                
                                // Get chapter count from cached indexes
                                final chapterCount = allIndexesAsync.whenOrNull(
                                  data: (indexes) => indexes[book.id]?.chapterCount ?? 0,
                                ) ?? 0;
                                final isLoadingChapters = allIndexesAsync.isLoading;
                                
                                // Debug: Log loading state
                                if (isLoadingChapters) {
                                  print('DEBUG: All book indexes are loading...');
                                } else if (chapterCount > 0) {
                                  print('DEBUG: Book ${book.id} has $chapterCount chapters (from cache)');
                                }
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected 
                                    ? BorderSide(color: theme.colorScheme.primary, width: 2)
                                    : BorderSide.none,
                                ),
                                child: InkWell(
                                  onTap: _isLoading ? null : () {
                                    ref.read(selectedBookIdProvider.notifier).state = book.id;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                book.title,
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (isInk)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Interaktiv',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: theme.colorScheme.onPrimaryContainer,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'von ${book.author}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              isInk ? Icons.gamepad : Icons.menu_book,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _getChapterDisplayText(isInk, chapterCount, isLoadingChapters),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            const Spacer(),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Start button
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _startBook,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Ausgewähltes Buch starten'),
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
