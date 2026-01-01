import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/repositories/book_repository.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';

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
    final selectedBookId = ref.read(selectedBookIdProvider);
    final repository = ref.read(bookRepositoryProvider);
    final format = repository.getStoryFormat(selectedBookId);
    
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Lade Geschichte...';
      _loadingProgress = 0.2;
    });

    try {
      if (format == StoryFormat.ink) {
        // Load Ink story
        setState(() {
          _loadingMessage = 'Lade interaktive Geschichte...';
          _loadingProgress = 0.5;
        });
        
        await ref.read(inkStoryProvider.future);
        
        if (!mounted) return;
        
        setState(() {
          _loadingMessage = 'Bereit!';
          _loadingProgress = 1.0;
        });
        
        await Future.delayed(const Duration(milliseconds: 150));
        
        if (!mounted) return;
        
        // Navigate to Ink reader
        context.goToInkReader();
      } else {
        // Load regular story (DOCX)
        final bookIndex = await ref.read(bookIndexProvider(selectedBookId).future);
        
        if (!mounted) return;
        
        setState(() {
          _loadingMessage = 'Lade Kapitel 1 von ${bookIndex.chapterCount}...';
          _loadingProgress = 0.5;
        });
        
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
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
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
                        'Verfügbare Bücher',
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
        
        // Loading overlay with progress
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.85),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: Colors.white24,
                      color: theme.colorScheme.primary,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _loadingMessage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
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
