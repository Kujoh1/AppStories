import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:ui' as ui;

/// Ultra high-performance typewriter animation
/// With REAL blur effect using ImageFilter
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
      child: _TypewriterWithBlur(
        text: text,
        scrollController: scrollController,
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
  
  static const int glowDurationMs = 1800;
  static const int blurDurationMs = 1500;
  static const double maxBlurSigma = 8.0; // Max blur strength
  
  static const double fontSize = 18.0;
  static const double lineHeight = 1.9;
  static const double letterSpacing = 2.0;
  
  static const Color glowColor = Color(0xFF30ACFF);
  static const Color darkTextColor = Color(0xFFE8DCC0);
  static const Color lightTextColor = Color(0xFF2C1810);
  static const Color darkCursorColor = Color(0xFFD4AF37);
  static const Color lightCursorColor = Color(0xFF8B4513);
}

class _WordInfo {
  final int startIndex;
  final int endIndex;
  final int revealTime;
  _WordInfo(this.startIndex, this.endIndex, this.revealTime);
}

class _TypewriterWithBlur extends StatefulWidget {
  final String text;
  final ScrollController scrollController;

  const _TypewriterWithBlur({
    required this.text,
    required this.scrollController,
  });

  @override
  State<_TypewriterWithBlur> createState() => _TypewriterWithBlurState();
}

