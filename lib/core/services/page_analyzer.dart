import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/models/story_page.dart';
import 'ink_parser.dart';
import 'hyphenator_service.dart';

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
    this.fontSize = 18.0,
    this.lineHeight = 1.5,            // Match PageViewWidget lineHeight
    this.letterSpacing = 0.45,
    this.horizontalPadding = 16.0,
    this.fontFamily = 'EBGaramond',   // Match PageViewWidget default font
    this.imageHeight = 180.0,
    this.imageSpacing = 20.0,
    this.choiceButtonHeight = 240.0,  // Increased for new gradient design with more padding
    this.choiceSpacing = 12.0,        // Match actual spacing in PageViewWidget
    this.choiceHeaderHeight = 70.0,   // Increased for icon + text + spacing (28 + 20 + 20)
    this.topPadding = 16.0,
    this.bottomPadding = 40.0,        // Match PageViewWidget bottom padding
    this.safetyBuffer = 8.0,          // Minimal safety margin - maximize text space
  });

  TextStyle get textStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    height: lineHeight,
    letterSpacing: letterSpacing,
    fontVariations: const [FontVariation('wght', 600)], // Match PageViewWidget fontWeight
  );
  
  double get lineHeightPixels => fontSize * lineHeight;
}

/// Pre-analyzes story content and calculates all pages before reading starts
class PageAnalyzer {
  final PageLayoutConfig config;
  
  const PageAnalyzer({this.config = const PageLayoutConfig()});
  
  /// Calculate the quote state at the end of a text
  /// Returns true if the text ends with an open quote (started with „ but not closed)
  /// Ignores soft hyphens (U+00AD) which may be present for hyphenation
  bool _endsWithOpenQuote(String text) {
    bool inQuote = false;
    
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      
      // Skip soft hyphens (used for hyphenation)
      if (code == 0x00AD) continue;
      
      // » (Guillemet right-pointing, U+00BB) - opens quotes
      if (code == 0x00BB) {
        inQuote = true;
      }
      // « (Guillemet left-pointing, U+00AB) - closes quotes
      else if (inQuote && code == 0x00AB) {
        inQuote = false;
      }
    }
    
