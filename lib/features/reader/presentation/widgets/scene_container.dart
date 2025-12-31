import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../../settings/providers/settings_provider.dart';
import 'animated_story_text.dart';
import 'scene_layout_handler.dart';

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

/// A container that manages scene layout and animations
/// Layout: Text (top) → Image (24px below text) → Flexible space → Choices (bottom)
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
  
  // Text pagination "Weiter" button state
  bool _showTextNextPageButton = false;
  final ValueNotifier<int> _textNextPageTrigger = ValueNotifier<int>(0);

  // Timing
  static const Duration _sceneFadeDuration = Duration(milliseconds: 400);
  static const Duration _imageFadeDuration = Duration(milliseconds: 600);
  static const Duration _interactionFadeDuration = Duration(milliseconds: 400);
  static const Duration _delayAfterText = Duration(milliseconds: 300);
  static const Duration _delayAfterImage = Duration(milliseconds: 200);

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
      _resetAndStartNewScene();
    }
  }

  void _resetAndStartNewScene() {
    _sceneController.reset();
    _imageController.reset();
    _interactionController.reset();
    setState(() => _phase = ScenePhase.entering);
    _startScene();
  }

  void _startScene() {
    final settings = ref.read(settingsProvider);
    
    if (settings.skipAnimation) {
      // Skip all animations
      _sceneController.value = 1.0;
      _imageController.value = 1.0;
      _interactionController.value = 1.0;
      setState(() => _phase = ScenePhase.complete);
    } else {
      // Fade in scene
      _sceneController.forward();
      setState(() => _phase = ScenePhase.textPlaying);
    }
  }

  void _onTextComplete() {
    if (_phase != ScenePhase.textPlaying) return;
    
    final settings = ref.read(settingsProvider);
    if (settings.skipAnimation) {
      _skipToComplete();
      return;
    }
    
    setState(() => _phase = ScenePhase.revealing);
    
    // Sequence: Text done → Image fades in → Interaction fades in
    Future.delayed(_delayAfterText, () {
      if (!mounted) return;
      
      if (widget.scene.hasImage) {
        _imageController.forward().then((_) {
          if (!mounted) return;
          Future.delayed(_delayAfterImage, () {
            if (!mounted) return;
            _showInteraction();
          });
        });
      } else {
        _showInteraction();
      }
    });
  }

  void _showInteraction() {
    if (!mounted) return;
    _interactionController.forward().then((_) {
      if (mounted) {
        setState(() => _phase = ScenePhase.complete);
      }
    });
  }

  void _skipToComplete() {
    _sceneController.value = 1.0;
    _imageController.value = 1.0;
    _interactionController.value = 1.0;
    setState(() => _phase = ScenePhase.complete);
  }

  @override
  void dispose() {
    _sceneController.dispose();
    _imageController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate layout using the handler
        final layout = SceneLayoutCalculator.calculate(
          availableHeight: constraints.maxHeight,
          availableWidth: constraints.maxWidth,
          hasImage: widget.scene.hasImage,
          hasChoices: widget.scene.hasChoices,
          hasContinueButton: widget.scene.canContinue && !widget.scene.hasChoices,
          choiceCount: widget.scene.choices.length,
        );
        
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _sceneController,
            curve: Curves.easeOut,
          ),
          child: SceneLayoutWidget(
            layout: layout,
            textWidget: _buildTextArea(layout.textAreaHeight, constraints.maxWidth),
            imageWidget: widget.scene.hasImage ? _buildImage() : null,
            interactionWidget: widget.scene.hasInteraction ? _buildInteraction() : null,
            imageVisible: _imageController.value > 0 || _phase == ScenePhase.complete,
            interactionVisible: _interactionController.value > 0 || _phase == ScenePhase.complete,
            textNextPageButton: _showTextNextPageButton ? _buildTextNextPageButton() : null,
          ),
        );
      },
    );
  }

  Widget _buildTextArea(double height, double width) {
    return DecorativeStoryText(
      key: ValueKey('text_${widget.scene.id}'),
      text: widget.scene.text,
      onPageComplete: _onTextComplete,
      maxHeight: height,
      onNextPageButtonVisibility: (visible) {
        if (mounted) {
          setState(() => _showTextNextPageButton = visible);
        }
      },
      nextPageTrigger: _textNextPageTrigger,
    );
  }
  
  void _onTextNextPageButtonPressed() {
    _textNextPageTrigger.value++;
  }
  
  Widget _buildTextNextPageButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTextNextPageButtonPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE8DCC0).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_forward_rounded, color: Color(0xFFE8DCC0), size: 18),
                SizedBox(width: 10),
                Text(
                  'Weiter',
                  style: TextStyle(
                    color: Color(0xFFE8DCC0),
                    fontSize: 16,
                    fontFamily: 'Mynerve',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeOut,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SmartImage(
            assetPath: widget.scene.imagePath!,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildInteraction() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _interactionController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _interactionController,
          curve: Curves.easeOutCubic,
        )),
        child: widget.scene.hasChoices 
            ? _buildChoices() 
            : _buildContinueButton(),
      ),
    );
  }

  Widget _buildChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Was tust du?',
            style: TextStyle(
              fontFamily: 'Mynerve',
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Choice buttons
          ...widget.scene.choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildChoiceButton(choice),
          )),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(SceneChoice choice) {
    final theme = Theme.of(context);
    final isEnabled = _phase == ScenePhase.complete;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? choice.onSelected : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(isEnabled ? 0.3 : 0.15),
            ),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primary.withOpacity(0.05),
          ),
          child: Text(
            choice.text,
            style: TextStyle(
              fontFamily: 'Mynerve',
              fontSize: 14,
              color: isEnabled 
                  ? const Color(0xFFE8DCC0)
                  : const Color(0xFFE8DCC0).withOpacity(0.4),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _phase == ScenePhase.complete;
    final theme = Theme.of(context);

    return Center(
      child: FilledButton.icon(
        onPressed: isEnabled ? widget.onContinue : null,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text(
          'Weiter',
          style: TextStyle(
            fontFamily: 'Mynerve',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          foregroundColor: const Color(0xFFE8DCC0),
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.05),
          disabledForegroundColor: const Color(0xFFE8DCC0).withOpacity(0.3),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(isEnabled ? 0.2 : 0.1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
