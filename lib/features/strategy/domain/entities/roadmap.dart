/// Roadmap Entity
///
/// A day-by-day distribution of the student's real "next best topics"
/// across the days actually available before their target exam date,
/// sized to their real daily study hours. Not a template — see
/// StrategyRepositoryImpl._buildRoadmap for how the distribution is
/// computed from real recommendation data.
class Roadmap {
  final String label; // '7-Day Crash Plan' / '30-Day Strategy' / '90-Day Strategy'
  final int totalDays;
  final int weeksUntilExam;
  final List<RoadmapDay> days;

  const Roadmap({
    required this.label,
    required this.totalDays,
    required this.weeksUntilExam,
    required this.days,
  });
}

class RoadmapDay {
  final DateTime date;
  final int dayNumber; // 1-indexed
  final List<RoadmapItem> items;
  final int totalMinutes;

  const RoadmapDay({
    required this.date,
    required this.dayNumber,
    required this.items,
    required this.totalMinutes,
  });
}

class RoadmapItem {
  final String topicId;
  final String topicName;
  final String subjectName;
  final int durationMinutes;
  final RoadmapActivityType activityType;

  const RoadmapItem({
    required this.topicId,
    required this.topicName,
    required this.subjectName,
    required this.durationMinutes,
    required this.activityType,
  });
}

enum RoadmapActivityType { learn, pyqPractice, revision }
