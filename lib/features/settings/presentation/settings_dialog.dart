import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Settings dialog for app configuration
class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  // Temporary state for pending changes
  late StoryFont _pendingFont;
  late StoryFontSize _pendingFontSize;
  late TextAnimationSpeed _pendingSpeed;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize with current settings
    final settings = ref.read(settingsProvider);
    _pendingFont = settings.storyFont;
    _pendingFontSize = settings.fontSize;
    _pendingSpeed = settings.textSpeed;
  }
  
  void _updatePendingFont(StoryFont font) {
    setState(() {
      _pendingFont = font;
      _checkForChanges();
    });
  }
  
  void _updatePendingFontSize(StoryFontSize size) {
    setState(() {
      _pendingFontSize = size;
      _checkForChanges();
    });
  }
  
  void _updatePendingSpeed(TextAnimationSpeed speed) {
    setState(() {
      _pendingSpeed = speed;
      _checkForChanges();
    });
  }
  
  void _checkForChanges() {
    final settings = ref.read(settingsProvider);
    _hasChanges = _pendingFont != settings.storyFont ||
                  _pendingFontSize != settings.fontSize ||
                  _pendingSpeed != settings.textSpeed;
  }
  
  Future<void> _saveSettings() async {
    if (!_hasChanges) {
      Navigator.of(context).pop(false);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final settings = ref.read(settingsProvider);
      final fontChanged = _pendingFont != settings.storyFont;
      final fontSizeChanged = _pendingFontSize != settings.fontSize;
      
      // Apply all settings
      await ref.read(settingsProvider.notifier).applySettings(
        storyFont: _pendingFont,
        fontSize: _pendingFontSize,
        textSpeed: _pendingSpeed,
      );
      
      // If font or size changed, we need to signal that layout recalculation is needed
      final needsRecalc = fontChanged || fontSizeChanged;
      
      // Small delay to show loading animation
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        Navigator.of(context).pop(needsRecalc);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Einstellungen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mynerve',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Text Animation Speed
                  _buildSettingSection(
                    icon: Icons.speed_rounded,
                    label: 'Text-Animation',
                    primaryColor: primaryColor,
                    child: _buildSpeedOptions(primaryColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Font Size Selection
                  _buildSettingSection(
                    icon: Icons.format_size_rounded,
                    label: 'Schriftgröße',
                    primaryColor: primaryColor,
                    child: _buildFontSizeOptionsHorizontal(primaryColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Font Selection
                  _buildSettingSection(
                    icon: Icons.font_download_rounded,
                    label: 'Schriftart',
                    primaryColor: primaryColor,
                    child: _buildFontOptionsHorizontal(primaryColor),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Save Button
                  _buildSaveButton(context, primaryColor),
                ],
              ),
            ),
          ),
        ),
        
        // Loading Overlay
        if (_isLoading)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Einstellungen werden angewendet...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'Mynerve',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Layout wird neu berechnet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontFamily: 'Mynerve',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  /// Build the font selection section
  Widget _buildFontSection(BuildContext context, Color primaryColor) {
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
                final isSelected = _pendingFont == font;
                final fontFamily = font == StoryFont.mynerve ? 'Mynerve' : 'EBGaramond';
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: font == StoryFont.mynerve ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _updatePendingFont(font),
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
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Abc',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFFFDF0FF)
                                    : Colors.white.withOpacity(0.6),
                                fontFamily: fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppSettings.getFontName(font),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected 
                                    ? primaryColor
                                    : Colors.white.withOpacity(0.7),
                                fontFamily: 'Mynerve',
                              ),
                            ),
                          ],
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
  
  /// Build the font size selection section
  Widget _buildFontSizeSection(BuildContext context, Color primaryColor) {
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
                  Icons.format_size_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Schriftgröße',
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
            
            // Size cards
            Row(
              children: StoryFontSize.values.map((size) {
                final isSelected = _pendingFontSize == size;
                final sizeValue = size == StoryFontSize.small ? 16 : 18;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: size == StoryFontSize.small ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _updatePendingFontSize(size),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$sizeValue',
                              style: TextStyle(
                                fontSize: sizeValue.toDouble() + 8,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? const Color(0xFFFDF0FF)
                                    : Colors.white.withOpacity(0.6),
                                fontFamily: 'Mynerve',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              size == StoryFontSize.small ? 'Klein' : 'Groß',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected 
                                    ? primaryColor
                                    : Colors.white.withOpacity(0.5),
                                fontFamily: 'Mynerve',
                              ),
                            ),
                          ],
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

  /// Build the text animation speed selection section
  Widget _buildTextSpeedSection(BuildContext context, Color primaryColor) {
    final speedOptions = [
      (speed: TextAnimationSpeed.normal, label: 'Normal'),
      (speed: TextAnimationSpeed.fast, label: 'Schnell'),
      (speed: TextAnimationSpeed.faster, label: 'Schneller'),
      (speed: TextAnimationSpeed.instant, label: 'Sofort'),
    ];

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
            
            // Speed cards
            Row(
              children: speedOptions.map((option) {
                final isSelected = _pendingSpeed == option.speed;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option.speed != TextAnimationSpeed.instant ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _updatePendingSpeed(option.speed),
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
                            fontSize: 11,
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
  
  /// Build the save button
  Widget _buildSaveButton(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: _saveSettings,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hasChanges
                ? [primaryColor, primaryColor.withOpacity(0.8)]
                : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hasChanges ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save_rounded,
              color: _hasChanges ? Colors.white : Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Speichern',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _hasChanges ? Colors.white : Colors.white.withOpacity(0.5),
                fontFamily: 'Mynerve',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Settings section with label above options
  Widget _buildSettingSection({
    required IconData icon,
    required String label,
    required Color primaryColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
  
  /// Speed options as pill buttons
  Widget _buildSpeedOptions(Color primaryColor) {
    final speedOptions = [
      (speed: TextAnimationSpeed.normal, label: 'Normal'),
      (speed: TextAnimationSpeed.fast, label: 'Schnell'),
      (speed: TextAnimationSpeed.faster, label: '2x'),
      (speed: TextAnimationSpeed.instant, label: 'Sofort'),
    ];

    return Row(
      children: speedOptions.map((option) {
        final isSelected = _pendingSpeed == option.speed;
        final isLast = option.speed == TextAnimationSpeed.instant;
        return Expanded(
          child: GestureDetector(
            onTap: () => _updatePendingSpeed(option.speed),
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// Font size options - horizontal layout
  Widget _buildFontSizeOptionsHorizontal(Color primaryColor) {
    return Row(
      children: StoryFontSize.values.map((size) {
        final isSelected = _pendingFontSize == size;
        final isLast = size == StoryFontSize.large;
        return Expanded(
          child: GestureDetector(
            onTap: () => _updatePendingFontSize(size),
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Text(
                AppSettings.getFontSizeName(size),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// Font options with preview - horizontal layout
  Widget _buildFontOptionsHorizontal(Color primaryColor) {
    return Row(
      children: StoryFont.values.map((font) {
        final isSelected = _pendingFont == font;
        final fontFamily = font == StoryFont.mynerve ? 'Mynerve' : 'EBGaramond';
        final isLast = font == StoryFont.garamond;
        return Expanded(
          child: GestureDetector(
            onTap: () => _updatePendingFont(font),
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white60,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppSettings.getFontName(font),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? primaryColor : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
