import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:ui' as ui;

/// Paged typewriter animation - no scrolling, page by page
class DecorativeStoryText extends StatelessWidget {
  final String text;
  final ValueChanged<bool>? onPauseChanged;

  const DecorativeStoryText({
    super.key,
    required this.text,
    this.onPauseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minWidth: 320,
        maxWidth: 415,
      ),
      child: _PagedTypewriter(
        text: text,
        onPauseChanged: onPauseChanged,
      ),
    );
  }
}

/// Configuration
class _Config {
  static const int charDelayMs = 25;
  static const int punctuationDelayMs = 300;
  static const int sentenceDelayMs = 1200;
  static const int newlineDelayMs = 600;
  static const int pageTransitionMs = 3000;
  
  static const int glowDurationMs = 1800;
  static const int blurDurationMs = 1500;
  static const double maxBlurSigma = 8.0;
  
  static const double fontSize = 18.0;
  static const double lineHeight = 1.9;
  static const double letterSpacing = 2.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 40.0;
  
  static const Color glowColor = Color(0xFF30ACFF);
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
  _WordInfo(this.startIndex, this.endIndex, this.revealTime);
}

/// Page boundary info
class _PageInfo {
  final int startCharIndex;
  final int endCharIndex;
  final String text;
  
  _PageInfo({
    required this.startCharIndex,
    required this.endCharIndex,
    required this.text,
  });
}

class _PagedTypewriter extends StatefulWidget {
  final String text;
  final ValueChanged<bool>? onPauseChanged;

  const _PagedTypewriter({
    required this.text,
    this.onPauseChanged,
  });

  @override
  State<_PagedTypewriter> createState() => _PagedTypewriterState();
}

