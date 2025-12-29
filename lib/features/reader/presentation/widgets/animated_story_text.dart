import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

/// Ultra high-performance typewriter animation
/// Optimized for constant 60 FPS on iPhone 13
/// Word-based glow effect for better performance
class DecorativeStoryText extends StatelessWidget {
  final String text;
  final ScrollController scrollController;

  const DecorativeStoryText({
    super.key,
    required this.text,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minWidth: 320,
        maxWidth: 415,
      ),
      child: _UltraPerformanceTypewriter(
        text: text,
        scrollController: scrollController,
      ),
    );
  }
}

/// Configuration for performance tuning
class _TypewriterConfig {
  // Timing
  static const int charDelayMs = 25;
  static const int punctuationDelayMs = 300;
  static const int sentenceDelayMs = 1200;
  static const int newlineDelayMs = 600;
  
  // Glow effect - WORD BASED
  static const int glowDurationMs = 1800;
  static const int maxActiveGlowWords = 8; // Track last 8 words
  
  // Font
  static const double fontSize = 18.0;
  static const double lineHeight = 1.9;
  static const double letterSpacing = 2.0;
  
  // Scroll
  static const int scrollThrottleMs = 150;
  
  // Colors
  static const Color glowColor = Color(0xFF30ACFF);
  static const Color darkTextColor = Color(0xFFE8DCC0);
  static const Color lightTextColor = Color(0xFF2C1810);
  static const Color darkCursorColor = Color(0xFFD4AF37);
  static const Color lightCursorColor = Color(0xFF8B4513);
}

/// Word boundary info for glow tracking
class _WordInfo {
  final int startIndex;
  final int endIndex;
  final int revealTime;
  
  _WordInfo(this.startIndex, this.endIndex, this.revealTime);
}

/// Optimized typewriter using word-based glow
class _UltraPerformanceTypewriter extends StatefulWidget {
  final String text;
  final ScrollController scrollController;

  const _UltraPerformanceTypewriter({
    required this.text,
    required this.scrollController,
  });

  @override
  State<_UltraPerformanceTypewriter> createState() => _UltraPerformanceTypewriterState();
}

