import 'package:equatable/equatable.dart';

/// Represents an AI-generated recommendation
class AIRecommendation extends Equatable {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final String? targetModule; // e.g., 'planner', 'resources', 'knowledge_graph'
  final String? targetId;
  final double priority; // 0.0 to 1.0
  final String reason;
  final DateTime createdAt;

  const AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.targetModule,
    this.targetId,
    required this.priority,
    required this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetModule,
        targetId,
        priority,
        reason,
        createdAt,
      ];
}

enum RecommendationType {
  studyPlan,
  resource,
  topicFocus,
  practiceSession,
  revision,
  mockTest,
}
