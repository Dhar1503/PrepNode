import 'package:equatable/equatable.dart';

/// Weak Area Entity
/// Represents areas needing improvement with recommendations
class WeakArea extends Equatable {
  final String userId;
  final List<WeakTopic> weakTopics;
  final List<Recommendation> recommendations;
  final DateTime lastUpdated;

  const WeakArea({
    required this.userId,
    required this.weakTopics,
    required this.recommendations,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, weakTopics, recommendations, lastUpdated];
}

/// Weak Topic
/// Topic identified as needing improvement
class WeakTopic extends Equatable {
  final String topicId;
  final String topicName;
  final String subjectId;
  final String subjectName;
  final double currentAccuracy;
  final double targetAccuracy;
  final int attempts;
  final WeaknessSeverity severity;
  final List<String> prerequisiteTopics; // topics that might help

  const WeakTopic({
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    required this.subjectName,
    required this.currentAccuracy,
    required this.targetAccuracy,
    required this.attempts,
    required this.severity,
    required this.prerequisiteTopics,
  });

  @override
  List<Object?> get props => [
        topicId,
        topicName,
        subjectId,
        subjectName,
        currentAccuracy,
        targetAccuracy,
        attempts,
        severity,
        prerequisiteTopics,
      ];
}

/// Weakness Severity
/// Severity level of weakness
enum WeaknessSeverity {
  mild,
  moderate,
  significant,
}

/// Recommendation
/// Personalized recommendation for improvement
class Recommendation extends Equatable {
  final String id;
  final String type; // 'revision', 'practice', 'learn', 'rest'
  final String title;
  final String description;
  final String reason; // "Why this?" explanation
  final String? topicId;
  final String? subjectId;
  final int priority; // 1-10, higher is more urgent
  final DateTime createdAt;
  final bool isCompleted;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    this.topicId,
    this.subjectId,
    required this.priority,
    required this.createdAt,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        reason,
        topicId,
        subjectId,
        priority,
        createdAt,
        isCompleted,
  ];
}
