import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Epic episode completion screen with stunning animations
class EpisodeEndScreen extends StatefulWidget {
  final int episodeNumber;
  final int totalEpisodes;
  final bool hasNextEpisode;
  final VoidCallback onNextEpisode;
  final VoidCallback onReplay;

  const EpisodeEndScreen({
    super.key,
    required this.episodeNumber,
    required this.totalEpisodes,
    required this.hasNextEpisode,
    required this.onNextEpisode,
    required this.onReplay,
  });

  @override
  State<EpisodeEndScreen> createState() => _EpisodeEndScreenState();
}

class _EpisodeEndScreenState extends State<EpisodeEndScreen>
    with TickerProviderStateMixin {
  // Entry animations
  late AnimationController _entryController;
  late AnimationController _glowPulseController;
  late AnimationController _particleController;
  late AnimationController _buttonIdleController;
  
  // Button press animations
  late AnimationController _buttonPressController;
  late AnimationController _explosionController;
  
  // State
  bool _isButtonPressed = false;
  bool _hasTriggered = false;
  final List<_Particle> _particles = [];
  final List<_ExplosionParticle> _explosionParticles = [];

  @override
  void initState() {
    super.initState();
    
    // Entry animation (staggered reveal)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    // Continuous glow pulse
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // Floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    // Button idle breathing
    _buttonIdleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Button press scale
    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    // Explosion effect
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Generate floating particles
    _generateParticles();
    
    // Initial haptic
    HapticFeedback.mediumImpact();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 4,
        speed: 0.3 + random.nextDouble() * 0.7,
        opacity: 0.2 + random.nextDouble() * 0.4,
        delay: random.nextDouble(),
      ));
    }
  }

  void _generateExplosion() {
    final random = math.Random();
    _explosionParticles.clear();
    for (int i = 0; i < 30; i++) {
      final angle = (i / 30) * 2 * math.pi + random.nextDouble() * 0.5;
      _explosionParticles.add(_ExplosionParticle(
        angle: angle,
        distance: 50 + random.nextDouble() * 150,
        size: 4 + random.nextDouble() * 8,
        color: HSLColor.fromAHSL(
          1.0,
          280 + random.nextDouble() * 60, // Purple to pink range
          0.7 + random.nextDouble() * 0.3,
          0.5 + random.nextDouble() * 0.3,
        ).toColor(),
      ));
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowPulseController.dispose();
    _particleController.dispose();
    _buttonIdleController.dispose();
    _buttonPressController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  void _onButtonDown() {
    setState(() => _isButtonPressed = true);
    _buttonPressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onButtonUp() {
    if (_hasTriggered) return;
    
    setState(() {
      _isButtonPressed = false;
      _hasTriggered = true;
    });
    
    _buttonPressController.reverse();
    
    // Heavy haptic for release
    HapticFeedback.heavyImpact();
    
    // Trigger explosion
    _generateExplosion();
    _explosionController.forward().then((_) {
      // Navigate after explosion
      Future.delayed(const Duration(milliseconds: 200), () {
        widget.onNextEpisode();
      });
    });
  }

  void _onButtonCancel() {
    setState(() => _isButtonPressed = false);
    _buttonPressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.5,
          colors: [
            Color(0xFF1A1215),
            Color(0xFF0A0806),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating particles background
          _buildFloatingParticles(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated badge
                _buildAnimatedBadge(),
                
                const SizedBox(height: 40),
                
                // Episode completed text
                _buildCompletedText(),
                
                const SizedBox(height: 16),
                
                // Subtitle
                _buildSubtitle(),
                
                const SizedBox(height: 32),
                
                // Progress indicator
                _buildProgressIndicator(),
                
                const Spacer(flex: 2),
                
                // Next episode button (only if there's a next one)
                if (widget.hasNextEpisode)
                  _buildNextEpisodeButton(),
                
                const SizedBox(height: 24),
                
                // Secondary actions
                _buildSecondaryActions(),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
          
          // Explosion particles overlay
          if (_hasTriggered)
            _buildExplosion(),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedBadge() {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _glowPulseController]),
      builder: (context, child) {
        final entryValue = Curves.elasticOut.transform(
          (_entryController.value * 1.5).clamp(0.0, 1.0),
        );
        final glowValue = _glowPulseController.value;
        
        return Transform.scale(
          scale: entryValue,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.25 + glowValue * 0.15),
                  const Color(0xFF4CAF50).withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.4 + glowValue * 0.2),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2 + glowValue * 0.15),
                  blurRadius: 30 + glowValue * 20,
                  spreadRadius: glowValue * 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating ring
                Transform.rotate(
                  angle: _particleController.value * 2 * math.pi,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Check icon
                Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: const Color(0xFF4CAF50).withOpacity(0.9),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedText() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final delay = 0.2;
        final progress = ((_entryController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final curve = Curves.easeOutBack.transform(progress);
        
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve)),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFDF0FF),
                  Color(0xFFE8D0F0),
                  Color(0xFFFDF0FF),
                ],
              ).createShader(bounds),
              child: Text(
                'Episode ${widget.episodeNumber}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Mynerve',
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final delay = 0.35;
        final progress = ((_entryController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: progress,
          child: Text(
            widget.hasNextEpisode
                ? 'Abgeschlossen! Bereit für mehr?'
                : 'Alle Episoden abgeschlossen!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
              fontFamily: 'Mynerve',
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final delay = 0.4;
        final progress = ((_entryController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: progress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                // Episode dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.totalEpisodes, (index) {
                    final isCompleted = index < widget.episodeNumber;
                    final isCurrent = index == widget.episodeNumber - 1;
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + index * 100),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isCompleted
                            ? const Color(0xFF4CAF50)
                            : Colors.white.withOpacity(0.2),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 12),
                
                // Progress text
                Text(
                  '${widget.episodeNumber} von ${widget.totalEpisodes} Episoden',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextEpisodeButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _buttonIdleController,
        _buttonPressController,
      ]),
      builder: (context, _) {
        final delay = 0.5;
        final entryProgress = ((_entryController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final entryCurve = Curves.elasticOut.transform(entryProgress);
        
        final idleScale = 1.0 + _buttonIdleController.value * 0.02;
        final pressScale = 1.0 - _buttonPressController.value * 0.08;
        final totalScale = entryCurve * idleScale * pressScale;
        
        final glowIntensity = _buttonIdleController.value;
        
        return Opacity(
          opacity: entryProgress,
          child: Transform.scale(
            scale: totalScale,
            child: GestureDetector(
              onTapDown: (_) => _onButtonDown(),
              onTapUp: (_) => _onButtonUp(),
              onTapCancel: _onButtonCancel,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF9C27B0),
                      const Color(0xFF7B1FA2),
                      const Color(0xFF6A1B9A),
                    ],
                  ),
                  boxShadow: [
                    // Outer glow
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.3 + glowIntensity * 0.2),
                      blurRadius: 20 + glowIntensity * 15,
                      spreadRadius: glowIntensity * 5,
                    ),
                    // Inner shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2 + glowIntensity * 0.1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated play icon
                    AnimatedBuilder(
                      animation: _buttonIdleController,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(_buttonIdleController.value * 3, 0),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Episode ${widget.episodeNumber + 1} starten',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chevron with animation
                    AnimatedBuilder(
                      animation: _buttonIdleController,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(_buttonIdleController.value * 5, 0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 24,
                          ),
                        );
                      },
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

  Widget _buildSecondaryActions() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final delay = 0.6;
        final progress = ((_entryController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: progress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SecondaryButton(
                icon: Icons.replay_rounded,
                label: 'Nochmal',
                onTap: widget.onReplay,
              ),
              const SizedBox(width: 32),
              _SecondaryButton(
                icon: Icons.home_rounded,
                label: 'Bibliothek',
                onTap: () => context.go('/'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExplosion() {
    return AnimatedBuilder(
      animation: _explosionController,
      builder: (context, _) {
        return CustomPaint(
          painter: _ExplosionPainter(
            particles: _explosionParticles,
            progress: _explosionController.value,
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height * 0.7,
            ),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Secondary action button with micro-interactions
class _SecondaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scale = 1.0 - _controller.value * 0.1;
          
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(_isPressed ? 0.1 : 0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Particle data class
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double delay;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.delay,
  });
}

// Explosion particle data class
class _ExplosionParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _ExplosionParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}

// Floating particles painter
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final animProgress = (progress + particle.delay) % 1.0;
      final y = (particle.y + animProgress * particle.speed) % 1.0;
      
      final paint = Paint()
        ..color = const Color(0xFF9C27B0).withOpacity(particle.opacity * (1 - y))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// Explosion painter
class _ExplosionPainter extends CustomPainter {
  final List<_ExplosionParticle> particles;
  final double progress;
  final Offset center;

  _ExplosionPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final easeOut = Curves.easeOutQuart.transform(progress);
    final fadeOut = Curves.easeInQuart.transform(progress);
    
    for (final particle in particles) {
      final distance = particle.distance * easeOut;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;
      
      final particleSize = particle.size * (1 - fadeOut * 0.5);
      final opacity = (1 - fadeOut).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 0.5);
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExplosionPainter oldDelegate) => true;
}

