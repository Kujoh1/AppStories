import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../../../domain/models/story_page.dart';
import '../../../../core/widgets/smart_image.dart';

/// Configuration for text animation
class _AnimConfig {
  // Base delay per character in milliseconds
  // This is divided by speedMultiplier:
  // - Normal (1x): 12ms per char (~6 sec for 500 chars)
  // - Schnell (3x): 4ms per char (~2 sec for 500 chars)
  // - Schneller (10x): 1.2ms per char (~0.6 sec for 500 chars)
  // - Sofort: skipAnimation=true, kein delay
  static const int charDelayMs = 12;
  static const int glowDurationMs = 1200;
  static const double lineHeight = 1.9;
  static const double letterSpacing = 0.45;
  static const Color glowColor = Color(0xFFFDF0FF);
  static const Color darkTextColor = Color(0xFFFDF0FF);
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
  final String fontFamily;
  final double fontSize;

  const PageViewWidget({
    super.key,
    required this.page,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onChoiceSelected,
    this.skipAnimation = false,
    this.speedMultiplier = 1.0,
    this.fontFamily = 'EBGaramond',
    this.fontSize = 18.0,
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
                        
                        // Choices (if present and text complete)
                        if (_textComplete && widget.page.hasChoices) ...[
                          const SizedBox(height: 16),
                          _buildChoices(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Chapter/Page indicator (hidden)
                // Positioned(
                //   left: 8,
                //   bottom: 8,
                //   child: _buildChapterPageIndicator(),
                // ),
                
                // Copyright (hidden)
                // Positioned(
                //   right: 8,
                //   bottom: 8,
                //   child: _buildCopyright(),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final fullText = widget.page.text;
    
    final baseStyle = TextStyle(
      fontFamily: widget.fontFamily,
      fontSize: widget.fontSize,
      height: _AnimConfig.lineHeight,
      letterSpacing: _AnimConfig.letterSpacing,
      color: _textColor,
    );

    // Always render full text for correct justified layout
    // Use _charIndex to control visibility
    return LayoutBuilder(
      builder: (context, constraints) {
        // Process text to show visible hyphens at line breaks
        final processedText = _processHyphensForDisplay(
          fullText, 
          baseStyle, 
          constraints.maxWidth,
        );
        return _buildRevealedText(processedText, baseStyle, now, _charIndex);
      },
    );
  }
  
  /// Replaces soft hyphens at line breaks with visible hyphens
  /// 
  /// Flutter doesn't natively show hyphens when breaking at soft hyphens (U+00AD).
  /// This method analyzes the text layout and replaces soft hyphens that occur
  /// at line endings with visible hyphen characters.
  String _processHyphensForDisplay(String text, TextStyle style, double maxWidth) {
    // Count soft hyphens for debugging
    final softHyphenCount = text.split('\u00AD').length - 1;
    if (softHyphenCount > 0) {
      print('🔤 [Hyphen] Found $softHyphenCount soft hyphens in text (${text.length} chars)');
    }
    
    if (!text.contains('\u00AD')) return text;
    
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
    )..layout(maxWidth: maxWidth);
    
    // Find soft hyphens that are at line breaks by checking Y position
    final softHyphensAtBreaks = <int>{};
    
    for (int i = 0; i < text.length - 1; i++) {
      if (text.codeUnitAt(i) == 0x00AD) {
        // Get the position of this soft hyphen and the next character
        final boxes = textPainter.getBoxesForSelection(
          TextSelection(baseOffset: i, extentOffset: i + 1),
        );
        final nextBoxes = textPainter.getBoxesForSelection(
          TextSelection(baseOffset: i + 1, extentOffset: i + 2),
        );
        
        if (boxes.isNotEmpty && nextBoxes.isNotEmpty) {
          // If the next character is on a different line (different Y), this is a break point
          final currentY = boxes.first.top;
          final nextY = nextBoxes.first.top;
          
          if ((nextY - currentY).abs() > 5) { // Different line
            softHyphensAtBreaks.add(i);
          }
        }
      }
    }
    
    // Build result: replace soft hyphens at breaks with visible hyphens, remove others
    final result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 0x00AD) {
        if (softHyphensAtBreaks.contains(i)) {
          result.write('-'); // Visible hyphen at line break
        }
        // Otherwise, skip the soft hyphen (it's not needed)
      } else {
        result.write(text[i]);
      }
    }
    
    return result.toString();
  }

  Widget _buildRevealedText(String text, TextStyle baseStyle, int now, int visibleChars) {
    if (text.isEmpty) {
      // Show placeholder to maintain layout
      return Text(' ', style: baseStyle);
    }
    
    // Clamp visibleChars to actual text length (text may be shorter after hyphen processing)
    final effectiveVisibleChars = visibleChars.clamp(0, text.length);
    
    // Determine which characters are in quotes
    // ONLY highlight text between „ (German opening, U+201E) and closing quotes
    // Use startsInQuote from the page to handle cross-page quotes
    // Note: Soft hyphens have been processed - they're now regular hyphens or removed
    final isInQuote = List<bool>.filled(text.length, false);
    bool quoteState = widget.page.startsInQuote; // Start with inherited state!
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      
      // » (Guillemet right-pointing, U+00BB) opens quotes
      if (code == 0x00BB) { // »
        quoteState = true;
        isInQuote[i] = true;
      }
      // « (Guillemet left-pointing, U+00AB) closes quotes
      else if (quoteState && code == 0x00AB) { // «
        isInQuote[i] = true;
        quoteState = false;
      }
      // Regular character - inherit state
      else {
        isInQuote[i] = quoteState;
      }
    }
    
