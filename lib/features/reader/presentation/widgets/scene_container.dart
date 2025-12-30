import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../settings/providers/settings_provider.dart';
import 'animated_story_text.dart';

/// Immutable snapshot of a scene's content
class SceneData {
  final String id;
  final String text;
  final String? backgroundPath;
  final String? imagePath;
  final List<SceneChoice> choices;
  final bool canContinue;

  const SceneData({
    required this.id,
    required this.text,
    this.backgroundPath,
    this.imagePath,
    this.choices = const [],
    this.canContinue = false,
  });

  bool get hasImage => imagePath != null;
  bool get hasChoices => choices.isNotEmpty;
  bool get hasInteraction => hasChoices || canContinue;
}

class SceneChoice {
  final String text;
  final VoidCallback onSelected;

  const SceneChoice({required this.text, required this.onSelected});
}

/// Animation phase for scene content
enum ScenePhase {
  entering,
  textPlaying,
  revealing,
  complete,
}

/// A container that fits ALL content on ONE screen.
/// Text is the only variable - it paginates if too long.
/// Image and choices are always visible at fixed positions.
class SceneContainer extends ConsumerStatefulWidget {
  final SceneData scene;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const SceneContainer({
    super.key,
    required this.scene,
    this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<SceneContainer> createState() => _SceneContainerState();
}

class _SceneContainerState extends ConsumerState<SceneContainer>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _sceneController;
  late AnimationController _imageController;
  late AnimationController _interactionController;

  // State
  ScenePhase _phase = ScenePhase.entering;

  // Fixed layout heights
  static const double _imageHeight = 200.0;
  static const double _choiceButtonHeight = 48.0;
  static const double _choiceSpacing = 8.0;
  static const double _sectionSpacing = 24.0;
  static const double _continueButtonHeight = 52.0;

  // Timing
  static const Duration _sceneFadeDuration = Duration(milliseconds: 400);
  static const Duration _imageFadeDuration = Duration(milliseconds: 800);
  static const Duration _interactionFadeDuration = Duration(milliseconds: 500);
  static const Duration _delayAfterText = Duration(milliseconds: 400);
  static const Duration _delayAfterImage = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startScene();
  }

  void _initAnimations() {
    _sceneController = AnimationController(
      vsync: this,
      duration: _sceneFadeDuration,
    );
    _imageController = AnimationController(
      vsync: this,
      duration: _imageFadeDuration,
    );
    _interactionController = AnimationController(
      vsync: this,
      duration: _interactionFadeDuration,
    );
  }

