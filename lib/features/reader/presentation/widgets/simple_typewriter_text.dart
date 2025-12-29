import 'package:flutter/material.dart';
import 'dart:async';

/// Classic Typewriter Effect - inspired by codepen.io/gavra/pen/nNRvKX
/// Simple, elegant, nostalgic
class SimpleTypewriterText extends StatefulWidget {
  final String text;
  final ScrollController scrollController;
  final int speedMs; // Time delay per character
  final int lineDelayMs; // Pause between lines

  const SimpleTypewriterText({
    super.key,
    required this.text,
    required this.scrollController,
    this.speedMs = 100,
    this.lineDelayMs = 500,
  });

  @override
  State<SimpleTypewriterText> createState() => _SimpleTypewriterTextState();
}

class _SimpleTypewriterTextState extends State<SimpleTypewriterText> 
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentCharIndex = 0;
  Timer? _typeTimer;
  
  // Cursor blink animation
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize blinking cursor
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);
    
    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_cursorController);
    
    // Start typewriter after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startTypewriter();
    });
    
    widget.scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
  
  void _onScroll() {
    // Skip to end on scroll
    if (widget.scrollController.hasClients) {
      final scrollDelta = widget.scrollController.position.pixels;
      if (scrollDelta > 50 && _currentCharIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text;
          _currentCharIndex = widget.text.length;
        });
        _typeTimer?.cancel();
      }
    }
  }
  
  void _startTypewriter() {
    _typeTimer?.cancel();
    
    void typeNextChar() {
      if (!mounted || _currentCharIndex >= widget.text.length) {
        _typeTimer?.cancel();
        return;
      }
      
      setState(() {
        _displayedText = widget.text.substring(0, _currentCharIndex + 1);
        _currentCharIndex++;
      });
      
      // Auto-scroll to keep text visible
      _ensureTextVisible();
      
      // Check for line break - add delay
      if (_currentCharIndex < widget.text.length) {
        final currentChar = widget.text[_currentCharIndex - 1];
        final delay = currentChar == '\n' 
            ? widget.lineDelayMs 
            : widget.speedMs;
        
        _typeTimer = Timer(Duration(milliseconds: delay), typeNextChar);
      }
    }
    
    typeNextChar();
  }
  
  void _ensureTextVisible() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.scrollController.hasClients) return;
      
      final scrollPosition = widget.scrollController.position;
      final maxScroll = scrollPosition.maxScrollExtent;
      
      if (maxScroll > 0) {
        widget.scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final textColor = isDark 
        ? const Color(0xFFE8DCC0)
        : const Color(0xFF2C1810);
    
    final cursorColor = isDark 
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B4513);
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minWidth: 320,
        maxWidth: 415,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: AnimatedBuilder(
            animation: _cursorAnimation,
            builder: (context, child) {
              return RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Garamond, Georgia, serif',
                    fontSize: 26,
                    height: 1.8,
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  children: [
                    TextSpan(text: _displayedText),
                    // Blinking cursor
                    if (_currentCharIndex < widget.text.length)
                      TextSpan(
                        text: '_',
                        style: TextStyle(
                          color: cursorColor.withOpacity(_cursorAnimation.value),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

