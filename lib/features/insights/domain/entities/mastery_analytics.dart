import 'package:equatable/equatable.dart';

/// Mastery Analytics Entity
/// Represents topic-wise mastery levels across subjects
class MasteryAnalytics extends Equatable {
  final String userId;
  final List<TopicMastery> topicMasteries;
  final DateTime lastUpdated;

  const MasteryAnalytics({
    required this.userId,
    required this.topicMasteries,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, topicMasteries, lastUpdated];
}

/// Topic Mastery
/// Individual topic mastery state
class TopicMastery extends Equatable {
  final String topicId;
  final String topicName;
  final String subjectId;
  final String subjectName;
  final double masteryPercentage; // 0.0 to 1.0
  final MasteryLevel level;
  final int questionsAttempted;
  final int questionsCorrect;
  final int studyMinutes;
  final DateTime lastStudied;

  const TopicMastery({
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    required this.subjectName,
    required this.masteryPercentage,
    required this.level,
    required this.questionsAttempted,
    required this.questionsCorrect,
    required this.studyMinutes,
    required this.lastStudied,
  });

  @override
  List<Object?> get props => [
        topicId,
        topicName,
        subjectId,
        subjectName,
        masteryPercentage,
        level,
        questionsAttempted,
        questionsCorrect,
        studyMinutes,
        lastStudied,
      ];
}

/// Mastery Level
/// Categorical mastery state
enum MasteryLevel {
  notStarted,
  inProgress,
  building,
  mastered,
}
