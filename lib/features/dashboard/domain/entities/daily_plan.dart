import 'daily_task.dart';

/// Daily Plan Entity
/// Represents the user's study plan for a specific day
class DailyPlan {
  final String date;
  final List<DailyTask> tasks;
  final String? supportiveMessage;

  const DailyPlan({
    required this.date,
    required this.tasks,
    this.supportiveMessage,
  });

  DailyPlan copyWith({
    String? date,
    List<DailyTask>? tasks,
    String? supportiveMessage,
  }) {
    return DailyPlan(
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      supportiveMessage: supportiveMessage ?? this.supportiveMessage,
    );
  }

  int get completedTasks => tasks.where((t) => t.status == TaskStatus.completed).length;
  int get totalTasks => tasks.length;
  double get completionPercentage => totalTasks > 0 ? completedTasks / totalTasks : 0;
  bool get isEmpty => tasks.isEmpty;
}
