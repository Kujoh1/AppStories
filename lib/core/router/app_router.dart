import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../features/reader/presentation/pages/home_page.dart';

/// Central router configuration using go_router
/// Supports deep linking and clean navigation
class AppRouter {
  // Private constructor
  AppRouter._();

  // Route paths
  static const String home = '/';
  static const String reader = '/reader';

  /// Creates the router configuration
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: home,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: reader,
          name: 'reader',
          builder: (context, state) {
            // Extract page ID from query parameters
            final pageId = state.uri.queryParameters['pageId'] ?? 'page_1';
            return ReaderPage(initialPageId: pageId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'Seite nicht gefunden',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'Unbekannter Fehler',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(home),
                child: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension for easier navigation
extension GoRouterExtension on BuildContext {
  /// Navigate to reader with specific page
  void goToReader({String pageId = 'page_1'}) {
    go('${AppRouter.reader}?pageId=$pageId');
  }

  /// Navigate to home
  void goToHome() {
    go(AppRouter.home);
  }
}


