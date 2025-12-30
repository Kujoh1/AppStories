import 'package:flutter/services.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:archive/archive.dart';
import '../../domain/models/chapter_info.dart';

/// Parsed story element types
enum StoryElementType {
  text,       // Regular text
  image,      // [IMAGE:filename.png]
  layout,     // [LAYOUT:centered|fullwidth|etc]
  effect,     // [EFFECT:shake|glow|fade|etc]
  choice,     // [CHOICE:Option A|Option B|Option C]
  audio,      // [AUDIO:filename.mp3]
  pause,      // [PAUSE:2000] - pause in ms
  style,      // [STYLE:bold|italic|large|etc]
  chapter,    // [CHAPTER:Title]
  note,       // [NOTE:author note - not shown to reader]
  custom,     // For future extensions
}

/// A single parsed element from the story
class StoryElement {
  final StoryElementType type;
  final String content;
  final Map<String, String> attributes;
  
  const StoryElement({
    required this.type,
    required this.content,
    this.attributes = const {},
  });
  
  @override
  String toString() => 'StoryElement($type: $content, $attributes)';
}

/// Result of parsing a story document
class ParsedStory {
  final List<StoryElement> elements;
  final String rawText;
  
  const ParsedStory({
    required this.elements,
    required this.rawText,
  });
  
  /// Get only the text content (for display)
  String get displayText {
    return elements
        .where((e) => e.type == StoryElementType.text)
        .map((e) => e.content)
        .join('');
  }
  
  /// Get all elements of a specific type
  List<StoryElement> getElementsByType(StoryElementType type) {
    return elements.where((e) => e.type == type).toList();
  }
}

/// Service to parse Word documents and extract tagged content
class StoryParser {
  
  // Tag pattern: [TYPE:content] or [TYPE:content|attr1=value1|attr2=value2]
  static final RegExp _tagPattern = RegExp(r'\[([A-Z]+):([^\]]+)\]');
  
  /// Load and parse a .docx file from assets
  static Future<ParsedStory> loadFromAsset(String assetPath) async {
    try {
      // Load the docx file as bytes
      final ByteData data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      
      // Try docx_to_text first
      String rawText = docxToText(bytes);
      
      // If it returns XML (web fallback issue), parse manually
      if (rawText.contains('<?xml') || rawText.contains('<w:document')) {
        rawText = _extractTextFromDocx(bytes);
      }
      
      // Parse tags
      final elements = _parseText(rawText);
      
      return ParsedStory(
        elements: elements,
        rawText: rawText,
      );
    } catch (e) {
      throw Exception('Failed to load story from $assetPath: $e');
    }
  }
  
