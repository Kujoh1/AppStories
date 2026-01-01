import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import '../../../../domain/models/story_page.dart';
import '../../../../core/widgets/smart_image.dart';

/// Configuration for text animation
class _AnimConfig {
  static const int charDelayMs = 12;
  static const int glowDurationMs = 1200;
  static const double fontSize = 16.0;
  static const double lineHeight = 1.9;
  static const double letterSpacing = 0.5;
  static const Color glowColor = Color(0xFFFEFFE9);
  static const Color darkTextColor = Color(0xFFE8DCC0);
}

/// Unified page display widget
/// 
/// Displays a single StoryPage with:
/// - Animated text reveal (typewriter effect)
/// - Optional image with fade-in
/// - Optional choices
/// - Unified swipe navigation
/// - "Weiter" button as alternative
class PageViewWidget extends StatefulWidget {
  final StoryPage page;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final void Function(PageChoice choice)? onChoiceSelected;
  final bool skipAnimation;
  final double speedMultiplier;

  const PageViewWidget({
    super.key,
    required this.page,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onChoiceSelected,
    this.skipAnimation = false,
    this.speedMultiplier = 1.0,
  });

  @override
  State<PageViewWidget> createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget>
    with TickerProviderStateMixin {
  
  // Text animation state
  int _charIndex = 0;
  bool _textComplete = false;
  Ticker? _ticker;
  int _nextCharTime = 0;
  
  // Image animation
  late AnimationController _imageController;
  
  // Swipe state
  double _swipeDx = 0.0;
  static const double _swipeThreshold = 60.0;
  
  // Glow effects
  final List<_GlowWord> _glowWords = [];
  int _currentWordStart = 0;
  
  Color _textColor = _AnimConfig.darkTextColor;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startAnimation();
  }

