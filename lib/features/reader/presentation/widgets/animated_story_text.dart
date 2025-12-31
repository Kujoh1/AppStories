import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../settings/providers/settings_provider.dart';

/// Paged typewriter animation - no scrolling, page by page
class DecorativeStoryText extends ConsumerWidget {
  final String text;
  final ValueChanged<bool>? onPauseChanged;
  final VoidCallback? onPageComplete; // Called when current page animation finishes
  final double? maxHeight; // Maximum height for text area (for pagination calculation)

  const DecorativeStoryText({
    super.key,
    required this.text,
    this.onPauseChanged,
    this.onPageComplete,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return _PagedTypewriter(
      text: text,
      onPauseChanged: onPauseChanged,
      onPageComplete: onPageComplete,
      speedMultiplier: settings.speedMultiplier,
      skipAnimation: settings.skipAnimation,
      maxHeight: maxHeight,
    );
  }
}

/// Configuration
class _Config {
  static const int charDelayMs = 12; // Was 25
  
  // New timing ranges for natural reading flow (halved for 2x speed)
  static const int commaDelayMinMs = 75;
  static const int commaDelayMaxMs = 150;
  
  static const int sentenceDelayMinMs = 175;
  static const int sentenceDelayMaxMs = 350;
  
  static const int punctuationDelayMinMs = 200;
  static const int punctuationDelayMaxMs = 400;
  
  static const int newlineDelayMinMs = 400;
  static const int newlineDelayMaxMs = 750;
  
  static const int ellipseDelayMinMs = 300;
  static const int ellipseDelayMaxMs = 600;

  static const int pageTransitionMs = 3000;
  
  // Chapter title cinema animation (shortened for better UX)
  static const int chapterFadeInMs = 800;
  static const int chapterHoldMs = 1200;
  static const int chapterFadeOutMs = 600;
  static const int chapterToTextDelayMs = 300;
  
  static const int glowDurationMs = 1800;
  // Blur duration varies by sentence length: short=min, long=max
  static const int blurDurationMinMs = 500;
  static const int blurDurationMaxMs = 1500;
  static const int shortSentenceLength = 50;  // chars - gets min blur
  static const int longSentenceLength = 150;  // chars - gets max blur
  static const double maxBlurSigma = 8.0;
  
  static const double fontSize = 16.0;
  static const double dialogueFontSize = 17.0; // Slightly larger for dialogue
  static const double lineHeight = 1.9;
  static const double letterSpacing = 2.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 40.0;
  
  // Swipe hint dimensions: 20px top padding + 22px icon + 2px spacing + 16px text + extra margin
  static const double swipeHintHeight = 80.0;
  
  static const String dialogueFont = 'GrechenFuemen'; // For text in quotes
  
  static const Color glowColor = Color(0xFFFEFFE9);  // Warm glow
  static const Color darkTextColor = Color(0xFFE8DCC0);
  static const Color lightTextColor = Color(0xFF2C1810);
  
  // Ghost text (preview) settings
  static const double ghostOpacity = 0.08;
  static const double ghostBlurSigma = 3.0;
}

class _WordInfo {
  final int startIndex;
  final int endIndex;
  final int revealTime;
  final int blurDuration; // Calculated based on position on page
  _WordInfo(this.startIndex, this.endIndex, this.revealTime, this.blurDuration);
}

/// Page boundary info
class _PageInfo {
  final int startCharIndex;
  final int endCharIndex;
  final String text;
  final double height; // Actual height of this page's text
  
  _PageInfo({
    required this.startCharIndex,
    required this.endCharIndex,
    required this.text,
    required this.height,
  });
}

class _PagedTypewriter extends StatefulWidget {
  final String text;
  final ValueChanged<bool>? onPauseChanged;
  final VoidCallback? onPageComplete;
  final double speedMultiplier;
  final bool skipAnimation;
  final double? maxHeight; // Maximum height for pagination

  const _PagedTypewriter({
    required this.text,
    this.onPauseChanged,
    this.onPageComplete,
    this.speedMultiplier = 1.0,
    this.skipAnimation = false,
    this.maxHeight,
  });

  @override
  State<_PagedTypewriter> createState() => _PagedTypewriterState();
}

class _PagedTypewriterState extends State<_PagedTypewriter>
    with TickerProviderStateMixin {
  
  int _charIndex = 0;
  
  final List<_WordInfo> _glowingWords = [];
  int _currentWordStart = 0;
  int _currentWordStartTime = 0;
  int _currentWordBlurDuration = _Config.blurDurationMinMs;
  
  Timer? _typeTimer;
  Ticker? _ticker;
  
  bool _isPaused = false;
  Timer? _pauseTimer;
  
  late Color _textColor;
  
  // Page system
  List<_PageInfo> _pages = [];
  int _currentPageIndex = 0;
  bool _isPageTransitioning = false;
  double _pageOpacity = 1.0;
  Size? _availableSize;
  bool _awaitingNextPageSwipe = false;
  double _swipeDx = 0.0; // negative = swipe left (to advance)
  late final AnimationController _swipeController;
  Animation<double>? _swipeAnim;

  static const double _swipeThresholdPx = 120.0;
  static const int _swipeCommitMs = 190;
  static const int _swipeSnapBackMs = 160;
  
  // Chapter title cinema animation
  bool _showingChapterTitle = true;
  String? _chapterTitle;
  String? _bodyText;
  late AnimationController _chapterAnimController;
  late Animation<double> _chapterOpacity;
  late Animation<double> _chapterScale;
  late Animation<double> _chapterBlur;
  late Animation<double> _chapterLetterSpacing;
  
  @override
  void initState() {
    super.initState();
    
    // Extract chapter title from text
    _extractChapterTitle();
    
    // Setup chapter animation
    _chapterAnimController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _Config.chapterFadeInMs + _Config.chapterHoldMs + _Config.chapterFadeOutMs,
      ),
    );
    
