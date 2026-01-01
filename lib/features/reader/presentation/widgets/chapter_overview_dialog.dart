import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/chapter_info.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';

/// Beautiful chapter/scene overview dialog for navigation
class ChapterOverviewDialog extends ConsumerWidget {
  final bool isInkStory;
  final String currentChapterName;
  final int currentChapterIndex;
  final VoidCallback? onClose;

  const ChapterOverviewDialog({
    super.key,
    required this.isInkStory,
    required this.currentChapterName,
    required this.currentChapterIndex,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isInkStory,
    required String currentChapterName,
    required int currentChapterIndex,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ChapterOverviewDialog(
        isInkStory: isInkStory,
        currentChapterName: currentChapterName,
        currentChapterIndex: currentChapterIndex,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookId = ref.watch(selectedBookIdProvider);
    final bookIndexAsync = ref.watch(bookIndexProvider(bookId));

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

          // Header
          _buildHeader(context, ref),

          // Content
          Expanded(
            child: bookIndexAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE8DCC0),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fehler beim Laden: $error',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (bookIndex) => _buildChapterList(context, ref, bookIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final bookId = ref.watch(selectedBookIdProvider);
    final bookIndexAsync = ref.watch(bookIndexProvider(bookId));
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Icon(
                isInkStory ? Icons.account_tree : Icons.menu_book,
                color: const Color(0xFFE8DCC0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isInkStory ? 'Szenen-Übersicht' : 'Kapitel-Übersicht',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8DCC0),
                    fontFamily: 'Mynerve',
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white38,
                  size: 20,
                ),
                tooltip: 'Schließen',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress info
          bookIndexAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (bookIndex) {
              final progress = (currentChapterIndex + 1) / bookIndex.chapterCount;
              return Column(
                children: [
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8DCC0), Color(0xFFFEFFE9)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Progress text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentChapterIndex + 1} von ${bookIndex.chapterCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontFamily: 'Mynerve',
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}% abgeschlossen',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontFamily: 'Mynerve',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(BuildContext context, WidgetRef ref, BookIndex bookIndex) {
    // For Ink stories, get choice information
    final runtime = isInkStory ? ref.watch(inkRuntimeProvider) : null;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookIndex.chapterCount,
      itemBuilder: (context, index) {
        final chapter = bookIndex.chapters[index];
        final isCurrent = index == currentChapterIndex;
        final isCompleted = index < currentChapterIndex;
        final isLocked = index > currentChapterIndex;

        // Get choice information for Ink stories
        String? choiceText;
        if (isInkStory && runtime != null) {
          final choice = runtime.getChoiceToKnot(chapter.title);
          choiceText = choice?.choiceText;
        }

        return _buildChapterTile(
          context,
          ref,
          chapter,
          index,
          isCurrent: isCurrent,
          isCompleted: isCompleted,
          isLocked: isLocked,
          choiceText: choiceText,
        );
      },
    );
  }

  Widget _buildChapterTile(
    BuildContext context,
    WidgetRef ref,
    ChapterInfo chapter,
    int index, {
    required bool isCurrent,
    required bool isCompleted,
    required bool isLocked,
    String? choiceText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLocked ? null : () => _navigateToChapter(context, ref, index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isCurrent
                  ? const LinearGradient(
                      colors: [Color(0x40E8DCC0), Color(0x20E8DCC0)],
                    )
                  : null,
              color: isCurrent ? null : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFFE8DCC0).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(isCurrent, isCompleted, isLocked, choiceText),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getStatusIcon(isCurrent, isCompleted, isLocked, choiceText),
                    color: _getStatusIconColor(isCurrent, isCompleted, isLocked, choiceText),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Chapter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter number/name
                      Text(
                        isInkStory 
                            ? chapter.title
                            : 'Kapitel ${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isLocked 
                              ? Colors.white38
                              : isCurrent 
                                  ? const Color(0xFFE8DCC0)
                                  : Colors.white.withOpacity(0.87),
                          fontFamily: 'Mynerve',
                        ),
                      ),
                      
                      if (!isInkStory && chapter.title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          chapter.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: isLocked ? Colors.white24 : Colors.white54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Choice text (if available)
                      if (choiceText != null && choiceText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DCC0).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE8DCC0).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: const Color(0xFFE8DCC0).withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  choiceText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: const Color(0xFFE8DCC0).withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Status text
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(isCurrent, isCompleted, isLocked, choiceText),
                        style: TextStyle(
                          fontSize: 11,
                          color: isLocked ? Colors.white24 : Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow or lock
                Icon(
                  isLocked 
                      ? Icons.lock_outline
                      : Icons.arrow_forward_ios,
                  color: isLocked 
                      ? Colors.white24
                      : Colors.white38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isCurrent, bool isCompleted, bool isLocked, String? choiceText) {
    if (isLocked) return Colors.white10;
    if (isCurrent) return const Color(0xFFE8DCC0).withOpacity(0.2);
    if (isCompleted) {
      return choiceText != null 
          ? const Color(0xFFE8DCC0).withOpacity(0.15) // Golden for choices
          : Colors.green.withOpacity(0.2); // Green for regular completion
    }
    return Colors.white10;
  }

  IconData _getStatusIcon(bool isCurrent, bool isCompleted, bool isLocked, String? choiceText) {
    if (isLocked) return Icons.lock_outline;
    if (isCurrent) return Icons.play_circle_outline;
    if (isCompleted) {
      return choiceText != null 
          ? Icons.call_split_rounded // Branch icon for choices
          : Icons.check_circle_outline; // Check for regular completion
    }
    return Icons.radio_button_unchecked;
  }

  Color _getStatusIconColor(bool isCurrent, bool isCompleted, bool isLocked, String? choiceText) {
    if (isLocked) return Colors.white24;
    if (isCurrent) return const Color(0xFFE8DCC0);
    if (isCompleted) {
      return choiceText != null 
          ? const Color(0xFFE8DCC0) // Golden for choices
          : Colors.green; // Green for regular completion
    }
    return Colors.white38;
  }

  String _getStatusText(bool isCurrent, bool isCompleted, bool isLocked, String? choiceText) {
    if (isLocked) return 'Gesperrt';
    if (isCurrent) return 'Aktuell';
    if (isCompleted) {
      return choiceText != null ? 'Entscheidung getroffen' : 'Abgeschlossen';
    }
    return 'Verfügbar';
  }

  void _navigateToChapter(BuildContext context, WidgetRef ref, int chapterIndex) {
    if (isInkStory) {
      // For Ink stories, navigate to specific knot
      final bookId = ref.read(selectedBookIdProvider);
      final bookIndexAsync = ref.read(bookIndexProvider(bookId));
      
      bookIndexAsync.whenData((bookIndex) {
        if (chapterIndex < bookIndex.chapters.length) {
          final targetKnot = bookIndex.chapters[chapterIndex].title;
          // Navigate to specific knot in Ink story
          ref.read(inkRuntimeProvider.notifier).navigateToKnot(targetKnot);
        }
      });
    } else {
      // For regular books, update chapter index
      ref.read(currentChapterIndexProvider.notifier).state = chapterIndex;
    }
    
    // Close dialog
    Navigator.of(context).pop();
  }
}
