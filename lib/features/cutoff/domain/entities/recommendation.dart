import 'package:equatable/equatable.dart';

/// Represents a personalized recommendation for improvement
class Recommendation extends Equatable {
  final String id;
  final String type; // 'study', 'practice', 'revision', 'focus'
  final String title;
  final String description;
  final String? topicId;
  final String? subjectId;
  final int priority; // 1-3, 1 = highest
  final String estimatedImpact;
  final String timeRequired;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.topicId,
    this.subjectId,
    required this.priority,
    required this.estimatedImpact,
    required this.timeRequired,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        topicId,
        subjectId,
        priority,
        estimatedImpact,
        timeRequired,
      ];
}
