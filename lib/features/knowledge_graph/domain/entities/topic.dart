/// Topic Entity
/// Represents a topic or subtopic under a subject
class Topic {
  final String id;
  final String subjectId;
  final String? parentTopicId;
  final String name;
  final String? difficulty;
  final double importanceScore;

  const Topic({
    required this.id,
    required this.subjectId,
    this.parentTopicId,
    required this.name,
    this.difficulty,
    this.importanceScore = 0.5,
  });

  Topic copyWith({
    String? id,
    String? subjectId,
    String? parentTopicId,
    String? name,
    String? difficulty,
    double? importanceScore,
  }) {
    return Topic(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      parentTopicId: parentTopicId ?? this.parentTopicId,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      importanceScore: importanceScore ?? this.importanceScore,
    );
  }
}