    // Complex multi-phase animation
    final fadeInEnd = _Config.chapterFadeInMs / 
        (_Config.chapterFadeInMs + _Config.chapterHoldMs + _Config.chapterFadeOutMs);
    final holdEnd = (_Config.chapterFadeInMs + _Config.chapterHoldMs) / 
        (_Config.chapterFadeInMs + _Config.chapterHoldMs + _Config.chapterFadeOutMs);
    
    _chapterOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: fadeInEnd * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (holdEnd - fadeInEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: (1.0 - holdEnd) * 100,
      ),
    ]).animate(_chapterAnimController);
    
    _chapterScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: fadeInEnd * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.02),
        weight: (holdEnd - fadeInEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.15).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1.0 - holdEnd) * 100,
      ),
    ]).animate(_chapterAnimController);
    
    _chapterBlur = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 15.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: fadeInEnd * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: (holdEnd - fadeInEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 10.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1.0 - holdEnd) * 100,
      ),
    ]).animate(_chapterAnimController);
    
    _chapterLetterSpacing = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 20.0, end: 4.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: fadeInEnd * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 4.0, end: 5.0),
        weight: (holdEnd - fadeInEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 5.0, end: 15.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: (1.0 - holdEnd) * 100,
      ),
    ]).animate(_chapterAnimController);
    
    _chapterAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: _Config.chapterToTextDelayMs), () {
          if (mounted) {
            setState(() => _showingChapterTitle = false);
            // Text starts immediately - pages are calculated in build
          }
        });
      }
    });
    
    _ticker = createTicker(_onTick)..start();
    _swipeController = AnimationController(vsync: this);
    
    // Start chapter animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _chapterTitle != null) {
        _chapterAnimController.forward();
      } else if (mounted) {
        // No chapter title found, skip to content
        setState(() => _showingChapterTitle = false);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _startTypewriter();
        });
      }
    });
  }
  
  void _extractChapterTitle() {
    final text = widget.text.trim();
    final lines = text.split('\n');
    
    if (lines.isEmpty) {
      _bodyText = text;
      return;
    }
    
    // Check if first line looks like a chapter title
    final firstLine = lines.first.trim();
    
    // Match patterns like "Kapitel 1:", "Kapitel Eins:", "Chapter 1:", etc.
    final chapterPatterns = [
      RegExp(r'^Kapitel\s+\d+\s*[:\-–—]?\s*.*', caseSensitive: false),
      RegExp(r'^Kapitel\s+\w+\s*[:\-–—]?\s*.*', caseSensitive: false),
      RegExp(r'^Chapter\s+\d+\s*[:\-–—]?\s*.*', caseSensitive: false),
    ];
    
    bool isChapterTitle = chapterPatterns.any((pattern) => pattern.hasMatch(firstLine));
    
    if (isChapterTitle) {
      _chapterTitle = firstLine;
      // Remove the chapter title from body text
      _bodyText = lines.skip(1).join('\n').trimLeft();
    } else {
      _bodyText = text;
    }
  }
  
  void _onTick(Duration elapsed) {
    if (!mounted) return;
    
    final now = elapsed.inMilliseconds;
    
    // Cleanup old glows and trigger repaint for blur animation
    if (now % 50 < 16) {
      _cleanupOldGlows();
      if (_hasActiveEffects()) {
        setState(() {});
      }
    }
  }
  
  bool _hasActiveEffects() {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final word in _glowingWords) {
      if (now - word.revealTime < _Config.glowDurationMs) return true;
    }
    if (_currentWordStartTime > 0) return true;
    return false;
  }
  
  void _cleanupOldGlows() {
    final now = DateTime.now().millisecondsSinceEpoch;
    while (_glowingWords.isNotEmpty) {
      if (now - _glowingWords.first.revealTime > _Config.glowDurationMs) {
        _glowingWords.removeAt(0);
      } else {
        break;
      }
    }
  }
  
  bool _isQuote(String char) {
    const quotes = ['„', '"', '«', '»', '"', '\'', '‘', '’', '“', '”', '\"'];
    return quotes.contains(char);
  }

  /// Check if the current position is an ellipse "..." or similar
  bool _isEllipse(String text, int charIndex) {
    if (charIndex < 2) return false;
    // Check for "..." or ".." 
    return text[charIndex] == '.' && text[charIndex - 1] == '.' && text[charIndex - 2] == '.';
  }
  
  /// Find the last complete sentence end within the given range
  /// Returns the position AFTER the sentence end (including trailing quotes and whitespace)
  int _findSentenceEnd(String text, int startIndex, int maxIndex) {
    int lastSentenceEnd = -1;
    
    // Search backwards from maxIndex to find the last sentence ending
    // Don't skip first 10 chars - we need to find any sentence end
    final searchStart = startIndex;
    
    for (int i = maxIndex - 1; i >= searchStart; i--) {
      if (_isSentenceEndingPunctuation(text, i)) {
        lastSentenceEnd = i + 1;
        
        // Include trailing closing quotes (German: „..." ends with " which is U+201C)
        while (lastSentenceEnd < text.length && _isClosingQuote(text[lastSentenceEnd])) {
          lastSentenceEnd++;
        }
        
        // Skip trailing whitespace
        while (lastSentenceEnd < text.length && 
               (text[lastSentenceEnd] == ' ' || text[lastSentenceEnd] == '\n')) {
          lastSentenceEnd++;
        }
        
        break;
      }
    }
    
    return lastSentenceEnd;
  }
  
  /// Find the next sentence end starting from the given position
  int _findNextSentenceEnd(String text, int startIndex) {
    for (int i = startIndex; i < text.length; i++) {
      if (_isSentenceEndingPunctuation(text, i)) {
        int sentenceEnd = i + 1;
        
        // Include trailing closing quotes
        while (sentenceEnd < text.length && _isClosingQuote(text[sentenceEnd])) {
          sentenceEnd++;
        }
        
        // Skip trailing whitespace
        while (sentenceEnd < text.length && 
               (text[sentenceEnd] == ' ' || text[sentenceEnd] == '\n')) {
          sentenceEnd++;
        }
        
        return sentenceEnd;
      }
    }
    
    // No sentence end found - return end of text
    return text.length;
  }
  
  /// Check if character at position is sentence-ending punctuation
  bool _isSentenceEndingPunctuation(String text, int index) {
    if (index < 0 || index >= text.length) return false;
    
    final char = text[index];
    
    // Basic sentence enders
    if (char == '.' || char == '!' || char == '?') {
      // Don't break on ellipsis in the middle of text
      if (char == '.' && _isEllipse(text, index)) {
        // Only consider ellipsis as sentence end if followed by capital letter or quote
        final nextNonSpace = _findNextNonWhitespace(text, index + 1);
        if (nextNonSpace == -1) return true; // End of text
        final nextChar = text[nextNonSpace];
        return _isClosingQuote(nextChar) || 
               nextChar.toUpperCase() == nextChar && nextChar.toLowerCase() != nextChar;
      }
      return true;
    }
    
    return false;
  }
  
  /// Check if character is a closing quotation mark
  bool _isClosingQuote(String char) {
    // Closing quotes including German quotes:
    // " (ASCII), " (U+201C - German closing), " (U+201D), » (U+00BB), ' (U+2019), ' (ASCII)
    const closingQuoteChars = '"\u201C\u201D\u00BB\u2019\'';
    return closingQuoteChars.contains(char);
  }
  
  /// Find next non-whitespace character
  int _findNextNonWhitespace(String text, int startIndex) {
    for (int i = startIndex; i < text.length; i++) {
      if (text[i] != ' ' && text[i] != '\n' && text[i] != '\t') {
        return i;
      }
    }
    return -1;
  }

  /// Calculate blur duration based on sentence length
  /// Short sentences = short blur, long sentences = long blur
  int _calculateBlurDuration(int charIndex) {
    // Find sentence boundaries (. ! ?)
    final text = _displayText;
    
    // Find start of current sentence (last sentence-ending punctuation before charIndex)
    int sentenceStart = 0;
    for (int i = charIndex - 1; i >= 0; i--) {
      final char = text[i];
      if (char == '.' || char == '!' || char == '?') {
        sentenceStart = i + 1;
        
        // Skip trailing quotes that belong to the PREVIOUS sentence
        while (sentenceStart < text.length && _isQuote(text[sentenceStart])) {
          sentenceStart++;
        }

        // Skip whitespace after punctuation
        while (sentenceStart < text.length && 
               (text[sentenceStart] == ' ' || text[sentenceStart] == '\n')) {
          sentenceStart++;
        }
        break;
      }
    }
    
    // Find end of current sentence (next sentence-ending punctuation after charIndex)
    int sentenceEnd = text.length;
    for (int i = charIndex; i < text.length; i++) {
      final char = text[i];
      if (char == '.' || char == '!' || char == '?') {
        sentenceEnd = i + 1;
        
        // Include trailing quotes in this sentence
        while (sentenceEnd < text.length && _isQuote(text[sentenceEnd])) {
          sentenceEnd++;
        }
        break;
      }
    }
    
    // Calculate sentence length
    final sentenceLength = sentenceEnd - sentenceStart;
    
    // Interpolate blur duration based on sentence length
    // Short sentences (<=50 chars) = min blur
    // Long sentences (>=150 chars) = max blur
    final minLen = _Config.shortSentenceLength;
    final maxLen = _Config.longSentenceLength;
    
    if (sentenceLength <= minLen) {
      return _Config.blurDurationMinMs;
    } else if (sentenceLength >= maxLen) {
      return _Config.blurDurationMaxMs;
    } else {
      // Linear interpolation
      final t = (sentenceLength - minLen) / (maxLen - minLen);
      final duration = _Config.blurDurationMinMs + 
          ((_Config.blurDurationMaxMs - _Config.blurDurationMinMs) * t);
      return duration.round();
    }
  }
  
  // Pre-computed dialogue indices (cached for performance)
  Set<int>? _dialogueIndicesCache;
  String? _dialogueCacheText;
  
  /// Get pre-computed set of character indices that are inside quotes
  Set<int> _getDialogueIndices() {
    final text = _displayText;
    if (_dialogueCacheText == text && _dialogueIndicesCache != null) {
      return _dialogueIndicesCache!;
    }
    
    // German quotes: „..." (U+201E opens, U+201C closes)
    // English quotes: "..." (U+201C opens, U+201D closes) 
    // French quotes: «...» or »...«
    // Straight quotes: "..." (U+0022)
    
    final indices = <int>{};
    bool inQuote = false;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      
      // Opening quotes: „ (U+201E), « (U+00AB), » as opener (U+00BB)
      if (code == 0x201E || code == 0x00AB) {
        inQuote = true;
        indices.add(i);
      }
      // Closing quotes: " (U+201C), " (U+201D), » (U+00BB), « as closer (U+00AB)
      else if (inQuote && (code == 0x201C || code == 0x201D || code == 0x00BB)) {
        indices.add(i);
        inQuote = false;
      }
      // Straight quote " (U+0022) - toggles state
      else if (code == 0x0022) {
        if (inQuote) {
          indices.add(i);
          inQuote = false;
        } else {
          inQuote = true;
          indices.add(i);
        }
      }
      // Inside quotes
      else if (inQuote) {
        indices.add(i);
      }
    }
    
    _dialogueIndicesCache = indices;
    _dialogueCacheText = text;
    return indices;
  }
  
  /// O(1) lookup for dialogue check
  bool _isDialogue(int globalIndex) {
    return _getDialogueIndices().contains(globalIndex);
  }
  
  /// Calculate how many lines fit on a page
  /// Reserves space for swipe hint (shown when multiple pages exist)
  int _calculateLinesPerPage(double availableHeight) {
    final lineHeight = _Config.fontSize * _Config.lineHeight;
    // Reserve space for swipe hint + vertical padding
    final usableHeight = availableHeight - (_Config.verticalPadding * 2) - _Config.swipeHintHeight;
    return (usableHeight / lineHeight).floor().clamp(1, 100);
  }
  
  /// Get the actual text to display (body text without chapter title)
  String get _displayText => _bodyText ?? widget.text;
  
  /// Split text into pages based on available size
  void _calculatePages(Size size) {
    if (_availableSize == size && _pages.isNotEmpty) return;
    _availableSize = size;
    
    final linesPerPage = _calculateLinesPerPage(size.height);
    final textWidth = size.width - (_Config.horizontalPadding * 2);
    
    final baseStyle = TextStyle(
      fontFamily: 'Mynerve',
      fontSize: _Config.fontSize,
      height: _Config.lineHeight,
      letterSpacing: _Config.letterSpacing,
      fontWeight: FontWeight.w600,
    );
    
    final textToUse = _displayText;
    
    // Use a single TextPainter for efficient measurement
    final painter = TextPainter(
      text: TextSpan(text: textToUse, style: baseStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: textWidth);
    
    // Get line metrics for the entire text at once
    final lineMetrics = painter.computeLineMetrics();
    final totalLines = lineMetrics.length;
    
    _pages = [];
    int lineIndex = 0;
    int nextStartCharIndex = 0; // Track where next page should start
    
    while (lineIndex < totalLines && nextStartCharIndex < textToUse.length) {
      final startLine = lineIndex;
      final endLine = (lineIndex + linesPerPage).clamp(0, totalLines);
      
      // Use tracked start position (ensures no gaps between pages)
      int startCharIndex = nextStartCharIndex;
      int endCharIndex = textToUse.length;
      
      if (endLine < lineMetrics.length) {
        // Find character at start of next page (end of this page)
        final endOffset = painter.getPositionForOffset(
          Offset(0, lineMetrics[endLine].baseline - lineMetrics[endLine].ascent + 1)
        );
        // Only use this if it's ahead of our start
        if (endOffset.offset > startCharIndex) {
          endCharIndex = endOffset.offset;
        }
      }
      
      // ALWAYS end at a sentence boundary - never split sentences across pages
      if (endCharIndex < textToUse.length) {
        int sentenceEnd = _findSentenceEnd(textToUse, startCharIndex, endCharIndex);
        
        if (sentenceEnd > startCharIndex) {
          // Found a sentence boundary within the page
          endCharIndex = sentenceEnd;
        } else {
          // No sentence end found within page - search forward to find one
          sentenceEnd = _findNextSentenceEnd(textToUse, endCharIndex);
          if (sentenceEnd > endCharIndex) {
            endCharIndex = sentenceEnd;
          }
        }
      }
      
      // Safety: ensure we make progress - find next sentence if stuck
      if (endCharIndex <= startCharIndex) {
        final nextEnd = _findNextSentenceEnd(textToUse, startCharIndex);
        endCharIndex = nextEnd > startCharIndex ? nextEnd : textToUse.length;
      }
      
      // Create page
      if (endCharIndex > startCharIndex) {
        // Calculate height for this page based on actual content
        final pageText = textToUse.substring(startCharIndex, endCharIndex);
        final pagePainter = TextPainter(
          text: TextSpan(text: pageText, style: baseStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: textWidth);
        final pageLineCount = pagePainter.computeLineMetrics().length;
        final pageHeight = pageLineCount * _Config.fontSize * _Config.lineHeight;
        pagePainter.dispose();
        
        _pages.add(_PageInfo(
          startCharIndex: startCharIndex,
          endCharIndex: endCharIndex,
          text: pageText,
          height: pageHeight,
        ));
        
        // Next page starts exactly where this one ended
        nextStartCharIndex = endCharIndex;
      }
      
      // Move to next visual line block
      if (endCharIndex >= textToUse.length) break;
      
      // Estimate lines consumed for visual positioning
      final linesConsumed = ((endCharIndex - startCharIndex) / 
          (textToUse.length / totalLines)).ceil().clamp(1, linesPerPage);
      lineIndex = startLine + linesConsumed;
      
      // Safety: ensure progress
      if (lineIndex <= startLine) lineIndex = startLine + 1;
    }
    
    painter.dispose();
    
    // Start typewriter after pages are calculated
    if (_charIndex == 0 && _pages.isNotEmpty) {
      if (widget.skipAnimation) {
        // Instant mode - show all text immediately
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _charIndex = _displayText.length;
            });
            widget.onPageComplete?.call();
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _startTypewriter();
        });
      }
    }
  }
  
  bool _isWhitespace(String char) => char == ' ' || char == '\n' || char == '\t';
  
  void _startTypewriter() {
    _typeTimer?.cancel();
    if (_isPaused || !mounted || _isPageTransitioning || _awaitingNextPageSwipe) return;
    final text = _displayText;
    if (_charIndex >= text.length) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final char = text[_charIndex];
    
    // Track word start time and calculate blur duration based on position
    if (_charIndex == _currentWordStart && !_isWhitespace(char)) {
      _currentWordStartTime = now;
      _currentWordBlurDuration = _calculateBlurDuration(_charIndex);
    }
    
    // Word completed
    if (_isWhitespace(char) && _charIndex > _currentWordStart) {
      if (_glowingWords.length >= 8) _glowingWords.removeAt(0);
      final blurDuration = _calculateBlurDuration(_currentWordStart);
      _glowingWords.add(_WordInfo(_currentWordStart, _charIndex, _currentWordStartTime, blurDuration));
      _currentWordStart = _charIndex + 1;
      _currentWordStartTime = 0;
    } else if (_isWhitespace(char)) {
      _currentWordStart = _charIndex + 1;
      _currentWordStartTime = 0;
    }
    
    setState(() => _charIndex++);
    
    // Check if we need to transition to next page
    _checkPageTransition();
    
    if (_charIndex < text.length && !_isPageTransitioning) {
      int delay = (_Config.charDelayMs * widget.speedMultiplier).round();
      final random = math.Random();
      
      final bool isSentencePunctuation = char == '.' || char == '!' || char == '?';
      final bool isComma = char == ',';
      final bool isSpecialPunctuation = char == ';' || char == ':';
      final bool isNewline = char == '\n';
      final bool isEllipse = _isEllipse(text, _charIndex - 1);
      
      final bool nextIsQuote = _charIndex < text.length && _isQuote(text[_charIndex]);
      final bool isQuote = _isQuote(char);
      final bool prevIsSentencePunctuation = _charIndex > 1 && (text[_charIndex - 2] == '.' || text[_charIndex - 2] == '!' || text[_charIndex - 2] == '?');

      if (isEllipse) {
        delay = ((_Config.ellipseDelayMinMs + random.nextInt(_Config.ellipseDelayMaxMs - _Config.ellipseDelayMinMs)) * widget.speedMultiplier).round();
      } else if (isSentencePunctuation) {
        if (nextIsQuote) {
          delay = (_Config.charDelayMs * widget.speedMultiplier).round();
        } else {
          delay = ((_Config.sentenceDelayMinMs + random.nextInt(_Config.sentenceDelayMaxMs - _Config.sentenceDelayMinMs)) * widget.speedMultiplier).round();
        }
      } else if (isQuote && prevIsSentencePunctuation) {
        delay = ((_Config.sentenceDelayMinMs + random.nextInt(_Config.sentenceDelayMaxMs - _Config.sentenceDelayMinMs)) * widget.speedMultiplier).round();
      } else if (isComma) {
        delay = ((_Config.commaDelayMinMs + random.nextInt(_Config.commaDelayMaxMs - _Config.commaDelayMinMs)) * widget.speedMultiplier).round();
      } else if (isSpecialPunctuation) {
        delay = ((_Config.punctuationDelayMinMs + random.nextInt(_Config.punctuationDelayMaxMs - _Config.punctuationDelayMinMs)) * widget.speedMultiplier).round();
      } else if (isNewline) {
        delay = ((_Config.newlineDelayMinMs + random.nextInt(_Config.newlineDelayMaxMs - _Config.newlineDelayMinMs)) * widget.speedMultiplier).round();
      }
      
      _typeTimer = Timer(Duration(milliseconds: delay), _startTypewriter);
    } else if (_charIndex >= text.length && _charIndex > _currentWordStart) {
      final blurDuration = _calculateBlurDuration(_currentWordStart);
      _glowingWords.add(_WordInfo(_currentWordStart, _charIndex, _currentWordStartTime, blurDuration));
      // Animation complete - notify parent
      widget.onPageComplete?.call();
    }
  }
  
  void _checkPageTransition() {
    if (_pages.isEmpty || _currentPageIndex >= _pages.length) return;
    
    final currentPage = _pages[_currentPageIndex];
    
    // If we've reached the end of this page
    if (_charIndex >= currentPage.endCharIndex) {
      if (_currentPageIndex < _pages.length - 1) {
        // Do NOT auto-advance between pages. Wait for a swipe-release gesture.
        if (!_awaitingNextPageSwipe) {
          _typeTimer?.cancel();
          setState(() {
            _awaitingNextPageSwipe = true;
            _swipeDx = 0.0;
          });
        }
      } else {
        // Last page completed
        widget.onPageComplete?.call();
      }
    }
  }
  
  void _performPageTransition() {
    if (_isPageTransitioning) return;
    
    setState(() {
      _isPageTransitioning = true;
    });
    
    // Fade out
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => _pageOpacity = 0.0);
    });
    
    // Switch page and fade in
    Future.delayed(Duration(milliseconds: _Config.pageTransitionMs ~/ 2), () {
      if (!mounted) return;
      setState(() {
        _currentPageIndex++;
        // Don't clear glowing words - let effects fade out naturally
        _currentWordStart = _pages[_currentPageIndex].startCharIndex;
        _currentWordStartTime = 0;
        _currentWordBlurDuration = _Config.blurDurationMinMs;
      });
    });
    
    Future.delayed(Duration(milliseconds: _Config.pageTransitionMs ~/ 2 + 100), () {
      if (!mounted) return;
      setState(() => _pageOpacity = 1.0);
    });
    
    // Resume typing
    Future.delayed(Duration(milliseconds: _Config.pageTransitionMs), () {
      if (!mounted) return;
      setState(() {
        _isPageTransitioning = false;
      });
      _startTypewriter();
    });
  }
  
  void _onPressStart() {
    if (_awaitingNextPageSwipe) return;
    _pauseTimer?.cancel();
    _pauseTimer = Timer(const Duration(milliseconds: 40), () {
      if (mounted && !_isPaused) {
        _isPaused = true;
        _typeTimer?.cancel();
        widget.onPauseChanged?.call(true);
      }
    });
  }
  
  void _onPressEnd() {
    if (_awaitingNextPageSwipe) return;
    _pauseTimer?.cancel();
    if (_isPaused) {
      _isPaused = false;
      widget.onPauseChanged?.call(false);
      _startTypewriter();
    }
  }

  bool get _hasNextPage => _pages.isNotEmpty && _currentPageIndex < _pages.length - 1;

  void _snapBack() {
    _swipeController.stop();
    _swipeController.duration = const Duration(milliseconds: _swipeSnapBackMs);
    _swipeAnim = Tween<double>(begin: _swipeDx, end: 0.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
    );
    _swipeController
      ..value = 0
      ..forward();
    _swipeController.addListener(() {
      if (!mounted) return;
      setState(() => _swipeDx = _swipeAnim?.value ?? 0.0);
    });
  }

  Future<void> _commitToNextPage(double offscreenDx) async {
    if (!_hasNextPage) return;
    if (_isPageTransitioning) return;

    setState(() => _isPageTransitioning = true);
    _swipeController.stop();
    _swipeController.duration = const Duration(milliseconds: _swipeCommitMs);
    _swipeAnim = Tween<double>(begin: _swipeDx, end: -offscreenDx).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeInCubic),
    );
    _swipeController
      ..value = 0
      ..forward();
    _swipeController.addListener(() {
      if (!mounted) return;
      setState(() => _swipeDx = _swipeAnim?.value ?? _swipeDx);
    });

    await _swipeController.forward(from: 0.0);
    if (!mounted) return;

    setState(() {
      _currentPageIndex++;
      _awaitingNextPageSwipe = false;
      _swipeDx = 0.0;
      _currentWordStart = _pages[_currentPageIndex].startCharIndex;
      _currentWordStartTime = 0;
      _currentWordBlurDuration = _Config.blurDurationMinMs;
      _isPageTransitioning = false;
    });

    // Start the next page only after release (we call this from drag end/tap).
    _startTypewriter();
  }
  
  @override
  void dispose() {
    _typeTimer?.cancel();
    _pauseTimer?.cancel();
    _ticker?.dispose();
    _chapterAnimController.dispose();
    _swipeController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _textColor = isDark ? _Config.darkTextColor : _Config.lightTextColor;
  }
  
  @override
  Widget build(BuildContext context) {
    // Show cinematic chapter title first
    if (_showingChapterTitle && _chapterTitle != null) {
      return _buildChapterTitleCinema();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use provided maxHeight or fall back to constraints
        final effectiveHeight = widget.maxHeight ?? constraints.maxHeight;
        
        // Calculate pages based on available space (using body text without chapter title)
        final size = Size(constraints.maxWidth, effectiveHeight);
        _calculatePages(size);
        
        if (_pages.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final currentPage = _pages[_currentPageIndex];
        final nextPage = _hasNextPage ? _pages[_currentPageIndex + 1] : null;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Calculate blur intensity for current word (using position-based duration)
        double blurIntensity = 0.0;
        if (_currentWordStartTime > 0) {
          final elapsed = now - _currentWordStartTime;
          if (elapsed < _currentWordBlurDuration) {
            final t = elapsed / _currentWordBlurDuration;
            blurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t);
          }
        }
        
        final baseStyle = TextStyle(
          fontFamily: 'Mynerve',
          fontSize: _Config.fontSize,
          height: _Config.lineHeight,
          letterSpacing: _Config.letterSpacing,
          fontWeight: FontWeight.w600,
          color: _textColor,
        );
        
        final canSwipeAdvance = _awaitingNextPageSwipe && nextPage != null;

        // Fill available space - text at top, hint at bottom of viewport
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Listener(
            onPointerDown: (_) => _onPressStart(),
            onPointerUp: (_) => _onPressEnd(),
            onPointerCancel: (_) => _onPressEnd(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: canSwipeAdvance ? (_) => _swipeController.stop() : null,
              onHorizontalDragUpdate: canSwipeAdvance
                  ? (d) {
                      // Swipe left (negative dx) to advance
                      final next = (_swipeDx + d.delta.dx).clamp(-_swipeThresholdPx * 1.6, 0.0);
                      setState(() => _swipeDx = next);
                    }
                  : null,
              onHorizontalDragEnd: canSwipeAdvance
                  ? (_) async {
                      if ((-_swipeDx) >= _swipeThresholdPx) {
                        await _commitToNextPage(constraints.maxWidth);
                      } else {
                        _snapBack();
                      }
                    }
                  : null,
              onTap: canSwipeAdvance ? () => _commitToNextPage(constraints.maxWidth) : null,
              child: AnimatedOpacity(
                opacity: _pageOpacity,
                duration: Duration(milliseconds: _Config.pageTransitionMs ~/ 2),
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    // TEXT CONTENT - aligned to top
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 320,
                          maxWidth: 415,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: _Config.horizontalPadding,
                          vertical: _Config.verticalPadding,
                        ),
                        child: SizedBox(
                          height: currentPage.height,
                          child: RepaintBoundary(
                            child: Stack(
                              children: [
                                // NEXT PAGE PREVIEW (behind) while waiting
                                if (canSwipeAdvance)
                                  Opacity(
                                    opacity: 0.12,
                                    child: _buildGhostText(nextPage, baseStyle),
                                  ),

                                // CURRENT PAGE (front), moved by swipe
                                Transform.translate(
                                  offset: Offset(_swipeDx, 0),
                                  child: Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.0,
                                        child: _buildLayoutPlaceholder(currentPage, baseStyle),
                                      ),
                                      Positioned.fill(
                                        child: _buildGhostText(currentPage, baseStyle),
                                      ),
                                      Positioned.fill(
                                        child: _buildRevealedText(currentPage, baseStyle, now, blurIntensity),
                                      ),
                                      if (blurIntensity > 0.05 && _currentWordStart < _charIndex)
                                        Positioned.fill(
                                          child: _buildBlurredCurrentWord(currentPage, baseStyle, blurIntensity),
                                        ),
                                      ..._buildBlurredCompletedWords(currentPage, baseStyle, now),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // SWIPE HINT - always at bottom of viewport
                    if (canSwipeAdvance)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.55,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Wischen für nächste Seite',
                                  style: TextStyle(
                                    color: Color(0xFFE8DCC0),
                                    fontSize: 12,
                                    fontFamily: 'Mynerve',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_right_rounded, color: Color(0xFFE8DCC0), size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Cinematic chapter title animation
  Widget _buildChapterTitleCinema() {
    return AnimatedBuilder(
      animation: _chapterAnimController,
      builder: (context, child) {
        final blur = _chapterBlur.value;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: isDark ? const Color(0xFF0A0806) : const Color(0xFFF8F4EC),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: double.infinity, // Fixed width to prevent horizontal shifts
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                      tileMode: TileMode.decal,
                    ),
                    child: Opacity(
                      opacity: _chapterOpacity.value,
                      child: Transform.scale(
                        scale: _chapterScale.value,
                        child: _buildChapterTitleWidget(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChapterTitleWidget(bool isDark) {
    // Split title into parts: "Kapitel X:" and subtitle
    final title = _chapterTitle ?? '';
    String mainPart = title;
    String? subtitlePart;
    
    // Find the colon or dash separator
    final colonIndex = title.indexOf(':');
    final dashIndex = title.indexOf(RegExp(r'[\-–—]'));
    
    int separatorIndex = -1;
    if (colonIndex > 0) separatorIndex = colonIndex;
    if (dashIndex > 0 && (separatorIndex < 0 || dashIndex < separatorIndex)) {
      separatorIndex = dashIndex;
    }
    
    if (separatorIndex > 0) {
      mainPart = title.substring(0, separatorIndex).trim();
      subtitlePart = title.substring(separatorIndex + 1).trim();
    }
    
    final baseColor = isDark ? const Color(0xFFE8DCC0) : const Color(0xFF2C1810);
    final glowColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFF8B4513);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30), // Safety margin
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main part (e.g., "Kapitel 1")
          SizedBox(
            height: 40,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      glowColor.withOpacity(0.8),
                      baseColor,
                      glowColor.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    mainPart.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Mynerve',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: _chapterLetterSpacing.value * 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Decorative line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildDecorativeLine(glowColor),
          ),
          
          // Subtitle (e.g., "Das Summen")
          if (subtitlePart != null && subtitlePart.isNotEmpty)
            SizedBox(
              height: 60,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitlePart,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Mynerve',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _chapterLetterSpacing.value,
                      height: 1.3,
                      color: baseColor,
                      shadows: [
                        Shadow(
                          color: glowColor.withOpacity(0.5 * _chapterOpacity.value),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDecorativeLine(Color color) {
    return SizedBox(
      width: 120,
      height: 3,
      child: CustomPaint(
        painter: _DecorativeLinePainter(
          color: color,
          progress: _chapterOpacity.value,
        ),
      ),
    );
  }
  
  /// Build layout placeholder with correct fonts for dialogue
  Widget _buildLayoutPlaceholder(_PageInfo page, TextStyle baseStyle) {
    final dialogueStyle = baseStyle.copyWith(
      fontFamily: _Config.dialogueFont,
      fontSize: _Config.dialogueFontSize,
      fontStyle: FontStyle.italic,
    );
    
    final spans = <TextSpan>[];
    for (int i = 0; i < page.text.length; i++) {
      final globalIndex = page.startCharIndex + i;
      final isDialogue = _isDialogue(globalIndex);
      final charStyle = isDialogue ? dialogueStyle : baseStyle;
      spans.add(TextSpan(text: page.text[i], style: charStyle));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
  
  /// Ghost text - full page preview, blurry and dim
  Widget _buildGhostText(_PageInfo page, TextStyle baseStyle) {
    final dialogueStyle = baseStyle.copyWith(
      fontFamily: _Config.dialogueFont,
      fontSize: _Config.dialogueFontSize,
      fontStyle: FontStyle.italic,
    );
    
    // Build spans with correct fonts for dialogue
    final spans = <TextSpan>[];
    for (int i = 0; i < page.text.length; i++) {
      final globalIndex = page.startCharIndex + i;
      final isDialogue = _isDialogue(globalIndex);
      final charStyle = isDialogue ? dialogueStyle : baseStyle;
      spans.add(TextSpan(text: page.text[i], style: charStyle));
    }
    
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: _Config.ghostBlurSigma,
        sigmaY: _Config.ghostBlurSigma,
        tileMode: TileMode.decal,
      ),
      child: Opacity(
        opacity: _Config.ghostOpacity,
        child: RichText(
          text: TextSpan(children: spans),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
  
  /// Build revealed text with glow effects - renders FULL page text for layout stability
  Widget _buildRevealedText(_PageInfo page, TextStyle baseStyle, int now, double blurIntensity) {
    final pageRevealedChars = (_charIndex - page.startCharIndex).clamp(0, page.text.length);
    
    // Pre-calculate which chars are in quotes (dialogue) for font switching
    
    // Calculate glow intensities AND track which chars are still blurred
    final Map<int, double> glowMap = {};
    final Set<int> blurredChars = {};
    
    for (final word in _glowingWords) {
      final wordStart = word.startIndex - page.startCharIndex;
      final wordEnd = word.endIndex - page.startCharIndex;
      
      if (wordEnd <= 0 || wordStart >= page.text.length) continue;
      
      final elapsed = now - word.revealTime;
      
      if (elapsed < word.blurDuration) {
        final t = elapsed / word.blurDuration;
        final wordBlurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t);
        if (wordBlurIntensity > 0.05) {
          for (int i = wordStart.clamp(0, page.text.length); i < wordEnd.clamp(0, pageRevealedChars); i++) {
            blurredChars.add(i);
          }
        }
      }
      
      if (elapsed < _Config.glowDurationMs) {
        final t = elapsed / _Config.glowDurationMs;
        final intensity = 1.0 - (t * t);
        for (int i = wordStart.clamp(0, page.text.length); i < wordEnd.clamp(0, pageRevealedChars); i++) {
          if (!blurredChars.contains(i)) {
            glowMap[i] = intensity;
          }
        }
      }
    }
    
    // Current word (page-relative)
    final currentWordStartRel = _currentWordStart - page.startCharIndex;
    final currentWordEndRel = _charIndex - page.startCharIndex;
    
    final bool currentWordIsBlurred = blurIntensity > 0.05;
    if (currentWordIsBlurred && currentWordStartRel >= 0) {
      for (int i = currentWordStartRel.clamp(0, page.text.length); i < currentWordEndRel.clamp(0, pageRevealedChars); i++) {
        blurredChars.add(i);
      }
    } else if (currentWordStartRel >= 0) {
      for (int i = currentWordStartRel.clamp(0, page.text.length); i < currentWordEndRel.clamp(0, pageRevealedChars); i++) {
        glowMap[i] = 1.0;
      }
    }
    
    // Dialogue style (GrechenFuemen font for text in quotes)
    final dialogueStyle = baseStyle.copyWith(
      fontFamily: _Config.dialogueFont,
      fontSize: _Config.dialogueFontSize,
      fontStyle: FontStyle.italic,
    );
    
    // Build COMPLETE page text - character by character for stable layout
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isRevealed = i < pageRevealedChars;
      final isBlurred = blurredChars.contains(i);
      final glowIntensity = glowMap[i];
      
      // Check if this char is inside quotes (dialogue)
      final globalIndex = page.startCharIndex + i;
      final isDialogue = _isDialogue(globalIndex);
      final charStyle = isDialogue ? dialogueStyle : baseStyle;
      
      if (!isRevealed) {
        // Not yet revealed - transparent
        spans.add(TextSpan(text: char, style: charStyle.copyWith(color: Colors.transparent)));
      } else if (isBlurred) {
        // Blurred (rendered in blur layer) - transparent here
        spans.add(TextSpan(text: char, style: charStyle.copyWith(color: Colors.transparent)));
      } else if (glowIntensity != null && glowIntensity > 0.1) {
        // Glowing
        final glowColor = Color.lerp(_Config.glowColor, _textColor, 1.0 - glowIntensity)!;
        spans.add(TextSpan(
          text: char,
          style: charStyle.copyWith(
            color: glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8 * glowIntensity),
                blurRadius: 25.0 * glowIntensity,
              ),
            ],
          ),
        ));
      } else {
        // Normal revealed text - use character-specific style
        spans.add(TextSpan(text: char, style: charStyle));
      }
    }
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
  
  /// Build blurred completed words
  List<Widget> _buildBlurredCompletedWords(_PageInfo page, TextStyle baseStyle, int now) {
    final widgets = <Widget>[];
    
    for (final word in _glowingWords) {
      final elapsed = now - word.revealTime;
      if (elapsed < word.blurDuration) {
        final t = elapsed / word.blurDuration;
        final blurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t);
        
        if (blurIntensity > 0.05) {
          // Convert to page-relative
          final wordStartRel = (word.startIndex - page.startCharIndex).clamp(0, page.text.length);
          final wordEndRel = (word.endIndex - page.startCharIndex).clamp(0, page.text.length);
          
          if (wordEndRel > wordStartRel) {
            widgets.add(
              Positioned.fill(
                child: _buildBlurredWord(page, baseStyle, wordStartRel, wordEndRel, blurIntensity),
              ),
            );
          }
        }
      }
    }
    
    return widgets;
  }
  
  Widget _buildBlurredWord(_PageInfo page, TextStyle baseStyle, int startIndex, int endIndex, double blurIntensity) {
    final sigma = _Config.maxBlurSigma * blurIntensity;
    
    // Dialogue style
    final dialogueStyle = baseStyle.copyWith(
      fontFamily: _Config.dialogueFont,
      fontSize: _Config.dialogueFontSize,
      fontStyle: FontStyle.italic,
    );
    
    // Render FULL page text with only the word visible (for layout stability)
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isInWord = i >= startIndex && i < endIndex;
      
      // Check if in dialogue
      final globalIndex = page.startCharIndex + i;
      final isDialogue = _isDialogue(globalIndex);
      final charStyle = isDialogue ? dialogueStyle : baseStyle;
      
      if (isInWord) {
        spans.add(TextSpan(
          text: char,
          style: charStyle.copyWith(
            color: _Config.glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8),
                blurRadius: 25.0,
              ),
            ],
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: char,
          style: charStyle.copyWith(color: Colors.transparent),
        ));
      }
    }
    
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.decal,
      ),
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.left,
      ),
    );
  }
  
  Widget _buildBlurredCurrentWord(_PageInfo page, TextStyle baseStyle, double blurIntensity) {
    final currentWordStartRel = (_currentWordStart - page.startCharIndex).clamp(0, page.text.length);
    final currentWordEndRel = (_charIndex - page.startCharIndex).clamp(0, page.text.length);
    
    if (currentWordStartRel >= currentWordEndRel) return const SizedBox.shrink();
    
    final sigma = _Config.maxBlurSigma * blurIntensity;
    
    // Dialogue style
    final dialogueStyle = baseStyle.copyWith(
      fontFamily: _Config.dialogueFont,
      fontSize: _Config.dialogueFontSize,
      fontStyle: FontStyle.italic,
    );
    
    // Render FULL page text with only current word visible (for layout stability)
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isInWord = i >= currentWordStartRel && i < currentWordEndRel;
      
      // Check if in dialogue
      final globalIndex = page.startCharIndex + i;
      final isDialogue = _isDialogue(globalIndex);
      final charStyle = isDialogue ? dialogueStyle : baseStyle;
      
      if (isInWord) {
        spans.add(TextSpan(
          text: char,
          style: charStyle.copyWith(
            color: _Config.glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8),
                blurRadius: 25.0,
              ),
            ],
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: char,
          style: charStyle.copyWith(color: Colors.transparent),
        ));
      }
    }
    
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.decal,
      ),
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.left,
      ),
    );
  }
}

/// Decorative line painter for chapter title
class _DecorativeLinePainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _DecorativeLinePainter({
    required this.color,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw line from center outward
    final lineWidth = size.width * progress;
    final halfWidth = lineWidth / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    // Main line
    canvas.drawLine(
      Offset(centerX - halfWidth, centerY),
      Offset(centerX + halfWidth, centerY),
      paint,
    );
    
    // Decorative dots at ends
    if (progress > 0.5) {
      final dotPaint = Paint()
        ..color = color.withOpacity(progress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX - halfWidth - 6, centerY),
        2,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(centerX + halfWidth + 6, centerY),
        2,
        dotPaint,
      );
    }
    
    // Diamond in center
    if (progress > 0.3) {
      final diamondPaint = Paint()
        ..color = color.withOpacity(progress)
        ..style = PaintingStyle.fill;
      
      final diamondPath = Path()
        ..moveTo(centerX, centerY - 4)
        ..lineTo(centerX + 4, centerY)
        ..lineTo(centerX, centerY + 4)
        ..lineTo(centerX - 4, centerY)
        ..close();
      
      canvas.drawPath(diamondPath, diamondPaint);
    }
  }
  
  @override
  bool shouldRepaint(_DecorativeLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
