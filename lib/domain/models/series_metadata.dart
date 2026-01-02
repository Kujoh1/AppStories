/// Metadata for a series (collection of episodes)
class SeriesMetadata {
  final String seriesId;
  final String title;
  final String author;
  final String? coverImage;
  final List<EpisodeInfo> episodes;

  const SeriesMetadata({
    required this.seriesId,
    required this.title,
    required this.author,
    this.coverImage,
    required this.episodes,
  });

  /// Total number of episodes in this series
  int get episodeCount => episodes.length;

  /// Get episode by number (1-based)
  EpisodeInfo? getEpisode(int number) {
    return episodes.firstWhere(
      (e) => e.number == number,
      orElse: () => episodes.first,
    );
  }
}

/// Information about a single episode in a series
class EpisodeInfo {
  final int number;
  final String title;
  final String filePath;
  final String? description;
  final int? estimatedMinutes;

  const EpisodeInfo({
    required this.number,
    required this.title,
    required this.filePath,
    this.description,
    this.estimatedMinutes,
  });

  /// Display title with episode number
  String get displayTitle => 'Episode $number: $title';

  /// Short display (just number)
  String get shortTitle => 'Ep. $number';
}

/// Progress state for an episode
enum EpisodeStatus {
  locked,    // Not yet available
  available, // Can be started (first episode or previous completed)
  inProgress,// Currently being read
  completed, // Fully read
}

/// Episode with its current status
class EpisodeWithStatus {
  final EpisodeInfo episode;
  final EpisodeStatus status;
  final double? progressPercent; // 0.0 - 1.0 for in-progress episodes

  const EpisodeWithStatus({
    required this.episode,
    required this.status,
    this.progressPercent,
  });

  bool get isPlayable => status == EpisodeStatus.available || 
                         status == EpisodeStatus.inProgress ||
                         status == EpisodeStatus.completed;
}

