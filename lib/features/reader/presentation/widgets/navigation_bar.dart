import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Bottom navigation bar for page navigation
class PageNavigationBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  const PageNavigationBar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    this.onPreviousPressed,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            Expanded(
              child: FilledButton.icon(
                onPressed: canGoBack ? onPreviousPressed : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
                style: FilledButton.styleFrom(
                  backgroundColor: canGoBack
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.surfaceVariant,
                  foregroundColor: canGoBack
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            // Next button
            Expanded(
              child: FilledButton(
                onPressed: canGoForward ? onNextPressed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canGoForward
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceVariant,
                  foregroundColor: canGoForward
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Weiter'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

