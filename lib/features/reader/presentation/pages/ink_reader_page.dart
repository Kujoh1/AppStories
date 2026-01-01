import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ink_parser.dart';
import '../../../../core/widgets/smart_image.dart';
import '../../providers/book_provider.dart';
import '../../providers/chapter_provider.dart';
import '../widgets/scene_container.dart';
import '../widgets/chapter_overview_dialog.dart';
import '../../../settings/presentation/settings_dialog.dart';

/// Reader page for Ink format stories with choices
class InkReaderPage extends ConsumerStatefulWidget {
  const InkReaderPage({super.key});

  @override
  ConsumerState<InkReaderPage> createState() => _InkReaderPageState();
}

class _InkReaderPageState extends ConsumerState<InkReaderPage>
    with TickerProviderStateMixin {
  
  // Background animation
  late AnimationController _bgController;
  late Animation<double> _bgOpacity;
  static const double _backgroundMaxOpacity = 0.03;
  
  String? _currentBackground;
  String? _previousBackground;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgOpacity = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inkStoryAsync = ref.watch(inkStoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: inkStoryAsync.when(
        loading: () => _buildLoadingScreen(),
        error: (error, stack) => _buildErrorScreen(error),
        data: (story) => _buildStoryReader(story),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: _buildDefaultGradient(),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFE8DCC0),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Container(
      decoration: _buildDefaultGradient(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFE8DCC0),
              ),
              const SizedBox(height: 24),
              Text(
                'Fehler beim Laden',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFE8DCC0),
                  fontFamily: 'Mynerve',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => ref.invalidate(inkStoryProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryReader(InkStory story) {
    final runtime = ref.watch(inkRuntimeProvider);

    // Initialize runtime if needed
    if (runtime == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(inkRuntimeProvider.notifier).initialize(story);
      });
      return _buildLoadingScreen();
    }

    // Check for story end
    final currentKnot = runtime.currentKnot;
    if (currentKnot == null) {
      return _buildEndScreen();
    }

    // Update background if changed
    _updateBackground(runtime.currentBackground);

    // Build scene data
    final sceneData = _buildSceneData(runtime);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer with crossfade
        _buildBackgroundLayer(),

        // Dark overlay for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),

        // Main content
        SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(runtime),

              // Scene container
              Expanded(
                child: SceneContainer(
                  key: ValueKey(sceneData.id),
                  scene: sceneData,
                  onContinue: () => _continueStory(),
                  onBack: runtime.canGoBack ? () => _goBack() : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SceneData _buildSceneData(InkRuntime runtime) {
    final knot = runtime.currentKnot!;
    
    // DEBUG: Print image debugging info
    print('DEBUG: Building scene for knot: ${runtime.currentKnotName}');
    print('DEBUG: Current tags: ${runtime.currentTags}');
    print('DEBUG: Current image path: ${runtime.currentImage}');
    print('DEBUG: Has image: ${runtime.currentImage != null}');
    
    return SceneData(
      id: runtime.currentKnotName,
      text: knot.content,
      backgroundPath: runtime.currentBackground,
      imagePath: runtime.currentImage,
      choices: runtime.currentChoices.asMap().entries.map((entry) {
        return SceneChoice(
          text: entry.value.text,
          onSelected: () => _makeChoice(entry.key),
        );
      }).toList(),
      canContinue: runtime.canContinue,
    );
  }

  void _updateBackground(String? newBackground) {
    if (newBackground != _currentBackground) {
      _previousBackground = _currentBackground;
      _currentBackground = newBackground;
      
      if (newBackground != null) {
        _bgController.forward(from: 0);
      }
    }
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient (always visible)
        Container(decoration: _buildDefaultGradient()),

        // Previous background (fading out)
        if (_previousBackground != null)
          Opacity(
            opacity: _backgroundMaxOpacity,
            child: SmartImage(
              key: ValueKey('bg_prev_$_previousBackground'),
              assetPath: _previousBackground!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallback: const SizedBox.shrink(),
            ),
          ),

        // Current background (fading in)
        if (_currentBackground != null)
          FadeTransition(
            opacity: _bgOpacity.drive(
              Tween<double>(begin: 0.0, end: _backgroundMaxOpacity),
            ),
            child: SmartImage(
              key: ValueKey('bg_curr_$_currentBackground'),
              assetPath: _currentBackground!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallback: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  BoxDecoration _buildDefaultGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0806),
          Color(0xFF12100C),
          Color(0xFF0A0806),
        ],
      ),
    );
  }

  Widget _buildAppBar(InkRuntime runtime) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              runtime.canGoBack ? Icons.arrow_back_rounded : Icons.close_rounded,
              color: Colors.white38,
              size: 22,
            ),
            onPressed: () {
              if (runtime.canGoBack) {
                _goBack();
              } else {
                context.go('/');
              }
            },
            tooltip: runtime.canGoBack ? 'Eine Szene zurück' : 'Schließen',
          ),

          // Scene overview button
          IconButton(
            icon: const Icon(Icons.account_tree, color: Colors.white38, size: 20),
            onPressed: () => _showSceneOverview(runtime),
            tooltip: 'Szenen-Übersicht',
          ),

          // Scene indicator
          Expanded(
            child: Text(
              _formatKnotName(runtime.currentKnotName),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white24,
                letterSpacing: 1.5,
                fontFamily: 'Mynerve',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white38, size: 20),
            onPressed: () => SettingsDialog.show(context),
            tooltip: 'Einstellungen',
          ),

          // Home
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white38, size: 20),
            onPressed: () => context.go('/'),
            tooltip: 'Zum Startbildschirm',
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    final theme = Theme.of(context);

    return Container(
      decoration: _buildDefaultGradient(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 56,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Ende der Geschichte',
                style: TextStyle(
                  color: const Color(0xFFE8DCC0),
                  fontSize: 26,
                  fontFamily: 'Mynerve',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Du hast deine eigene Version geschrieben.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Mynerve',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetStory,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Nochmal spielen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.library_books_rounded, size: 18),
                    label: const Text('Bibliothek'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
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

  // --- Actions ---

  void _makeChoice(int index) {
    ref.read(inkRuntimeProvider.notifier).makeChoice(index);
  }

  void _continueStory() {
    ref.read(inkRuntimeProvider.notifier).continueStory();
  }

  void _goBack() {
    ref.read(inkRuntimeProvider.notifier).goBack();
  }

  void _resetStory() {
    _currentBackground = null;
    _previousBackground = null;
    ref.read(inkRuntimeProvider.notifier).reset();
  }

  void _showSceneOverview(InkRuntime runtime) {
    final bookId = ref.read(selectedBookIdProvider);
    final bookIndexAsync = ref.read(bookIndexProvider(bookId));
    
    bookIndexAsync.whenData((bookIndex) {
      // Find current scene index
      final currentKnotName = runtime.currentKnotName;
      final knotNames = bookIndex.chapters.map((c) => c.title).toList();
      final currentIndex = knotNames.indexOf(currentKnotName);
      
      ChapterOverviewDialog.show(
        context,
        isInkStory: true,
        currentChapterName: currentKnotName,
        currentChapterIndex: currentIndex >= 0 ? currentIndex : 0,
      );
    });
  }

  String _formatKnotName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