    // Build rich text with visibility based on effectiveVisibleChars
    // FULL text is always rendered for correct justified layout
    final spans = <TextSpan>[];
    int lastEnd = 0;
    
    for (final glow in _glowWords) {
      if (glow.endIndex > text.length) continue;
      
      // Add non-glow text before this glow
      if (glow.startIndex > lastEnd) {
        _addTextWithVisibility(
          spans,
          text,
          lastEnd,
          glow.startIndex,
          baseStyle,
          isInQuote,
          effectiveVisibleChars,
        );
      }
      
      // Calculate glow intensity
      final elapsed = now - glow.revealTime;
      final t = (elapsed / _AnimConfig.glowDurationMs).clamp(0.0, 1.0);
      final intensity = (1.0 - t) * (1.0 - t);
      
      // Add glow text with proper styling
      final isQuoted = _isAnyCharInQuotes(glow.startIndex, glow.endIndex, isInQuote);
      
      _addTextWithVisibility(
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
            // White glow for quoted text (temporarily disabled)
            // if (isQuoted) ...[
            //   Shadow(
            //     color: const Color(0xFFFDF0FF).withOpacity(0.6),
            //     blurRadius: 12,
            //   ),
            //   Shadow(
            //     color: const Color(0xFFFDF0FF).withOpacity(0.3),
            //     blurRadius: 20,
            //   ),
            // ],
          ],
        ),
        isInQuote,
        effectiveVisibleChars,
      );
      
      lastEnd = glow.endIndex;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      _addTextWithVisibility(
        spans,
        text,
        lastEnd,
        text.length,
        baseStyle,
        isInQuote,
        effectiveVisibleChars,
      );
    }
    
    return RichText(
      text: TextSpan(children: spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans),
      textAlign: TextAlign.justify,
    );
  }
  
  /// Add text spans with visibility control for justified text animation
  void _addTextWithVisibility(
    List<TextSpan> spans,
    String text,
    int start,
    int end,
    TextStyle baseStyle,
    List<bool> isInQuote,
    int visibleChars,
  ) {
    if (start >= end) return;
    
    // Split the segment into visible and invisible parts
    final visibleEnd = visibleChars.clamp(start, end);
    
    // Add visible part (if any)
    if (visibleEnd > start) {
      _addTextSegmentWithQuotes(spans, text, start, visibleEnd, baseStyle, isInQuote, true);
    }
    
    // Add invisible part (if any) - transparent but still takes up space for layout
    if (visibleEnd < end) {
      _addTextSegmentWithQuotes(spans, text, visibleEnd, end, baseStyle, isInQuote, false);
    }
  }
  
  /// Add text segment with quote styling and visibility
  void _addTextSegmentWithQuotes(
    List<TextSpan> spans,
    String text,
    int start,
    int end,
    TextStyle baseStyle,
    List<bool> isInQuote,
    bool visible,
  ) {
    if (start >= end) return;
    
    int segmentStart = start;
    bool lastQuoteState = isInQuote[start];
    
    for (int i = start + 1; i <= end; i++) {
      final currentQuoteState = i < end ? isInQuote[i] : !lastQuoteState;
      
      if (currentQuoteState != lastQuoteState || i == end) {
        final segmentText = text.substring(segmentStart, i);
        final isQuoted = lastQuoteState;
        
        // Build shadows list (glow temporarily disabled)
        final shadows = <Shadow>[];
        // if (visible && isQuoted && segmentText.trim().isNotEmpty) {
        //   shadows.add(Shadow(
        //     color: const Color(0xFFFDF0FF).withOpacity(0.6),
        //     blurRadius: 12,
        //   ));
        //   shadows.add(Shadow(
        //     color: const Color(0xFFFDF0FF).withOpacity(0.3),
        //     blurRadius: 20,
        //   ));
        // }
        
        // Determine color based on visibility and quote state
        Color textColor;
        if (!visible) {
          textColor = Colors.transparent; // Invisible but takes space
        } else if (isQuoted) {
          textColor = const Color(0xFFFDF0FF);
        } else {
          textColor = baseStyle.color ?? _textColor;
        }
        
        spans.add(TextSpan(
          text: segmentText,
          style: baseStyle.copyWith(
            color: textColor,
            shadows: shadows.isEmpty ? baseStyle.shadows : shadows,
          ),
        ));
        
        segmentStart = i;
        if (i < end) {
          lastQuoteState = currentQuoteState;
        }
      }
    }
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
            color: lastQuoteState ? const Color(0xFFFDF0FF) : baseStyle.color,
            // Glow effect temporarily disabled
            // shadows: lastQuoteState ? [
            //   Shadow(
            //     color: const Color(0xFFFDF0FF).withOpacity(0.6),
            //     blurRadius: 12,
            //   ),
            //   Shadow(
            //     color: const Color(0xFFFDF0FF).withOpacity(0.3),
            //     blurRadius: 20,
            //   ),
            // ] : baseStyle.shadows,
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
          color: (lastQuoteState ?? false) ? const Color(0xFFFDF0FF) : baseStyle.color,
          // Glow effect temporarily disabled
          // shadows: (lastQuoteState ?? false) ? [
          //   Shadow(
          //     color: const Color(0xFFFDF0FF).withOpacity(0.6),
          //     blurRadius: 12,
          //   ),
          //   Shadow(
          //     color: const Color(0xFFFDF0FF).withOpacity(0.3),
          //     blurRadius: 20,
          //   ),
          // ] : baseStyle.shadows,
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
    return _AnimatedChoicesBox(
      choices: widget.page.choices,
      onChoiceSelected: widget.onChoiceSelected,
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

/// Animated choices container with header
class _AnimatedChoicesBox extends StatefulWidget {
  final List<PageChoice> choices;
  final void Function(PageChoice choice)? onChoiceSelected;

  const _AnimatedChoicesBox({
    required this.choices,
    this.onChoiceSelected,
  });

  @override
  State<_AnimatedChoicesBox> createState() => _AnimatedChoicesBoxState();
}

class _AnimatedChoicesBoxState extends State<_AnimatedChoicesBox> 
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<double> _headerSlide;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    
    _headerSlide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFBB86FC);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated header
        AnimatedBuilder(
          animation: _headerController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _headerSlide.value),
              child: Opacity(
                opacity: _headerFade.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.alt_route_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Was tust du?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.8,
                        fontFamily: 'Mynerve',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        
        // Choice buttons
        ...widget.choices.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < widget.choices.length - 1 ? 14 : 0,
            ),
            child: _AnimatedChoiceButton(
              choice: entry.value,
              index: entry.key,
              totalChoices: widget.choices.length,
              onTap: () => widget.onChoiceSelected?.call(entry.value),
            ),
          );
        }),
      ],
    );
  }
}

