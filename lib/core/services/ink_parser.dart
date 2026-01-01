import 'dart:convert';
import 'package:flutter/services.dart';

/// Asset configuration for a story (backgrounds, images, sounds)
class StoryAssets {
  final Map<String, String> backgrounds;
  final Map<String, String> images;
  final Map<String, String> sounds;
  final Map<String, String> moods;
  
  const StoryAssets({
    this.backgrounds = const {},
    this.images = const {},
    this.sounds = const {},
    this.moods = const {},
  });
  
  String? getBackground(String key) => backgrounds[key];
  String? getImage(String key) => images[key];
  String? getSound(String key) => sounds[key];
  String? getMood(String key) => moods[key];
  
  static Future<StoryAssets> loadFromAsset(String path) async {
    try {
      print('🎨 [StoryAssets] Loading from: $path');
      final content = await rootBundle.loadString(path);
      final json = jsonDecode(content) as Map<String, dynamic>;
      
      final images = Map<String, String>.from(json['IMG'] ?? {});
      print('🎨 [StoryAssets] Loaded ${images.length} images: ${images.keys.take(5).join(", ")}...');
      
      return StoryAssets(
        backgrounds: Map<String, String>.from(json['BG'] ?? {}),
        images: images,
        sounds: Map<String, String>.from(json['SFX'] ?? {}),
        moods: Map<String, String>.from(json['MOOD'] ?? {}),
      );
    } catch (e) {
      print('❌ [StoryAssets] Failed to load from $path: $e');
      // Return empty assets if file doesn't exist
      return const StoryAssets();
    }
  }
}

/// Represents a single choice in the story
class InkChoice {
  final String text;
  final String targetKnot;
  
  const InkChoice({
    required this.text,
    required this.targetKnot,
  });
}

/// Represents a knot (section) in the story
class InkKnot {
  final String name;
  final List<String> tags;
  final String content;
  final List<InkChoice> choices;
  final String? divert; // Auto-divert to next knot
  
  const InkKnot({
    required this.name,
    this.tags = const [],
    required this.content,
    this.choices = const [],
    this.divert,
  });
}

/// Parsed Ink story structure
class InkStory {
  final String title;
  final String author;
  final Map<String, int> variables;
  final Map<String, InkKnot> knots;
  final String startKnot;
  final StoryAssets assets;
  
  const InkStory({
    required this.title,
    this.author = 'Unbekannt',
    this.variables = const {},
    required this.knots,
    required this.startKnot,
    this.assets = const StoryAssets(),
  });
  
  int get knotCount => knots.length;
  
  InkKnot? getKnot(String name) => knots[name];
}

/// Represents a choice made by the user
class UserChoice {
  final String fromKnot;
  final String toKnot;
  final String choiceText;
  final int choiceIndex;
  final DateTime timestamp;

  const UserChoice({
    required this.fromKnot,
    required this.toKnot,
    required this.choiceText,
    required this.choiceIndex,
    required this.timestamp,
  });
}

/// Runtime state for playing an Ink story
class InkRuntime {
  final InkStory story;
  final Map<String, int> variables;
  String currentKnotName;
  final List<String> history = []; // Stores previous knot names
  final List<UserChoice> choiceHistory = []; // Stores user choices
  
  InkRuntime(this.story) 
      : variables = Map.from(story.variables),
        currentKnotName = story.startKnot;
  
  InkKnot? get currentKnot => story.getKnot(currentKnotName);
  
  /// Check if we can go back to a previous scene
  bool get canGoBack => history.isNotEmpty;

  /// Go back to the previous scene
  void goBack() {
    if (canGoBack) {
      currentKnotName = history.removeLast();
    }
  }

  /// Get current content with variable substitution
  String get currentContent {
    final knot = currentKnot;
    if (knot == null) return '';
    return _substituteVariables(knot.content);
  }
  
  /// Get current choices
  List<InkChoice> get currentChoices => currentKnot?.choices ?? [];
  
  /// Get current tags
  List<String> get currentTags => currentKnot?.tags ?? [];
  
  /// Get current background image path (from #BG: tag)
  String? get currentBackground {
    for (final tag in currentTags) {
      if (tag.startsWith('BG:')) {
        final key = tag.substring(3);
        return story.assets.getBackground(key);
      }
    }
    return null;
  }
  
