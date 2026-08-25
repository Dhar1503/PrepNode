import 'package:equatable/equatable.dart';

/// Represents an AI-generated insight about user performance or learning
class AIInsight extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String insight;
  final InsightCategory category;
  final List<String> relatedTopics;
  final List<String> suggestedActions;
  final DateTime createdAt;
  final bool isActioned;

  const AIInsight({
    required this.id,
    required this.userId,
    required this.title,
    required this.insight,
    required this.category,
    required this.relatedTopics,
    required this.suggestedActions,
    required this.createdAt,
    this.isActioned = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        insight,
        category,
        relatedTopics,
        suggestedActions,
        createdAt,
        isActioned,
      ];
}

enum InsightCategory {
  strength,
  weakness,
  trend,
  opportunity,
  warning,
}
