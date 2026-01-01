import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../../../core/widgets/animated_smart_image.dart';
import 'pages/image_settings_page.dart';

/// Settings dialog for app configuration
class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => const SettingsDialog(),
      ),
    );
  }

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final imageSettings = ref.watch(imageAnimationSettingsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mynerve',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Text Animation Speed
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Text-Animation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.87),
                            fontFamily: 'Mynerve',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Speed Selection
                    Text(
                      'Geschwindigkeit: ${AppSettings.getSpeedName(settings.textSpeed)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: settings.textSpeed.index.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      onChanged: (value) {
                        final speed = TextAnimationSpeed.values[value.round()];
                        ref.read(settingsProvider.notifier).setTextSpeed(speed);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Skip Animation Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sofort-Modus',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.87),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Text sofort anzeigen',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: settings.skipAnimation,
                          onChanged: (value) {
                            final speed = value ? TextAnimationSpeed.instant : TextAnimationSpeed.normal;
                            ref.read(settingsProvider.notifier).setTextSpeed(speed);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Image Animation Settings
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ImageSettingsPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bild-Animationen',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.87),
                                  fontFamily: 'Mynerve',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                imageSettings.instantMode ? 'Sofort-Modus' : 'Blur-Fade-Effekt',
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
            
            // Debug section
            _buildDebugSection(context),
            
            const SizedBox(height: 12),
            
            // Advanced settings button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ImageSettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Erweiterte Einstellungen'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Extra bottom padding for scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    return FutureBuilder<bool>(
      future: _getDebugOverlayState(),
      builder: (context, snapshot) {
        final isDebugEnabled = snapshot.data ?? false;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleDebugOverlay(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDebugEnabled 
                            ? Colors.greenAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDebugEnabled ? Icons.bug_report : Icons.bug_report_outlined,
                        color: isDebugEnabled ? Colors.greenAccent : Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug-Informationen',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.87),
                              fontFamily: 'Mynerve',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDebugEnabled 
                                ? 'FPS, Viewport & Route-Info aktiv'
                                : 'Performance & System-Info anzeigen',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                          if (!isDebugEnabled) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Tipp: Alt+D zum schnellen Umschalten',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white38,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isDebugEnabled,
                      onChanged: (_) => _toggleDebugOverlay(),
                      activeColor: Colors.greenAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _getDebugOverlayState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('debug_overlay_visible') ?? false;
  }

  Future<void> _toggleDebugOverlay() async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = prefs.getBool('debug_overlay_visible') ?? false;
    await prefs.setBool('debug_overlay_visible', !currentState);
    
    // Force a rebuild to update the UI
    if (mounted) {
      // Close and reopen the dialog to refresh the state
      Navigator.of(context).pop();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          SettingsDialog.show(context);
        }
      });
    }
  }
}