import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/series_metadata.dart';
import '../../../../domain/models/diamond_models.dart';
import '../../providers/reading_progress_provider.dart';
import '../../../diamonds/providers/diamond_providers.dart';
import '../../../diamonds/presentation/widgets/episode_unlock_dialog.dart';
import '../../../diamonds/presentation/widgets/diamond_balance_widget.dart';

/// Sheet for selecting an episode from a series
class EpisodeSelectionSheet extends ConsumerStatefulWidget {
  final SeriesMetadata series;
  final void Function(EpisodeInfo episode) onEpisodeSelected;

  const EpisodeSelectionSheet({
    super.key,
    required this.series,
    required this.onEpisodeSelected,
  });

  /// Show the episode selection sheet and return the selected episode
  static Future<EpisodeInfo?> show(
    BuildContext context, {
    required SeriesMetadata series,
  }) {
    return showModalBottomSheet<EpisodeInfo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EpisodeSelectionSheet(
        series: series,
        onEpisodeSelected: (episode) => Navigator.of(context).pop(episode),
      ),
    );
  }

  @override
  ConsumerState<EpisodeSelectionSheet> createState() => _EpisodeSelectionSheetState();
}

class _EpisodeSelectionSheetState extends ConsumerState<EpisodeSelectionSheet> {
  Set<int> _completedEpisodes = {};
  Set<int> _unlockedEpisodes = {};
  int _currentEpisode = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progressService = ref.read(readingProgressServiceProvider);
      
      // Load progress data (fast, from SharedPreferences)
      final completed = await progressService.getCompletedEpisodes(widget.series.seriesId);
      final current = await progressService.getCurrentEpisode(widget.series.seriesId);
      
      // Update UI immediately with progress data
      if (mounted) {
        setState(() {
          _completedEpisodes = completed;
          _currentEpisode = current;
          _isLoading = false;
        });
      }
      
      // Load unlock data in background (optional, only matters for episodes > 3)
      _loadUnlockedEpisodes();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadUnlockedEpisodes() async {
    try {
      final diamondRepo = ref.read(diamondRepositoryProvider);
      final unlocked = await diamondRepo.getUnlockedEpisodes(widget.series.seriesId);
      
      if (mounted) {
        setState(() {
          _unlockedEpisodes = unlocked;
        });
      }
    } catch (e) {
      // Ignore - episodes 1-3 are free anyway
    }
  }

  EpisodeStatus _getEpisodeStatus(EpisodeInfo episode) {
    if (_completedEpisodes.contains(episode.number)) {
      return EpisodeStatus.completed;
    }
    if (episode.number == _currentEpisode) {
      return EpisodeStatus.inProgress;
    }
    // All episodes are available (no locking)
    return EpisodeStatus.available;
  }

  bool _isEpisodeFree(int episodeNumber) {
    return episodeNumber <= EpisodeUnlockStatus.freeEpisodeCount;
  }

  bool _isEpisodeUnlocked(int episodeNumber) {
    // First 3 episodes are always free
    if (_isEpisodeFree(episodeNumber)) return true;
    // Check if unlocked with diamonds
    return _unlockedEpisodes.contains(episodeNumber);
  }

  Future<void> _handleEpisodeTap(EpisodeInfo episode) async {
    if (_isEpisodeUnlocked(episode.number)) {
      // Episode is free or already unlocked
      widget.onEpisodeSelected(episode);
    } else {
      // Show unlock dialog
      final unlocked = await EpisodeUnlockDialog.show(
        context,
        seriesId: widget.series.seriesId,
        episodeNumber: episode.number,
        episodeTitle: episode.title,
        onUnlocked: () {
          // Add to local unlocked set immediately
          if (mounted) {
            setState(() {
              _unlockedEpisodes.add(episode.number);
            });
          }
        },
      );
      
      if (unlocked && mounted) {
        // Auto-start the episode after unlock
        widget.onEpisodeSelected(episode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = _completedEpisodes.length;
    final totalEpisodes = widget.series.episodeCount;
    final progressPercent = totalEpisodes > 0 ? completedCount / totalEpisodes : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2520),
            Color(0xFF1A1512),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Diamond balance at top right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const DiamondBalanceWidget(
                        compact: true,
                        // No onTap = no plus icon shown
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Series icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.movie_filter_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Series title
                  Text(
                    widget.series.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFDF0FF),
                      fontFamily: 'Mynerve',
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Episode count and progress
                  Text(
                    '$completedCount von $totalEpisodes Episoden abgeschlossen',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                              width: constraints.maxWidth * progressPercent,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.7),
                                  ],
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
            ),
            
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            
            // Episode list
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.series.episodes.length,
                      itemBuilder: (context, index) {
                        final episode = widget.series.episodes[index];
                        final status = _getEpisodeStatus(episode);
                        final isFree = _isEpisodeFree(episode.number);
                        final isUnlocked = _isEpisodeUnlocked(episode.number);
                        return _EpisodeCard(
                          episode: episode,
                          status: status,
                          isFree: isFree,
                          isUnlocked: isUnlocked,
                          unlockCost: isFree ? 0 : EpisodeUnlockStatus.standardUnlockCost,
                          onTap: () => _handleEpisodeTap(episode),
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final EpisodeInfo episode;
  final EpisodeStatus status;
  final bool isFree;
  final bool isUnlocked;
  final int unlockCost;
  final VoidCallback? onTap;

  const _EpisodeCard({
    required this.episode,
    required this.status,
    required this.isFree,
    required this.isUnlocked,
    required this.unlockCost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsUnlock = !isFree && !isUnlocked;
    final isCompleted = status == EpisodeStatus.completed;
    final isInProgress = status == EpisodeStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isInProgress
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : needsUnlock
                      ? const Color(0xFF1E1E2E)
                      : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isInProgress
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : needsUnlock
                            ? const Color(0xFF4ECDC4).withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                width: isInProgress ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Episode number badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: needsUnlock
                        ? const LinearGradient(
                            colors: [Color(0xFF2D4A3E), Color(0xFF1E3A2F)],
                          )
                        : LinearGradient(
                            colors: isCompleted
                                ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                                : isInProgress
                                    ? [theme.colorScheme.primary.withOpacity(0.4), theme.colorScheme.primary.withOpacity(0.2)]
                                    : [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: needsUnlock
                        ? const Icon(
                            Icons.diamond_outlined,
                            color: Color(0xFF4ECDC4),
                            size: 20,
                          )
                        : isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.green,
                                size: 22,
                              )
                            : Text(
                                '${episode.number}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isInProgress
                                      ? theme.colorScheme.primary
                                      : const Color(0xFFFDF0FF),
                                ),
                              ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Episode info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFDF0FF),
                        ),
                      ),
                      if (episode.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          episode.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (episode.estimatedMinutes != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '~${episode.estimatedMinutes} Min.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action indicator or price
                if (needsUnlock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$unlockCost',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isFree && !isCompleted && !isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'GRATIS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isInProgress
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      isInProgress
                          ? Icons.play_arrow_rounded
                          : isCompleted
                              ? Icons.replay_rounded
                              : Icons.arrow_forward_ios_rounded,
                      color: isInProgress
                          ? theme.colorScheme.primary
                          : Colors.white.withOpacity(0.6),
                      size: isInProgress ? 20 : 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

