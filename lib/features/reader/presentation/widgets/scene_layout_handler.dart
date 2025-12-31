import 'package:flutter/material.dart';

/// Calculates optimal layout for scene content
/// Ensures proper spacing and pagination
class SceneLayoutCalculator {
  /// Minimum spacing between all content boxes
  static const double contentSpacing = 24.0;
  
  /// Fixed heights
  static const double imageHeight = 180.0;
  static const double choiceButtonHeight = 48.0;
  static const double choiceSpacing = 8.0;
  static const double continueButtonHeight = 52.0;
  static const double bottomPadding = 16.0;
  
  /// Calculate the layout for a scene
  static SceneLayout calculate({
    required double availableHeight,
    required double availableWidth,
    required bool hasImage,
    required bool hasChoices,
    required bool hasContinueButton,
    required int choiceCount,
  }) {
    // Calculate fixed heights
    double fixedHeight = 0;
    
    // Image section (if present)
    double imageSectionHeight = 0;
    if (hasImage) {
      imageSectionHeight = imageHeight;
      fixedHeight += imageSectionHeight + contentSpacing; // image + spacing to text
    }
    
    // Interaction section (choices or continue button)
    double interactionHeight = 0;
    if (hasChoices) {
      interactionHeight = _calculateChoicesHeight(choiceCount);
      fixedHeight += interactionHeight + contentSpacing; // interaction + spacing
    } else if (hasContinueButton) {
      interactionHeight = continueButtonHeight;
      fixedHeight += interactionHeight + contentSpacing;
    }
    
    // Bottom padding
    fixedHeight += bottomPadding;
    
    // Text gets remaining space
    final textAreaHeight = (availableHeight - fixedHeight).clamp(100.0, availableHeight * 0.65);
    
    return SceneLayout(
      totalHeight: availableHeight,
      textAreaHeight: textAreaHeight,
      imageHeight: hasImage ? imageSectionHeight : 0,
      interactionHeight: interactionHeight,
      spacing: contentSpacing,
      bottomPadding: bottomPadding,
      hasImage: hasImage,
      hasInteraction: hasChoices || hasContinueButton,
    );
  }
  
  static double _calculateChoicesHeight(int count) {
    if (count == 0) return 0;
    return 24 + // "Was tust du?" header
           12 + // spacing after header
           (count * choiceButtonHeight) +
           ((count - 1) * choiceSpacing) +
           8; // bottom margin
  }
}

/// Immutable layout configuration for a scene
class SceneLayout {
  final double totalHeight;
  final double textAreaHeight;
  final double imageHeight;
  final double interactionHeight;
  final double spacing;
  final double bottomPadding;
  final bool hasImage;
  final bool hasInteraction;
  
  const SceneLayout({
    required this.totalHeight,
    required this.textAreaHeight,
    required this.imageHeight,
    required this.interactionHeight,
    required this.spacing,
    required this.bottomPadding,
    required this.hasImage,
    required this.hasInteraction,
  });
  
  /// The flexible space between image and interaction
  double get flexibleSpace {
    final usedSpace = textAreaHeight + 
                      (hasImage ? imageHeight + spacing : 0) +
                      (hasInteraction ? interactionHeight + spacing : 0) +
                      bottomPadding;
    return (totalHeight - usedSpace).clamp(0.0, double.infinity);
  }
}

/// Widget that renders scene content with proper layout
/// Text + Image stick together at top, Interaction at bottom
class SceneLayoutWidget extends StatelessWidget {
  final SceneLayout layout;
  final Widget textWidget;
  final Widget? imageWidget;
  final Widget? interactionWidget;
  final bool imageVisible;
  final bool interactionVisible;
  
  const SceneLayoutWidget({
    super.key,
    required this.layout,
    required this.textWidget,
    this.imageWidget,
    this.interactionWidget,
    this.imageVisible = true,
    this.interactionVisible = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // UPPER CONTENT GROUP: Text + Image (stick together, valign top)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TEXT AREA - constrained max height for pagination, but shrinks to content
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: layout.textAreaHeight,
                ),
                child: textWidget,
              ),
              
              // IMAGE - 24px below text
              if (layout.hasImage && imageWidget != null && imageVisible) ...[
                SizedBox(height: layout.spacing),
                SizedBox(
                  height: layout.imageHeight,
                  child: imageWidget,
                ),
              ],
            ],
          ),
          
          // FLEXIBLE SPACE - pushes interaction to bottom
          const Spacer(),
          
          // INTERACTION AREA - valign bottom
          if (layout.hasInteraction && interactionWidget != null) ...[
            if (interactionVisible) interactionWidget!,
            SizedBox(height: layout.bottomPadding),
          ],
        ],
      ),
    );
  }
}