class _UltraPerformanceTypewriterState extends State<_UltraPerformanceTypewriter>
    with SingleTickerProviderStateMixin {
  
  // Animation state
  final ValueNotifier<int> _charIndex = ValueNotifier(0);
  final ValueNotifier<double> _cursorOpacity = ValueNotifier(1.0);
  final ValueNotifier<int> _glowTick = ValueNotifier(0);
  
  // Word-based glow tracking (much more efficient than per-character)
  final List<_WordInfo> _glowingWords = [];
  int _currentWordStart = 0;
  
  // Pre-computed word boundaries for fast lookup
  late List<int> _wordBoundaries; // Indices where words end
  
  // Timers
  Timer? _typeTimer;
  Ticker? _animationTicker;
  int _lastScrollTime = 0;
  int _lastGlowUpdate = 0;
  
  // Pause state
  bool _isPaused = false;
  Timer? _pauseTimer;
  
  // Layout
  late TextPainter _placeholderPainter;
  Size _textSize = Size.zero;
  
  // Theme cache
  late Color _textColor;
  late Color _cursorColor;
  bool _isDark = false;
  
  @override
  void initState() {
    super.initState();
    _computeWordBoundaries();
    _initTextPainter();
    _startAnimation();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _startTypewriter();
    });
  }
  
  /// Pre-compute word boundaries for O(1) lookup
  /// Words include punctuation - only whitespace separates words
  void _computeWordBoundaries() {
    _wordBoundaries = [];
    bool inWord = false;
    
    for (int i = 0; i < widget.text.length; i++) {
      final char = widget.text[i];
      final isWordChar = !_isWhitespace(char);
      
      if (inWord && !isWordChar) {
        _wordBoundaries.add(i); // Word ends here
        inWord = false;
      } else if (!inWord && isWordChar) {
        inWord = true;
      }
    }
    
    // Add final word boundary if text ends with a word
    if (inWord) {
      _wordBoundaries.add(widget.text.length);
    }
  }
  
  /// Only whitespace separates words - punctuation stays with the word
  bool _isWhitespace(String char) {
    return char == ' ' || char == '\n' || char == '\t';
  }
  
  /// Check if char is punctuation (for timing delays)
  bool _isPunctuation(String char) {
    return char == '.' || char == ',' || char == '!' || 
           char == '?' || char == ';' || char == ':' ||
           char == '"' || char == "'" || char == '-';
  }
  
  void _initTextPainter() {
    final style = TextStyle(
      fontFamily: 'Mynerve',
      fontSize: _TypewriterConfig.fontSize,
      height: _TypewriterConfig.lineHeight,
      letterSpacing: _TypewriterConfig.letterSpacing,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    
    _placeholderPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
  }
  
  void _startAnimation() {
    _animationTicker = createTicker(_onTick);
    _animationTicker!.start();
  }
  
  void _onTick(Duration elapsed) {
    final now = elapsed.inMilliseconds;
    
    // Cursor blink
    final cursorPhase = (now % 1060) / 1060.0;
    _cursorOpacity.value = cursorPhase < 0.5 ? 1.0 : 0.0;
    
    // Update glow animation (30 FPS)
    if (now - _lastGlowUpdate > 33 && _glowingWords.isNotEmpty) {
      _lastGlowUpdate = now;
      _cleanupOldGlows();
      _glowTick.value++;
    }
  }
  
  void _cleanupOldGlows() {
    final now = DateTime.now().millisecondsSinceEpoch;
    while (_glowingWords.isNotEmpty) {
      final age = now - _glowingWords.first.revealTime;
      if (age > _TypewriterConfig.glowDurationMs) {
        _glowingWords.removeAt(0);
      } else {
        break;
      }
    }
  }
  
  void _startTypewriter() {
    _typeTimer?.cancel();
    if (_isPaused || !mounted) return;
    
    final currentIndex = _charIndex.value;
    if (currentIndex >= widget.text.length) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final char = widget.text[currentIndex];
    
    // Check if we just completed a word (only whitespace separates words)
    // Punctuation stays with the word and glows blue
    if (_isWhitespace(char) && currentIndex > _currentWordStart) {
      // Word just ended - add to glow list
      if (_glowingWords.length >= _TypewriterConfig.maxActiveGlowWords) {
        _glowingWords.removeAt(0);
      }
      _glowingWords.add(_WordInfo(_currentWordStart, currentIndex, now));
      _currentWordStart = currentIndex + 1;
    } else if (_isWhitespace(char)) {
      _currentWordStart = currentIndex + 1;
    }
    
    _charIndex.value = currentIndex + 1;
    _checkScroll();
    
    // Calculate delay
    if (currentIndex + 1 < widget.text.length) {
      int delay = _TypewriterConfig.charDelayMs;
      
      if (char == '.' || char == '!' || char == '?') {
        delay = _TypewriterConfig.sentenceDelayMs;
      } else if (char == ',' || char == ';' || char == ':') {
        delay = _TypewriterConfig.punctuationDelayMs;
      } else if (char == '\n') {
        delay = _TypewriterConfig.newlineDelayMs;
      }
      
      _typeTimer = Timer(Duration(milliseconds: delay), _startTypewriter);
    } else {
      // Text complete - add final word if any
      if (currentIndex > _currentWordStart) {
        _glowingWords.add(_WordInfo(_currentWordStart, currentIndex + 1, now));
      }
    }
  }
  
  void _checkScroll() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastScrollTime < _TypewriterConfig.scrollThrottleMs) return;
    _lastScrollTime = now;
    
    if (!widget.scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) return;
      
      final position = widget.scrollController.position;
      final viewportHeight = position.viewportDimension;
      
      const avgCharWidth = 11.0;
      const availableWidth = 415.0 - 32.0;
      final charsPerLine = (availableWidth / avgCharWidth).floor();
      final lines = (_charIndex.value / charsPerLine).ceil();
      final cursorY = lines * _TypewriterConfig.fontSize * _TypewriterConfig.lineHeight + 60;
      
      final keepInView = viewportHeight * 0.7;
      final currentScroll = position.pixels;
      
      if (cursorY > currentScroll + keepInView) {
        final targetScroll = (cursorY - keepInView).clamp(0.0, position.maxScrollExtent);
        widget.scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _onPressStart() {
    _pauseTimer?.cancel();
    _pauseTimer = Timer(const Duration(milliseconds: 40), () {
      if (mounted && !_isPaused) {
        _isPaused = true;
        _typeTimer?.cancel();
      }
    });
  }
  
  void _onPressEnd() {
    _pauseTimer?.cancel();
    if (_isPaused) {
      _isPaused = false;
      _startTypewriter();
    }
  }
  
  @override
  void dispose() {
    _typeTimer?.cancel();
    _pauseTimer?.cancel();
    _animationTicker?.dispose();
    _charIndex.dispose();
    _cursorOpacity.dispose();
    _glowTick.dispose();
    _placeholderPainter.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _isDark = theme.brightness == Brightness.dark;
    _textColor = _isDark ? _TypewriterConfig.darkTextColor : _TypewriterConfig.lightTextColor;
    _cursorColor = _isDark ? _TypewriterConfig.darkCursorColor : _TypewriterConfig.lightCursorColor;
  }
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onPressStart(),
      onPointerUp: (_) => _onPressEnd(),
      onPointerCancel: (_) => _onPressEnd(),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _placeholderPainter.layout(maxWidth: constraints.maxWidth);
              _textSize = _placeholderPainter.size;
              
              return RepaintBoundary(
                child: SizedBox(
                  width: _textSize.width,
                  height: _textSize.height + 30,
                  child: _WordGlowPainterWidget(
                    text: widget.text,
                    charIndex: _charIndex,
                    cursorOpacity: _cursorOpacity,
                    glowTick: _glowTick,
                    glowingWords: _glowingWords,
                    currentWordStart: () => _currentWordStart,
                    textColor: _textColor,
                    cursorColor: _cursorColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget that paints text with word-based glow
class _WordGlowPainterWidget extends StatelessWidget {
  final String text;
  final ValueNotifier<int> charIndex;
  final ValueNotifier<double> cursorOpacity;
  final ValueNotifier<int> glowTick;
  final List<_WordInfo> glowingWords;
  final int Function() currentWordStart;
  final Color textColor;
  final Color cursorColor;

  const _WordGlowPainterWidget({
    required this.text,
    required this.charIndex,
    required this.cursorOpacity,
    required this.glowTick,
    required this.glowingWords,
    required this.currentWordStart,
    required this.textColor,
    required this.cursorColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: charIndex,
      builder: (context, currentCharIndex, _) {
        return ValueListenableBuilder<double>(
          valueListenable: cursorOpacity,
          builder: (context, opacity, _) {
            return ValueListenableBuilder<int>(
              valueListenable: glowTick,
              builder: (context, tick, _) {
                return CustomPaint(
                  painter: _WordGlowPainter(
                    text: text,
                    revealedChars: currentCharIndex,
                    cursorOpacity: opacity,
                    glowTick: tick,
                    glowingWords: glowingWords,
                    currentWordStart: currentWordStart(),
                    textColor: textColor,
                    cursorColor: cursorColor,
                  ),
                  isComplex: false,
                  willChange: true,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// High-performance painter with word-based glow
class _WordGlowPainter extends CustomPainter {
  final String text;
  final int revealedChars;
  final double cursorOpacity;
  final int glowTick;
  final List<_WordInfo> glowingWords;
  final int currentWordStart;
  final Color textColor;
  final Color cursorColor;
  
  _WordGlowPainter({
    required this.text,
    required this.revealedChars,
    required this.cursorOpacity,
    required this.glowTick,
    required this.glowingWords,
    required this.currentWordStart,
    required this.textColor,
    required this.cursorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final baseStyle = TextStyle(
      fontFamily: 'Mynerve',
      fontSize: _TypewriterConfig.fontSize,
      height: _TypewriterConfig.lineHeight,
      letterSpacing: _TypewriterConfig.letterSpacing,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
    
    // Build word glow map: charIndex -> intensity
    final Map<int, double> glowRanges = {};
    
    for (final word in glowingWords) {
      final elapsed = now - word.revealTime;
      if (elapsed < _TypewriterConfig.glowDurationMs) {
        final t = elapsed / _TypewriterConfig.glowDurationMs;
        final intensity = 1.0 - (t * t); // Quadratic ease-out
        
        // Mark all chars in this word for glow
        for (int i = word.startIndex; i < word.endIndex && i < revealedChars; i++) {
          glowRanges[i] = intensity;
        }
      }
    }
    
    // Also add current word being typed (full intensity)
    if (currentWordStart < revealedChars) {
      for (int i = currentWordStart; i < revealedChars; i++) {
        glowRanges[i] = 1.0;
      }
    }
    
    // Build spans efficiently - group consecutive chars with same glow
    final spans = <TextSpan>[];
    int segmentStart = 0;
    double? currentGlow;
    
    for (int i = 0; i <= revealedChars && i <= text.length; i++) {
      final glow = i < revealedChars ? glowRanges[i] : null;
      final glowLevel = glow != null && glow > 0.1 ? glow : null;
      
      // Check if glow state changed or we reached the end
      if (i == revealedChars || 
          (glowLevel == null) != (currentGlow == null) ||
          (glowLevel != null && currentGlow != null && (glowLevel - currentGlow).abs() > 0.2)) {
        
        // Flush current segment
        if (i > segmentStart) {
          final segmentText = text.substring(segmentStart, i);
          
          if (currentGlow != null && currentGlow > 0.1) {
            // Glowing segment
            final glowColor = Color.lerp(
              _TypewriterConfig.glowColor,
              textColor,
              1.0 - currentGlow,
            )!;
            
            spans.add(TextSpan(
              text: segmentText,
              style: baseStyle.copyWith(
                color: glowColor,
                shadows: [
                  Shadow(
                    color: _TypewriterConfig.glowColor.withOpacity(0.8 * currentGlow),
                    blurRadius: 15.0 * currentGlow,
                  ),
                ],
              ),
            ));
          } else {
            // Normal segment
            spans.add(TextSpan(text: segmentText, style: baseStyle));
          }
        }
        
        segmentStart = i;
        currentGlow = glowLevel;
      }
    }
    
    // Hidden text (transparent)
    if (revealedChars < text.length) {
      spans.add(TextSpan(
        text: text.substring(revealedChars),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
    }
    
    // Cursor
    if (revealedChars < text.length && cursorOpacity > 0) {
      spans.add(TextSpan(
        text: '▍',
        style: baseStyle.copyWith(
          color: cursorColor.withOpacity(cursorOpacity),
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    
    // Paint
    final painter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    
    painter.layout(maxWidth: size.width);
    painter.paint(canvas, Offset.zero);
    painter.dispose();
  }

  @override
  bool shouldRepaint(_WordGlowPainter oldDelegate) {
    return revealedChars != oldDelegate.revealedChars ||
           cursorOpacity != oldDelegate.cursorOpacity ||
           glowTick != oldDelegate.glowTick;
  }
}
