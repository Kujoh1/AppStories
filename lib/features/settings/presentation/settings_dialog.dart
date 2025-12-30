import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Settings dialog for app configuration
class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Einstellungen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontFamily: 'Mynerve',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            
            // Text speed setting
            Text(
              'Textgeschwindigkeit',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Mynerve',
              ),
            ),
            const SizedBox(height: 12),
            
            // Speed options
            Wrap(
              spacing: 8,
              children: TextAnimationSpeed.values.map((speed) {
                final isSelected = settings.textSpeed == speed;
                return ChoiceChip(
                  label: Text(
                    AppSettings.getSpeedName(speed),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontFamily: 'Mynerve',
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: Colors.white10,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(settingsProvider.notifier).setTextSpeed(speed);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              _getSpeedDescription(settings.textSpeed),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fertig'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  String _getSpeedDescription(TextAnimationSpeed speed) {
    switch (speed) {
      case TextAnimationSpeed.slow:
        return 'Gemütliches Lesen mit langen Pausen';
      case TextAnimationSpeed.normal:
        return 'Atmosphärische Typewriter-Animation';
      case TextAnimationSpeed.fast:
        return 'Schnelle Animation für erfahrene Leser';
      case TextAnimationSpeed.instant:
        return 'Text wird sofort vollständig angezeigt';
    }
  }
}