  @override
  void didUpdateWidget(SceneContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      _transitionToNewScene();
    }
  }

  Future<void> _transitionToNewScene() async {
    // Quick fade out
    await Future.wait([
      _interactionController.reverse(),
      _imageController.reverse(),
    ]);
    await _sceneController.reverse();
    
    // Start new scene
    _startScene();
  }

  Future<void> _startScene() async {
    // Check settings for instant text display
    final settings = ref.read(settingsProvider);
    final skipAnimations = settings.skipAnimation;
    
    if (skipAnimations) {
      _skipToComplete();
      return;
    }

    setState(() => _phase = ScenePhase.entering);
    
    // Preload image
    if (widget.scene.imagePath != null) {
      await _preloadImage(widget.scene.imagePath!);
    }

    await _sceneController.forward();
    setState(() => _phase = ScenePhase.textPlaying);
  }

  Future<void> _preloadImage(String path) async {
    try {
      final extensions = ['.png', '.jpg', '.jpeg'];
      final basePath = path.contains('.') 
          ? path.substring(0, path.lastIndexOf('.'))
          : path;
      
      for (final ext in extensions) {
        try {
          await rootBundle.load('$basePath$ext');
          return;
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _skipToComplete() {
    _sceneController.value = 1.0;
    _imageController.value = 1.0;
    _interactionController.value = 1.0;
    setState(() => _phase = ScenePhase.complete);
  }

  void _onTextComplete() {
    if (_phase != ScenePhase.textPlaying) return;
    
    setState(() => _phase = ScenePhase.revealing);
    _revealContent();
  }

  Future<void> _revealContent() async {
    await Future.delayed(_delayAfterText);

    // Show image
    if (widget.scene.hasImage && mounted) {
      await _imageController.forward();
      await Future.delayed(_delayAfterImage);
    }

    // Show interaction
    if (widget.scene.hasInteraction && mounted) {
      await _interactionController.forward();
    }

    if (mounted) {
      setState(() => _phase = ScenePhase.complete);
    }
  }

  @override
  void dispose() {
    _sceneController.dispose();
    _imageController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  /// Calculate fixed height for interaction area
  double _calculateInteractionHeight() {
    if (!widget.scene.hasInteraction) return 0;
    
    if (widget.scene.hasChoices) {
      // Header + choices + spacing
      final choicesCount = widget.scene.choices.length;
      return 24 + // "Was tust du?" header
             12 + // spacing after header
             (choicesCount * _choiceButtonHeight) +
             ((choicesCount - 1) * _choiceSpacing) +
             16; // bottom padding
    } else {
      return _continueButtonHeight + 16; // button + padding
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height for text
        // Screen = Text + Image + Interaction
        double reservedHeight = 0;
        
        if (widget.scene.hasImage) {
          reservedHeight += _imageHeight + _sectionSpacing;
        }
        
        if (widget.scene.hasInteraction) {
          reservedHeight += _calculateInteractionHeight() + _sectionSpacing;
        }
        
        // Text gets all remaining space
        final textHeight = constraints.maxHeight - reservedHeight;
        
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _sceneController,
            curve: Curves.easeOut,
          ),
          child: Column(
            children: [
              // TEXT AREA - fixed calculated height, paginates internally
              SizedBox(
                height: textHeight.clamp(100.0, constraints.maxHeight * 0.7),
                child: DecorativeStoryText(
                  key: ValueKey('text_${widget.scene.id}'),
                  text: widget.scene.text,
                  onPageComplete: _onTextComplete,
                ),
              ),
              
              // IMAGE AREA - fixed height
              if (widget.scene.hasImage) ...[
                const SizedBox(height: _sectionSpacing),
                _buildImageSection(),
              ],
              
              // INTERACTION AREA - fixed height
              if (widget.scene.hasInteraction) ...[
                const SizedBox(height: _sectionSpacing),
                _buildInteractionSection(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: _imageController, curve: Curves.easeOutCubic),
        ),
        child: SizedBox(
          height: _imageHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartImage(
                assetPath: widget.scene.imagePath!,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionSection() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _interactionController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _interactionController,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
          ),
          child: widget.scene.hasChoices
              ? _buildChoices()
              : _buildContinueButton(),
        ),
      ),
    );
  }

  Widget _buildChoices() {
    final theme = Theme.of(context);
    final isEnabled = _phase == ScenePhase.complete;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          'Was tust du?',
          style: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            fontFamily: 'Mynerve',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        
        // Choices
        ...widget.scene.choices.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.scene.choices.length - 1 ? _choiceSpacing : 0,
            ),
            child: SizedBox(
              height: _choiceButtonHeight,
              child: OutlinedButton(
                onPressed: isEnabled ? choice.onSelected : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.03),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  choice.text,
                  style: TextStyle(
                    color: isEnabled 
                        ? const Color(0xFFE8DCC0) 
                        : const Color(0xFFE8DCC0).withOpacity(0.4),
                    fontSize: 14,
                    fontFamily: 'Mynerve',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _phase == ScenePhase.complete;

    return SizedBox(
      height: _continueButtonHeight,
      child: Center(
        child: FilledButton.icon(
          onPressed: isEnabled ? widget.onContinue : null,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text('Weiter'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
