import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/models/story_page.dart';
import 'ink_parser.dart';

/// Configuration for text layout calculation
class PageLayoutConfig {
  final double fontSize;
  final double lineHeight;
  final double letterSpacing;
  final double horizontalPadding;
  final String fontFamily;
  
  /// Extra space reserved for image (when present)
  final double imageHeight;
  final double imageSpacing;
  
  /// Extra space reserved for choices
  final double choiceButtonHeight;
  final double choiceSpacing;
  final double choiceHeaderHeight;
  
  /// Top/bottom padding
  final double topPadding;
  final double bottomPadding;
  
  /// Safety buffer to prevent overflow
  final double safetyBuffer;

  const PageLayoutConfig({
    this.fontSize = 16.0,
    this.lineHeight = 1.9,
    this.letterSpacing = 0.5,
    this.horizontalPadding = 16.0,
    this.fontFamily = 'Mynerve',
    this.imageHeight = 180.0,
    this.imageSpacing = 20.0,
    this.choiceButtonHeight = 56.0, // Match PageViewWidget
    this.choiceSpacing = 8.0,
    this.choiceHeaderHeight = 40.0, // Match PageViewWidget
    this.topPadding = 16.0,
    this.bottomPadding = 16.0,
    this.safetyBuffer = 48.0, // Increased for safety
  });

  TextStyle get textStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    height: lineHeight,
    letterSpacing: letterSpacing,
  );
  
  double get lineHeightPixels => fontSize * lineHeight;
}

/// Pre-analyzes story content and calculates all pages before reading starts
class PageAnalyzer {
  final PageLayoutConfig config;
  
  const PageAnalyzer({this.config = const PageLayoutConfig()});

  /// Calculate available text height based on what elements are on the page
  double _calculateTextAreaHeight({
    required double viewportHeight,
    required bool hasImage,
    required bool hasChoices,
    required int choiceCount,
    bool hasContinueButton = true, // Default: always reserve space for button
  }) {
    double fixedHeight = config.topPadding + config.bottomPadding + config.safetyBuffer;
    
    if (hasImage) {
      fixedHeight += config.imageHeight + config.imageSpacing;
    }
    
    if (hasChoices && choiceCount > 0) {
      fixedHeight += config.choiceHeaderHeight +
                     (choiceCount * config.choiceButtonHeight) +
                     ((choiceCount - 1) * config.choiceSpacing) +
                     config.imageSpacing; // spacing before choices
    } else if (hasContinueButton) {
      // Reserve space for "Weiter" button (80px)
      fixedHeight += 80.0;
    }
    
    return (viewportHeight - fixedHeight).clamp(100.0, double.infinity);
  }

  /// Calculate how many lines fit in available height
  int _calculateLinesPerPage(double availableHeight) {
    return ((availableHeight / config.lineHeightPixels).floor() - 1).clamp(1, 100);
  }

