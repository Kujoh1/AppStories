import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/series_metadata.dart';
import '../../providers/reading_progress_provider.dart';

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
  int _currentEpisode = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progressService = ref.read(readingProgressServiceProvider);
    final completed = await progressService.getCompletedEpisodes(widget.series.seriesId);
    final current = await progressService.getCurrentEpisode(widget.series.seriesId);
    
    if (mounted) {
      setState(() {
        _completedEpisodes = completed;
        _currentEpisode = current;
        _isLoading = false;
      });
    }
  }

  EpisodeStatus _getEpisodeStatus(EpisodeInfo episode) {
    if (_completedEpisodes.contains(episode.number)) {
      return EpisodeStatus.completed;
    }
    if (episode.number == _currentEpisode) {
      return EpisodeStatus.inProgress;
    }
    // All episodes are always available
    return EpisodeStatus.available;
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
                        return _EpisodeCard(
                          episode: episode,
                          status: status,
                          onTap: status != EpisodeStatus.locked
                              ? () => widget.onEpisodeSelected(episode)
                              : null,
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
  final VoidCallback? onTap;

  const _EpisodeCard({
    required this.episode,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = status == EpisodeStatus.locked;
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
                  : Colors.white.withOpacity(isLocked ? 0.02 : 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isInProgress
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(isLocked ? 0.05 : 0.1),
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
                    gradient: isLocked
                        ? null
                        : LinearGradient(
                            colors: isCompleted
                                ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                                : isInProgress
                                    ? [theme.colorScheme.primary.withOpacity(0.4), theme.colorScheme.primary.withOpacity(0.2)]
                                    : [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                          ),
                    color: isLocked ? Colors.white.withOpacity(0.05) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isLocked
                        ? Icon(
                            Icons.lock_rounded,
                            color: Colors.white.withOpacity(0.3),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? Colors.white.withOpacity(0.4)
                              : const Color(0xFFFDF0FF),
                        ),
                      ),
                      if (episode.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          episode.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(isLocked ? 0.25 : 0.5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (episode.estimatedMinutes != null && !isLocked) ...[
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
                
                // Action indicator
                if (!isLocked)
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

