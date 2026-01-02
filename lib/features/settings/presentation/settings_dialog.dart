import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

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
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
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
            
            // Font Selection - Elegant switcher
            _buildFontSection(context, ref, settings),
            
            const SizedBox(height: 24),
            
            // Text Animation Speed - Card Selection
            _buildTextSpeedSection(context, ref, settings),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  /// Build the font selection section with elegant preview cards
  Widget _buildFontSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
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
            // Section header
            Row(
              children: [
                Icon(
                  Icons.font_download_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Schriftart',
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
            
            // Font cards
            Row(
              children: StoryFont.values.map((font) {
                final isSelected = settings.storyFont == font;
                final fontFamily = font == StoryFont.mynerve ? 'Mynerve' : 'EBGaramond';
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: font == StoryFont.mynerve ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(settingsProvider.notifier).setStoryFont(font);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? primaryColor.withOpacity(0.15)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? primaryColor
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ] : null,
                        ),
                        child: Column(
                          children: [
                            // Font preview text
                            Text(
                              'Abc',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFFFDF0FF)
                                    : Colors.white.withOpacity(0.6),
                                fontFamily: fontFamily,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Font name
                            Text(
                              AppSettings.getFontName(font),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected 
                                    ? primaryColor
                                    : Colors.white.withOpacity(0.7),
                                fontFamily: 'Mynerve',
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            // Font description
                            Text(
                              AppSettings.getFontDescription(font),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.4),
                                fontFamily: 'Mynerve',
                              ),
                            ),
                            
                            // Selected indicator
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Icon(
                                Icons.check_circle_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Preview text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(settings.storyFont),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0806),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  '„Die Antarktis will mich töten", flüsterte sie in die Dunkelheit.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: const Color(0xFFFDF0FF),
                    fontFamily: settings.fontFamily,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the text animation speed selection section with simple cards
  Widget _buildTextSpeedSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    final speedOptions = [
      (speed: TextAnimationSpeed.slow, label: 'Langsam'),
      (speed: TextAnimationSpeed.normal, label: 'Normal'),
      (speed: TextAnimationSpeed.fast, label: 'Schnell'),
      (speed: TextAnimationSpeed.instant, label: 'Sofort'),
    ];

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
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
            // Section header
            Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  color: primaryColor,
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
            
            // Speed cards in a row
            Row(
              children: speedOptions.map((option) {
                final isSelected = settings.textSpeed == option.speed;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option.speed != TextAnimationSpeed.instant ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(settingsProvider.notifier).setTextSpeed(option.speed);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? primaryColor.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? primaryColor
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                                ? primaryColor
                                : Colors.white.withOpacity(0.7),
                            fontFamily: 'Mynerve',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
