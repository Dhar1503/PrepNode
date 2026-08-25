import 'planner_task.dart';

/// Daily Plan Entity
/// Represents the complete study plan for a specific day
class DailyPlan {
  final String id;
  final DateTime date;
  final List<PlannerTask> tasks;
  final String? supportiveMessage;
  final int totalStudyMinutes;
  final int completedMinutes;
  final int breakMinutes;
  final bool isRestDay;

  const DailyPlan({
    required this.id,
    required this.date,
    required this.tasks,
    this.supportiveMessage,
    required this.totalStudyMinutes,
    this.completedMinutes = 0,
    this.breakMinutes = 0,
    this.isRestDay = false,
  });

  DailyPlan copyWith({
    String? id,
    DateTime? date,
    List<PlannerTask>? tasks,
    String? supportiveMessage,
    int? totalStudyMinutes,
    int? completedMinutes,
    int? breakMinutes,
    bool? isRestDay,
  }) {
    return DailyPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      supportiveMessage: supportiveMessage ?? this.supportiveMessage,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      isRestDay: isRestDay ?? this.isRestDay,
    );
  }

  double get completionPercentage {
    if (totalStudyMinutes == 0) return 0.0;
    return completedMinutes / totalStudyMinutes;
  }

  int get pendingTasksCount {
    return tasks.where((task) => task.status == TaskStatus.pending).length;
  }

  int get completedTasksCount {
    return tasks.where((task) => task.status == TaskStatus.completed).length;
  }

  bool get isEmpty => tasks.isEmpty;
}
