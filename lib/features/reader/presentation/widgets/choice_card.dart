import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/choice.dart';
import '../../../../core/constants/app_constants.dart';

/// Animated card widget for displaying a story choice with micro-animations
class ChoiceCard extends StatefulWidget {
  final Choice choice;
  final VoidCallback onTap;
  final int index;
  final int totalChoices;

  const ChoiceCard({
    super.key,
    required this.choice,
    required this.onTap,
    this.index = 0,
    this.totalChoices = 1,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressScale;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Entry animation with staggered delay
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Press animation
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Subtle pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    // Setup animations
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start entry animation with stagger
    Future.delayed(Duration(milliseconds: 100 + (widget.index * 120)), () {
      if (mounted) {
        _entryController.forward();
      }
    });
    
    // Start shimmer after entry completes
    Future.delayed(Duration(milliseconds: 700 + (widget.index * 120)), () {
      if (mounted) {
        _shimmerController.repeat();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pressController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _pressController,
        _shimmerController,
        _pulseController,
      ]),
      builder: (context, child) {
        final pulseGlow = 0.15 + (_pulseAnimation.value * 0.1);
        
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value * _pressScale.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: _handleTap,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Ambient shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      // Glow effect
                      BoxShadow(
                        color: primaryColor.withOpacity(_isPressed ? 0.4 : pulseGlow),
                        blurRadius: _isPressed ? 20 : 15,
                        spreadRadius: _isPressed ? 2 : 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2A2A3E),
                                const Color(0xFF1E1E2E),
                                primaryColor.withOpacity(0.15),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                        
                        // Shimmer overlay
                        Positioned.fill(
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: [
                                  _shimmerAnimation.value - 0.3,
                                  _shimmerAnimation.value,
                                  _shimmerAnimation.value + 0.3,
                                ].map((s) => s.clamp(0.0, 1.0)).toList(),
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(color: Colors.white),
                          ),
                        ),
                        
                        // Border gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withOpacity(_isPressed ? 0.6 : 0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Choice number indicator
                              _buildChoiceIndicator(primaryColor),
                              const SizedBox(width: 16),
                              
                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.choice.text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (widget.choice.description != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        widget.choice.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Arrow icon with animation
                              _buildArrowIcon(primaryColor),
                            ],
                          ),
                        ),
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

  Widget _buildChoiceIndicator(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.8),
                primaryColor.withOpacity(0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3 + _pulseAnimation.value * 0.2),
                blurRadius: 8,
                spreadRadius: _pulseAnimation.value * 2,
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

  Widget _buildArrowIcon(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final offset = math.sin(_pulseAnimation.value * math.pi) * 3;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed 
                  ? primaryColor.withOpacity(0.4)
                  : primaryColor.withOpacity(0.2),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _isPressed ? Colors.white : primaryColor,
            ),
          ),
        );
      },
    );
  }
}

/// Widget to display a list of choices with animated header
class ChoicesList extends StatefulWidget {
  final List<Choice> choices;
  final ValueChanged<Choice> onChoiceSelected;

  const ChoicesList({
    super.key,
    required this.choices,
    required this.onChoiceSelected,
  });

  @override
  State<ChoicesList> createState() => _ChoicesListState();
}

class _ChoicesListState extends State<ChoicesList> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOut,
      ),
    );
    
    _headerSlide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingMedium,
                    AppConstants.paddingSmall,
                    AppConstants.paddingMedium,
                    AppConstants.paddingMedium,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.alt_route_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Was tust du?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Choice cards with stagger animation
        ...widget.choices.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              left: AppConstants.paddingMedium,
              right: AppConstants.paddingMedium,
              bottom: entry.key < widget.choices.length - 1 
                  ? AppConstants.paddingSmall + 4
                  : 0,
            ),
            child: ChoiceCard(
              choice: entry.value,
              onTap: () => widget.onChoiceSelected(entry.value),
              index: entry.key,
              totalChoices: widget.choices.length,
            ),
          ),
        ),
      ],
    );
  }
}
