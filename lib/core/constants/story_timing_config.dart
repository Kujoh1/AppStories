/// Configuration for story text reveal timing
/// All values in milliseconds unless otherwise noted
class StoryTimingConfig {
  // Letter reveal timing
  final int letterRevealMs;
  
  // Word-based timing
  final int shortWordDelayMs;  // Words with < 5 letters
  final int longWordDelayMs;   // Words with >= 5 letters
  
  // Punctuation-based timing
  final int commaDelayMs;       // After comma (,)
  final int sentenceDelayMs;    // After period, exclamation, question (. ! ?)
  final int paragraphDelayMs;   // After sentence + paragraph break (\n\n)
  
  // Scroll behavior
  final int scrollSkipThreshold; // Scroll offset to skip to end
  
  // Initial delay before starting reveal
  final int initialDelayMs;
  
  // Character animation effects - separate durations per effect
  final int opacityDurationMs;     // Duration for opacity animation
  final int scaleDurationMs;       // Duration for scale animation
  final int blurDurationMs;        // Duration for blur animation
  
  // Opacity animation
  final double fadeStartOpacity;   // Starting opacity (0.0 = invisible)
  final double fadeEndOpacity;     // Ending opacity (1.0 = fully visible)
  
  // Scale animation with mid-point
  final double scaleStartFactor;   // Starting size (0.5 = 50% of normal)
  final double scaleMidFactor;     // Mid-point size (1.2 = 120% - overshoot)
  final double scaleMidPoint;      // When to reach mid-point (0.8 = at 80% of animation)
  final double scaleEndFactor;     // Ending size (1.0 = 100% normal)
  
  // Blur animation with mid-point
  final double blurStartRadius;    // Starting blur radius in pixels (20.0 = very blurred)
  final double blurMidRadius;      // Mid-point blur radius (10.0 = medium blur)
  final double blurMidPoint;       // When to reach mid-point (0.5 = at 50% of animation)
  final double blurEndRadius;      // Ending blur radius (0.0 = sharp)
  
  const StoryTimingConfig({
    this.letterRevealMs = 10,
    this.shortWordDelayMs = 50,
    this.longWordDelayMs = 100,
    this.commaDelayMs = 1000,
    this.sentenceDelayMs = 2000,
    this.paragraphDelayMs = 4000,
    this.scrollSkipThreshold = 100,
    this.initialDelayMs = 500,
    this.opacityDurationMs = 1500,
    this.scaleDurationMs = 1500,
    this.blurDurationMs = 1500,
    this.fadeStartOpacity = 0.0,
    this.fadeEndOpacity = 1.0,
    this.scaleStartFactor = 0.5,
    this.scaleMidFactor = 1.2,
    this.scaleMidPoint = 0.8,
    this.scaleEndFactor = 1.0,
    this.blurStartRadius = 20.0,
    this.blurMidRadius = 10.0,
    this.blurMidPoint = 0.5,
    this.blurEndRadius = 0.0,
  });

  /// Default configuration
  static const StoryTimingConfig defaultConfig = StoryTimingConfig();
  
  /// Fast reading configuration
  static const StoryTimingConfig fast = StoryTimingConfig(
    letterRevealMs: 5,
    shortWordDelayMs: 30,
    longWordDelayMs: 60,
    commaDelayMs: 300,
    sentenceDelayMs: 800,
    paragraphDelayMs: 1500,
    initialDelayMs: 200,
  );
  
  /// Slow, dramatic configuration
  static const StoryTimingConfig dramatic = StoryTimingConfig(
    letterRevealMs: 15,
    shortWordDelayMs: 80,
    longWordDelayMs: 150,
    commaDelayMs: 1500,
    sentenceDelayMs: 3000,
    paragraphDelayMs: 5000,
    initialDelayMs: 1000,
  );
  