  @override
  void didUpdateWidget(PageViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id) {
      _resetAndStart();
    }
  }

  void _resetAndStart() {
    _charIndex = 0;
    _textComplete = false;
    _glowWords.clear();
    _currentWordStart = 0;
    _imageController.reset();
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.skipAnimation) {
      setState(() {
        _charIndex = widget.page.text.length;
        _textComplete = true;
      });
      if (widget.page.hasImage) {
        _imageController.forward();
      }
      return;
    }
    
    _nextCharTime = DateTime.now().millisecondsSinceEpoch;
    _ticker?.dispose();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (_charIndex >= widget.page.text.length) {
      _ticker?.stop();
      if (!_textComplete) {
        setState(() => _textComplete = true);
        _onTextComplete();
      }
      return;
    }
    
    if (now >= _nextCharTime) {
      setState(() {
        final char = widget.page.text[_charIndex];
        _charIndex++;
        
        // Track word boundaries for glow
        if (char == ' ' || char == '\n' || _charIndex >= widget.page.text.length) {
          if (_charIndex > _currentWordStart + 1) {
            _glowWords.add(_GlowWord(
              startIndex: _currentWordStart,
              endIndex: _charIndex,
              revealTime: now,
            ));
          }
          _currentWordStart = _charIndex;
        }
        
        // Calculate next char delay (higher speedMultiplier = faster = less delay)
        final multiplier = widget.speedMultiplier > 0 ? widget.speedMultiplier : 1.0;
        int delay = (_AnimConfig.charDelayMs / multiplier).round();
        if (char == '.' || char == '!' || char == '?') {
          delay += (200 / multiplier).round();
        } else if (char == ',') {
          delay += (100 / multiplier).round();
        } else if (char == '\n') {
          delay += (300 / multiplier).round();
        }
        _nextCharTime = now + delay;
      });
    }
    
    // Cleanup old glows
    _glowWords.removeWhere((w) => now - w.revealTime > _AnimConfig.glowDurationMs);
  }

  void _onTextComplete() {
    if (widget.page.hasImage) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _imageController.forward();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _textColor = isDark ? _AnimConfig.darkTextColor : const Color(0xFF2C1810);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeDx = (_swipeDx + details.delta.dx).clamp(-120.0, 120.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_swipeDx.abs() > _swipeThreshold) {
      if (_swipeDx < 0 && !widget.page.isBlocked) {
        _goNext();
      } else if (_swipeDx > 0) {
        _goPrevious();
      }
    }
    setState(() => _swipeDx = 0.0);
  }

  void _goNext() {
    if (!_textComplete) {
      setState(() {
        _charIndex = widget.page.text.length;
        _textComplete = true;
      });
      _ticker?.stop();
      _onTextComplete();
      return;
    }
    
    if (!widget.page.isBlocked && widget.onNext != null) {
      widget.onNext!();
    }
  }

  void _goPrevious() {
    widget.onPrevious?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onTap: _goNext,
          child: Transform.translate(
            offset: Offset(_swipeDx * 0.3, 0),
            child: Stack(
              children: [
                // Main content - NO SCROLLING, fixed layout
                // This layout MUST match PageAnalyzer calculations exactly
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,     // PageLayoutConfig.topPadding
                      left: 16,    // PageLayoutConfig.horizontalPadding
                      right: 16,   // PageLayoutConfig.horizontalPadding
                      bottom: 40,  // PageLayoutConfig.bottomPadding
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Text content - gets ALL remaining space
                        Expanded(
                          child: _buildText(),
                        ),
                        
                        // Image (if present and text complete)
                        if (widget.page.hasImage && _textComplete) ...[
                          const SizedBox(height: 20), // imageSpacing
                          _buildImage(),
                        ],
                        
                        // Spacing before buttons
                        const SizedBox(height: 16),
                        
                        // Choices or Continue button
                        if (_textComplete) ...[
                          if (widget.page.hasChoices)
                            _buildChoices()
                          else if (widget.page.canContinue)
                            _buildContinueButton(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Chapter/Page indicator (fixed at bottom left)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _buildChapterPageIndicator(),
                ),
                
                // Copyright (fixed at bottom right)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _buildCopyright(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final displayedText = widget.page.text.substring(0, _charIndex);
    
    final baseStyle = TextStyle(
      fontFamily: 'Mynerve',
      fontSize: _AnimConfig.fontSize,
      height: _AnimConfig.lineHeight,
      letterSpacing: _AnimConfig.letterSpacing,
      color: _textColor,
    );

    return _buildRevealedText(displayedText, baseStyle, now);
  }

  Widget _buildRevealedText(String text, TextStyle baseStyle, int now) {
    if (text.isEmpty) {
      // Show placeholder to maintain layout
      return Text(' ', style: baseStyle);
    }
    
    // Determine which characters are in quotes
    // ONLY highlight text between „ (German opening, U+201E) and closing quotes
    final isInQuote = List<bool>.filled(text.length, false);
    bool quoteState = false;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      
      // ONLY „ (German opening quotation mark) opens quotes
      if (code == 0x201E) { // „
        quoteState = true;
        isInQuote[i] = true;
      }
      // Any of these close the quote (if one was opened with „)
      else if (quoteState && (code == 0x201D ||  // " Right double
                               code == 0x201C ||  // " Left double (used as closing in story)
                               code == 0x2019)) { // ' Right single
        isInQuote[i] = true;
        quoteState = false;
      }
      // Regular character - inherit state
      else {
        isInQuote[i] = quoteState;
      }
    }
    
    // Build rich text with glow spans AND quote styling
    final spans = <TextSpan>[];
    int lastEnd = 0;
    
    for (final glow in _glowWords) {
      if (glow.endIndex > text.length) continue;
      
      // Add non-glow text before this glow
      if (glow.startIndex > lastEnd) {
        _addTextWithQuoteColors(
          spans,
          text,
          lastEnd,
          glow.startIndex,
          baseStyle,
          isInQuote,
        );
      }
      
      // Calculate glow intensity
      final elapsed = now - glow.revealTime;
      final t = (elapsed / _AnimConfig.glowDurationMs).clamp(0.0, 1.0);
      final intensity = (1.0 - t) * (1.0 - t);
      
      // Add glow text with proper styling
      final isQuoted = _isAnyCharInQuotes(glow.startIndex, glow.endIndex, isInQuote);
      
      _addTextWithQuoteColors(
        spans,
        text,
        glow.startIndex,
        glow.endIndex,
        baseStyle.copyWith(
          shadows: [
            // Animation glow (yellow/gold)
            if (intensity > 0.05)
              Shadow(
                color: _AnimConfig.glowColor.withOpacity(intensity * 0.8),
                blurRadius: intensity * 12,
              ),
            // White glow for quoted text (stronger)
            if (isQuoted) ...[
              Shadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.6),
                blurRadius: 12,
              ),
              Shadow(
                color: const Color(0xFFFEFFE9).withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ],
        ),
        isInQuote,
      );
      
      lastEnd = glow.endIndex;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      _addTextWithQuoteColors(
        spans,
        text,
        lastEnd,
        text.length,
        baseStyle,
        isInQuote,
      );
    }
    
    return RichText(
      text: TextSpan(children: spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans),
    );
  }

  bool _isAnyCharInQuotes(int start, int end, List<bool> isInQuote) {
    for (int i = start; i < end && i < isInQuote.length; i++) {
      if (isInQuote[i]) return true;
    }
    return false;
  }

  void _addTextWithQuoteColors(
    List<TextSpan> spans,
    String text,
    int start,
    int end,
    TextStyle baseStyle,
    List<bool> isInQuote,
  ) {
    int segmentStart = start;
    bool? lastQuoteState;
    
    for (int i = start; i < end; i++) {
      final currentQuoteState = isInQuote[i];
      
      if (lastQuoteState != null && currentQuoteState != lastQuoteState) {
        // State changed - add the previous segment
        spans.add(TextSpan(
          text: text.substring(segmentStart, i),
          style: baseStyle.copyWith(
            color: lastQuoteState ? const Color(0xFFFFFFFF) : baseStyle.color,
            shadows: lastQuoteState ? [
              Shadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.6),
                blurRadius: 12,
              ),
              Shadow(
                color: const Color(0xFFFEFFE9).withOpacity(0.3),
                blurRadius: 20,
              ),
            ] : baseStyle.shadows,
          ),
        ));
        segmentStart = i;
      }
      
      lastQuoteState = currentQuoteState;
    }
    
    // Add the final segment
    if (segmentStart < end) {
      spans.add(TextSpan(
        text: text.substring(segmentStart, end),
        style: baseStyle.copyWith(
          color: (lastQuoteState ?? false) ? const Color(0xFFFFFFFF) : baseStyle.color,
          shadows: (lastQuoteState ?? false) ? [
            Shadow(
              color: const Color(0xFFFFFFFF).withOpacity(0.6),
              blurRadius: 12,
            ),
            Shadow(
              color: const Color(0xFFFEFFE9).withOpacity(0.3),
              blurRadius: 20,
            ),
          ] : baseStyle.shadows,
        ),
      ));
    }
  }


  Widget _buildImage() {
    return AnimatedBuilder(
      animation: _imageController,
      builder: (context, child) {
        final t = _imageController.value;
        final blur = (1.0 - t) * 8.0;
        final scale = 0.95 + (t * 0.05);
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: t,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: SmartImage(
                    assetPath: widget.page.imagePath!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFBB86FC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 16,
                color: Color(0xFFBB86FC),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Was tust du?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBB86FC),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Choice buttons with animation
        ...widget.page.choices.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _buildChoiceButton(choice, index),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChoiceButton(PageChoice choice, int index) {
    // Different accent colors for variety
    final accentColors = [
      const Color(0xFFBB86FC), // Purple
      const Color(0xFF03DAC6), // Teal
      const Color(0xFFCF6679), // Pink
    ];
    final accentColor = accentColors[index % accentColors.length];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onChoiceSelected?.call(choice),
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withOpacity(0.2),
        highlightColor: accentColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: accentColor.withOpacity(0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Choice number badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Choice text
              Expanded(
                child: Text(
                  choice.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFE8DCC0),
                    fontFamily: 'Mynerve',
                    height: 1.4,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 10),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: accentColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _goNext,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE8DCC0).withOpacity(0.5),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward_rounded, color: Color(0xFFE8DCC0), size: 18),
                SizedBox(width: 8),
                Text(
                  'Weiter',
                  style: TextStyle(
                    color: Color(0xFFE8DCC0),
                    fontSize: 15,
                    fontFamily: 'Mynerve',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterPageIndicator() {
    // Extract chapter number from sceneId (e.g., "chapter_2" -> 3, "s01_a" -> 1)
    final sceneId = widget.page.sceneId;
    String chapterText;
    
    if (sceneId.startsWith('chapter_')) {
      // DOCX format: chapter_0, chapter_1, etc.
      final chapterNum = int.tryParse(sceneId.replaceFirst('chapter_', '')) ?? 0;
      chapterText = 'Kapitel ${chapterNum + 1}';
    } else {
      // Ink format: use sceneTitle or sceneId
      chapterText = widget.page.sceneTitle ?? sceneId;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$chapterText, Seite ${widget.page.pageInScene}',
        style: TextStyle(
          fontFamily: 'Mynerve',
          fontSize: 10,
          color: Colors.white.withOpacity(0.4),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  Widget _buildCopyright() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '© AppStories 2025',
        style: TextStyle(
          fontFamily: 'Mynerve',
          fontSize: 9,
          color: Colors.white.withOpacity(0.25),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GlowWord {
  final int startIndex;
  final int endIndex;
  final int revealTime;
  
  _GlowWord({
    required this.startIndex,
    required this.endIndex,
    required this.revealTime,
  });
}
