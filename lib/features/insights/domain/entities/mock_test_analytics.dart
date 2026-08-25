import 'package:equatable/equatable.dart';

/// Mock Test Analytics Entity
/// Represents mock test performance analytics
class MockTestAnalytics extends Equatable {
  final String userId;
  final List<MockTestAttempt> attempts;
  final SubjectMockTestStats subjectStats;
  final DateTime lastUpdated;

  const MockTestAnalytics({
    required this.userId,
    required this.attempts,
    required this.subjectStats,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, attempts, subjectStats, lastUpdated];
}

/// Mock Test Attempt
/// Individual mock test attempt data
class MockTestAttempt extends Equatable {
  final String attemptId;
  final String testType; // 'topic', 'subject', 'full'
  final String subjectId;
  final String subjectName;
  final DateTime date;
  final double score;
  final double accuracy;
  final int totalQuestions;
  final int correctAnswers;
  final int durationMinutes;
  final List<SectionScore> sectionScores;

  const MockTestAttempt({
    required this.attemptId,
    required this.testType,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.score,
    required this.accuracy,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.durationMinutes,
    required this.sectionScores,
  });

  @override
  List<Object?> get props => [
        attemptId,
        testType,
        subjectId,
        subjectName,
        date,
        score,
        accuracy,
        totalQuestions,
        correctAnswers,
        durationMinutes,
        sectionScores,
      ];
}

/// Section Score
/// Score breakdown by test section
class SectionScore extends Equatable {
  final String sectionName;
  final int questionsInSection;
  final int correctInSection;
  final double sectionAccuracy;

  const SectionScore({
    required this.sectionName,
    required this.questionsInSection,
    required this.correctInSection,
    required this.sectionAccuracy,
  });

  @override
  List<Object?> get props => [
        sectionName,
        questionsInSection,
        correctInSection,
        sectionAccuracy,
      ];
}

/// Subject Mock Test Stats
/// Aggregate mock test stats per subject
class SubjectMockTestStats extends Equatable {
  final String subjectId;
  final String subjectName;
  final int totalAttempts;
  final double averageScore;
  final double averageAccuracy;
  final double bestScore;
  final double worstScore;
  final ScoreTrend trend; // 'improving', 'stable', 'declining'

  const SubjectMockTestStats({
    required this.subjectId,
    required this.subjectName,
    required this.totalAttempts,
    required this.averageScore,
    required this.averageAccuracy,
    required this.bestScore,
    required this.worstScore,
    required this.trend,
  });

  @override
  List<Object?> get props => [
        subjectId,
        subjectName,
        totalAttempts,
        averageScore,
        averageAccuracy,
        bestScore,
        worstScore,
        trend,
      ];
}

/// Score Trend
/// Direction of score improvement
enum ScoreTrend {
  improving,
  stable,
  declining,
}
