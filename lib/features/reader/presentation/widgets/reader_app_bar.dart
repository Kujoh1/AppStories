import 'package:flutter/material.dart';

/// Custom app bar for the reader screen
class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;

  const ReaderAppBar({
    super.key,
    required this.title,
    required this.currentPage,
    required this.totalPages,
    this.onSettingsTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentPage / totalPages;

    return AppBar(
      leading: onBackTap != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackTap,
              tooltip: 'Zurück',
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$currentPage / $totalPages',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (onSettingsTap != null)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettingsTap,
            tooltip: 'Einstellungen',
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}