class _PagedTypewriterState extends State<_PagedTypewriter>
    with SingleTickerProviderStateMixin {
  
  int _charIndex = 0;
  
  final List<_WordInfo> _glowingWords = [];
  int _currentWordStart = 0;
  int _currentWordStartTime = 0;
  
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
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
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
  
  /// Calculate how many lines fit on a page
  int _calculateLinesPerPage(double availableHeight) {
    final lineHeight = _Config.fontSize * _Config.lineHeight;
    final usableHeight = availableHeight - (_Config.verticalPadding * 2);
    return (usableHeight / lineHeight).floor();
  }
  
  /// Split text into pages based on available size
  void _calculatePages(Size size) {
    if (_availableSize == size && _pages.isNotEmpty) return;
    _availableSize = size;
    
    final linesPerPage = _calculateLinesPerPage(size.height);
    final textWidth = size.width - (_Config.horizontalPadding * 2);
    
    // Create TextPainter to measure text layout
    final baseStyle = TextStyle(
      fontFamily: 'Mynerve',
      fontSize: _Config.fontSize,
      height: _Config.lineHeight,
      letterSpacing: _Config.letterSpacing,
      fontWeight: FontWeight.w600,
    );
    
    _pages = [];
    int charIndex = 0;
    
    while (charIndex < widget.text.length) {
      // Find how many characters fit on this page
      int pageEndIndex = charIndex;
      int linesUsed = 0;
      
      while (pageEndIndex < widget.text.length && linesUsed < linesPerPage) {
        // Find end of current line
        int lineEnd = pageEndIndex;
        double lineWidth = 0;
        
        while (lineEnd < widget.text.length) {
          final char = widget.text[lineEnd];
          
          if (char == '\n') {
            lineEnd++;
            break;
          }
          
          // Measure character width (approximate)
          final charPainter = TextPainter(
            text: TextSpan(text: char, style: baseStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          
          if (lineWidth + charPainter.width > textWidth) {
            // Word wrap: find last space
            int wrapPoint = lineEnd;
            while (wrapPoint > pageEndIndex && widget.text[wrapPoint] != ' ') {
              wrapPoint--;
            }
            if (wrapPoint > pageEndIndex) {
              lineEnd = wrapPoint + 1;
            }
            charPainter.dispose();
            break;
          }
          
          lineWidth += charPainter.width;
          charPainter.dispose();
          lineEnd++;
        }
        
        pageEndIndex = lineEnd;
        linesUsed++;
      }
      
      // Create page
      _pages.add(_PageInfo(
        startCharIndex: charIndex,
        endCharIndex: pageEndIndex,
        text: widget.text.substring(charIndex, pageEndIndex),
      ));
      
      charIndex = pageEndIndex;
    }
    
    // Start typewriter after pages are calculated
    if (_charIndex == 0 && _pages.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _startTypewriter();
      });
    }
  }
  
  bool _isWhitespace(String char) => char == ' ' || char == '\n' || char == '\t';
  
  void _startTypewriter() {
    _typeTimer?.cancel();
    if (_isPaused || !mounted || _isPageTransitioning) return;
    if (_charIndex >= widget.text.length) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final char = widget.text[_charIndex];
    
    // Track word start time
    if (_charIndex == _currentWordStart && !_isWhitespace(char)) {
      _currentWordStartTime = now;
    }
    
    // Word completed
    if (_isWhitespace(char) && _charIndex > _currentWordStart) {
      if (_glowingWords.length >= 8) _glowingWords.removeAt(0);
      _glowingWords.add(_WordInfo(_currentWordStart, _charIndex, _currentWordStartTime));
      _currentWordStart = _charIndex + 1;
      _currentWordStartTime = 0;
    } else if (_isWhitespace(char)) {
      _currentWordStart = _charIndex + 1;
      _currentWordStartTime = 0;
    }
    
    setState(() => _charIndex++);
    
    // Check if we need to transition to next page
    _checkPageTransition();
    
    if (_charIndex < widget.text.length && !_isPageTransitioning) {
      int delay = _Config.charDelayMs;
      if (char == '.' || char == '!' || char == '?') {
        delay = _Config.sentenceDelayMs;
      } else if (char == ',' || char == ';' || char == ':') {
        delay = _Config.punctuationDelayMs;
      } else if (char == '\n') {
        delay = _Config.newlineDelayMs;
      }
      _typeTimer = Timer(Duration(milliseconds: delay), _startTypewriter);
    } else if (_charIndex >= widget.text.length && _charIndex > _currentWordStart) {
      _glowingWords.add(_WordInfo(_currentWordStart, _charIndex, _currentWordStartTime));
    }
  }
  
  void _checkPageTransition() {
    if (_pages.isEmpty || _currentPageIndex >= _pages.length) return;
    
    final currentPage = _pages[_currentPageIndex];
    
    // If we've reached the end of this page
    if (_charIndex >= currentPage.endCharIndex && _currentPageIndex < _pages.length - 1) {
      _performPageTransition();
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
        _glowingWords.clear();
        _currentWordStart = _pages[_currentPageIndex].startCharIndex;
        _currentWordStartTime = 0;
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
    _pauseTimer?.cancel();
    if (_isPaused) {
      _isPaused = false;
      widget.onPauseChanged?.call(false);
      _startTypewriter();
    }
  }
  
  @override
  void dispose() {
    _typeTimer?.cancel();
    _pauseTimer?.cancel();
    _ticker?.dispose();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate pages based on available space
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _calculatePages(size);
        
        if (_pages.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final currentPage = _pages[_currentPageIndex];
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Calculate blur intensity for current word
        double blurIntensity = 0.0;
        if (_currentWordStartTime > 0) {
          final elapsed = now - _currentWordStartTime;
          if (elapsed < _Config.blurDurationMs) {
            final t = elapsed / _Config.blurDurationMs;
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
        
        return Listener(
          onPointerDown: (_) => _onPressStart(),
          onPointerUp: (_) => _onPressEnd(),
          onPointerCancel: (_) => _onPressEnd(),
          child: AnimatedOpacity(
            opacity: _pageOpacity,
            duration: Duration(milliseconds: _Config.pageTransitionMs ~/ 2),
            curve: Curves.easeInOut,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _Config.horizontalPadding,
                vertical: _Config.verticalPadding,
              ),
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    // Layer 0: Invisible layout placeholder (defines exact size)
                    Opacity(
                      opacity: 0.0,
                      child: Text(currentPage.text, style: baseStyle),
                    ),
                    
                    // Layer 1: Ghost text (entire page, blurry & dim)
                    Positioned.fill(
                      child: _buildGhostText(currentPage.text, baseStyle),
                    ),
                    
                    // Layer 2: Sharp revealed text
                    Positioned.fill(
                      child: _buildRevealedText(currentPage, baseStyle, now, blurIntensity),
                    ),
                    
                    // Layer 3: Blurred overlay for current word
                    if (blurIntensity > 0.05 && _currentWordStart < _charIndex)
                      Positioned.fill(
                        child: _buildBlurredCurrentWord(currentPage, baseStyle, blurIntensity),
                      ),
                    
                    // Layer 4: Blurred recently completed words
                    ..._buildBlurredCompletedWords(currentPage, baseStyle, now),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Ghost text - full page preview, blurry and dim
  Widget _buildGhostText(String pageText, TextStyle baseStyle) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: _Config.ghostBlurSigma,
        sigmaY: _Config.ghostBlurSigma,
        tileMode: TileMode.decal,
      ),
      child: Opacity(
        opacity: _Config.ghostOpacity,
        child: Text(
          pageText,
          style: baseStyle,
        ),
      ),
    );
  }
  
  /// Build revealed text with glow effects - renders FULL page text for layout stability
  Widget _buildRevealedText(_PageInfo page, TextStyle baseStyle, int now, double blurIntensity) {
    final pageRevealedChars = (_charIndex - page.startCharIndex).clamp(0, page.text.length);
    
    // Calculate glow intensities AND track which chars are still blurred
    final Map<int, double> glowMap = {};
    final Set<int> blurredChars = {};
    
    for (final word in _glowingWords) {
      final wordStart = word.startIndex - page.startCharIndex;
      final wordEnd = word.endIndex - page.startCharIndex;
      
      if (wordEnd <= 0 || wordStart >= page.text.length) continue;
      
      final elapsed = now - word.revealTime;
      
      if (elapsed < _Config.blurDurationMs) {
        final t = elapsed / _Config.blurDurationMs;
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
    
    // Build COMPLETE page text - character by character for stable layout
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isRevealed = i < pageRevealedChars;
      final isBlurred = blurredChars.contains(i);
      final glowIntensity = glowMap[i];
      
      if (!isRevealed) {
        // Not yet revealed - transparent
        spans.add(TextSpan(text: char, style: baseStyle.copyWith(color: Colors.transparent)));
      } else if (isBlurred) {
        // Blurred (rendered in blur layer) - transparent here
        spans.add(TextSpan(text: char, style: baseStyle.copyWith(color: Colors.transparent)));
      } else if (glowIntensity != null && glowIntensity > 0.1) {
        // Glowing
        final glowColor = Color.lerp(_Config.glowColor, _textColor, 1.0 - glowIntensity)!;
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(
            color: glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8 * glowIntensity),
                blurRadius: 15.0 * glowIntensity,
              ),
            ],
          ),
        ));
      } else {
        // Normal revealed text - use exact same style as base
        spans.add(TextSpan(text: char, style: baseStyle));
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
      if (elapsed < _Config.blurDurationMs) {
        final t = elapsed / _Config.blurDurationMs;
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
    
    // Render FULL page text with only the word visible (for layout stability)
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isInWord = i >= startIndex && i < endIndex;
      
      if (isInWord) {
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(
            color: _Config.glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8),
                blurRadius: 15.0,
              ),
            ],
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(color: Colors.transparent),
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
    
    // Render FULL page text with only current word visible (for layout stability)
    final spans = <TextSpan>[];
    
    for (int i = 0; i < page.text.length; i++) {
      final char = page.text[i];
      final isInWord = i >= currentWordStartRel && i < currentWordEndRel;
      
      if (isInWord) {
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(
            color: _Config.glowColor,
            shadows: [
              Shadow(
                color: _Config.glowColor.withOpacity(0.8),
                blurRadius: 15.0,
              ),
            ],
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: char,
          style: baseStyle.copyWith(color: Colors.transparent),
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