  /// Custom configuration - edit values here for your needs
  static const StoryTimingConfig custom = StoryTimingConfig(
    letterRevealMs: 20,              // ← ANPASSEN: Zeit pro Buchstabe
    shortWordDelayMs: 50,            // ← ANPASSEN: Pause nach kurzem Wort (<5 Buchstaben)
    longWordDelayMs: 120,            // ← ANPASSEN: Pause nach langem Wort (≥5 Buchstaben)
    commaDelayMs: 500,               // ← ANPASSEN: Pause nach Komma
    sentenceDelayMs: 1200,           // ← ANPASSEN: Pause nach Punkt/!/?
    paragraphDelayMs: 1800,          // ← ANPASSEN: Pause nach Absatz
    scrollSkipThreshold: 100,        // ← ANPASSEN: Scroll-Pixel zum Überspringen
    initialDelayMs: 500,             // ← ANPASSEN: Verzögerung vor Start
    
    // Animation Durations (getrennt steuerbar!)
    opacityDurationMs: 3000,         // ← ANPASSEN: Dauer der Opacity-Animation
    scaleDurationMs: 1200,           // ← ANPASSEN: Dauer der Scale-Animation
    blurDurationMs: 5000,            // ← ANPASSEN: Dauer der Blur-Animation
    
    // Opacity-Effekt
    fadeStartOpacity: 0.0,           // ← ANPASSEN: Start-Transparenz (0.0 = unsichtbar)
    fadeEndOpacity: 1.0,             // ← ANPASSEN: End-Transparenz (1.0 = voll sichtbar)
    
    // Scale-Effekt mit Mid-Point (für Overshoot/Bounce)
    scaleStartFactor: 0.0,           // ← ANPASSEN: Start-Größe (0.5 = 50%)
    scaleMidFactor: 0.5,             // ← ANPASSEN: Mid-Größe bei Mid-Point (1.2 = 120% - Overshoot!)
    scaleMidPoint: 0.8,              // ← ANPASSEN: Wann Mid-Point erreicht wird (0.8 = bei 80%)
    scaleEndFactor: 1.0,             // ← ANPASSEN: End-Größe (1.0 = 100% normal)
    
    // Blur-Effekt mit Mid-Point
    blurStartRadius: 40.0,           // ← ANPASSEN: Start-Blur (20.0 = stark verschwommen)
    blurMidRadius: 20.0,             // ← ANPASSEN: Mid-Blur bei Mid-Point (10.0 = mittel)
    blurMidPoint: 0.5,               // ← ANPASSEN: Wann Mid-Point erreicht wird (0.5 = bei 50%)
    blurEndRadius: 0.0,              // ← ANPASSEN: End-Blur (0.0 = scharf)
  );
  
  /// Copy with modifications
  StoryTimingConfig copyWith({
    int? letterRevealMs,
    int? shortWordDelayMs,
    int? longWordDelayMs,
    int? commaDelayMs,
    int? sentenceDelayMs,
    int? paragraphDelayMs,
    int? scrollSkipThreshold,
    int? initialDelayMs,
    int? opacityDurationMs,
    int? scaleDurationMs,
    int? blurDurationMs,
    double? fadeStartOpacity,
    double? fadeEndOpacity,
    double? scaleStartFactor,
    double? scaleMidFactor,
    double? scaleMidPoint,
    double? scaleEndFactor,
    double? blurStartRadius,
    double? blurMidRadius,
    double? blurMidPoint,
    double? blurEndRadius,
  }) {
    return StoryTimingConfig(
      letterRevealMs: letterRevealMs ?? this.letterRevealMs,
      shortWordDelayMs: shortWordDelayMs ?? this.shortWordDelayMs,
      longWordDelayMs: longWordDelayMs ?? this.longWordDelayMs,
      commaDelayMs: commaDelayMs ?? this.commaDelayMs,
      sentenceDelayMs: sentenceDelayMs ?? this.sentenceDelayMs,
      paragraphDelayMs: paragraphDelayMs ?? this.paragraphDelayMs,
      scrollSkipThreshold: scrollSkipThreshold ?? this.scrollSkipThreshold,
      initialDelayMs: initialDelayMs ?? this.initialDelayMs,
      opacityDurationMs: opacityDurationMs ?? this.opacityDurationMs,
      scaleDurationMs: scaleDurationMs ?? this.scaleDurationMs,
      blurDurationMs: blurDurationMs ?? this.blurDurationMs,
      fadeStartOpacity: fadeStartOpacity ?? this.fadeStartOpacity,
      fadeEndOpacity: fadeEndOpacity ?? this.fadeEndOpacity,
      scaleStartFactor: scaleStartFactor ?? this.scaleStartFactor,
      scaleMidFactor: scaleMidFactor ?? this.scaleMidFactor,
      scaleMidPoint: scaleMidPoint ?? this.scaleMidPoint,
      scaleEndFactor: scaleEndFactor ?? this.scaleEndFactor,
      blurStartRadius: blurStartRadius ?? this.blurStartRadius,
      blurMidRadius: blurMidRadius ?? this.blurMidRadius,
      blurMidPoint: blurMidPoint ?? this.blurMidPoint,
      blurEndRadius: blurEndRadius ?? this.blurEndRadius,
    );
  }
  
  @override
  String toString() {
    return '''
StoryTimingConfig:
  Letter Reveal: ${letterRevealMs}ms
  Short Word (<5): ${shortWordDelayMs}ms
  Long Word (≥5): ${longWordDelayMs}ms
  Comma: ${commaDelayMs}ms
  Sentence: ${sentenceDelayMs}ms
  Paragraph: ${paragraphDelayMs}ms
  Scroll Skip: ${scrollSkipThreshold}px
  Initial Delay: ${initialDelayMs}ms
  
  Animation Effects (separate durations):
  Opacity: ${opacityDurationMs}ms | $fadeStartOpacity → $fadeEndOpacity
  Scale: ${scaleDurationMs}ms | ${scaleStartFactor}x → ${scaleMidFactor}x (at ${scaleMidPoint*100}%) → ${scaleEndFactor}x
  Blur: ${blurDurationMs}ms | ${blurStartRadius}px → ${blurMidRadius}px (at ${blurMidPoint*100}%) → ${blurEndRadius}px
''';
  }
}

