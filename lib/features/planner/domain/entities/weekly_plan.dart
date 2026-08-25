import 'daily_plan.dart';

/// Weekly Plan Entity
/// Represents the study plan for a week (7 days)
class WeeklyPlan {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<DateTime, DailyPlan> dailyPlans;
  final int totalStudyMinutes;
  final int completedMinutes;
  final int totalTasks;
  final int completedTasks;

  const WeeklyPlan({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyPlans,
    required this.totalStudyMinutes,
    this.completedMinutes = 0,
    required this.totalTasks,
    this.completedTasks = 0,
  });

  WeeklyPlan copyWith({
    String? id,
    DateTime? weekStart,
    DateTime? weekEnd,
    Map<DateTime, DailyPlan>? dailyPlans,
    int? totalStudyMinutes,
    int? completedMinutes,
    int? totalTasks,
    int? completedTasks,
  }) {
    return WeeklyPlan(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  double get completionPercentage {
    if (totalStudyMinutes == 0) return 0.0;
    return completedMinutes / totalStudyMinutes;
  }

  DailyPlan? getPlanForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return dailyPlans[normalizedDate];
  }

  List<DailyPlan> get plans => dailyPlans.values.toList();
}
