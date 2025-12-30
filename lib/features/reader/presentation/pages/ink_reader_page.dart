import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ink_parser.dart';
import '../../providers/book_provider.dart';
import '../widgets/animated_story_text.dart';
import '../../../settings/presentation/settings_dialog.dart';

/// Reader page for Ink format stories with choices
class InkReaderPage extends ConsumerStatefulWidget {
  const InkReaderPage({super.key});

  @override
  ConsumerState<InkReaderPage> createState() => _InkReaderPageState();
}

class _InkReaderPageState extends ConsumerState<InkReaderPage> 
    with TickerProviderStateMixin {
  
  // Animation phases
  bool _textComplete = false;
  bool _imageVisible = false;
  bool _showChoices = false;
  
  String? _currentKnotKey;
  String? _currentBackground;
  String? _currentImage;
  
  // Animation controllers
  late AnimationController _bgFadeController;
  late AnimationController _imageFadeController;
  late AnimationController _choicesFadeController;
  
  // Layout constants
  static const double _imageHeight = 220.0; // Reserved height for image
  static const double _choicesHeight = 200.0; // Reserved height for choices
  static const double _appBarHeight = 56.0;
  static const double _bottomPadding = 20.0;
  
  // Timing
  static const int _imageDelayAfterTextMs = 600;
  static const int _choicesDelayAfterImageMs = 800;
  
  @override
  void initState() {
    super.initState();
    _bgFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageFadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _choicesFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _bgFadeController.dispose();
    _imageFadeController.dispose();
    _choicesFadeController.dispose();
    super.dispose();
  }
  
  /// Calculate available height for text based on what else needs to be shown
  double _calculateTextAreaHeight(BuildContext context, bool hasImage, bool hasChoices) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    double usableHeight = screenHeight - safeAreaTop - safeAreaBottom - _appBarHeight;
    
    // Reserve space for image if present
    if (hasImage) {
      usableHeight -= _imageHeight;
    }
    
    // Reserve space for choices/continue button
    if (hasChoices) {
      usableHeight -= _choicesHeight;
    }
    
    // Bottom padding
    usableHeight -= _bottomPadding;
    
    return usableHeight.clamp(200.0, double.infinity);
  }
  
  void _onTextAnimationComplete() {
    if (!mounted || _textComplete) return;
    
    setState(() => _textComplete = true);
    
    // Phase 2: Fade in image (if any)
    if (_currentImage != null) {
      Future.delayed(const Duration(milliseconds: _imageDelayAfterTextMs), () {
        if (mounted && _textComplete) {
          setState(() => _imageVisible = true);
          _imageFadeController.forward(from: 0);
          
          // Phase 3: Show choices after image
          Future.delayed(const Duration(milliseconds: _choicesDelayAfterImageMs), () {
            if (mounted && _imageVisible) {
              setState(() => _showChoices = true);
              _choicesFadeController.forward(from: 0);
            }
          });
        }
      });
    } else {
      // No image - show choices directly
      Future.delayed(const Duration(milliseconds: _imageDelayAfterTextMs), () {
        if (mounted && _textComplete) {
          setState(() => _showChoices = true);
          _choicesFadeController.forward(from: 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inkStoryAsync = ref.watch(inkStoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: inkStoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorScreen(error),
        data: (story) => _buildStoryContent(story),
      ),
    );
  }
  
  Widget _buildErrorScreen(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Fehler: $error', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(inkStoryProvider),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoryContent(InkStory story) {
    final runtime = ref.watch(inkRuntimeProvider);
    
    // Initialize runtime if needed
    if (runtime == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(inkRuntimeProvider.notifier).initialize(story);
      });
      return const Center(child: CircularProgressIndicator());
    }
    
    final currentKnot = runtime.currentKnot;
    if (currentKnot == null) {
      return _buildEndScreen(context);
    }
    
    // Update when knot changes
    if (_currentKnotKey != runtime.currentKnotName) {
      _currentKnotKey = runtime.currentKnotName;
      
      // Reset animation states
      _textComplete = false;
      _imageVisible = false;
      _showChoices = false;
      _imageFadeController.reset();
      _choicesFadeController.reset();
      
      // Update background
      final newBg = runtime.currentBackground;
      if (newBg != _currentBackground) {
        _currentBackground = newBg;
        if (newBg != null) {
          _bgFadeController.forward(from: 0);
        }
      }
      
      // Update image
      _currentImage = runtime.currentImage;
    }
    
    final hasImage = _currentImage != null;
    final hasChoices = runtime.hasChoices || runtime.canContinue;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        _buildBackground(),
        
        // Main content layout
        SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context, runtime),
              
              // Text area - sized based on available space
              SizedBox(
                height: _calculateTextAreaHeight(context, hasImage, hasChoices),
                child: DecorativeStoryText(
                  key: ValueKey(_currentKnotKey),
                  text: currentKnot.content,
                  onPageComplete: _onTextAnimationComplete,
                ),
              ),
              
              // Image section (fixed height, appears after text)
              if (hasImage)
                _buildImageSection(),
              
              // Choices/Continue section (fixed height)
              if (hasChoices)
                _buildInteractionSection(runtime),
            ],
          ),
        ),
        
        // Tap hint overlay
        if (_textComplete && !_showChoices)
          _buildTapHint(),
      ],
    );
  }
  
  Widget _buildImageSection() {
    return AnimatedOpacity(
      opacity: _imageVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: SizedBox(
        height: _imageHeight,
        child: _currentImage != null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingSmall,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _currentImage!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
  
  Widget _buildInteractionSection(InkRuntime runtime) {
    return AnimatedOpacity(
      opacity: _showChoices ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: _choicesHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingSmall,
        ),
        child: runtime.hasChoices
            ? _buildChoicesList(runtime)
            : _buildContinueButtonInline(runtime),
      ),
    );
  }
  
  Widget _buildChoicesList(InkRuntime runtime) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Was tust du?',
          style: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            fontFamily: 'Mynerve',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: runtime.currentChoices.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final choice = runtime.currentChoices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: _showChoices ? () => _makeChoice(index) : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    choice.text,
                    style: const TextStyle(
                      color: Color(0xFFE8DCC0),
                      fontSize: 14,
                      height: 1.4,
                      fontFamily: 'Mynerve',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildContinueButtonInline(InkRuntime runtime) {
    if (!runtime.canContinue) return const SizedBox.shrink();
    
    return Center(
      child: FilledButton.icon(
        onPressed: _showChoices ? _continueStory : null,
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: const Text('Weiter'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (_currentBackground == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0806),
              Color(0xFF12100C),
              Color(0xFF0A0806),
            ],
          ),
        ),
      );
    }
    
    return FadeTransition(
      opacity: _bgFadeController,
      child: Image.asset(
        _currentBackground!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFF0A0806));
        },
      ),
    );
  }
  
  Widget _buildTapHint() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Center(
        child: GestureDetector(
          onTap: () {
            final runtime = ref.read(inkRuntimeProvider);
            if (runtime != null) {
              setState(() => _showChoices = true);
              _choicesFadeController.forward(from: 0);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Text(
              'Tippe um fortzufahren',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                letterSpacing: 1.5,
                fontFamily: 'Mynerve',
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEndScreen(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0806), Color(0xFF12100C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Ende der Geschichte',
                style: TextStyle(
                  color: const Color(0xFFE8DCC0),
                  fontSize: 24,
                  fontFamily: 'Mynerve',
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Du hast deine eigene Version geschrieben.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetStory,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Nochmal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text('Zurück'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, InkRuntime runtime) {
    return SizedBox(
      height: _appBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white38, size: 20),
              onPressed: () => context.go('/'),
              tooltip: 'Zurück zur Bibliothek',
            ),
            Expanded(
              child: Text(
                _formatKnotName(runtime.currentKnotName),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white24,
                  letterSpacing: 1.5,
                  fontFamily: 'Mynerve',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white38, size: 20),
              onPressed: () => SettingsDialog.show(context),
              tooltip: 'Einstellungen',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white38, size: 20),
              onPressed: _resetStory,
              tooltip: 'Neu starten',
            ),
          ],
        ),
      ),
    );
  }
  
  void _resetStory() {
    ref.read(inkRuntimeProvider.notifier).reset();
    setState(() {
      _textComplete = false;
      _imageVisible = false;
      _showChoices = false;
      _currentKnotKey = null;
      _currentBackground = null;
      _currentImage = null;
    });
  }
  
  String _formatKnotName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }
  
  void _continueStory() {
    ref.read(inkRuntimeProvider.notifier).continueStory();
    setState(() {
      _textComplete = false;
      _imageVisible = false;
      _showChoices = false;
      _currentKnotKey = null;
    });
  }

  void _makeChoice(int index) {
    ref.read(inkRuntimeProvider.notifier).makeChoice(index);
    setState(() {
      _textComplete = false;
      _imageVisible = false;
      _showChoices = false;
      _currentKnotKey = null;
    });
  }
}