  /// Get current overlay image path (from #IMG: tag)
  String? get currentImage {
    for (final tag in currentTags) {
      if (tag.startsWith('IMG:')) {
        final key = tag.substring(4);
        return story.assets.getImage(key);
      }
    }
    return null;
  }
  
  /// Get current mood tags (from #MOOD: tag)
  List<String> get currentMoods {
    for (final tag in currentTags) {
      if (tag.startsWith('MOOD:')) {
        return tag.substring(5).split(',').map((s) => s.trim()).toList();
      }
    }
    return [];
  }
  
  /// Get current sound effects (from #SFX: tag)
  List<String> get currentSfx {
    for (final tag in currentTags) {
      if (tag.startsWith('SFX:')) {
        return tag.substring(4).split(',').map((s) => s.trim()).toList();
      }
    }
    return [];
  }
  
  /// Check if story can continue (has divert or choices)
  bool get canContinue => currentKnot?.divert != null;
  
  /// Check if story has choices
  bool get hasChoices => currentChoices.isNotEmpty;
  
  /// Continue to next knot (follow divert)
  void continueStory() {
    final divert = currentKnot?.divert;
    if (divert != null) {
      history.add(currentKnotName); // Save current to history
      currentKnotName = divert;
    }
  }
  
  /// Make a choice and go to target knot
  void makeChoice(int choiceIndex) {
    if (choiceIndex >= 0 && choiceIndex < currentChoices.length) {
      final choice = currentChoices[choiceIndex];
      
      // Record the choice
      choiceHistory.add(UserChoice(
        fromKnot: currentKnotName,
        toKnot: choice.targetKnot,
        choiceText: choice.text,
        choiceIndex: choiceIndex,
        timestamp: DateTime.now(),
      ));
      
      history.add(currentKnotName); // Save current to history
      currentKnotName = choice.targetKnot;
    }
  }
  
  /// Reset to beginning
  void reset() {
    currentKnotName = story.startKnot;
    variables.clear();
    variables.addAll(story.variables);
    history.clear();
    choiceHistory.clear();
  }

  /// Navigate directly to a specific knot
  void navigateToKnot(String knotName) {
    if (story.knots.containsKey(knotName)) {
      history.add(currentKnotName); // Save current to history
      currentKnotName = knotName;
    }
  }

  /// Get the choice that led to a specific knot
  UserChoice? getChoiceToKnot(String knotName) {
    return choiceHistory.cast<UserChoice?>().firstWhere(
      (choice) => choice?.toKnot == knotName,
      orElse: () => null,
    );
  }

  /// Get the choice that was made from a specific knot
  UserChoice? getChoiceFromKnot(String knotName) {
    return choiceHistory.cast<UserChoice?>().firstWhere(
      (choice) => choice?.fromKnot == knotName,
      orElse: () => null,
    );
  }

  /// Check if a knot was visited via user choice
  bool wasKnotVisitedByChoice(String knotName) {
    return choiceHistory.any((choice) => choice.toKnot == knotName);
  }
  
  String _substituteVariables(String text) {
    var result = text;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return result;
  }
}

/// Parser for Ink story format
class InkParser {
  // Patterns for parsing
  static final _knotPattern = RegExp(r'^===\s*(\w+)\s*===$', multiLine: true);
  static final _choicePattern = RegExp(r'^\s*\*\s*\[([^\]]+)\]\s*->\s*(\w+)\s*$', multiLine: true);
  static final _divertPattern = RegExp(r'^\s*->\s*(\w+)\s*$', multiLine: true);
  static final _tagPattern = RegExp(r'^#(\w+):(.+)$', multiLine: true);
  static final _variablePattern = RegExp(r'^VAR\s+(\w+)\s*=\s*(\d+|true|false|"[^"]*")');
  
  /// Load and parse an Ink story from assets
  static Future<InkStory> loadFromAsset(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    
    // Try to load associated assets config
    final assetsPath = assetPath.replaceAll('.md', '_assets.json').replaceAll('.ink', '_assets.json');
    final assets = await StoryAssets.loadFromAsset(assetsPath);
    
    return parse(content, assetPath, assets: assets);
  }
  
