import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

/// Service for German hyphenation using TeX patterns
/// 
/// Adds soft hyphens (U+00AD) to text at valid break points.
/// Soft hyphens are invisible but allow Flutter to break words there
/// when needed for justified text layout.
class HyphenatorService {
  Hyphenator? _hyphenator;
  bool _initialized = false;
  
  /// Check if the service is initialized
  bool get isInitialized => _initialized;
  
  /// Initialize the hyphenator with German patterns
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load German hyphenation patterns asynchronously
      _hyphenator = await Hyphenator.loadAsync(
        Language.language_de_1996, // Modern German orthography
        symbol: '\u00AD', // Soft hyphen
        minLetterCount: 3, // Minimum letters before first hyphen
        minWordLength: 5, // Don't hyphenate short words
      );
      _initialized = true;
      print('✓ [Hyphenator] German patterns loaded successfully');
    } catch (e) {
      print('✗ [Hyphenator] Failed to load patterns: $e');
      _initialized = false;
    }
  }
  
  /// Hyphenate entire text while preserving structure
  /// 
  /// Uses the hyphenatorx library which handles word detection,
  /// punctuation preservation, and caching internally.
  String hyphenateText(String text) {
    if (!_initialized || _hyphenator == null || text.isEmpty) {
      print('⚠️ [Hyphenator] Not initialized or empty text');
      return text;
    }
    
    try {
      // hyphenatorx handles word detection and caching internally
      final result = _hyphenator!.hyphenateText(text);
      
      // Count inserted soft hyphens for debugging
      final insertedCount = result.split('\u00AD').length - 1;
      if (insertedCount > 0) {
        print('✓ [Hyphenator] Inserted $insertedCount soft hyphens');
      }
      
      return result;
    } catch (e) {
      print('⚠️ [Hyphenator] Error hyphenating text: $e');
      return text;
    }
  }
  
  /// Get cache statistics for debugging
  Map<String, int> getCacheStats() {
    if (!_initialized || _hyphenator == null) {
      return {'cachedWords': 0};
    }
    return {
      'cachedHyphened': _hyphenator!.cachedHyphendWords.length,
      'cachedNonHyphened': _hyphenator!.cachedNonHyphendWords.length,
    };
  }
}

