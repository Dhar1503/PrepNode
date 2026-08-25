/// Daily Task Entity
/// Represents a single task in the user's daily study plan
class DailyTask {
  final String id;
  final String topicName;
  final int durationMinutes;
  final String reason;
  final TaskStatus status;
  final TaskType type;

  const DailyTask({
    required this.id,
    required this.topicName,
    required this.durationMinutes,
    required this.reason,
    required this.status,
    required this.type,
  });

  DailyTask copyWith({
    String? id,
    String? topicName,
    int? durationMinutes,
    String? reason,
    TaskStatus? status,
    TaskType? type,
  }) {
    return DailyTask(
      id: id ?? this.id,
      topicName: topicName ?? this.topicName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  skipped,
}

enum TaskType {
  learn,
  pyq,
  revision,
}
