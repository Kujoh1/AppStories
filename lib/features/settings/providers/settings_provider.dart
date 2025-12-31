import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Text animation speed options
enum TextAnimationSpeed {
  slow,    // Langsam
  normal,  // Normal
  fast,    // Schnell
  faster,  // Schneller (2x schneller als fast)
  instant, // Sofort (keine Animation)
}

/// Settings state
class AppSettings {
  final TextAnimationSpeed textSpeed;
  final bool soundEnabled;
  
  const AppSettings({
    this.textSpeed = TextAnimationSpeed.normal,
    this.soundEnabled = true,
  });
  
  AppSettings copyWith({
    TextAnimationSpeed? textSpeed,
    bool? soundEnabled,
  }) {
    return AppSettings(
      textSpeed: textSpeed ?? this.textSpeed,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
  
  /// Get speed multiplier (lower = faster)
  double get speedMultiplier {
    switch (textSpeed) {
      case TextAnimationSpeed.slow:
        return 1.0;
      case TextAnimationSpeed.normal:
        return 0.5;
      case TextAnimationSpeed.fast:
        return 0.25;
      case TextAnimationSpeed.faster:
        return 0.125;  // 2x schneller als fast
      case TextAnimationSpeed.instant:
        return 0.0;
    }
  }
  
  /// Check if animation should be skipped entirely
  bool get skipAnimation => textSpeed == TextAnimationSpeed.instant;
  
  /// Get display name for speed
  static String getSpeedName(TextAnimationSpeed speed) {
    switch (speed) {
      case TextAnimationSpeed.slow:
        return 'Langsam';
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
    final speedIndex = prefs.getInt('textSpeed') ?? 1;
    final soundEnabled = prefs.getBool('soundEnabled') ?? true;
    
    state = AppSettings(
      textSpeed: TextAnimationSpeed.values[speedIndex.clamp(0, 4)],
      soundEnabled: soundEnabled,
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
}

/// Global settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

