import 'package:equatable/equatable.dart';

/// PYQ Performance Entity
/// Represents PYQ practice performance analytics
class PyqPerformance extends Equatable {
  final String userId;
  final List<SubjectPyqStats> subjectStats;
  final OverallPyqStats overallStats;
  final List<TopicPyqTrend> topicTrends;
  final DateTime lastUpdated;

  const PyqPerformance({
    required this.userId,
    required this.subjectStats,
    required this.overallStats,
    required this.topicTrends,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        subjectStats,
        overallStats,
        topicTrends,
        lastUpdated,
      ];
}

/// Subject PYQ Stats
/// PYQ performance per subject
class SubjectPyqStats extends Equatable {
  final String subjectId;
  final String subjectName;
  final int totalQuestionsAttempted;
  final int totalQuestionsCorrect;
  final double accuracy;
  final double averageTimePerQuestion; // in seconds
  final int topicsCovered;
  final int bookmarkedQuestions;

  const SubjectPyqStats({
    required this.subjectId,
    required this.subjectName,
    required this.totalQuestionsAttempted,
    required this.totalQuestionsCorrect,
    required this.accuracy,
    required this.averageTimePerQuestion,
    required this.topicsCovered,
    required this.bookmarkedQuestions,
  });

  @override
  List<Object?> get props => [
        subjectId,
        subjectName,
        totalQuestionsAttempted,
        totalQuestionsCorrect,
        accuracy,
        averageTimePerQuestion,
        topicsCovered,
        bookmarkedQuestions,
      ];
}

/// Overall PYQ Stats
/// Aggregate PYQ performance
class OverallPyqStats extends Equatable {
  final int totalQuestionsAttempted;
  final int totalQuestionsCorrect;
  final double overallAccuracy;
  final double totalTimeSpentMinutes;
  final int uniqueTopicsCovered;
  final int currentStreak; // consecutive days with practice

  const OverallPyqStats({
    required this.totalQuestionsAttempted,
    required this.totalQuestionsCorrect,
    required this.overallAccuracy,
    required this.totalTimeSpentMinutes,
    required this.uniqueTopicsCovered,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
        totalQuestionsAttempted,
        totalQuestionsCorrect,
        overallAccuracy,
        totalTimeSpentMinutes,
        uniqueTopicsCovered,
        currentStreak,
      ];
}

/// Topic PYQ Trend
/// PYQ performance trend for a specific topic over time
class TopicPyqTrend extends Equatable {
  final String topicId;
  final String topicName;
  final List<DailyPyqData> dailyData;

  const TopicPyqTrend({
    required this.topicId,
    required this.topicName,
    required this.dailyData,
  });

  @override
  List<Object?> get props => [topicId, topicName, dailyData];
}

/// Daily PYQ Data
/// PYQ practice data for a single day
class DailyPyqData extends Equatable {
  final DateTime date;
  final int questionsAttempted;
  final int questionsCorrect;
  final double accuracy;
  final int timeSpentMinutes;

  const DailyPyqData({
    required this.date,
    required this.questionsAttempted,
    required this.questionsCorrect,
    required this.accuracy,
    required this.timeSpentMinutes,
  });

  @override
  List<Object?> get props => [
        date,
        questionsAttempted,
        questionsCorrect,
        accuracy,
        timeSpentMinutes,
      ];
}
