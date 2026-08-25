/// Progress Summary Entity
/// Represents the user's overall progress and streak data
class ProgressSummary {
  final double syllabusCoveragePercent;
  final List<StreakDay> streakData;
  final int currentStreak;
  final int totalStudyDays;

  const ProgressSummary({
    required this.syllabusCoveragePercent,
    required this.streakData,
    required this.currentStreak,
    required this.totalStudyDays,
  });

  ProgressSummary copyWith({
    double? syllabusCoveragePercent,
    List<StreakDay>? streakData,
    int? currentStreak,
    int? totalStudyDays,
  }) {
    return ProgressSummary(
      syllabusCoveragePercent: syllabusCoveragePercent ?? this.syllabusCoveragePercent,
      streakData: streakData ?? this.streakData,
      currentStreak: currentStreak ?? this.currentStreak,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
    );
  }
}

/// Streak Day Entity
/// Represents study activity for a single day
class StreakDay {
  final DateTime date;
  final bool studied;
  final int? minutesStudied;

  const StreakDay({
    required this.date,
    required this.studied,
    this.minutesStudied,
  });

  StreakDay copyWith({
    DateTime? date,
    bool? studied,
    int? minutesStudied,
  }) {
    return StreakDay(
      date: date ?? this.date,
      studied: studied ?? this.studied,
      minutesStudied: minutesStudied ?? this.minutesStudied,
    );
  }
}
