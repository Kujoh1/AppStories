import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../core/widgets/animated_smart_image.dart';
import 'pages/image_settings_page.dart';

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
              spacing: 10,
              runSpacing: 10,
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
            const SizedBox(height: 24),
            
            // Image Animation Settings
            _buildImageSettings(context, ref),
            
            const SizedBox(height: 16),
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
      case TextAnimationSpeed.faster:
        return 'Sehr schnelle Animation für Eilige';
      case TextAnimationSpeed.instant:
        return 'Text wird sofort vollständig angezeigt';
    }
  }

  Widget _buildImageSettings(BuildContext context, WidgetRef ref) {
    final imageSettings = ref.watch(imageAnimationSettingsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(
              imageSettings.instantMode ? Icons.flash_on : Icons.animation,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Bild-Animationen',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Mynerve',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Quick toggle for instant mode
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(imageAnimationSettingsProvider.notifier)
                    .setInstantMode(!imageSettings.instantMode);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imageSettings.instantMode ? 'Sofort-Modus' : 'Blur-Fade-Effekt',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.87),
                              fontFamily: 'Mynerve',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            imageSettings.instantMode 
                                ? 'Bilder erscheinen sofort'
                                : 'Coole ${imageSettings.blurDuration.inMilliseconds}ms Blur-Animation',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: imageSettings.instantMode,
                      onChanged: (value) {
                        ref.read(imageAnimationSettingsProvider.notifier)
                            .setInstantMode(value);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Advanced settings button
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Close current dialog
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImageSettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.tune, size: 16),
            label: const Text(
              'Erweiterte Einstellungen',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}


