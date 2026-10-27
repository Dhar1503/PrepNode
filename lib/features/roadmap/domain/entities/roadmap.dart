/// Roadmap domain entities.
///
/// The roadmap is generated locally from the user's answers plus the
/// syllabus already in Drift — there is no model call and no backend. What
/// makes it feel adaptive is that it is regenerated from live progress
/// (see AdaptiveRoadmapEngine), not that it is stochastic.
library;

/// How much prior preparation the user reports.
enum PreparationLevel { beginner, intermediate, advanced }

/// When in the day they intend to study — used for task ordering and the
/// wording of reminders, not for anything scheduling-critical.
enum PreferredStudyTime { morning, afternoon, night }

/// Working students get a lighter daily load for the same total coverage.
enum StudentType { working, fullTime }

/// What kind of work a roadmap task represents.
enum RoadmapTaskKind { study, pyq, revision, mock, resource, assessment }

/// Lifecycle of a day on the timeline.
///
/// [locked] is a *future* day rather than a gated one — the user can always
/// look ahead, but a grey card signals "not yet" without pretending the
/// content is unavailable.
enum RoadmapDayStatus { completed, current, weak, missed, locked }

class RoadmapPreferences {
  final String userId;
  final String examId;
  final PreparationLevel level;
  final int hoursPerDay;
  final PreferredStudyTime preferredTime;
  final int targetMonth;
  final int targetYear;
  final StudentType studentType;

  const RoadmapPreferences({
    required this.userId,
    required this.examId,
    required this.level,
    required this.hoursPerDay,
    required this.preferredTime,
    required this.targetMonth,
    required this.targetYear,
    required this.studentType,
  });

  /// Minutes of study to schedule per day.
  ///
  /// A working student's stated hours are trimmed, because the honest
  /// failure mode of a generated plan is over-scheduling: a plan nobody can
  /// finish reads as failure every single day and gets abandoned. Better to
  /// under-schedule and let the streak build.
  int get dailyMinutes {
    final raw = hoursPerDay * 60;
    final adjusted = studentType == StudentType.working ? (raw * 0.8).round() : raw;
    return adjusted.clamp(30, 480);
  }

  RoadmapPreferences copyWith({
    String? userId,
    String? examId,
    PreparationLevel? level,
    int? hoursPerDay,
    PreferredStudyTime? preferredTime,
    int? targetMonth,
    int? targetYear,
    StudentType? studentType,
  }) {
    return RoadmapPreferences(
      userId: userId ?? this.userId,
      examId: examId ?? this.examId,
      level: level ?? this.level,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      preferredTime: preferredTime ?? this.preferredTime,
      targetMonth: targetMonth ?? this.targetMonth,
      targetYear: targetYear ?? this.targetYear,
      studentType: studentType ?? this.studentType,
    );
  }
}

class RoadmapTask {
  final String id;
  final String dayId;
  final String? topicId;
  final String title;
  final RoadmapTaskKind kind;
  final int estimatedMinutes;
  final bool isCompleted;
  final int orderIndex;

  const RoadmapTask({
    required this.id,
    required this.dayId,
    required this.title,
    required this.kind,
    required this.estimatedMinutes,
    this.topicId,
    this.isCompleted = false,
    this.orderIndex = 0,
  });

  RoadmapTask copyWith({bool? isCompleted}) {
    return RoadmapTask(
      id: id,
      dayId: dayId,
      topicId: topicId,
      title: title,
      kind: kind,
      estimatedMinutes: estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex,
    );
  }
}

class RoadmapDay {
  final String id;
  final int dayNumber;
  final int weekNumber;
  final DateTime date;
  final String focusLabel;
  final RoadmapDayStatus status;
  final List<RoadmapTask> tasks;

  const RoadmapDay({
    required this.id,
    required this.dayNumber,
    required this.weekNumber,
    required this.date,
    required this.focusLabel,
    required this.status,
    this.tasks = const [],
  });

  int get totalMinutes =>
      tasks.fold(0, (sum, task) => sum + task.estimatedMinutes);

  int get completedCount => tasks.where((t) => t.isCompleted).length;

  /// 0.0-1.0, and 0 rather than NaN for an empty day.
  double get progress =>
      tasks.isEmpty ? 0.0 : completedCount / tasks.length;

  bool get isFullyComplete => tasks.isNotEmpty && completedCount == tasks.length;

  RoadmapDay copyWith({
    RoadmapDayStatus? status,
    List<RoadmapTask>? tasks,
  }) {
    return RoadmapDay(
      id: id,
      dayNumber: dayNumber,
      weekNumber: weekNumber,
      date: date,
      focusLabel: focusLabel,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }
}

/// The whole 30-day plan plus the derived bits the dashboard needs.
class Roadmap {
  final List<RoadmapDay> days;

  const Roadmap({required this.days});

  bool get isEmpty => days.isEmpty;

  /// The day matching today's date, or null when the plan has run out —
  /// which is the signal to regenerate rather than an error.
  RoadmapDay? get today {
    final now = DateTime.now();
    for (final day in days) {
      if (day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day) {
        return day;
      }
    }
    return null;
  }

  int get completedDays =>
      days.where((d) => d.status == RoadmapDayStatus.completed).length;

  double get overallProgress {
    if (days.isEmpty) return 0.0;
    final total = days.fold<int>(0, (sum, d) => sum + d.tasks.length);
    if (total == 0) return 0.0;
    final done = days.fold<int>(0, (sum, d) => sum + d.completedCount);
    return done / total;
  }
}