  /// Find how much text fits in available space using TextPainter
  int _findTextThatFits(String text, int startIndex, double width, double maxHeight) {
    if (startIndex >= text.length) return text.length;
    
    final maxLines = _calculateLinesPerPage(maxHeight);
    int low = startIndex + 1;
    int high = text.length;
    
    // Binary search to find max characters that fit
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      final testText = text.substring(startIndex, mid);
      final painter = TextPainter(
        text: TextSpan(text: testText, style: config.textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: width);
      final lines = painter.computeLineMetrics().length;
      painter.dispose();
      
      if (lines <= maxLines) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    
    return low;
  }

  /// Find the last sentence boundary (., !, ?, or newline) within range
  int _findSentenceEnd(String text, int startIndex, int endIndex) {
    int lastEnd = startIndex;
    
    for (int i = endIndex - 1; i > startIndex; i--) {
      final char = text[i];
      if (char == '.' || char == '!' || char == '?' || char == '\n') {
        // Check if it's end of sentence (next char is space or end)
        if (i + 1 >= text.length || text[i + 1] == ' ' || text[i + 1] == '\n') {
          lastEnd = i + 1;
          break;
        }
      }
    }
    
    return lastEnd;
  }

  /// Paginate text into pages that fit the viewport
  List<String> _paginateText({
    required String text,
    required double viewportWidth,
    required double textAreaHeight,
  }) {
    if (text.trim().isEmpty) return [''];
    
    final textWidth = viewportWidth - (config.horizontalPadding * 2);
    final pages = <String>[];
    int startCharIndex = 0;
    
    while (startCharIndex < text.length) {
      // Find how much text fits
      int endCharIndex = _findTextThatFits(
        text, startCharIndex, textWidth, textAreaHeight);
      
      // Try to break at sentence boundary
      if (endCharIndex < text.length) {
        final sentenceEnd = _findSentenceEnd(text, startCharIndex, endCharIndex);
        if (sentenceEnd > startCharIndex) {
          endCharIndex = sentenceEnd;
        } else {
          // Try word boundary
          int wordEnd = endCharIndex;
          while (wordEnd > startCharIndex && 
                 text[wordEnd - 1] != ' ' && 
                 text[wordEnd - 1] != '\n') {
            wordEnd--;
          }
          if (wordEnd > startCharIndex) {
            endCharIndex = wordEnd;
          }
        }
      }
      
      // Safety: ensure progress
      if (endCharIndex <= startCharIndex) {
        endCharIndex = (startCharIndex + 50).clamp(0, text.length);
      }
      
      pages.add(text.substring(startCharIndex, endCharIndex).trim());
      startCharIndex = endCharIndex;
      
      // Skip leading whitespace for next page
      while (startCharIndex < text.length && 
             (text[startCharIndex] == ' ' || text[startCharIndex] == '\n')) {
        startCharIndex++;
      }
    }
    
    return pages.isEmpty ? [''] : pages;
  }

  /// Analyze an Ink story and create all pages
  Future<PagedBook> analyzeInkStory({
    required InkStory story,
    required String bookId,
    required double viewportWidth,
    required double viewportHeight,
    String? startKnot,
  }) async {
    final pages = <StoryPage>[];
    final sceneToPageIndex = <String, int>{};
    int pageId = 1;
    
    // Get knot order starting from startKnot
    final knotOrder = _getLinearKnotOrder(story, startKnot ?? story.startKnot);
    
    for (final knotName in knotOrder) {
      final knot = story.knots[knotName];
      if (knot == null) continue;
      
      // Record scene start
      sceneToPageIndex[knotName] = pages.length;
      
      // Get image for this scene (from tags)
      String? imagePath;
      for (final tag in knot.tags) {
        if (tag.startsWith('IMG:')) {
          final key = tag.substring(4);
          imagePath = story.assets.getImage(key);
          break;
        }
      }
      
      // Convert choices
      final choices = knot.choices.asMap().entries.map((e) => PageChoice(
        text: e.value.text,
        targetSceneId: e.value.targetKnot,
        index: e.key,
      )).toList();
      
      final hasImage = imagePath != null;
      final hasChoices = choices.isNotEmpty;
      final canContinue = knot.divert != null;
      
      // Calculate text area height for last page (may have image/choices)
      final lastPageTextHeight = _calculateTextAreaHeight(
        viewportHeight: viewportHeight,
        hasImage: hasImage,
        hasChoices: hasChoices,
        choiceCount: choices.length,
        hasContinueButton: !hasChoices && canContinue,
      );
      
      // Calculate text area height for non-last pages (no image/choices, but always has continue button)
      final regularTextHeight = _calculateTextAreaHeight(
        viewportHeight: viewportHeight,
        hasImage: false,
        hasChoices: false,
        choiceCount: 0,
        hasContinueButton: true,
      );
      
      // Paginate the text
      // First pass: estimate how many pages without image/choices
      final textPages = _paginateText(
        text: knot.content,
        viewportWidth: viewportWidth,
        textAreaHeight: regularTextHeight,
      );
      
      // If last page would overflow with image/choices, re-paginate
      if ((hasImage || hasChoices) && textPages.length == 1 && knot.content.isNotEmpty) {
        final adjustedPages = _paginateText(
          text: knot.content,
          viewportWidth: viewportWidth,
          textAreaHeight: lastPageTextHeight,
        );
        textPages.clear();
        textPages.addAll(adjustedPages);
      }
      
      final totalPagesInScene = textPages.length;
      
      // Create StoryPage objects
      for (int i = 0; i < textPages.length; i++) {
        final isLast = i == textPages.length - 1;
        
        pages.add(StoryPage(
          id: pageId++,
          sceneId: knotName,
          pageInScene: i + 1,
          totalPagesInScene: totalPagesInScene,
          text: textPages[i],
          imagePath: isLast ? imagePath : null,
          choices: isLast ? choices : const [],
          isLastPageOfScene: isLast,
          canContinue: isLast ? canContinue : true,
          sceneTitle: i == 0 ? _formatSceneTitle(knotName) : null,
        ));
      }
    }
    
    return PagedBook(
      bookId: bookId,
      title: story.title,
      pages: pages,
      sceneToPageIndex: sceneToPageIndex,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
  }

  /// Get linear order of knots following diverts (for initial analysis)
  List<String> _getLinearKnotOrder(InkStory story, String startKnot) {
    final order = <String>[];
    final visited = <String>{};
    String? current = startKnot;
    
    while (current != null && !visited.contains(current)) {
      final knot = story.knots[current];
      if (knot == null) break;
      
      visited.add(current);
      order.add(current);
      
      // Follow divert if no choices
      if (knot.choices.isEmpty && knot.divert != null) {
        current = knot.divert;
      } else {
        // Stop at choices - branches will be explored dynamically
        current = null;
      }
    }
    
    // Add any unvisited knots (for complete analysis)
    for (final knotName in story.knots.keys) {
      if (!visited.contains(knotName)) {
        order.add(knotName);
      }
    }
    
    return order;
  }

  /// Format scene title for display
  String? _formatSceneTitle(String knotName) {
    // Don't show technical names like "s01_a"
    if (knotName.contains('_') && knotName.length < 10) {
      return null;
    }
    return knotName;
  }

  /// Analyze a DOCX/plain text story and create all pages
  Future<PagedBook> analyzeDocxStory({
    required String bookId,
    required String title,
    required List<({String title, String content})> chapters,
    required double viewportWidth,
    required double viewportHeight,
  }) async {
    final pages = <StoryPage>[];
    final sceneToPageIndex = <String, int>{};
    int pageId = 1;
    
    for (int chapterIndex = 0; chapterIndex < chapters.length; chapterIndex++) {
      final chapter = chapters[chapterIndex];
      final chapterId = 'chapter_$chapterIndex';
      
      // Record chapter start
      sceneToPageIndex[chapterId] = pages.length;
      
      // Calculate text area height (no image/choices for DOCX)
      final textHeight = _calculateTextAreaHeight(
        viewportHeight: viewportHeight,
        hasImage: false,
        hasChoices: false,
        choiceCount: 0,
      );
      
      // Paginate the chapter
      final textPages = _paginateText(
        text: chapter.content,
        viewportWidth: viewportWidth,
        textAreaHeight: textHeight,
      );
      
      final totalPagesInScene = textPages.length;
      
      // Create StoryPage objects
      for (int i = 0; i < textPages.length; i++) {
        final isLast = i == textPages.length - 1;
        final isLastChapter = chapterIndex == chapters.length - 1;
        
        pages.add(StoryPage(
          id: pageId++,
          sceneId: chapterId,
          pageInScene: i + 1,
          totalPagesInScene: totalPagesInScene,
          text: textPages[i],
          isLastPageOfScene: isLast,
          canContinue: !(isLast && isLastChapter),
          sceneTitle: i == 0 ? chapter.title : null,
        ));
      }
    }
    
    return PagedBook(
      bookId: bookId,
      title: title,
      pages: pages,
      sceneToPageIndex: sceneToPageIndex,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
  }
}

