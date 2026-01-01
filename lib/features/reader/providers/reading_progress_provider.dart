import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading progress data
class ReadingProgress {
  final int pageIndex;
  final int totalPages;
  
  const ReadingProgress({
    required this.pageIndex,
    required this.totalPages,
  });
  
  double get progressPercent => totalPages > 0 ? (pageIndex + 1) / totalPages : 0;
}

/// Stores and retrieves reading progress for each book
class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';
  static const String _totalPrefix = 'reading_total_';
  
  /// Get saved progress for a book (returns null if no progress)
  Future<ReadingProgress?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    
    final pageIndex = prefs.getInt(pageKey);
    final totalPages = prefs.getInt(totalKey);
    
    if (pageIndex == null) return null;
    
    return ReadingProgress(
      pageIndex: pageIndex,
      totalPages: totalPages ?? 100, // Fallback
    );
  }
  
  /// Save current page index and total pages for a book
  Future<void> saveProgress(String bookId, int pageIndex, int totalPages) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    
    await prefs.setInt(pageKey, pageIndex);
    await prefs.setInt(totalKey, totalPages);
  }
  
  /// Clear progress for a book (when starting from beginning)
  Future<void> clearProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final pageKey = '$_keyPrefix$bookId';
    final totalKey = '$_totalPrefix$bookId';
    
    await prefs.remove(pageKey);
    await prefs.remove(totalKey);
  }
  
  /// Get all saved progress (for debugging or overview)
  Future<Map<String, ReadingProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final Map<String, ReadingProgress> progress = {};
    
    for (final key in allKeys) {
      final bookId = key.replaceFirst(_keyPrefix, '');
      final pageIndex = prefs.getInt(key);
      final totalPages = prefs.getInt('$_totalPrefix$bookId');
      
      if (pageIndex != null) {
        progress[bookId] = ReadingProgress(
          pageIndex: pageIndex,
          totalPages: totalPages ?? 100,
        );
      }
    }
    
    return progress;
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
