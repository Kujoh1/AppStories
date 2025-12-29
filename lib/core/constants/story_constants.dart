/// Constants specific to story presentation
class StoryConstants {
  StoryConstants._();

  // Canvas dimensions for story display (mobile-first)
  static const double canvasMinWidth = 320.0;
  static const double canvasMaxWidth = 415.0;
  
  // Optimal reading width
  static const double optimalWidth = 375.0;
  
  // Animation timings
  static const Duration wordFadeDuration = Duration(milliseconds: 400);
  static const Duration scrollRevealDelay = Duration(milliseconds: 50);
  
  // Typography
  static const double storyFontSize = 18.0;
  static const double storyLineHeight = 1.8;
  static const double storyLetterSpacing = 0.5;
  
  // Spacing
  static const double storyHorizontalPadding = 24.0;
  static const double storyVerticalPadding = 40.0;
  static const double wordSpacing = 8.0;
  static const double lineSpacing = 12.0;
}

