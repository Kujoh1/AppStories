/// Represents a choice/decision point in the story
/// that leads to a different page/branch
class Choice {
  final String id;
  final String text;
  final String nextPageId;
  final String? description;

  const Choice({
    required this.id,
    required this.text,
    required this.nextPageId,
    this.description,
  });

  Choice copyWith({
    String? id,
    String? text,
    String? nextPageId,
    String? description,
  }) {
    return Choice(
      id: id ?? this.id,
      text: text ?? this.text,
      nextPageId: nextPageId ?? this.nextPageId,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Choice &&
        other.id == id &&
        other.text == text &&
        other.nextPageId == nextPageId &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, nextPageId, description);
  }
}


