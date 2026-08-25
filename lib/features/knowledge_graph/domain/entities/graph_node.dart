/// Graph Node Entity
/// Represents a node in the knowledge graph (Subject, Unit, Topic, Subtopic)
class GraphNode {
  final String id;
  final String name;
  final NodeType type;
  final MasteryState masteryState;
  final double masteryPercentage;
  final int? estimatedStudyMinutes;
  final DifficultyLevel? difficulty;
  final double? importanceScore;
  final String? parentId;

  const GraphNode({
    required this.id,
    required this.name,
    required this.type,
    required this.masteryState,
    required this.masteryPercentage,
    this.estimatedStudyMinutes,
    this.difficulty,
    this.importanceScore,
    this.parentId,
  });

  GraphNode copyWith({
    String? id,
    String? name,
    NodeType? type,
    MasteryState? masteryState,
    double? masteryPercentage,
    int? estimatedStudyMinutes,
    DifficultyLevel? difficulty,
    double? importanceScore,
    String? parentId,
  }) {
    return GraphNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      masteryState: masteryState ?? this.masteryState,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
      estimatedStudyMinutes: estimatedStudyMinutes ?? this.estimatedStudyMinutes,
      difficulty: difficulty ?? this.difficulty,
      importanceScore: importanceScore ?? this.importanceScore,
      parentId: parentId ?? this.parentId,
    );
  }
}

enum NodeType {
  exam,
  subject,
  unit,
  topic,
  subtopic,
}

enum MasteryState {
  notStarted,
  inProgress,
  mastered,
  needsRevision,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}
