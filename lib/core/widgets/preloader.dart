import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Elegant preloader animation for app startup
class AppPreloader extends StatefulWidget {
  final String? loadingText;
  final double progress;
  
  const AppPreloader({
    super.key,
    this.loadingText,
    this.progress = 0.0,
  });

  @override
  State<AppPreloader> createState() => _AppPreloaderState();
}

class _AppPreloaderState extends State<AppPreloader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? const Color(0xFF0A0806) 
        : const Color(0xFFF8F4EC);
    final primaryColor = isDark 
        ? const Color(0xFFD4AF37) 
        : const Color(0xFF8B4513);
    final textColor = isDark 
        ? const Color(0xFFE8DCC0) 
        : const Color(0xFF2C1810);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated book icon
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _rotateController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withOpacity(_glowAnimation.value * 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: _buildAnimatedBook(primaryColor),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // App name
            Text(
              'AppStories',
              style: TextStyle(
                fontFamily: 'Mynerve',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                color: textColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Loading text
            if (widget.loadingText != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + (_pulseAnimation.value - 0.8) * 2.5,
                    child: Text(
                      widget.loadingText!,
                      style: TextStyle(
                        fontFamily: 'Mynerve',
                        fontSize: 14,
                        letterSpacing: 2,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 32),
            
            // Progress indicator
            SizedBox(
              width: 200,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 3),
                    painter: _ProgressPainter(
                      progress: widget.progress,
                      color: primaryColor,
                      glowIntensity: _glowAnimation.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedBook(Color color) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        // Subtle floating animation
        final floatOffset = math.sin(_rotateController.value * math.pi * 2) * 4;
        
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Icon(
            Icons.auto_stories,
            size: 64,
            color: color,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double glowIntensity;
  
  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Background line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      backgroundPaint,
    );
    
    // Progress line with glow
    if (progress > 0) {
      final progressWidth = size.width * progress.clamp(0.0, 1.0);
      
      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(glowIntensity * 0.5)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(progressWidth, size.height / 2),
        glowPaint,
      );
      
      // Main line
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(progressWidth, size.height / 2),
        progressPaint,
      );
      
      // End dot
      if (progress < 1.0) {
        canvas.drawCircle(
          Offset(progressWidth, size.height / 2),
          4,
          Paint()..color = color,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.glowIntensity != glowIntensity;
}




