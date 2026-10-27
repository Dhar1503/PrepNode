/// Streak, XP and level domain.
///
/// All of this is derived from local activity; nothing here talks to a
/// network. The point of the layer is that "did the user study today" has
/// exactly one definition, in one place, rather than each feature deciding
/// for itself.
library;

/// Everything that counts as studying. Each maps to an XP award and, the
/// first time it happens on a given day, extends the streak.
enum StudyActivity {
  plannerTask,
  pyqAnswered,
  mockCompleted,
  revisionDone,
  resourceStudied,
  topicCompleted,
}

extension StudyActivityXp on StudyActivity {
  /// XP values from the brief. Mock is worth the most because it is the
  /// highest-effort, highest-signal activity; PYQs are small because they
  /// are answered in bulk.
  int get xp => switch (this) {
        StudyActivity.plannerTask => 20,
        StudyActivity.pyqAnswered => 5,
        StudyActivity.mockCompleted => 100,
        StudyActivity.revisionDone => 15,
        StudyActivity.resourceStudied => 10,
        StudyActivity.topicCompleted => 20,
      };

  String get source => switch (this) {
        StudyActivity.plannerTask => 'planner',
        StudyActivity.pyqAnswered => 'pyq',
        StudyActivity.mockCompleted => 'mock',
        StudyActivity.revisionDone => 'revision',
        StudyActivity.resourceStudied => 'resource',
        StudyActivity.topicCompleted => 'topic',
      };

  String get label => switch (this) {
        StudyActivity.plannerTask => 'Planner task completed',
        StudyActivity.pyqAnswered => 'PYQ answered',
        StudyActivity.mockCompleted => 'Mock test completed',
        StudyActivity.revisionDone => 'Revision completed',
        StudyActivity.resourceStudied => 'Resource studied',
        StudyActivity.topicCompleted => 'Topic completed',
      };
}

class StreakState {
  final int current;
  final int longest;
  final DateTime? lastStudyDate;
  final int freezeCount;

  /// Dates in the last 30 days on which the user did anything at all.
  final Set<DateTime> activeDays;

  /// The subset of [activeDays] that included question practice (a PYQ or a
  /// mock test) rather than only reading or planner ticks. Derived from the
  /// `source` column the XP ledger already records, so it needs no extra
  /// table — it is the same rows, grouped differently.
  final Set<DateTime> practisedDays;

  const StreakState({
    this.current = 0,
    this.longest = 0,
    this.lastStudyDate,
    this.freezeCount = 0,
    this.activeDays = const {},
    this.practisedDays = const {},
  });

  /// How many of the last [days] days had any activity. The week strip
  /// leads with this because "4 of the last 7 days" needs no interpreting,
  /// where a bare streak number does.
  int studyDaysInLast(int days) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return activeDays.where((d) => !d.isBefore(start)).length;
  }

  /// Whether today already counted. Used to decide whether the flame is lit
  /// and whether the daily streak bonus has been awarded.
  bool get studiedToday {
    final last = lastStudyDate;
    if (last == null) return false;
    final now = DateTime.now();
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  /// True when the streak is alive but today has not been earned yet — the
  /// state worth nudging the user about.
  bool get atRisk => current > 0 && !studiedToday;
}

/// Streak milestones that unlock a badge.
class StreakMilestone {
  final int days;
  final String code;
  final String title;

  const StreakMilestone(this.days, this.code, this.title);

  static const all = [
    StreakMilestone(3, 'streak_3', 'Getting Started'),
    StreakMilestone(7, 'streak_7', 'One Week Strong'),
    StreakMilestone(14, 'streak_14', 'Fortnight Focus'),
    StreakMilestone(30, 'streak_30', 'Monthly Discipline'),
    StreakMilestone(60, 'streak_60', 'Two Month Grind'),
    StreakMilestone(100, 'streak_100', 'Century of Consistency'),
  ];

  /// The milestones a streak of [days] has reached.
  static List<StreakMilestone> reachedBy(int days) =>
      all.where((m) => days >= m.days).toList();

  /// The next one to aim for, or null once all are earned.
  static StreakMilestone? nextAfter(int days) {
    for (final m in all) {
      if (days < m.days) return m;
    }
    return null;
  }
}

/// Level bands. Thresholds grow super-linearly so early levels arrive fast
/// (the part that builds the habit) and later ones stay meaningful.
class Level {
  final int index;
  final String title;
  final int minXp;

  const Level(this.index, this.title, this.minXp);

  static const all = [
    Level(1, 'Explorer', 0),
    Level(2, 'Learner', 250),
    Level(3, 'Strategist', 750),
    Level(4, 'Achiever', 1800),
    Level(5, 'Topper', 3500),
    Level(6, 'Scholar', 6000),
  ];

  static Level forXp(int xp) {
    var current = all.first;
    for (final level in all) {
      if (xp >= level.minXp) current = level;
    }
    return current;
  }

  static Level? nextAfter(int xp) {
    for (final level in all) {
      if (xp < level.minXp) return level;
    }
    return null;
  }
}

class XpState {
  final int totalXp;
  final int todayXp;

  /// XP earned per source, for the breakdown on the score screen.
  final Map<String, int> bySource;

  const XpState({
    this.totalXp = 0,
    this.todayXp = 0,
    this.bySource = const {},
  });

  Level get level => Level.forXp(totalXp);

  Level? get nextLevel => Level.nextAfter(totalXp);

  /// XP still needed for the next level, or 0 at max level.
  int get xpToNextLevel {
    final next = nextLevel;
    return next == null ? 0 : next.minXp - totalXp;
  }

  /// 0.0-1.0 progress through the current level band, for the ring.
  double get levelProgress {
    final next = nextLevel;
    if (next == null) return 1.0;
    final span = next.minXp - level.minXp;
    if (span <= 0) return 1.0;
    return ((totalXp - level.minXp) / span).clamp(0.0, 1.0);
  }
}

/// A daily challenge or weekly mission — same shape, different cadence.
class Objective {
  final String id;
  final String code;
  final String title;
  final int target;
  final int progress;
  final bool isWeekly;

  const Objective({
    required this.id,
    required this.code,
    required this.title,
    required this.target,
    required this.progress,
    this.isWeekly = false,
  });

  bool get isComplete => progress >= target;

  double get ratio => target <= 0 ? 0.0 : (progress / target).clamp(0.0, 1.0);
}