  /// Manually extract text from docx (ZIP containing XML)
  static String _extractTextFromDocx(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Find document.xml
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          final content = String.fromCharCodes(file.content as List<int>);
          return _parseWordXml(content);
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  
  /// Parse Word XML and extract text content
  static String _parseWordXml(String xml) {
    final buffer = StringBuffer();
    
    // Extract all <w:t> text elements
    final textPattern = RegExp(r'<w:t[^>]*>([^<]*)</w:t>');
    final paragraphEnd = RegExp(r'</w:p>');
    
    int lastEnd = 0;
    
    for (final match in textPattern.allMatches(xml)) {
      // Check if there was a paragraph break before this text
      final beforeText = xml.substring(lastEnd, match.start);
      if (paragraphEnd.hasMatch(beforeText) && buffer.isNotEmpty) {
        buffer.writeln();
      }
      
      buffer.write(match.group(1) ?? '');
      lastEnd = match.end;
    }
    
    return buffer.toString().trim();
  }
  
  /// Parse text and extract tags
  static List<StoryElement> _parseText(String text) {
    final elements = <StoryElement>[];
    int lastEnd = 0;
    
    for (final match in _tagPattern.allMatches(text)) {
      // Add text before this tag
      if (match.start > lastEnd) {
        final textBefore = text.substring(lastEnd, match.start);
        if (textBefore.trim().isNotEmpty) {
          elements.add(StoryElement(
            type: StoryElementType.text,
            content: textBefore,
          ));
        }
      }
      
      // Parse the tag
      final tagType = match.group(1)!;
      final tagContent = match.group(2)!;
      
      final element = _parseTag(tagType, tagContent);
      if (element != null) {
        elements.add(element);
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining text after last tag
    if (lastEnd < text.length) {
      final remainingText = text.substring(lastEnd);
      if (remainingText.trim().isNotEmpty) {
        elements.add(StoryElement(
          type: StoryElementType.text,
          content: remainingText,
        ));
      }
    }
    
    // If no tags found, return the whole text
    if (elements.isEmpty && text.trim().isNotEmpty) {
      elements.add(StoryElement(
        type: StoryElementType.text,
        content: text,
      ));
    }
    
    return elements;
  }
  
  /// Parse a single tag
  static StoryElement? _parseTag(String type, String content) {
    // Parse content and attributes: content|attr1=val1|attr2=val2
    final parts = content.split('|');
    final mainContent = parts.first.trim();
    
    final attributes = <String, String>{};
    for (int i = 1; i < parts.length; i++) {
      final attrParts = parts[i].split('=');
      if (attrParts.length == 2) {
        attributes[attrParts[0].trim()] = attrParts[1].trim();
      } else {
        // Attribute without value (flag)
        attributes[parts[i].trim()] = 'true';
      }
    }
    
    final elementType = _typeFromString(type);
    
    return StoryElement(
      type: elementType,
      content: mainContent,
      attributes: attributes,
    );
  }
  
  /// Convert string to StoryElementType
  static StoryElementType _typeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'IMAGE':
        return StoryElementType.image;
      case 'LAYOUT':
        return StoryElementType.layout;
      case 'EFFECT':
        return StoryElementType.effect;
      case 'CHOICE':
        return StoryElementType.choice;
      case 'AUDIO':
        return StoryElementType.audio;
      case 'PAUSE':
        return StoryElementType.pause;
      case 'STYLE':
        return StoryElementType.style;
      case 'CHAPTER':
        return StoryElementType.chapter;
      case 'NOTE':
        return StoryElementType.note;
      default:
        return StoryElementType.custom;
    }
  }
  
  /// Pattern for detecting chapter headings in text
  static final RegExp _chapterPattern = RegExp(
    r'^(Kapitel\s+\d+\s*[:\-–—]?\s*.*)$|^(Kapitel\s+\w+\s*[:\-–—]?\s*.*)$|^(Chapter\s+\d+\s*[:\-–—]?\s*.*)$',
    multiLine: true,
    caseSensitive: false,
  );
  
  /// Extract chapter index (structure only) from raw text - FAST
  /// Returns list of ChapterInfo with positions, without loading content
  static List<ChapterInfo> extractChapterIndex(String rawText) {
    final chapters = <ChapterInfo>[];
    
    final matches = _chapterPattern.allMatches(rawText).toList();
    
    if (matches.isEmpty) {
      // No chapter markers found - treat entire text as one chapter
      chapters.add(ChapterInfo(
        index: 0,
        title: 'Kapitel 1',
        startCharIndex: 0,
        endCharIndex: rawText.length,
      ));
      return chapters;
    }
    
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final title = match.group(0)?.trim() ?? 'Kapitel ${i + 1}';
      final startIndex = match.start;
      
      // End is either start of next chapter or end of text
      final endIndex = (i + 1 < matches.length) 
          ? matches[i + 1].start 
          : rawText.length;
      
      chapters.add(ChapterInfo(
        index: i,
        title: title,
        startCharIndex: startIndex,
        endCharIndex: endIndex,
      ));
    }
    
    return chapters;
  }
  
  /// Extract a single chapter's content by index
  static ChapterContent? extractChapter(String rawText, int chapterIndex, List<ChapterInfo> chapters) {
    if (chapterIndex < 0 || chapterIndex >= chapters.length) return null;
    
    final chapter = chapters[chapterIndex];
    final content = rawText.substring(chapter.startCharIndex, chapter.endCharIndex);
    
    return ChapterContent(
      chapterIndex: chapterIndex,
      title: chapter.title,
      content: content,
    );
  }
  
  /// Quick load - only get raw text without full parsing
  static Future<String> loadRawTextFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      
      String rawText = docxToText(bytes);
      
      if (rawText.contains('<?xml') || rawText.contains('<w:document')) {
        rawText = _extractTextFromDocx(bytes);
      }
      
      return rawText;
    } catch (e) {
      throw Exception('Failed to load from $assetPath: $e');
    }
  }
}