class _TypewriterWithBlurState extends State<_TypewriterWithBlur>
    with SingleTickerProviderStateMixin {
  
  int _charIndex = 0;
  double _cursorOpacity = 1.0;
  
  final List<_WordInfo> _glowingWords = [];
  int _currentWordStart = 0;
  int _currentWordStartTime = 0;
  
  Timer? _typeTimer;
  Ticker? _ticker;
  int _lastScrollTime = 0;
  
  bool _isPaused = false;
  Timer? _pauseTimer;
  
  late Color _textColor;
  late Color _cursorColor;
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _startTypewriter();
    });
  }
  
  void _onTick(Duration elapsed) {
    if (!mounted) return;
    
    final now = elapsed.inMilliseconds;
    final cursorPhase = (now % 1060) / 1060.0;
    final newCursorOpacity = cursorPhase < 0.5 ? 1.0 : 0.0;
    
    if (newCursorOpacity != _cursorOpacity) {
      setState(() => _cursorOpacity = newCursorOpacity);
    }
    
    // Cleanup old glows and trigger repaint for blur animation
    if (now % 50 < 16) {
      _cleanupOldGlows();
      if (_hasActiveEffects()) {
        setState(() {}); // Trigger repaint for blur/glow animation
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
  
  bool _isWhitespace(String char) => char == ' ' || char == '\n' || char == '\t';
  
  void _startTypewriter() {
    _typeTimer?.cancel();
    if (_isPaused || !mounted) return;
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
    _checkScroll();
    
    if (_charIndex < widget.text.length) {
      int delay = _Config.charDelayMs;
      if (char == '.' || char == '!' || char == '?') {
        delay = _Config.sentenceDelayMs;
      } else if (char == ',' || char == ';' || char == ':') {
        delay = _Config.punctuationDelayMs;
      } else if (char == '\n') {
        delay = _Config.newlineDelayMs;
      }
      _typeTimer = Timer(Duration(milliseconds: delay), _startTypewriter);
    } else if (_charIndex > _currentWordStart) {
      _glowingWords.add(_WordInfo(_currentWordStart, _charIndex, _currentWordStartTime));
    }
  }
  
  void _checkScroll() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastScrollTime < 150) return;
    _lastScrollTime = now;
    
    if (!widget.scrollController.hasClients) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) return;
      
      final position = widget.scrollController.position;
      final viewportHeight = position.viewportDimension;
      final charsPerLine = ((415.0 - 32.0) / 11.0).floor();
      final lines = (_charIndex / charsPerLine).ceil();
      final cursorY = lines * _Config.fontSize * _Config.lineHeight + 60;
      
      final keepInView = viewportHeight * 0.7;
      if (cursorY > position.pixels + keepInView) {
        widget.scrollController.animateTo(
          (cursorY - keepInView).clamp(0.0, position.maxScrollExtent),
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
    _ticker?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _textColor = isDark ? _Config.darkTextColor : _Config.lightTextColor;
    _cursorColor = isDark ? _Config.darkCursorColor : _Config.lightCursorColor;
  }
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Calculate blur intensity for current word
    double blurIntensity = 0.0;
    if (_currentWordStartTime > 0) {
      final elapsed = now - _currentWordStartTime;
      if (elapsed < _Config.blurDurationMs) {
        final t = elapsed / _Config.blurDurationMs;
        blurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t); // Cubic ease-in
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
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: RepaintBoundary(
            child: Stack(
              children: [
                // Layer 1: Invisible placeholder for layout
                Opacity(
                  opacity: 0.0,
                  child: Text(widget.text, style: baseStyle),
                ),
                
                // Layer 2: Sharp text (revealed portion)
                _buildTextWithEffects(baseStyle, now, blurIntensity, isBlurred: false),
                
                // Layer 3: Blurred overlay for current word (fades out)
                if (blurIntensity > 0.05 && _currentWordStart < _charIndex)
                  _buildBlurredCurrentWord(baseStyle, blurIntensity),
                
                // Layer 4: Blurred overlay for recently completed words
                ..._buildBlurredCompletedWords(baseStyle, now),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextWithEffects(TextStyle baseStyle, int now, double blurIntensity, {required bool isBlurred}) {
    final spans = <TextSpan>[];
    
    // Calculate glow intensities AND track which chars are still blurred
    final Map<int, double> glowMap = {};
    final Set<int> blurredChars = {}; // Chars that should be hidden (rendered in blur layer)
    
    for (final word in _glowingWords) {
      final elapsed = now - word.revealTime;
      
      // Check if this word is still in blur phase
      if (elapsed < _Config.blurDurationMs) {
        final t = elapsed / _Config.blurDurationMs;
        final wordBlurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t);
        if (wordBlurIntensity > 0.05) {
          // This word is still blurred - hide it in this layer
          for (int i = word.startIndex; i < word.endIndex && i < _charIndex; i++) {
            blurredChars.add(i);
          }
        }
      }
      
      // Glow effect (longer duration)
      if (elapsed < _Config.glowDurationMs) {
        final t = elapsed / _Config.glowDurationMs;
        final intensity = 1.0 - (t * t);
        for (int i = word.startIndex; i < word.endIndex && i < _charIndex; i++) {
          if (!blurredChars.contains(i)) {
            glowMap[i] = intensity;
          }
        }
      }
    }
    
    // Current word: only gets glow if blur is done, otherwise HIDE it here
    final bool currentWordIsBlurred = blurIntensity > 0.05;
    if (currentWordIsBlurred) {
      for (int i = _currentWordStart; i < _charIndex; i++) {
        blurredChars.add(i);
      }
    } else {
      for (int i = _currentWordStart; i < _charIndex; i++) {
        glowMap[i] = 1.0;
      }
    }
    
    // Build text segments
    int segmentStart = 0;
    double? currentGlow;
    bool? isHidden;
    
    for (int i = 0; i <= _charIndex && i <= widget.text.length; i++) {
      final charIsHidden = blurredChars.contains(i);
      final glow = (!charIsHidden && i < _charIndex) ? glowMap[i] : null;
      final glowLevel = (glow != null && glow > 0.1) ? glow : null;
      
      final glowChanged = (glowLevel == null) != (currentGlow == null) ||
          (glowLevel != null && currentGlow != null && (glowLevel - currentGlow).abs() > 0.15);
      final hiddenChanged = charIsHidden != isHidden;
      
      if (i == _charIndex || glowChanged || hiddenChanged) {
        if (i > segmentStart) {
          final text = widget.text.substring(segmentStart, i);
          
          // If this segment is blurred, make it TRANSPARENT
          if (isHidden == true) {
            spans.add(TextSpan(
              text: text,
              style: baseStyle.copyWith(color: Colors.transparent),
            ));
          } else if (currentGlow != null && currentGlow > 0.1) {
            final glowColor = Color.lerp(_Config.glowColor, _textColor, 1.0 - currentGlow)!;
            spans.add(TextSpan(
              text: text,
              style: baseStyle.copyWith(
                color: glowColor,
                shadows: [
                  Shadow(
                    color: _Config.glowColor.withOpacity(0.8 * currentGlow),
                    blurRadius: 15.0 * currentGlow,
                  ),
                ],
              ),
            ));
          } else {
            spans.add(TextSpan(text: text, style: baseStyle));
          }
        }
        segmentStart = i;
        currentGlow = glowLevel;
        isHidden = charIsHidden;
      }
    }
    
    // Hidden text
    if (_charIndex < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(_charIndex),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
    }
    
    // Cursor
    if (_charIndex < widget.text.length && _cursorOpacity > 0) {
      spans.add(TextSpan(
        text: '▍',
        style: baseStyle.copyWith(
          color: _cursorColor.withOpacity(_cursorOpacity),
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
  
  /// Build list of blurred widgets for recently completed words
  List<Widget> _buildBlurredCompletedWords(TextStyle baseStyle, int now) {
    final widgets = <Widget>[];
    
    for (final word in _glowingWords) {
      final elapsed = now - word.revealTime;
      if (elapsed < _Config.blurDurationMs) {
        final t = elapsed / _Config.blurDurationMs;
        final blurIntensity = (1.0 - t) * (1.0 - t) * (1.0 - t); // Cubic ease-in
        
        if (blurIntensity > 0.05) {
          widgets.add(_buildBlurredWord(baseStyle, word.startIndex, word.endIndex, blurIntensity));
        }
      }
    }
    
    return widgets;
  }
  
  /// Renders a specific word range with blur effect
  Widget _buildBlurredWord(TextStyle baseStyle, int startIndex, int endIndex, double blurIntensity) {
    final sigma = _Config.maxBlurSigma * blurIntensity;
    final spans = <TextSpan>[];
    
    // Text before word (transparent - for positioning)
    if (startIndex > 0) {
      spans.add(TextSpan(
        text: widget.text.substring(0, startIndex),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
    }
    
    // The word itself (visible, blurred)
    final wordEnd = endIndex.clamp(0, widget.text.length);
    final wordText = widget.text.substring(startIndex, wordEnd);
    spans.add(TextSpan(
      text: wordText,
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
    
    // Rest of text (transparent)
    if (wordEnd < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(wordEnd),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
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
  
  /// Renders ONLY the current word with a real blur effect
  Widget _buildBlurredCurrentWord(TextStyle baseStyle, double blurIntensity) {
    if (_currentWordStart >= _charIndex) return const SizedBox.shrink();
    
    final sigma = _Config.maxBlurSigma * blurIntensity;
    
    // Build the text with the current word highlighted
    final spans = <TextSpan>[];
    
    // Text before current word (transparent - just for positioning)
    if (_currentWordStart > 0) {
      spans.add(TextSpan(
        text: widget.text.substring(0, _currentWordStart),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
    }
    
    // Current word - ALWAYS full glow color (matches Layer 2 when blur ends)
    final currentWord = widget.text.substring(_currentWordStart, _charIndex);
    spans.add(TextSpan(
      text: currentWord,
      style: baseStyle.copyWith(
        color: _Config.glowColor, // Full neon blue
        shadows: [
          Shadow(
            color: _Config.glowColor.withOpacity(0.8),
            blurRadius: 15.0,
          ),
        ],
      ),
    ));
    
    // Rest of text (transparent)
    if (_charIndex < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(_charIndex),
        style: baseStyle.copyWith(color: Colors.transparent),
      ));
    }
    
    // Blur decreases, color stays constant
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
