import 'package:flutter/material.dart';

/// Minimal preloader - only shows a progress bar
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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? const Color(0xFF0A0806) 
        : const Color(0xFFF8F4EC);
    // Lila passend zum App-Design
    final primaryColor = isDark 
        ? const Color(0xFFBB86FC)  // Material Purple accent
        : const Color(0xFF7C4DFF); // Deep Purple

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: 200,
          child: AnimatedBuilder(
            animation: _glowAnimation,
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
      ),
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
      
      // End dot (pulsing)
      if (progress < 1.0) {
        canvas.drawCircle(
          Offset(progressWidth, size.height / 2),
          3 + glowIntensity,
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
