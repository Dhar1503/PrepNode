/// Planner Task Entity
/// Represents a single task in the study plan
class PlannerTask {
  final String id;
  final String topicId;
  final String title;
  final int durationMinutes;
  final String reason;
  final TaskType type;
  final TaskStatus status;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final int? order;
  final bool isBreak;

  const PlannerTask({
    required this.id,
    required this.topicId,
    required this.title,
    required this.durationMinutes,
    required this.reason,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.completedAt,
    this.order,
    this.isBreak = false,
  });

  PlannerTask copyWith({
    String? id,
    String? topicId,
    String? title,
    int? durationMinutes,
    String? reason,
    TaskType? type,
    TaskStatus? status,
    DateTime? scheduledDate,
    DateTime? completedAt,
    int? order,
    bool? isBreak,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
      isBreak: isBreak ?? this.isBreak,
    );
  }

  bool get isCompleted => status == TaskStatus.completed;
  bool get isSkipped => status == TaskStatus.skipped;
  bool get isPending => status == TaskStatus.pending;
}

enum TaskType {
  learn,
  pyq,
  revision,
  break_,
  mockTest,
}

enum TaskStatus {
  pending,
  completed,
  skipped,
  inProgress,
}
