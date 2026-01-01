import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'smart_image.dart';

/// Settings provider for image animation preferences
final imageAnimationSettingsProvider = StateNotifierProvider<ImageAnimationSettings, ImageAnimationState>((ref) {
  return ImageAnimationSettings();
});

class ImageAnimationState {
  final bool instantMode;
  final Duration fadeDuration;
  final Duration blurDuration;

  const ImageAnimationState({
    this.instantMode = false,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.blurDuration = const Duration(milliseconds: 120),
  });

  ImageAnimationState copyWith({
    bool? instantMode,
    Duration? fadeDuration,
    Duration? blurDuration,
  }) {
    return ImageAnimationState(
      instantMode: instantMode ?? this.instantMode,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      blurDuration: blurDuration ?? this.blurDuration,
    );
  }
}

class ImageAnimationSettings extends StateNotifier<ImageAnimationState> {
  ImageAnimationSettings() : super(const ImageAnimationState());

  void setInstantMode(bool instant) {
    state = state.copyWith(instantMode: instant);
  }

  void setFadeDuration(Duration duration) {
    state = state.copyWith(fadeDuration: duration);
  }

  void setBlurDuration(Duration duration) {
    state = state.copyWith(blurDuration: duration);
  }
}

/// An animated smart image widget with blur fade-in effect
class AnimatedSmartImage extends ConsumerStatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final bool autoStart;
  final VoidCallback? onAnimationComplete;

  const AnimatedSmartImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.fallback,
    this.autoStart = true,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<AnimatedSmartImage> createState() => _AnimatedSmartImageState();
}

class _AnimatedSmartImageState extends ConsumerState<AnimatedSmartImage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _blurController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;

  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    final settings = ref.read(imageAnimationSettingsProvider);
    
    _fadeController = AnimationController(
      duration: settings.fadeDuration,
      vsync: this,
    );

    _blurController = AnimationController(
      duration: settings.blurDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _blurController,
      curve: Curves.easeOut,
    ));

    // Listen for animation completion
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedSmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _resetAnimation();
    }
  }

  void _resetAnimation() {
    _animationStarted = false;
    _fadeController.reset();
    _blurController.reset();
  }

  void _onImageLoaded() {
    if (!mounted) return;

    if (widget.autoStart && !_animationStarted) {
      startAnimation();
    }
  }

  void startAnimation() {
    if (!mounted || _animationStarted) return;

    final settings = ref.read(imageAnimationSettingsProvider);
    
    setState(() {
      _animationStarted = true;
    });

    if (settings.instantMode) {
      // Instant mode: skip animations
      _fadeController.value = 1.0;
      _blurController.value = 1.0;
      widget.onAnimationComplete?.call();
    } else {
      // Animated mode: start blur first, then fade
      _blurController.forward();
      
      // Start fade animation slightly after blur starts
      Future.delayed(Duration(milliseconds: settings.blurDuration.inMilliseconds ~/ 3), () {
        if (mounted) {
          _fadeController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(imageAnimationSettingsProvider);

    // Update animation durations if settings changed
    if (_fadeController.duration != settings.fadeDuration) {
      _fadeController.duration = settings.fadeDuration;
    }
    if (_blurController.duration != settings.blurDuration) {
      _blurController.duration = settings.blurDuration;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _blurAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: _ImageLoader(
              assetPath: widget.assetPath,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              fallback: widget.fallback,
              onImageLoaded: _onImageLoaded,
            ),
          ),
        );
      },
    );
  }
}

/// Internal widget to handle image loading and notify when ready
class _ImageLoader extends StatefulWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;
  final VoidCallback onImageLoaded;

  const _ImageLoader({
    required this.assetPath,
    required this.fit,
    required this.onImageLoaded,
    this.width,
    this.height,
    this.fallback,
  });

  @override
  State<_ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<_ImageLoader> {
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    // Notify that image is ready to load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notified && mounted) {
        _notified = true;
        widget.onImageLoaded();
      }
    });
  }

  @override
  void didUpdateWidget(_ImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _notified = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_notified && mounted) {
          _notified = true;
          widget.onImageLoaded();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartImage(
      assetPath: widget.assetPath,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      fallback: widget.fallback,
    );
  }
}
