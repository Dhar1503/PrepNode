/// Upcoming Schedule Entity
/// Represents an upcoming scheduled item
class UpcomingSchedule {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final ScheduleType type;
  final String? description;

  const UpcomingSchedule({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.type,
    this.description,
  });

  UpcomingSchedule copyWith({
    String? id,
    String? title,
    DateTime? scheduledAt,
    ScheduleType? type,
    String? description,
  }) {
    return UpcomingSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }
}

enum ScheduleType {
  mockTest,
  revision,
  milestone,
}