    return inQuote;
  }

  /// Calculate the actual height needed for a single choice button
  /// MUST match PageViewWidget._buildChoiceButton EXACTLY
  double _calculateChoiceHeight(String choiceText, double viewportWidth) {
    // Constants from PageViewWidget._buildChoiceButton
    // Container padding (line 625)
    const containerPaddingH = 20.0;
    const containerPaddingV = 16.0;
    
    // Badge (lines 651-672): width 28, height 28
    const badgeWidth = 28.0;
    const badgeHeight = 28.0;
    
    // Spacing after badge (line 673)
    const badgeSpacing = 14.0;
    
    // Arrow icon (lines 690-694): width 16
    const arrowWidth = 16.0;
    
    // Spacing before arrow (line 688)
    const arrowSpacing = 10.0;
    
    // Box shadow offset (line 644)
    const shadowOffset = 4.0;
    
    // Available width for text (badge + spacing + text + spacing + arrow)
    final availableTextWidth = viewportWidth 
        - (containerPaddingH * 2)  // left + right padding
        - badgeWidth 
        - badgeSpacing 
        - arrowSpacing
        - arrowWidth
        - (config.horizontalPadding * 2);  // screen padding
    
    // Measure text height (lines 676-686)
    final textPainter = TextPainter(
      text: TextSpan(
        text: choiceText,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: 'Mynerve',
          height: 1.4,
          letterSpacing: 0.3,
        ),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: availableTextWidth);
    
    // Total button height
    // = max(textHeight, badgeHeight) + vertical padding + shadow
    final contentHeight = textPainter.height > badgeHeight ? textPainter.height : badgeHeight;
    final totalHeight = contentHeight + (containerPaddingV * 2) + shadowOffset;
    
    textPainter.dispose();
    
    return totalHeight;
  }

  /// Calculate total height needed for all choices
  /// MUST match PageViewWidget._buildChoices EXACTLY
  double _calculateTotalChoicesHeight(List<PageChoice> choices, double viewportWidth) {
    if (choices.isEmpty) return 0.0;
    
    double totalHeight = 0.0;
    
    // Header section (lines 552-579 in page_view_widget.dart)
    // Row: Icon container (28px) + SizedBox(10px) + Text (~20px) = ~58px
    totalHeight += 58.0;
    
    // SizedBox(height: 20) after header (line 579)
    totalHeight += 20.0;
    
    // Calculate actual height for each choice
    final choiceHeights = <double>[];
    for (int i = 0; i < choices.length; i++) {
      final height = _calculateChoiceHeight(choices[i].text, viewportWidth);
      choiceHeights.add(height);
      
      // Choice button height
      totalHeight += height;
      
      // Padding.only(bottom: 12) for each choice (line 585)
      totalHeight += 12.0;
    }
    
    print('   📦 Choice box breakdown:');
    print('      Header (icon + text + spacing): 78px');
    print('      ${choices.length} choices: ${choiceHeights.map((h) => h.toInt()).toList()}');
    print('      Spacing after each: 12px × ${choices.length}');
    print('      ✅ TOTAL: ${totalHeight.toInt()}px');
    
    return totalHeight;
  }

  /// Calculate available text height based on what elements are on the page
  double _calculateTextAreaHeight({
    required double viewportHeight,
    required double viewportWidth,
    required bool hasImage,
    required List<PageChoice> choices,
    String? debugPageId, // For logging
  }) {
    double fixedHeight = config.topPadding + config.bottomPadding + config.safetyBuffer;
    
    if (hasImage) {
      fixedHeight += config.imageHeight + config.imageSpacing;
    }
    
    if (choices.isNotEmpty) {
      // Dynamic height calculation based on actual choice text
      // Also add spacing before choices (16px in PageViewWidget)
      fixedHeight += 16.0; // SizedBox before choices
      fixedHeight += _calculateTotalChoicesHeight(choices, viewportWidth);
    }
    
    final availableHeight = (viewportHeight - fixedHeight).clamp(100.0, double.infinity);
    
    if (debugPageId != null) {
      print('   📏 [Page $debugPageId] Available for text: ${availableHeight.toInt()}px (viewport: ${viewportHeight.toInt()}, fixed: ${fixedHeight.toInt()})');
    }
    
    return availableHeight;
  }

  /// Calculate how many lines fit in available height
  int _calculateLinesPerPage(double availableHeight) {
    // Use ALL available space - no artificial reduction
    return (availableHeight / config.lineHeightPixels).floor().clamp(1, 100);
  }

  /// Find how much text fits in available space using TextPainter
  int _findTextThatFits(String text, int startIndex, double width, double maxHeight, {String? debugInfo}) {
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
        textAlign: TextAlign.justify,
      )..layout(maxWidth: width);
      final lines = painter.computeLineMetrics().length;
      painter.dispose();
      
      if (lines <= maxLines) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    
    // Verify the result and log details if requested
    if (debugInfo != null) {
      final finalText = text.substring(startIndex, low);
      final verifyPainter = TextPainter(
        text: TextSpan(text: finalText, style: config.textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.justify,
      )..layout(maxWidth: width);
      final actualLines = verifyPainter.computeLineMetrics().length;
      final actualHeight = verifyPainter.height;
      verifyPainter.dispose();
      
      print('   📝 [$debugInfo] Text fitting:');
      print('      Max lines allowed: $maxLines (from ${maxHeight.toInt()}px height)');
      print('      Actual lines used: $actualLines');
      print('      Calculated text height: ${actualHeight.toInt()}px');
      print('      Characters fitted: ${low - startIndex}');
      print('      Text preview: "${finalText.substring(0, finalText.length > 50 ? 50 : finalText.length)}..."');
    }
    
    return low;
  }

  /// Check if position i is a sentence end
  /// Handles: . ! ? ... and quotes after punctuation
  bool _isSentenceEnd(String text, int i) {
    if (i < 0 || i >= text.length) return false;
    final char = text[i];
    
    // At end of text
    if (i + 1 >= text.length) {
      return char == '.' || char == '!' || char == '?';
    }
    
    final next = text[i + 1];
    
    // Standard: . ! ? followed by space or newline
    if ((char == '.' || char == '!' || char == '?') && 
        (next == ' ' || next == '\n')) {
      // Avoid breaking on abbreviations like "z.B." or "Dr."
      if (char == '.' && i > 0) {
        final prev = text[i - 1];
        // Single letter before dot = likely abbreviation
        if (i >= 2 && text[i - 2] == ' ' && prev.toUpperCase() == prev) {
          return false; // Skip single capital letter abbreviations
        }
      }
      return true;
    }
    
    // Ellipsis: ... followed by space
    if (char == '.' && i >= 2 && 
        text[i - 1] == '.' && text[i - 2] == '.' &&
        (next == ' ' || next == '\n')) {
      return true;
    }
    
    // After closing quote: ." or !" or ?" or »" 
    if ((char == '"' || char == '»' || char == '"' || char == '\'') && 
        i > 0 && (next == ' ' || next == '\n')) {
      final prev = text[i - 1];
      if (prev == '.' || prev == '!' || prev == '?') return true;
    }
    
    return false;
  }

  /// Check if position i is a clause end (good secondary break point)
  bool _isClauseEnd(String text, int i) {
    if (i < 0 || i >= text.length - 1) return false;
    final char = text[i];
    final next = text[i + 1];
    
    // Semicolon or colon followed by space
    if ((char == ';' || char == ':') && next == ' ') return true;
    
    // En-dash or em-dash with spaces
    if ((char == '–' || char == '—') && next == ' ') return true;
    
    return false;
  }

  /// Find the BEST break point - NEVER breaks in the middle of a sentence
  /// Priority: Sentence end > Paragraph > Clause > Comma > Word > Hard cut
  int _findBestBreakPoint(String text, int startIndex, int endIndex) {
    // Minimum break point: at least 40% of the page should be filled
    final minBreak = startIndex + ((endIndex - startIndex) * 0.4).round();
    
    // 1. HIGHEST PRIORITY: Sentence end (. ! ? ...)
    for (int i = endIndex - 1; i >= minBreak; i--) {
      if (_isSentenceEnd(text, i)) {
        return i + 1;
      }
    }
    
    // 2. Paragraph break (newline)
    for (int i = endIndex - 1; i >= minBreak; i--) {
      if (text[i] == '\n') {
        return i + 1;
      }
    }
    
    // 3. Clause end (; : –)
    for (int i = endIndex - 1; i >= minBreak; i--) {
      if (_isClauseEnd(text, i)) {
        return i + 1;
      }
    }
    
    // 4. Comma (last resort before word boundary)
    for (int i = endIndex - 1; i >= minBreak; i--) {
      if (text[i] == ',' && i + 1 < text.length && text[i + 1] == ' ') {
        return i + 2; // After the space
      }
    }
    
    // 5. Word boundary (space)
    int wordEnd = endIndex;
    while (wordEnd > startIndex && text[wordEnd - 1] != ' ' && text[wordEnd - 1] != '\n') {
      wordEnd--;
    }
    if (wordEnd > minBreak) {
      return wordEnd;
    }
    
    // 6. Hard cut (should rarely happen - very long words)
    return endIndex;
  }

  /// Paginate text into pages that fit the viewport
  /// PRINCIPLE: Fill each page as much as possible, NEVER break mid-sentence
  List<String> _paginateText({
    required String text,
    required double viewportWidth,
    required double textAreaHeight,
    String? debugSceneId, // For logging specific scenes
  }) {
    if (text.trim().isEmpty) return [''];
    
    final textWidth = viewportWidth - (config.horizontalPadding * 2);
    final pages = <String>[];
    int startCharIndex = 0;
    int pageInScene = 1;
    
    while (startCharIndex < text.length) {
      // Find MAXIMUM text that fits visually
      final shouldDebug = debugSceneId != null;
      int endCharIndex = _findTextThatFits(
        text, 
        startCharIndex, 
        textWidth, 
        textAreaHeight,
        debugInfo: shouldDebug ? '$debugSceneId-P$pageInScene' : null,
      );
      
      // If we can fit ALL remaining text, do it - no break needed
      if (endCharIndex >= text.length) {
        final remaining = text.substring(startCharIndex).trim();
        if (remaining.isNotEmpty) {
          pages.add(remaining);
        }
        break;
      }
      
      // We need to break - use hierarchical break point search
      // This ensures we NEVER break in the middle of a sentence
      int breakPoint = _findBestBreakPoint(text, startCharIndex, endCharIndex);
      
      // Safety: ensure progress (should never happen with proper break logic)
      if (breakPoint <= startCharIndex) {
        breakPoint = (startCharIndex + 50).clamp(0, text.length);
      }
      
      final pageText = text.substring(startCharIndex, breakPoint).trim();
      if (pageText.isNotEmpty) {
        pages.add(pageText);
        pageInScene++;
      }
      startCharIndex = breakPoint;
      
      // Skip leading whitespace for next page
      while (startCharIndex < text.length && 
             (text[startCharIndex] == ' ' || text[startCharIndex] == '\n')) {
        startCharIndex++;
      }
    }
    
    return pages.isEmpty ? [''] : pages;
  }

  /// Analyze an Ink story and create all pages
  /// 
  /// KEY PRINCIPLE: For scenes with choices, calculate the LAST page first
  /// (where choices appear), then paginate the remaining text for earlier pages.
  /// 
  /// If [hyphenator] is provided, text will be hyphenated for optimal
  /// justified text layout using soft hyphens.
  Future<PagedBook> analyzeInkStory({
    required InkStory story,
    required String bookId,
    required double viewportWidth,
    required double viewportHeight,
    String? startKnot,
    HyphenatorService? hyphenator,
  }) async {
    final pages = <StoryPage>[];
    final sceneToPageIndex = <String, int>{};
    int pageId = 1;
    
    // Get knot order starting from startKnot
    final knotOrder = _getLinearKnotOrder(story, startKnot ?? story.startKnot);
    
    print('📐 [PageAnalyzer] Analyzing ${knotOrder.length} scenes');
    print('   Viewport: ${viewportWidth.toInt()}x${viewportHeight.toInt()}');
    
    int processedKnots = 0;
    for (final knotName in knotOrder) {
      final knot = story.knots[knotName];
      if (knot == null) continue;
      
      // Yield to event loop every 5 knots to allow UI updates
      processedKnots++;
      if (processedKnots % 5 == 0) {
        await Future.delayed(Duration.zero);
      }
      
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
      
      // Hyphenate text for optimal justified layout
      final sceneText = hyphenator?.isInitialized == true
          ? hyphenator!.hyphenateText(knot.content)
          : knot.content;
      
      // Convert choices (also hyphenate choice text)
      final choices = knot.choices.asMap().entries.map((e) => PageChoice(
        text: hyphenator?.isInitialized == true
            ? hyphenator!.hyphenateText(e.value.text)
            : e.value.text,
        targetSceneId: e.value.targetKnot,
        index: e.key,
      )).toList();
      
      final hasImage = imagePath != null;
      final hasChoices = choices.isNotEmpty;
      final canContinue = knot.divert != null;
      
      // Paginate using new "last page first" algorithm
      final textPages = _paginateSceneText(
        text: sceneText,
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
        hasImage: hasImage,
        choices: choices,
        debugSceneId: hasChoices ? knotName : null,
      );
      
      final totalPagesInScene = textPages.length;
      
      // Track quote state across pages within this scene
      bool currentQuoteState = false;
      
      // Create StoryPage objects
      for (int i = 0; i < textPages.length; i++) {
        final isLast = i == textPages.length - 1;
        final currentPageId = pageId;
        final pageText = textPages[i];
        
        // This page starts with the quote state from the previous page
        final startsInQuote = currentQuoteState;
        
        // Calculate quote state at the end of this page for the next page
        currentQuoteState = _endsWithOpenQuote(pageText);
        
        pages.add(StoryPage(
          id: pageId++,
          sceneId: knotName,
          pageInScene: i + 1,
          totalPagesInScene: totalPagesInScene,
          text: pageText,
          imagePath: isLast ? imagePath : null,
          choices: isLast ? choices : const [],
          isLastPageOfScene: isLast,
          canContinue: isLast ? canContinue : true,
          sceneTitle: i == 0 ? _formatSceneTitle(knotName) : null,
          startsInQuote: startsInQuote,
        ));
        
        // Log pages with choices for debugging
        if (isLast && choices.isNotEmpty) {
          print('   🎯 Page $currentPageId ($knotName): ${choices.length} choices, text: ${pageText.length} chars');
        }
      }
    }
    
    print('✅ [PageAnalyzer] Generated ${pages.length} total pages');
    
    return PagedBook(
      bookId: bookId,
      title: story.title,
      pages: pages,
      sceneToPageIndex: sceneToPageIndex,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
  }
  
  /// Paginate scene text using "last page first" algorithm
  /// 
  /// This ensures that the last page (with choices/image) is calculated first,
  /// then the remaining text is paginated for earlier pages.
  List<String> _paginateSceneText({
    required String text,
    required double viewportWidth,
    required double viewportHeight,
    required bool hasImage,
    required List<PageChoice> choices,
    String? debugSceneId,
  }) {
    if (text.trim().isEmpty) return [''];
    
    final textWidth = viewportWidth - (config.horizontalPadding * 2);
    final trimmedText = text.trim();
    
    // Calculate available text height for LAST page (with image/choices)
    final lastPageTextHeight = _calculateTextAreaHeight(
      viewportHeight: viewportHeight,
      viewportWidth: viewportWidth,
      hasImage: hasImage,
      choices: choices,
      debugPageId: debugSceneId != null ? '$debugSceneId-LAST' : null,
    );
    
    // Calculate available text height for REGULAR pages (no image/choices)
    final regularTextHeight = _calculateTextAreaHeight(
      viewportHeight: viewportHeight,
      viewportWidth: viewportWidth,
      hasImage: false,
      choices: const [],
    );
    
    // STEP 1: Find how much text fits on the LAST page
    // We work backwards: find the text that fits with choices/image
    final lastPageMaxChars = _findTextThatFitsFromEnd(
      trimmedText,
      textWidth,
      lastPageTextHeight,
    );
    
    // If ALL text fits on the last page, we're done
    if (lastPageMaxChars >= trimmedText.length) {
      if (debugSceneId != null) {
        print('   ✅ [$debugSceneId] All text fits on 1 page (${trimmedText.length} chars)');
      }
      return [trimmedText];
    }
    
    // STEP 2: Find a good break point for the last page
    // Start from end, find text that fits, then find sentence boundary
    final lastPageStartIndex = trimmedText.length - lastPageMaxChars;
    final lastPageBreakPoint = _findBestBreakPointForLastPage(trimmedText, lastPageStartIndex);
    
    // Extract last page text
    final lastPageText = trimmedText.substring(lastPageBreakPoint).trim();
    final remainingText = trimmedText.substring(0, lastPageBreakPoint).trim();
    
    if (debugSceneId != null) {
      print('   📄 [$debugSceneId] Split: ${remainingText.length} chars before, ${lastPageText.length} chars on last page');
    }
    
    // STEP 3: Paginate the remaining text for earlier pages (regular height)
    final earlierPages = <String>[];
    if (remainingText.isNotEmpty) {
      earlierPages.addAll(_paginateText(
        text: remainingText,
        viewportWidth: viewportWidth,
        textAreaHeight: regularTextHeight,
      ));
    }
    
    // Combine: earlier pages + last page
    return [...earlierPages, lastPageText];
  }
  
  /// Find how much text fits from the END of the text
  /// Returns the maximum number of characters that fit
  int _findTextThatFitsFromEnd(String text, double width, double maxHeight) {
    final maxLines = _calculateLinesPerPage(maxHeight);
    int low = 1;
    int high = text.length;
    
    // Binary search to find max characters that fit
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      final startIndex = text.length - mid;
      final testText = text.substring(startIndex);
      final painter = TextPainter(
        text: TextSpan(text: testText, style: config.textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.justify,
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
  
  /// Find the best break point for the last page
  /// Searches forward from the approximate start to find a sentence boundary
  int _findBestBreakPointForLastPage(String text, int approximateStart) {
    // Don't start too close to the beginning
    final minStart = (text.length * 0.3).round();
    final searchStart = approximateStart < minStart ? minStart : approximateStart;
    
    // Look for sentence end near the approximate start
    // Search forward up to 200 characters to find a good break
    for (int i = searchStart; i < text.length && i < searchStart + 200; i++) {
      if (_isSentenceEnd(text, i)) {
        // Skip any whitespace after the sentence
        int breakPoint = i + 1;
        while (breakPoint < text.length && 
               (text[breakPoint] == ' ' || text[breakPoint] == '\n')) {
          breakPoint++;
        }
        return breakPoint;
      }
    }
    
    // If no sentence end found, look for paragraph break
    for (int i = searchStart; i < text.length && i < searchStart + 200; i++) {
      if (text[i] == '\n') {
        return i + 1;
      }
    }
    
    // If no good break found, just use the approximate start
    // But ensure we're at a word boundary
    int wordStart = searchStart;
    while (wordStart < text.length && text[wordStart] != ' ' && text[wordStart] != '\n') {
      wordStart++;
    }
    while (wordStart < text.length && (text[wordStart] == ' ' || text[wordStart] == '\n')) {
      wordStart++;
    }
    
    return wordStart;
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
        viewportWidth: viewportWidth,
        hasImage: false,
        choices: const [],
      );
      
      // Paginate the chapter
      final textPages = _paginateText(
        text: chapter.content,
        viewportWidth: viewportWidth,
        textAreaHeight: textHeight,
      );
      
      final totalPagesInScene = textPages.length;
      
      // Track quote state across pages
      bool currentQuoteState = false;
      
      // Create StoryPage objects
      for (int i = 0; i < textPages.length; i++) {
        final isLast = i == textPages.length - 1;
        final isLastChapter = chapterIndex == chapters.length - 1;
        final pageText = textPages[i];
        
        final startsInQuote = currentQuoteState;
        currentQuoteState = _endsWithOpenQuote(pageText);
        
        pages.add(StoryPage(
          id: pageId++,
          sceneId: chapterId,
          pageInScene: i + 1,
          totalPagesInScene: totalPagesInScene,
          text: pageText,
          isLastPageOfScene: isLast,
          canContinue: !(isLast && isLastChapter),
          sceneTitle: i == 0 ? chapter.title : null,
          startsInQuote: startsInQuote,
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

