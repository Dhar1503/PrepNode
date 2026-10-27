import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/progression/data/datasources/progression_local_datasource.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';

class TestDatabaseService implements DatabaseService {
  final PrepNodeDatabase _db;

  TestDatabaseService(this._db);

  @override
  PrepNodeDatabase get database => _db;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PrepNodeDatabase db;
  late ProgressionLocalDataSource source;
  const userId = 'u1';

  setUp(() async {
    db = PrepNodeDatabase(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    await db.into(db.users).insert(UsersCompanion.insert(
          userId: userId,
          name: 'Aspirant',
          email: 'p@example.com',
          passwordHash: 'x',
        ));
    source = ProgressionLocalDataSource(
      databaseService: TestDatabaseService(db),
    );
  });

  tearDown(() async => db.close());

  group('streak', () {
    test('a fresh user has no streak', () async {
      final streak = await source.getStreak(userId);
      expect(streak.current, 0);
      expect(streak.longest, 0);
      expect(streak.studiedToday, isFalse);
    });

    test('studying today starts a 1-day streak', () async {
      await source.awardXp(userId, StudyActivity.plannerTask);
      final streak = await source.getStreak(userId);

      expect(streak.current, 1);
      expect(streak.longest, 1);
      expect(streak.studiedToday, isTrue);
    });

    test('studying five times in one day still counts as one day', () async {
      for (var i = 0; i < 5; i++) {
        await source.awardXp(userId, StudyActivity.pyqAnswered,
            dedupeKey: 'q$i');
      }

      final streak = await source.getStreak(userId);
      expect(streak.current, 1,
          reason: 'a streak measures days of consistency, not volume');
    });

    test('a consecutive day extends the streak', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await source.recordStudyActivity(userId, at: yesterday);
      await source.recordStudyActivity(userId);

      final streak = await source.getStreak(userId);
      expect(streak.current, 2);
      expect(streak.longest, 2);
    });

    test('a missed day breaks the streak but keeps the longest on record',
        () async {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      await source.recordStudyActivity(userId, at: threeDaysAgo);
      await source.recordStudyActivity(userId, at: twoDaysAgo);

      // Nothing yesterday — the gap is what breaks it.
      final streak = await source.getStreak(userId);
      expect(streak.current, 0);
      expect(streak.longest, 2, reason: 'the best run should survive a lapse');
    });

    test('the streak survives a new datasource over the same database',
        () async {
      await source.awardXp(userId, StudyActivity.plannerTask);

      // Simulate an app restart: everything in-memory is thrown away.
      final afterRestart = ProgressionLocalDataSource(
        databaseService: TestDatabaseService(db),
      );
      final streak = await afterRestart.getStreak(userId);

      expect(streak.current, 1,
          reason: 'a streak held only in a provider would reset here');
      expect(streak.studiedToday, isTrue);
    });

    test('milestone badges unlock at the documented thresholds', () async {
      var day = DateTime.now().subtract(const Duration(days: 6));
      for (var i = 0; i < 7; i++) {
        await source.recordStudyActivity(userId, at: day);
        day = day.add(const Duration(days: 1));
      }

      final streak = await source.getStreak(userId);
      expect(streak.current, 7);

      final badges = await source.getBadgeCodes(userId);
      expect(badges, contains('streak_3'));
      expect(badges, contains('streak_7'));
      expect(badges, isNot(contains('streak_14')));
    });
  });

  group('XP', () {
    test('each activity awards the documented amount', () async {
      expect(StudyActivity.plannerTask.xp, 20);
      expect(StudyActivity.pyqAnswered.xp, 5);
      expect(StudyActivity.mockCompleted.xp, 100);
      expect(StudyActivity.revisionDone.xp, 15);
      expect(StudyActivity.resourceStudied.xp, 10);
    });

    test('awards accumulate, including the once-daily streak bonus', () async {
      await source.awardXp(userId, StudyActivity.mockCompleted, dedupeKey: 'm1');
      await source.awardXp(userId, StudyActivity.pyqAnswered, dedupeKey: 'q1');

      final xp = await source.getXp(userId);
      // 100 + 5 + 25 (streak bonus, once)
      expect(xp.totalXp, 130);
      expect(xp.todayXp, 130);
      expect(xp.bySource['streak'], 25,
          reason: 'the daily bonus must not be awarded twice');
    });

    test('a duplicate dedupeKey is rejected', () async {
      final first = await source.awardXp(userId, StudyActivity.plannerTask,
          dedupeKey: 'task-1');
      final second = await source.awardXp(userId, StudyActivity.plannerTask,
          dedupeKey: 'task-1');

      expect(first, 20);
      expect(second, 0, reason: 'the same task must not be farmed for XP');

      final xp = await source.getXp(userId);
      expect(xp.bySource['planner'], 20);
    });

    test('XP survives a restart', () async {
      await source.awardXp(userId, StudyActivity.mockCompleted, dedupeKey: 'm1');

      final afterRestart = ProgressionLocalDataSource(
        databaseService: TestDatabaseService(db),
      );
      final xp = await afterRestart.getXp(userId);
      expect(xp.totalXp, 125);
    });
  });

