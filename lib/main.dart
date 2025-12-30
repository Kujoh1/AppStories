import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/widgets/debug_overlay.dart';
import 'core/widgets/preloader.dart';
import 'core/utils/custom_scroll_behavior.dart';
import 'features/reader/providers/book_provider.dart';
import 'features/settings/providers/settings_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppStoriesApp(),
    ),
  );
}

class AppStoriesApp extends ConsumerStatefulWidget {
  const AppStoriesApp({super.key});

  @override
  ConsumerState<AppStoriesApp> createState() => _AppStoriesAppState();
}

class _AppStoriesAppState extends ConsumerState<AppStoriesApp> {
  bool _isLoading = true;
  String _loadingMessage = 'Initialisiere...';
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _preloadContent();
  }

  Future<void> _preloadContent() async {
    // Small delay for UI to settle
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    setState(() {
      _loadingMessage = 'Lade Einstellungen...';
      _loadingProgress = 0.1;
    });

    // Preload settings first and wait for SharedPreferences to load
    await ref.read(settingsProvider.notifier).initialized;
    
    if (!mounted) return;
    setState(() {
      _loadingMessage = 'Lade Geschichte...';
      _loadingProgress = 0.2;
    });

    // Preload the book list
    try {
      await ref.read(booksProvider.future);
      
      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Lade Geschichten...';
        _loadingProgress = 0.5;
      });

      // Preload the default book
      await ref.read(bookProvider.future);
      
      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Bereite Inhalte vor...';
        _loadingProgress = 0.8;
      });
      
      // Brief pause for visual feedback
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      setState(() {
        _loadingProgress = 1.0;
        _loadingMessage = 'Fertig!';
      });
      
      // Fade out delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // On error, still proceed to app (error will be shown there)
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    Widget app = MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      scrollBehavior: const CustomScrollBehavior(),
      builder: (context, child) {
        // Show preloader during initial load
        if (_isLoading) {
          return AppPreloader(
            loadingText: _loadingMessage,
            progress: _loadingProgress,
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );

    // Wrap everything for web
    if (kIsWeb) {
      app = ColoredBox(
        color: const Color(0xFF000000), // Black background
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 415),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: app,
            ),
          ),
        ),
      );
    }

    // Add debug overlay
    return DebugOverlay(child: app);
  }
}
