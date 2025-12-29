import 'choice.dart';

/// Represents a single page/chapter in the story
/// This is a node in the story graph
class StoryPage {
  final String id;
  final String title;
  final String content;
  final List<Choice> choices;
  final int displayOrder; // For sequential navigation
  final bool isPlaceholder;

  const StoryPage({
    required this.id,
    required this.title,
    required this.content,
    this.choices = const [],
    required this.displayOrder,
    this.isPlaceholder = false,
  });

  /// Check if this page has branching choices
  bool get hasBranching => choices.isNotEmpty;

  /// Check if this is a linear page (no branching)
  bool get isLinear => choices.isEmpty;

  StoryPage copyWith({
    String? id,
    String? title,
    String? content,
    List<Choice>? choices,
    int? displayOrder,
    bool? isPlaceholder,
  }) {
    return StoryPage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      choices: choices ?? this.choices,
      displayOrder: displayOrder ?? this.displayOrder,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryPage &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.displayOrder == displayOrder &&
        other.isPlaceholder == isPlaceholder;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, content, displayOrder, isPlaceholder);
  }
}


