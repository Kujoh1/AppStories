import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves reading progress for each book
class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';
  
  /// Get saved page index for a book (returns null if no progress)
  Future<int?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$bookId';
    final value = prefs.getInt(key);
    return value;
  }
  
  /// Save current page index for a book
  Future<void> saveProgress(String bookId, int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$bookId';
    await prefs.setInt(key, pageIndex);
  }
  
  /// Clear progress for a book (when starting from beginning)
  Future<void> clearProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$bookId';
    await prefs.remove(key);
  }
  
  /// Get all saved progress (for debugging or overview)
  Future<Map<String, int>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final Map<String, int> progress = {};
    
    for (final key in allKeys) {
      final bookId = key.replaceFirst(_keyPrefix, '');
      final value = prefs.getInt(key);
      if (value != null) {
        progress[bookId] = value;
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
final bookProgressProvider = FutureProvider.family<int?, String>((ref, bookId) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getProgress(bookId);
});

