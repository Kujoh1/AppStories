import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/widgets/debug_overlay.dart';
import 'core/widgets/mobile_viewport_wrapper.dart';
import 'core/utils/custom_scroll_behavior.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppStoriesApp(),
    ),
  );
}

class AppStoriesApp extends StatelessWidget {
  const AppStoriesApp({super.key});

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


