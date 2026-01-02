import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Text animation speed options
enum TextAnimationSpeed {
  normal,  // Normal
  fast,    // Schnell
  faster,  // Schneller
  instant, // Sofort (keine Animation)
}

/// Font family options
enum StoryFont {
  mynerve,    // Handschrift-artig, verspielt
  garamond,   // Klassisch, elegant, wie ein echtes Buch
}

/// Font size options
enum StoryFontSize {
  small,  // 16pt
  large,  // 18pt
}

/// Settings state
class AppSettings {
  final TextAnimationSpeed textSpeed;
  final bool soundEnabled;
  final StoryFont storyFont;
  final StoryFontSize fontSize;
  
  const AppSettings({
    this.textSpeed = TextAnimationSpeed.normal,
    this.soundEnabled = true,
    this.storyFont = StoryFont.garamond, // Garamond als Standard
    this.fontSize = StoryFontSize.large, // 18pt als Standard
  });
  
  AppSettings copyWith({
    TextAnimationSpeed? textSpeed,
    bool? soundEnabled,
    StoryFont? storyFont,
    StoryFontSize? fontSize,
  }) {
    return AppSettings(
      textSpeed: textSpeed ?? this.textSpeed,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      storyFont: storyFont ?? this.storyFont,
      fontSize: fontSize ?? this.fontSize,
    );
  }
  
  /// Get the font size value in pixels
  double get fontSizeValue {
    switch (fontSize) {
      case StoryFontSize.small:
        return 16.0;
      case StoryFontSize.large:
        return 18.0;
    }
  }
  
  /// Get display name for font size
  static String getFontSizeName(StoryFontSize size) {
    switch (size) {
      case StoryFontSize.small:
        return '16';
      case StoryFontSize.large:
        return '18';
    }
  }
  
  /// Get the font family name for Flutter
  String get fontFamily {
    switch (storyFont) {
      case StoryFont.mynerve:
        return 'Mynerve';
      case StoryFont.garamond:
        return 'EBGaramond';
    }
  }
  
  /// Get display name for font
  static String getFontName(StoryFont font) {
    switch (font) {
      case StoryFont.mynerve:
        return 'Mynerve';
      case StoryFont.garamond:
        return 'EB Garamond';
    }
  }
  
  /// Get font description
  static String getFontDescription(StoryFont font) {
    switch (font) {
      case StoryFont.mynerve:
        return 'Modern & verspielt';
      case StoryFont.garamond:
        return 'Klassisch & elegant';
    }
  }
  
  /// Get speed multiplier (higher = faster animation)
  /// Base delay is 12ms per char, divided by multiplier:
  /// - Normal: 12ms / 1 = 12ms per char (~6 sec for 500 chars)
  /// - Schnell: 12ms / 3 = 4ms per char (~2 sec for 500 chars)
  /// - Schneller: 12ms / 10 = 1.2ms per char (~0.6 sec for 500 chars)
  /// - Sofort: Animation wird übersprungen
  double get speedMultiplier {
    switch (textSpeed) {
      case TextAnimationSpeed.normal:
        return 1.0;   // Normal (~6 Sekunden pro Seite)
      case TextAnimationSpeed.fast:
        return 3.0;   // Schnell (~2 Sekunden pro Seite)
      case TextAnimationSpeed.faster:
        return 10.0;  // Schneller (<1 Sekunde pro Seite)
      case TextAnimationSpeed.instant:
        return 1000.0; // Wird nicht verwendet, da skipAnimation=true
    }
  }
  
  /// Check if animation should be skipped entirely
  bool get skipAnimation => textSpeed == TextAnimationSpeed.instant;
  
  /// Get display name for speed
  static String getSpeedName(TextAnimationSpeed speed) {
    switch (speed) {
      case TextAnimationSpeed.normal:
        return 'Normal';
      case TextAnimationSpeed.fast:
        return 'Schnell';
      case TextAnimationSpeed.faster:
        return 'Schneller';
      case TextAnimationSpeed.instant:
        return 'Sofort';
    }
  }
}

/// Settings notifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  late final Future<void> _initialized;
  
  SettingsNotifier() : super(const AppSettings()) {
    _initialized = _loadSettings();
  }
  
  /// Wait for settings to be loaded from SharedPreferences
  Future<void> get initialized => _initialized;
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final speedIndex = prefs.getInt('textSpeed') ?? 0; // Default to normal
    final soundEnabled = prefs.getBool('soundEnabled') ?? true;
    final fontIndex = prefs.getInt('storyFont') ?? 1; // Default to Garamond
    final fontSizeIndex = prefs.getInt('fontSize') ?? 1; // Default to large (18)
    
    final clampedSpeedIndex = speedIndex.clamp(0, TextAnimationSpeed.values.length - 1);
    final loadedSpeed = TextAnimationSpeed.values[clampedSpeedIndex];
    
    state = AppSettings(
      textSpeed: loadedSpeed,
      soundEnabled: soundEnabled,
      storyFont: StoryFont.values[fontIndex.clamp(0, StoryFont.values.length - 1)],
      fontSize: StoryFontSize.values[fontSizeIndex.clamp(0, StoryFontSize.values.length - 1)],
    );
  }
  
  Future<void> setTextSpeed(TextAnimationSpeed speed) async {
    state = state.copyWith(textSpeed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('textSpeed', speed.index);
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }
  
  Future<void> setStoryFont(StoryFont font) async {
    state = state.copyWith(storyFont: font);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('storyFont', font.index);
  }
  
  Future<void> setFontSize(StoryFontSize size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size.index);
  }
  
  /// Apply multiple settings at once (for save button)
  Future<void> applySettings({
    TextAnimationSpeed? textSpeed,
    StoryFont? storyFont,
    StoryFontSize? fontSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (textSpeed != null) {
      await prefs.setInt('textSpeed', textSpeed.index);
    }
    if (storyFont != null) {
      await prefs.setInt('storyFont', storyFont.index);
    }
    if (fontSize != null) {
      await prefs.setInt('fontSize', fontSize.index);
    }
    
    state = state.copyWith(
      textSpeed: textSpeed,
      storyFont: storyFont,
      fontSize: fontSize,
    );
  }
}

/// Global settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

