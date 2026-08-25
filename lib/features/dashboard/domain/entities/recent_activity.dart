/// Recent Activity Entity
/// Represents a recently completed activity
class RecentActivity {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime completedAt;
  final ActivityType type;
  final int? durationMinutes;

  const RecentActivity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.completedAt,
    required this.type,
    this.durationMinutes,
  });

  RecentActivity copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? completedAt,
    ActivityType? type,
    int? durationMinutes,
  }) {
    return RecentActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

enum ActivityType {
  topicCompleted,
  pyqPractice,
  mockTest,
  revision,
}
