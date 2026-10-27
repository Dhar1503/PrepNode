import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';

/// Persists streak, XP, badge and objective state.
///
/// Every write goes to Drift immediately rather than being held in a
/// provider, because the whole point of a streak is that it survives the
/// app being killed — an in-memory counter would reset on every cold start,
/// which is exactly the bug this layer exists to prevent.
class ProgressionLocalDataSource {
  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  ProgressionLocalDataSource({required DatabaseService databaseService})
      : _databaseService = databaseService;

  PrepNodeDatabase get _db => _databaseService.database;

  /// Local midnight for [date]. Streak arithmetic is done on whole days, so
  /// every stored date is normalised — otherwise "yesterday" depends on
  /// what time of day the user studied.
  static DateTime dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // ==================== STREAK ====================

  /// Records that the user studied, and returns the resulting streak.
  ///
  /// Idempotent within a day: studying five times today still counts once,
  /// so the streak reflects days of consistency rather than volume.
  Future<StreakState> recordStudyActivity(
    String userId, {
    DateTime? at,
  }) async {
    final today = dayOf(at ?? DateTime.now());
    final existing = await (_db.select(_db.streaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.streaks).insert(StreaksCompanion.insert(
            userId: userId,
            currentStreak: const Value(1),
            longestStreak: const Value(1),
            lastStudyDate: Value(today),
          ));
      return getStreak(userId);
    }

    final last = existing.lastStudyDate == null ? null : dayOf(existing.lastStudyDate!);

    // Already counted today — nothing to do.
    if (last != null && last.isAtSameMomentAs(today)) {
      return getStreak(userId);
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final continues = last != null && last.isAtSameMomentAs(yesterday);
    final newCurrent = continues ? existing.currentStreak + 1 : 1;
    final newLongest =
        newCurrent > existing.longestStreak ? newCurrent : existing.longestStreak;

    await (_db.update(_db.streaks)..where((t) => t.userId.equals(userId)))
        .write(StreaksCompanion(
      currentStreak: Value(newCurrent),
      longestStreak: Value(newLongest),
      lastStudyDate: Value(today),
      updatedAt: Value(DateTime.now()),
    ));

    await _awardStreakMilestones(userId, newCurrent);
    return getStreak(userId);
  }

  /// Reads the streak, expiring it if the user has missed a day.
  ///
  /// The expiry is computed on read rather than written by a background
  /// job: there is no scheduler in an offline app, and a streak that only
  /// resets when you next open the app would show a stale "12 days" to
  /// someone who last studied a fortnight ago.
  Future<StreakState> getStreak(String userId) async {
    final row = await (_db.select(_db.streaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    final activity = await _activityByDay(userId);
    final activeDays = activity.$1;
    final practisedDays = activity.$2;

    if (row == null) {
      return StreakState(
        activeDays: activeDays,
        practisedDays: practisedDays,
      );
    }

    final today = dayOf(DateTime.now());
    final last = row.lastStudyDate == null ? null : dayOf(row.lastStudyDate!);
    var current = row.currentStreak;

    if (last != null) {
      final gap = today.difference(last).inDays;
      if (gap > 1) current = 0;
    }

    return StreakState(
      current: current,
      longest: row.longestStreak,
      lastStudyDate: row.lastStudyDate,
      freezeCount: row.freezeCount,
      activeDays: activeDays,
      practisedDays: practisedDays,
    );
  }

  /// Days with any activity, and the subset that included question
  /// practice, over the last 30 days.
  ///
  /// Both come from the XP ledger rather than a separate log, so the strip
  /// and the streak can never disagree. 30 days covers both the week strip
  /// and the four-week grid from one read.
  ///
  /// "Practised" means a PYQ or a mock — answering questions, as opposed to
  /// ticking a planner task or opening a resource. That is the distinction
  /// worth a second colour: it is the difference between showing up and
  /// testing yourself.
  Future<(Set<DateTime>, Set<DateTime>)> _activityByDay(String userId) async {
    final since = dayOf(DateTime.now()).subtract(const Duration(days: 30));
    final rows = await (_db.select(_db.xpHistory)
          ..where((t) =>
              t.userId.equals(userId) & t.earnedAt.isBiggerOrEqualValue(since)))
        .get();

    const practiceSources = {'pyq', 'mock'};
    final active = <DateTime>{};
    final practised = <DateTime>{};

    for (final row in rows) {
      final day = dayOf(row.earnedAt);
      active.add(day);
      if (practiceSources.contains(row.source)) practised.add(day);
    }

    return (active, practised);
  }

  /// Headline counts for the profile, read straight from tables that
  /// already exist. Returned as a record rather than a new entity class —
  /// nothing here is persisted or reused elsewhere, so a type declaration
  /// would be ceremony around four integers.
  ///
  /// "Topics explored" counts distinct topics the user has answered a
  /// question in, which is a stronger claim than "opened once" and matches
  /// what mastery is derived from.
  Future<({
    int daysStudied,
    int questionsAttempted,
    int topicsExplored,
    int mockTests,
  })> getProfileStats(String userId) async {
    final activity = await _activityByDay(userId);

    final attemptRow = await _db.customSelect(
      '''
      SELECT COUNT(*) AS attempted,
             COUNT(DISTINCT q.topic_id) AS topics
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
      ''',
      variables: [Variable.withString(userId)],
    ).getSingleOrNull();

    final mockRows = await (_db.select(_db.mockTests)
          ..where((t) => t.userId.equals(userId) & t.submittedAt.isNotNull()))
        .get();

    return (
      daysStudied: activity.$1.length,
      questionsAttempted: attemptRow?.read<int>('attempted') ?? 0,
      topicsExplored: attemptRow?.read<int>('topics') ?? 0,
      mockTests: mockRows.length,
    );
  }

  Future<void> _awardStreakMilestones(String userId, int streak) async {
    for (final milestone in StreakMilestone.reachedBy(streak)) {
      await awardBadge(userId, milestone.code);
    }
  }

  // ==================== XP ====================

  /// Awards XP for an activity, records the study day, and keeps daily and
  /// weekly objectives in step — one call per user action.
  ///
  /// [dedupeKey] makes an award happen at most once; the unique index on
  /// (user_id, dedupe_key) is what enforces it, so a double-tap or a replayed
  /// event cannot inflate the total.
  Future<int> awardXp(
    String userId,
    StudyActivity activity, {
    String? note,
    String? dedupeKey,
    int? amountOverride,
  }) async {
    final amount = amountOverride ?? activity.xp;
    try {
      await _db.into(_db.xpHistory).insert(XpHistoryCompanion.insert(
            entryId: _uuid.v4(),
            userId: userId,
            source: activity.source,
            amount: amount,
            note: Value(note),
            dedupeKey: Value(dedupeKey),
          ));
    } catch (_) {
      // Unique-index violation: this exact award already happened.
      return 0;
    }

    await recordStudyActivity(userId);
    await _awardDailyStreakBonus(userId);
    await _advanceObjectives(userId, activity);
    await _awardLevelBadge(userId);
    return amount;
  }

  /// The +25 "kept your streak" bonus, once per calendar day.
  Future<void> _awardDailyStreakBonus(String userId) async {
    final today = dayOf(DateTime.now());
    final key = 'streak-${today.toIso8601String()}';
    try {
      await _db.into(_db.xpHistory).insert(XpHistoryCompanion.insert(
            entryId: _uuid.v4(),
            userId: userId,
            source: 'streak',
            amount: 25,
            note: const Value('Daily streak bonus'),
            dedupeKey: Value(key),
          ));
    } catch (_) {
      // Already awarded today.
    }
  }

  Future<XpState> getXp(String userId) async {
    final rows = await (_db.select(_db.xpHistory)
          ..where((t) => t.userId.equals(userId)))
        .get();

    final today = dayOf(DateTime.now());
    var total = 0;
    var todayTotal = 0;
    final bySource = <String, int>{};

    for (final row in rows) {
      total += row.amount;
      bySource[row.source] = (bySource[row.source] ?? 0) + row.amount;
      if (dayOf(row.earnedAt).isAtSameMomentAs(today)) {
        todayTotal += row.amount;
      }
    }

    return XpState(totalXp: total, todayXp: todayTotal, bySource: bySource);
  }

  Future<void> _awardLevelBadge(String userId) async {
    final xp = await getXp(userId);
    await awardBadge(userId, 'level_${xp.level.title.toLowerCase()}');
  }

  // ==================== BADGES ====================

  /// Inserts a badge if the user does not already hold it. The unique
  /// (user_id, code) index makes the check race-free.
  Future<void> awardBadge(String userId, String code) async {
    try {
      await _db.into(_db.badges).insert(BadgesCompanion.insert(
            badgeId: _uuid.v4(),
            userId: userId,
            code: code,
          ));
    } catch (_) {
      // Already earned.
    }
  }

  Future<List<String>> getBadgeCodes(String userId) async {
    final rows = await (_db.select(_db.badges)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows.map((r) => r.code).toList();
  }

  // ==================== CHALLENGES & MISSIONS ====================

  /// The Monday of the week containing [date].
  static DateTime weekStartOf(DateTime date) {
    final day = dayOf(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Today's challenge, created on first read so there is always one.
  /// The choice rotates by day-of-year so it is stable within a day and
  /// varies across days without needing randomness.
  Future<Objective> getDailyChallenge(String userId) async {
    final today = dayOf(DateTime.now());
    final existing = await (_db.select(_db.dailyChallenges)
          ..where((t) => t.userId.equals(userId) & t.date.equals(today)))
        .getSingleOrNull();

    if (existing != null) {
      return Objective(
        id: existing.challengeId,
        code: existing.code,
        title: existing.title,
        target: existing.targetCount,
        progress: existing.progressCount,
      );
    }

    final template = _dailyTemplates[
        today.difference(DateTime(today.year)).inDays % _dailyTemplates.length];
    final id = _uuid.v4();
    await _db.into(_db.dailyChallenges).insert(DailyChallengesCompanion.insert(
          challengeId: id,
          userId: userId,
          date: today,
          code: template.$1,
          title: template.$2,
          targetCount: template.$3,
        ));

    return Objective(
      id: id,
      code: template.$1,
      title: template.$2,
      target: template.$3,
      progress: 0,
    );
  }

  Future<Objective> getWeeklyMission(String userId) async {
    final weekStart = weekStartOf(DateTime.now());
    final existing = await (_db.select(_db.weeklyMissions)
          ..where((t) => t.userId.equals(userId) & t.weekStart.equals(weekStart)))
        .getSingleOrNull();

    if (existing != null) {
      return Objective(
        id: existing.missionId,
        code: existing.code,
        title: existing.title,
        target: existing.targetCount,
        progress: existing.progressCount,
        isWeekly: true,
      );
    }

    final template = _weeklyTemplates[
        (weekStart.difference(DateTime(weekStart.year)).inDays ~/ 7) %
            _weeklyTemplates.length];
    final id = _uuid.v4();
    await _db.into(_db.weeklyMissions).insert(WeeklyMissionsCompanion.insert(
          missionId: id,
          userId: userId,
          weekStart: weekStart,
          code: template.$1,
          title: template.$2,
          targetCount: template.$3,
        ));

    return Objective(
      id: id,
      code: template.$1,
      title: template.$2,
      target: template.$3,
      progress: 0,
      isWeekly: true,
    );
  }

  /// Nudges whichever objectives this activity counts toward.
  Future<void> _advanceObjectives(String userId, StudyActivity activity) async {
    final daily = await getDailyChallenge(userId);
    if (_counts(daily.code, activity) && !daily.isComplete) {
      final next = daily.progress + 1;
      await (_db.update(_db.dailyChallenges)
            ..where((t) => t.challengeId.equals(daily.id)))
          .write(DailyChallengesCompanion(
        progressCount: Value(next),
        completedAt:
            next >= daily.target ? Value(DateTime.now()) : const Value.absent(),
      ));
    }

    final weekly = await getWeeklyMission(userId);
    if (_counts(weekly.code, activity) && !weekly.isComplete) {
      final next = weekly.progress + 1;
      await (_db.update(_db.weeklyMissions)
            ..where((t) => t.missionId.equals(weekly.id)))
          .write(WeeklyMissionsCompanion(
        progressCount: Value(next),
        completedAt:
            next >= weekly.target ? Value(DateTime.now()) : const Value.absent(),
      ));
    }
  }

  bool _counts(String code, StudyActivity activity) {
    return switch (code) {
      'planner_tasks' => activity == StudyActivity.plannerTask,
      'solve_pyqs' => activity == StudyActivity.pyqAnswered,
      'take_mocks' => activity == StudyActivity.mockCompleted,
      'revise_topics' => activity == StudyActivity.revisionDone,
      'study_resources' => activity == StudyActivity.resourceStudied,
      // "any activity" objectives.
      'stay_active' => true,
      _ => false,
    };
  }

  /// (code, title, target)
  static const List<(String, String, int)> _dailyTemplates = [
    ('solve_pyqs', 'Answer 10 previous-year questions', 10),
    ('planner_tasks', 'Finish 2 planner tasks', 2),
    ('revise_topics', 'Revise 1 topic', 1),
    ('study_resources', 'Study 1 resource', 1),
    ('stay_active', 'Do any 3 study activities', 3),
  ];

  static const List<(String, String, int)> _weeklyTemplates = [
    ('planner_tasks', 'Complete 5 planner tasks this week', 5),
    ('solve_pyqs', 'Solve 50 PYQs this week', 50),
    ('take_mocks', 'Take 2 mock tests this week', 2),
    ('stay_active', 'Study on 5 different days', 5),
  ];
}
