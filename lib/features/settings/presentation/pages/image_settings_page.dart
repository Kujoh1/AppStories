import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/animated_smart_image.dart';

class ImageSettingsPage extends ConsumerWidget {
  const ImageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageAnimationSettingsProvider);
    final notifier = ref.read(imageAnimationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bild-Einstellungen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Instant Mode Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        settings.instantMode ? Icons.flash_on : Icons.animation,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sofort-Modus',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.instantMode 
                                  ? 'Bilder erscheinen sofort ohne Animation'
                                  : 'Bilder faden mit coolem Blur-Effekt ein',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.instantMode,
                        onChanged: notifier.setInstantMode,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animation Settings (only visible when not in instant mode)
          if (!settings.instantMode) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Animations-Einstellungen',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Blur Duration Slider
                    Text(
                      'Blur-Effekt Dauer: ${settings.blurDuration.inMilliseconds}ms',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: settings.blurDuration.inMilliseconds.toDouble(),
                      min: 50,
                      max: 500,
                      divisions: 18,
                      label: '${settings.blurDuration.inMilliseconds}ms',
                      onChanged: (value) {
                        notifier.setBlurDuration(Duration(milliseconds: value.round()));
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fade Duration Slider
                    Text(
                      'Fade-Effekt Dauer: ${settings.fadeDuration.inMilliseconds}ms',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: settings.fadeDuration.inMilliseconds.toDouble(),
                      min: 100,
                      max: 1000,
                      divisions: 18,
                      label: '${settings.fadeDuration.inMilliseconds}ms',
                      onChanged: (value) {
                        notifier.setFadeDuration(Duration(milliseconds: value.round()));
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Preview Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.preview,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Vorschau',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showPreview(context),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Test'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Teste die Einstellungen mit einem Beispielbild',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Reset Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _resetToDefaults(notifier),
              icon: const Icon(Icons.restore),
              label: const Text('Standardwerte wiederherstellen'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PreviewDialog(),
    );
  }

  void _resetToDefaults(ImageAnimationSettings notifier) {
    notifier.setInstantMode(false);
    notifier.setBlurDuration(const Duration(milliseconds: 120));
    notifier.setFadeDuration(const Duration(milliseconds: 300));
  }
}

class _PreviewDialog extends ConsumerStatefulWidget {
  const _PreviewDialog();

  @override
  ConsumerState<_PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends ConsumerState<_PreviewDialog> {
  final GlobalKey _imageKey = GlobalKey();
  int _imageIndex = 0;
  
  // Sample images for preview (using placeholder paths)
  final List<String> _sampleImages = [
    'assets/img/sample1.png',
    'assets/img/sample2.png', 
    'assets/img/sample3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Animation Vorschau',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedSmartImage(
                    key: ValueKey(_imageIndex),
                    assetPath: _sampleImages[_imageIndex % _sampleImages.length],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    autoStart: true,
                    fallback: Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.image, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _playAgain,
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Nochmal'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Schließen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _playAgain() {
    setState(() {
      _imageIndex++;
    });
  }
}
