import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Interactive text container with zoom, scale, and font customization
/// Prepared for pinch-to-zoom and double-tap interactions
class InteractiveTextContainer extends StatefulWidget {
  final String text;
  final double textScale;
  final double zoom;
  final String fontFamily;
  final TextStyle? baseTextStyle;
  final VoidCallback? onDoubleTap;
  final ValueChanged<double>? onZoomChanged;

  const InteractiveTextContainer({
    super.key,
    required this.text,
    this.textScale = AppConstants.defaultTextScale,
    this.zoom = AppConstants.defaultZoom,
    this.fontFamily = 'default',
    this.baseTextStyle,
    this.onDoubleTap,
    this.onZoomChanged,
  });

  @override
  State<InteractiveTextContainer> createState() =>
      _InteractiveTextContainerState();
}

class _InteractiveTextContainerState extends State<InteractiveTextContainer>
    with SingleTickerProviderStateMixin {
  late double _currentZoom;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.zoom;

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(InteractiveTextContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoom != widget.zoom) {
      _animateZoomChange(oldWidget.zoom, widget.zoom);
    }
  }

  void _animateZoomChange(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0.0);
  }

  void _handleDoubleTap() {
    if (widget.onDoubleTap != null) {
      widget.onDoubleTap!();
    } else {
      // Default behavior: toggle between 1x and 1.5x zoom
      final newZoom =
          _currentZoom == AppConstants.defaultZoom ? 1.5 : AppConstants.defaultZoom;
      _handleZoomChange(newZoom);
    }
  }

  void _handleZoomChange(double newZoom) {
    setState(() {
      _currentZoom = newZoom.clamp(
        AppConstants.minZoom,
        AppConstants.maxZoom,
      );
    });
    widget.onZoomChanged?.call(_currentZoom);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = widget.baseTextStyle ?? theme.textTheme.bodyLarge;

    // Apply text scale and font family
    final effectiveStyle = baseStyle?.copyWith(
      fontFamily: widget.fontFamily == 'default' ? null : widget.fontFamily,
      fontSize: (baseStyle.fontSize ?? 16) * widget.textScale,
    );

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedDefaultTextStyle(
          style: effectiveStyle ?? const TextStyle(),
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeInOut,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: SelectableText(
                widget.text,
                style: effectiveStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified version for non-interactive text display
class SimpleTextContainer extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const SimpleTextContainer({
    super.key,
    required this.text,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
        child: SelectableText(
          text,
          style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}