/// Animated individual choice button with micro-animations
class _AnimatedChoiceButton extends StatefulWidget {
  final PageChoice choice;
  final int index;
  final int totalChoices;
  final VoidCallback onTap;

  const _AnimatedChoiceButton({
    required this.choice,
    required this.index,
    required this.totalChoices,
    required this.onTap,
  });

  @override
  State<_AnimatedChoiceButton> createState() => _AnimatedChoiceButtonState();
}

class _AnimatedChoiceButtonState extends State<_AnimatedChoiceButton> 
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isPressed = false;
  
  // Different accent colors for variety
  static const _accentColors = [
    Color(0xFFBB86FC), // Purple
    Color(0xFF03DAC6), // Teal  
    Color(0xFFCF6679), // Pink
    Color(0xFFFFB74D), // Amber
  ];

  Color get _accentColor => _accentColors[widget.index % _accentColors.length];

  @override
  void initState() {
    super.initState();
    
    // Entry animation with stagger
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Setup animations
    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Start entry with stagger
    Future.delayed(Duration(milliseconds: 80 + (widget.index * 150)), () {
      if (mounted) _entryController.forward();
    });
    
    // Start shimmer and pulse after entry
    Future.delayed(Duration(milliseconds: 700 + (widget.index * 150)), () {
      if (mounted) {
        _shimmerController.repeat();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _shimmerController,
        _pulseController,
      ]),
      builder: (context, child) {
        final pulseGlow = 0.2 + (_pulseAnimation.value * 0.15);
        
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value * (_isPressed ? 0.96 : 1.0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: _handleTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF151520), // Fallback dark color
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E2A),
                        const Color(0xFF151520),
                        Color.lerp(const Color(0xFF151520), _accentColor, 0.1)!,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: _accentColor.withOpacity(
                        _isPressed ? 0.9 : 0.35 + (_pulseAnimation.value * 0.15)
                      ),
                      width: _isPressed ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: _accentColor.withOpacity(_isPressed ? 0.4 : pulseGlow),
                        blurRadius: _isPressed ? 20 : 15,
                        spreadRadius: _isPressed ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Number indicator
                        _buildNumberIndicator(),
                        const SizedBox(width: 14),
                        
                        // Choice text
                        Expanded(
                          child: Text(
                            widget.choice.text,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFDF0FF),
                              fontFamily: 'Mynerve',
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Arrow
                        _buildArrowIcon(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accentColor.withOpacity(0.9),
                _accentColor.withOpacity(0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.3 + _pulseAnimation.value * 0.25),
                blurRadius: 10,
                spreadRadius: _pulseAnimation.value * 3,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArrowIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final offset = math.sin(_pulseAnimation.value * math.pi) * 4;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed 
                  ? _accentColor.withOpacity(0.5)
                  : _accentColor.withOpacity(0.2),
              border: Border.all(
                color: _accentColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _isPressed ? Colors.white : _accentColor,
            ),
          ),
        );
      },
    );
  }
}