  /// Parse Ink content
  static InkStory parse(String content, String sourcePath, {StoryAssets assets = const StoryAssets()}) {
    final variables = <String, int>{};
    final knots = <String, InkKnot>{};
    String? startKnot;
    String title = 'Unbekannte Geschichte';
    String author = 'Unbekannt';
    
    // Extract title from first comment
    final titleMatch = RegExp(r'//.*?—\s*(.+?)\s*\(').firstMatch(content);
    if (titleMatch != null) {
      title = titleMatch.group(1)?.trim() ?? title;
    }
    
    // Parse global variables
    for (final match in _variablePattern.allMatches(content)) {
      final name = match.group(1)!;
      final valueStr = match.group(2)!;
      if (valueStr == 'true') {
        variables[name] = 1;
      } else if (valueStr == 'false') {
        variables[name] = 0;
      } else if (valueStr.startsWith('"')) {
        // String variable - skip for now
      } else {
        variables[name] = int.tryParse(valueStr) ?? 0;
      }
    }
    
    // Find starting divert
    final startMatch = RegExp(r'^->\s*(\w+)', multiLine: true).firstMatch(content);
    if (startMatch != null) {
      startKnot = startMatch.group(1);
    }
    
    // Find all knots
    final knotMatches = _knotPattern.allMatches(content).toList();
    
    for (int i = 0; i < knotMatches.length; i++) {
      final knotMatch = knotMatches[i];
      final knotName = knotMatch.group(1)!;
      
      // Get content until next knot or end
      final startIndex = knotMatch.end;
      final endIndex = (i + 1 < knotMatches.length) 
          ? knotMatches[i + 1].start 
          : content.length;
      
      final knotContent = content.substring(startIndex, endIndex).trim();
      
      // Parse this knot
      var knot = _parseKnot(knotName, knotContent);

      // UX guarantee:
      // If a knot has no choices and no explicit divert, auto-divert to the next knot in file order.
      // This ensures "Weiter" exists on non-choice pages (unless this is the last knot).
      if (knot.choices.isEmpty && knot.divert == null && i + 1 < knotMatches.length) {
        final nextKnotName = knotMatches[i + 1].group(1)!;
        knot = InkKnot(
          name: knot.name,
          tags: knot.tags,
          content: knot.content,
          choices: knot.choices,
          divert: nextKnotName,
        );
      }

      knots[knotName] = knot;
      
      // Set first knot as start if not already set
      startKnot ??= knotName;
    }
    
    return InkStory(
      title: title,
      author: author,
      variables: variables,
      knots: knots,
      startKnot: startKnot ?? 'start',
      assets: assets,
    );
  }
  
  static InkKnot _parseKnot(String name, String content) {
    final tags = <String>[];
    final choices = <InkChoice>[];
    String? divert;
    final textLines = <String>[];
    
    final lines = content.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip empty lines and comments
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('//')) continue;
      
      // Parse tags
      final tagMatch = _tagPattern.firstMatch(trimmed);
      if (tagMatch != null) {
        tags.add('${tagMatch.group(1)}:${tagMatch.group(2)}');
        continue;
      }
      
      // Parse choices
      final choiceMatch = _choicePattern.firstMatch(trimmed);
      if (choiceMatch != null) {
        choices.add(InkChoice(
          text: choiceMatch.group(1)!,
          targetKnot: choiceMatch.group(2)!,
        ));
        continue;
      }
      
      // Parse divert
      final divertMatch = _divertPattern.firstMatch(trimmed);
      if (divertMatch != null) {
        divert = divertMatch.group(1);
        continue;
      }
      
      // Skip variable changes for now (handled in runtime)
      if (trimmed.startsWith('~')) continue;
      
      // Regular text
      textLines.add(trimmed);
    }
    
    return InkKnot(
      name: name,
      tags: tags,
      content: textLines.join('\n'),
      choices: choices,
      divert: divert,
    );
  }
  
  /// Quick scan to get story metadata without full parse
  static Future<({String title, String author, int knotCount})> getMetadata(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    
    // Extract title
    final titleMatch = RegExp(r'//.*?—\s*(.+?)\s*\(').firstMatch(content);
    final title = titleMatch?.group(1)?.trim() ?? 'Unbekannte Geschichte';
    
    // Count knots
    final knotCount = _knotPattern.allMatches(content).length;
    
    return (title: title, author: 'Unbekannt', knotCount: knotCount);
  }
}

