import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading progress data
class ReadingProgress {
  final int pageIndex;
  final int totalPages;
  final DateTime? lastReadAt;
  
  const ReadingProgress({
    required this.pageIndex,
    required this.totalPages,
    this.lastReadAt,
  });
  
  double get progressPercent => totalPages > 0 ? (pageIndex + 1) / totalPages : 0;
  
  /// Whether this book has been read at all
  bool get hasBeenRead => lastReadAt != null;
}

/// Stores and retrieves reading progress for each book
class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';
  static const String _totalPrefix = 'reading_total_';
  static const String _lastReadPrefix = 'reading_lastread_';
  
  // Episode-specific prefixes
  static const String _episodeCompletedPrefix = 'episode_completed_';
  static const String _episodeProgressPrefix = 'episode_progress_';
  static const String _currentEpisodePrefix = 'current_episode_';
  
  /// Get saved progress for a book (returns null if no progress)
  Future<ReadingProgress?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    final lastReadKey = '$_lastReadPrefix$bookId';
    
    final pageIndex = prefs.getInt(pageKey);
    final totalPages = prefs.getInt(totalKey);
    final lastReadMillis = prefs.getInt(lastReadKey);
    
    if (pageIndex == null) return null;
    
    return ReadingProgress(
      pageIndex: pageIndex,
      totalPages: totalPages ?? 100,
      lastReadAt: lastReadMillis != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastReadMillis) 
          : null,
    );
  }
  
  /// Save current page index and total pages for a book
  Future<void> saveProgress(String bookId, int pageIndex, int totalPages) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    final lastReadKey = '$_lastReadPrefix$bookId';
    
    await prefs.setInt(pageKey, pageIndex);
    await prefs.setInt(totalKey, totalPages);
    await prefs.setInt(lastReadKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Clear progress for a book (when starting from beginning)
  Future<void> clearProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    final lastReadKey = '$_lastReadPrefix$bookId';
    
    await prefs.remove(pageKey);
    await prefs.remove(totalKey);
    await prefs.remove(lastReadKey);
  }
  
  /// Get all saved progress (for sorting books by last read)
  Future<Map<String, ReadingProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final Map<String, ReadingProgress> progress = {};
    
    for (final key in allKeys) {
      final bookId = key.replaceFirst(_keyPrefix, '');
      final pageIndex = prefs.getInt(key);
      final totalPages = prefs.getInt('$_totalPrefix$bookId');
      final lastReadMillis = prefs.getInt('$_lastReadPrefix$bookId');
      
      if (pageIndex != null) {
        progress[bookId] = ReadingProgress(
          pageIndex: pageIndex,
          totalPages: totalPages ?? 100,
          lastReadAt: lastReadMillis != null 
              ? DateTime.fromMillisecondsSinceEpoch(lastReadMillis) 
              : null,
        );
      }
    }
    
    return progress;
  }
  
  // ==================== EPISODE TRACKING ====================
  
  /// Mark an episode as completed
  Future<void> markEpisodeCompleted(String seriesId, int episodeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_episodeCompletedPrefix${seriesId}_$episodeNumber';
    await prefs.setBool(key, true);
    
    // Also update last read timestamp for the series
    final lastReadKey = '$_lastReadPrefix$seriesId';
    await prefs.setInt(lastReadKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Check if an episode has been completed
  Future<bool> isEpisodeCompleted(String seriesId, int episodeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_episodeCompletedPrefix${seriesId}_$episodeNumber';
    return prefs.getBool(key) ?? false;
  }
  
  /// Get all completed episode numbers for a series
  Future<Set<int>> getCompletedEpisodes(String seriesId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = '$_episodeCompletedPrefix${seriesId}_';
    final completedEpisodes = <int>{};
    
    for (final key in prefs.getKeys()) {
      if (key.startsWith(prefix)) {
        final episodeStr = key.replaceFirst(prefix, '');
        final episodeNum = int.tryParse(episodeStr);
        if (episodeNum != null && (prefs.getBool(key) ?? false)) {
          completedEpisodes.add(episodeNum);
        }
      }
    }
    
    return completedEpisodes;
  }
  
  /// Check if an episode is unlocked - all episodes are always available
  Future<bool> isEpisodeUnlocked(String seriesId, int episodeNumber) async {
    // All episodes are always unlocked
    return true;
  }
  
  /// Get the current episode number being read (or 1 if none)
  Future<int> getCurrentEpisode(String seriesId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_currentEpisodePrefix$seriesId';
    return prefs.getInt(key) ?? 1;
  }
  
  /// Set the current episode being read
  Future<void> setCurrentEpisode(String seriesId, int episodeNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_currentEpisodePrefix$seriesId';
    await prefs.setInt(key, episodeNumber);
  }
  
  /// Save progress for a specific episode
  Future<void> saveEpisodeProgress(String seriesId, int episodeNumber, int pageIndex, int totalPages) async {
    final prefs = await SharedPreferences.getInstance();
    final bookId = '${seriesId}_episode_$episodeNumber';
    
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    final lastReadKey = '$_lastReadPrefix$seriesId'; // Use series ID for sorting
    
    await prefs.setInt(pageKey, pageIndex);
    await prefs.setInt(totalKey, totalPages);
    await prefs.setInt(lastReadKey, DateTime.now().millisecondsSinceEpoch);
    
    // Update current episode
    await setCurrentEpisode(seriesId, episodeNumber);
  }
  
  /// Get progress for a specific episode
  Future<ReadingProgress?> getEpisodeProgress(String seriesId, int episodeNumber) async {
    final bookId = '${seriesId}_episode_$episodeNumber';
    return getProgress(bookId);
  }
  
  /// Clear progress for a specific episode
  Future<void> clearEpisodeProgress(String seriesId, int episodeNumber) async {
    final bookId = '${seriesId}_episode_$episodeNumber';
    await clearProgress(bookId);
  }
  
  /// Get the highest unlocked episode number
  Future<int> getHighestUnlockedEpisode(String seriesId, int totalEpisodes) async {
    final completed = await getCompletedEpisodes(seriesId);
    
    // Find the first non-completed episode
    for (int i = 1; i <= totalEpisodes; i++) {
      if (!completed.contains(i)) {
        return i;
      }
    }
    
    // All completed - return last episode
    return totalEpisodes;
  }
  
  /// Get series progress info (completed episodes / total)
  Future<({int completed, int current})> getSeriesProgress(String seriesId, int totalEpisodes) async {
    final completed = await getCompletedEpisodes(seriesId);
    final current = await getCurrentEpisode(seriesId);
    return (completed: completed.length, current: current);
  }
}

/// Provider for the reading progress service
final readingProgressServiceProvider = Provider<ReadingProgressService>((ref) {
  return ReadingProgressService();
});

/// Provider to get progress for a specific book
final bookProgressProvider = FutureProvider.family<ReadingProgress?, String>((ref, bookId) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getProgress(bookId);
});

/// Provider to get all reading progress (for sorting)
final allProgressProvider = FutureProvider<Map<String, ReadingProgress>>((ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getAllProgress();
});

/// Provider to get completed episodes for a series
final completedEpisodesProvider = FutureProvider.family<Set<int>, String>((ref, seriesId) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getCompletedEpisodes(seriesId);
});

/// Provider to get current episode for a series
final currentEpisodeProvider = FutureProvider.family<int, String>((ref, seriesId) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getCurrentEpisode(seriesId);
});

/// Provider to get series progress
final seriesProgressProvider = FutureProvider.family<({int completed, int current}), ({String seriesId, int totalEpisodes})>((ref, params) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getSeriesProgress(params.seriesId, params.totalEpisodes);
});
