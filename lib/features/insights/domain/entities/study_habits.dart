import 'package:equatable/equatable.dart';

/// Study Habits Entity
/// Represents study time and consistency analytics
class StudyHabits extends Equatable {
  final String userId;
  final List<DailyStudyData> dailyData;
  final WeeklyStudyStats weeklyStats;
  final SubjectTimeDistribution subjectDistribution;
  final DateTime lastUpdated;

  const StudyHabits({
    required this.userId,
    required this.dailyData,
    required this.weeklyStats,
    required this.subjectDistribution,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        dailyData,
        weeklyStats,
        subjectDistribution,
        lastUpdated,
      ];
}

/// Daily Study Data
/// Study data for a single day
class DailyStudyData extends Equatable {
  final DateTime date;
  final int totalStudyMinutes;
  final Map<String, int> subjectMinutes; // subjectId -> minutes
  final int topicsCompleted;
  final int pyqsAttempted;
  final bool metDailyGoal;

  const DailyStudyData({
    required this.date,
    required this.totalStudyMinutes,
    required this.subjectMinutes,
    required this.topicsCompleted,
    required this.pyqsAttempted,
    required this.metDailyGoal,
  });

  @override
  List<Object?> get props => [
        date,
        totalStudyMinutes,
        subjectMinutes,
        topicsCompleted,
        pyqsAttempted,
        metDailyGoal,
      ];
}

/// Weekly Study Stats
/// Aggregate study statistics for a week
class WeeklyStudyStats extends Equatable {
  final int totalStudyMinutes;
  final int averageDailyMinutes;
  final int activeStudyDays;
  final int currentStreak; // consecutive days with study
  final int longestStreak;
  final double goalCompletionRate; // percentage of daily goals met

  const WeeklyStudyStats({
    required this.totalStudyMinutes,
    required this.averageDailyMinutes,
    required this.activeStudyDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.goalCompletionRate,
  });

  @override
  List<Object?> get props => [
        totalStudyMinutes,
        averageDailyMinutes,
        activeStudyDays,
        currentStreak,
        longestStreak,
        goalCompletionRate,
      ];
}

/// Subject Time Distribution
/// Time spent per subject
class SubjectTimeDistribution extends Equatable {
  final List<SubjectTimeEntry> entries;

  const SubjectTimeDistribution({
    required this.entries,
  });

  @override
  List<Object?> get props => [entries];
}

/// Subject Time Entry
/// Time spent on a specific subject
class SubjectTimeEntry extends Equatable {
  final String subjectId;
  final String subjectName;
  final int totalMinutes;
  final double percentageOfTotal;

  const SubjectTimeEntry({
    required this.subjectId,
    required this.subjectName,
    required this.totalMinutes,
    required this.percentageOfTotal,
  });

  @override
  List<Object?> get props => [
        subjectId,
        subjectName,
        totalMinutes,
        percentageOfTotal,
  ];
}
