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
      duration: const Duration(milliseconds: 800),
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
      Future.delayed(const Duration(milliseconds: 300), () {
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: _goNext,
      child: Transform.translate(
        offset: Offset(_swipeDx * 0.3, 0),
        child: Stack(
          children: [
            // Main scrollable content - PREVENTS ALL OVERFLOW
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 80, // Extra space for page indicator
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text content (no ghost layer)
                    _buildText(),
                    
                    // Image (if present and text complete)
                    if (widget.page.hasImage && _textComplete) ...[
                      const SizedBox(height: 20),
                      _buildImage(),
                    ],
                    
                    // Spacing before buttons
                    const SizedBox(height: 24),
                    
                    // Choices or Continue button
                    if (_textComplete) ...[
                      if (widget.page.hasChoices)
                        _buildChoices()
                      else if (widget.page.canContinue)
                        _buildContinueButton(),
                    ],
                    
                    // Bottom spacing
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Page indicator (fixed at bottom left)
            Positioned(
              left: 8,
              bottom: 8,
              child: _buildPageIndicator(),
            ),
          ],
        ),
      ),
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

    // Simple text display - NO GHOST LAYER (causes offset issues)
    return _buildRevealedText(displayedText, baseStyle, now);
  }

  Widget _buildRevealedText(String text, TextStyle baseStyle, int now) {
    if (text.isEmpty) {
      // Show placeholder to maintain layout
      return Text(' ', style: baseStyle);
    }
    
    // Build rich text with glow spans
    final spans = <TextSpan>[];
    int lastEnd = 0;
    
    for (final glow in _glowWords) {
      if (glow.endIndex > text.length) continue;
      
      if (glow.startIndex > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, glow.startIndex),
          style: baseStyle,
        ));
      }
      
      final elapsed = now - glow.revealTime;
      final t = (elapsed / _AnimConfig.glowDurationMs).clamp(0.0, 1.0);
      final intensity = (1.0 - t) * (1.0 - t);
      
      spans.add(TextSpan(
        text: text.substring(glow.startIndex, glow.endIndex),
        style: baseStyle.copyWith(
          shadows: intensity > 0.05 ? [
            Shadow(
              color: _AnimConfig.glowColor.withOpacity(intensity * 0.8),
              blurRadius: intensity * 12,
            ),
          ] : null,
        ),
      ));
      
      lastEnd = glow.endIndex;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans),
    );
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
        const Text(
          'Was tust du?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ...widget.page.choices.map((choice) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildChoiceButton(choice),
        )),
      ],
    );
  }

  Widget _buildChoiceButton(PageChoice choice) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onChoiceSelected?.call(choice),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE8DCC0).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            choice.text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE8DCC0),
              fontFamily: 'Mynerve',
            ),
            textAlign: TextAlign.center,
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

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.page.pageIndicator(widget.totalPages),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: Colors.white.withOpacity(0.5),
          letterSpacing: 1,
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