  group('levels', () {
    test('thresholds map to the documented titles', () {
      expect(Level.forXp(0).title, 'Explorer');
      expect(Level.forXp(300).title, 'Learner');
      expect(Level.forXp(1000).title, 'Strategist');
      expect(Level.forXp(2000).title, 'Achiever');
      expect(Level.forXp(4000).title, 'Topper');
      expect(Level.forXp(10000).title, 'Scholar');
    });

    test('progress and remaining XP are consistent', () {
      const state = XpState(totalXp: 500);
      expect(state.level.title, 'Learner');
      expect(state.nextLevel!.title, 'Strategist');
      expect(state.xpToNextLevel, 250);
      expect(state.levelProgress, closeTo(0.5, 0.01));
    });

    test('the top level reports no next level rather than a negative gap', () {
      const state = XpState(totalXp: 99999);
      expect(state.nextLevel, isNull);
      expect(state.xpToNextLevel, 0);
      expect(state.levelProgress, 1.0);
    });
  });

  group('challenges and missions', () {
    test('a daily challenge is created on first read and reused after', () async {
      final first = await source.getDailyChallenge(userId);
      final second = await source.getDailyChallenge(userId);

      expect(first.id, second.id, reason: 'one challenge per day, not per read');
      expect(first.target, greaterThan(0));
    });

    test('matching activity advances the challenge', () async {
      final challenge = await source.getDailyChallenge(userId);

      // Award an activity the challenge counts. 'stay_active' counts
      // everything, so pick the activity its code names where possible.
      final activity = switch (challenge.code) {
        'solve_pyqs' => StudyActivity.pyqAnswered,
        'planner_tasks' => StudyActivity.plannerTask,
        'revise_topics' => StudyActivity.revisionDone,
        'study_resources' => StudyActivity.resourceStudied,
        _ => StudyActivity.plannerTask,
      };

      await source.awardXp(userId, activity, dedupeKey: 'a1');
      final after = await source.getDailyChallenge(userId);

      expect(after.progress, 1);
    });

    test('a weekly mission is keyed to the Monday of the week', () async {
      final mission = await source.getWeeklyMission(userId);
      expect(mission.isWeekly, isTrue);
      expect(mission.target, greaterThan(0));

      final again = await source.getWeeklyMission(userId);
      expect(again.id, mission.id);
    });

    test('weekStartOf returns Monday for every day of the week', () {
      // 2026-03-04 is a Wednesday.
      final wed = DateTime(2026, 3, 4);
      final monday = ProgressionLocalDataSource.weekStartOf(wed);
      expect(monday.weekday, DateTime.monday);
      expect(monday, DateTime(2026, 3, 2));

      final sunday = DateTime(2026, 3, 8);
      expect(ProgressionLocalDataSource.weekStartOf(sunday), DateTime(2026, 3, 2));
    });
  });

  group('week strip data', () {
    test('studyDaysInLast counts only days inside the window', () async {
      // Today, 3 days ago (inside the 7-day window), 10 days ago (outside).
      final now = DateTime.now();
      for (final offset in [0, 3, 10]) {
        await source.awardXp(
          userId,
          StudyActivity.plannerTask,
          dedupeKey: 'd\$offset',
        );
      }
      // All three awards land today because awardXp stamps now(); assert the
      // window logic directly instead.
      final today = DateTime(now.year, now.month, now.day);
      final state = StreakState(activeDays: {
        today,
        today.subtract(const Duration(days: 3)),
        today.subtract(const Duration(days: 10)),
      });

      expect(state.studyDaysInLast(7), 2,
          reason: 'the 10-day-old entry is outside the week');
      expect(state.studyDaysInLast(28), 3);
    });

    test('answering a PYQ marks the day as practised, a planner tick does not',
        () async {
      await source.awardXp(userId, StudyActivity.plannerTask, dedupeKey: 'p1');
      var streak = await source.getStreak(userId);
      expect(streak.activeDays, isNotEmpty);
      expect(streak.practisedDays, isEmpty,
          reason: 'a planner tick is studying, not practising');

      await source.awardXp(userId, StudyActivity.pyqAnswered, dedupeKey: 'q1');
      streak = await source.getStreak(userId);
      expect(streak.practisedDays, isNotEmpty);
      expect(streak.practisedDays.length, lessThanOrEqualTo(streak.activeDays.length),
          reason: 'practised days are a subset of active days');
    });

    test('a mock test also counts as practice', () async {
      await source.awardXp(userId, StudyActivity.mockCompleted, dedupeKey: 'm1');
      final streak = await source.getStreak(userId);
      expect(streak.practisedDays, isNotEmpty);
    });

    test('a fresh user has no active or practised days', () async {
      final streak = await source.getStreak(userId);
      expect(streak.activeDays, isEmpty);
      expect(streak.practisedDays, isEmpty);
      expect(streak.studyDaysInLast(7), 0);
    });
  });
}
