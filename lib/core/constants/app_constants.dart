/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'AppStories';
  static const String appVersion = '1.0.0';

  // Book IDs
  static const String defaultBookId = 'book_001';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Text scaling
  static const double minTextScale = 0.8;
  static const double defaultTextScale = 1.0;
  static const double maxTextScale = 2.0;
  static const double textScaleStep = 0.1;

  // Zoom
  static const double minZoom = 0.5;
  static const double defaultZoom = 1.0;
  static const double maxZoom = 3.0;

  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Reader settings
  static const double readerMaxWidth = 800.0;
  static const double readerMinPadding = 16.0;
}


