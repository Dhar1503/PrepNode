/// Study Session Entity
/// Represents a completed study session with tracking data
class StudySession {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final int actualDurationMinutes;
  final int plannedDurationMinutes;
  final SessionQuality quality;
  final String? notes;
  final List<String> topicIdsCovered;

  const StudySession({
    required this.id,
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.actualDurationMinutes,
    required this.plannedDurationMinutes,
    required this.quality,
    this.notes,
    required this.topicIdsCovered,
  });

  StudySession copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? actualDurationMinutes,
    int? plannedDurationMinutes,
    SessionQuality? quality,
    String? notes,
    List<String>? topicIdsCovered,
  }) {
    return StudySession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      plannedDurationMinutes: plannedDurationMinutes ?? this.plannedDurationMinutes,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      topicIdsCovered: topicIdsCovered ?? this.topicIdsCovered,
    );
  }

  double get adherenceRate {
    if (plannedDurationMinutes == 0) return 1.0;
    return actualDurationMinutes / plannedDurationMinutes;
  }
}

enum SessionQuality {
  excellent,
  good,
  fair,
  poor,
}
