import 'package:drift/drift.dart';
// Drift generates a table class `RoadmapPreferences` and row classes
// `RoadmapDay`/`RoadmapTask` whose names collide with the domain entities of
// the same name. The domain types are the ones this layer speaks in; the
// Drift equivalents are only reached through `_db.roadmapDays` and the
// generated Companions, which are not hidden here.
import 'package:prepnode/core/data/database/database.dart'
    hide RoadmapPreferences, RoadmapDay, RoadmapTask;
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/roadmap/data/services/adaptive_roadmap_engine.dart';
import 'package:prepnode/features/roadmap/data/services/roadmap_generator.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

/// Reads and writes the roadmap, and gathers the signals the adaptive
/// engine runs on. Everything comes from Drift — no network anywhere.
class RoadmapLocalDataSource {
  final DatabaseService _databaseService;
  final RoadmapGenerator _generator;
  final AdaptiveRoadmapEngine _engine;

  RoadmapLocalDataSource({
    required DatabaseService databaseService,
    RoadmapGenerator generator = const RoadmapGenerator(),
    AdaptiveRoadmapEngine engine = const AdaptiveRoadmapEngine(),
  })  : _databaseService = databaseService,
        _generator = generator,
        _engine = engine;

  PrepNodeDatabase get _db => _databaseService.database;

  // ==================== PREFERENCES ====================

  Future<void> savePreferences(RoadmapPreferences prefs) async {
    await _db.into(_db.roadmapPreferences).insertOnConflictUpdate(
          RoadmapPreferencesCompanion.insert(
            userId: prefs.userId,
            examId: prefs.examId,
            level: prefs.level.name,
            hoursPerDay: prefs.hoursPerDay,
            preferredTime: prefs.preferredTime.name,
            targetMonth: prefs.targetMonth,
            targetYear: prefs.targetYear,
            studentType: prefs.studentType.name,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<RoadmapPreferences?> getPreferences(String userId) async {
    final row = await (_db.select(_db.roadmapPreferences)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    if (row == null) return null;

    return RoadmapPreferences(
      userId: row.userId,
      examId: row.examId,
      level: _parseEnum(PreparationLevel.values, row.level, PreparationLevel.beginner),
      hoursPerDay: row.hoursPerDay,
      preferredTime: _parseEnum(
          PreferredStudyTime.values, row.preferredTime, PreferredStudyTime.morning),
      targetMonth: row.targetMonth,
      targetYear: row.targetYear,
      studentType: _parseEnum(StudentType.values, row.studentType, StudentType.fullTime),
    );
  }

  /// Whether the wizard still needs to run.
  Future<bool> hasRoadmap(String userId) async {
    final rows = await (_db.select(_db.roadmapDays)
          ..where((t) => t.userId.equals(userId))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  // ==================== GENERATION ====================

  /// Generates and persists a fresh 30-day plan, replacing any existing one.
  ///
  /// Replacement is deliberate: a roadmap is a projection, not a log. What
  /// the user actually did lives in attempts, sessions and the XP ledger,
  /// none of which this touches.
  Future<void> generateAndSave(RoadmapPreferences prefs) async {
    final topics = await _loadSyllabus(prefs.examId, prefs.userId);
    final days = _generator.generate(
      preferences: prefs,
      topics: topics,
      startDate: DateTime.now(),
    );

    await _db.transaction(() async {
      await (_db.delete(_db.roadmapTasks)
            ..where((t) => t.userId.equals(prefs.userId)))
          .go();
      await (_db.delete(_db.roadmapDays)
            ..where((t) => t.userId.equals(prefs.userId)))
          .go();

      for (final day in days) {
        await _db.into(_db.roadmapDays).insert(RoadmapDaysCompanion.insert(
              dayId: day.id,
              userId: prefs.userId,
              dayNumber: day.dayNumber,
              weekNumber: day.weekNumber,
              date: day.date,
              focusLabel: day.focusLabel,
              status: Value(day.status.name),
            ));

        for (final task in day.tasks) {
          await _db.into(_db.roadmapTasks).insert(RoadmapTasksCompanion.insert(
                taskId: task.id,
                dayId: day.id,
                userId: prefs.userId,
                topicId: Value(task.topicId),
                title: task.title,
                kind: task.kind.name,
                estimatedMinutes: task.estimatedMinutes,
                orderIndex: Value(task.orderIndex),
              ));
        }
      }
    });
  }

  /// Reads the whole roadmap back with live statuses applied.
  Future<Roadmap> getRoadmap(String userId) async {
    final dayRows = await (_db.select(_db.roadmapDays)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.dayNumber)]))
        .get();
    if (dayRows.isEmpty) return const Roadmap(days: []);

    final taskRows = await (_db.select(_db.roadmapTasks)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();

    final tasksByDay = <String, List<RoadmapTask>>{};
    for (final row in taskRows) {
      tasksByDay.putIfAbsent(row.dayId, () => []).add(RoadmapTask(
            id: row.taskId,
            dayId: row.dayId,
            topicId: row.topicId,
            title: row.title,
            kind: _parseEnum(RoadmapTaskKind.values, row.kind, RoadmapTaskKind.study),
            estimatedMinutes: row.estimatedMinutes,
            isCompleted: row.status == 'completed',
            orderIndex: row.orderIndex,
          ));
    }

    final days = dayRows
        .map((row) => RoadmapDay(
              id: row.dayId,
              dayNumber: row.dayNumber,
              weekNumber: row.weekNumber,
              date: row.date,
              focusLabel: row.focusLabel,
              status: _parseEnum(
                  RoadmapDayStatus.values, row.status, RoadmapDayStatus.locked),
              tasks: tasksByDay[row.dayId] ?? const [],
            ))
        .toList();

    return Roadmap(days: _engine.recomputeStatuses(days));
  }

  /// Marks a roadmap task done. Returns the task's kind so the caller can
  /// award the matching XP — the datasource deliberately does not reach into
  /// progression itself, to keep the two features independent.
  Future<RoadmapTaskKind?> completeTask(String taskId) async {
    final row = await (_db.select(_db.roadmapTasks)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingleOrNull();
    if (row == null || row.status == 'completed') return null;

    await (_db.update(_db.roadmapTasks)..where((t) => t.taskId.equals(taskId)))
        .write(RoadmapTasksCompanion(
      status: const Value('completed'),
      completedAt: Value(DateTime.now()),
    ));

    return _parseEnum(RoadmapTaskKind.values, row.kind, RoadmapTaskKind.study);
  }

  // ==================== ADAPTATION ====================

  /// Runs the adaptive engine against live signals and persists whatever it
  /// changed, from tomorrow onward.
  Future<AdaptationResult> adaptRoadmap(String userId) async {
    final prefs = await getPreferences(userId);
    if (prefs == null) {
      return const AdaptationResult(days: [], changes: []);
    }

    final roadmap = await getRoadmap(userId);
    if (roadmap.isEmpty) {
      return const AdaptationResult(days: [], changes: []);
    }

    final signals = await gatherSignals(userId, roadmap);
    final todayNumber = roadmap.today?.dayNumber ?? 1;

    final result = _engine.adapt(
      days: roadmap.days,
      signals: signals,
      preferences: prefs,
      // From tomorrow: rewriting today under the user mid-session would be
      // disorienting.
      fromDayNumber: todayNumber + 1,
    );

    if (!result.didAdapt) return result;

    await _db.transaction(() async {
      for (final day in result.days) {
        if (day.dayNumber <= todayNumber) continue;
        await (_db.delete(_db.roadmapTasks)..where((t) => t.dayId.equals(day.id)))
            .go();
        for (final task in day.tasks) {
          await _db.into(_db.roadmapTasks).insert(RoadmapTasksCompanion.insert(
                taskId: task.id,
                dayId: day.id,
                userId: userId,
                topicId: Value(task.topicId),
                title: task.title,
                kind: task.kind.name,
                estimatedMinutes: task.estimatedMinutes,
                orderIndex: Value(task.orderIndex),
              ));
        }
      }
    });

    return result;
  }

  /// Builds the signal bundle from real activity.
  Future<LearningSignals> gatherSignals(String userId, Roadmap roadmap) async {
    final today = DateTime.now();
    final past = roadmap.days
        .where((d) => d.date.isBefore(DateTime(today.year, today.month, today.day)))
        .toList();

    final completedDays = past.where((d) => d.isFullyComplete).length;
    final missedDays = past.where((d) => d.completedCount == 0).length;
    final scheduled = past.fold<int>(0, (sum, d) => sum + d.tasks.length);
    final done = past.fold<int>(0, (sum, d) => sum + d.completedCount);
    final completionRate = scheduled == 0 ? 0.0 : done / scheduled;

    return LearningSignals(
      completedDays: completedDays,
      missedDays: missedDays,
      subjectMastery: await _subjectMastery(userId),
      averageMockScore: await _averageMockScore(userId),
      completionRate: completionRate,
    );
  }

  /// Per-subject accuracy from the attempt history — the same source the
  /// Knowledge Graph derives mastery from, so the two never disagree.
  Future<Map<String, double>> _subjectMastery(String userId) async {
    final rows = await _db.customSelect(
      '''
      SELECT q.subject_id AS subject_id,
             COUNT(*) AS attempted,
             SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS correct
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
      GROUP BY q.subject_id
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    final result = <String, double>{};
    for (final row in rows) {
      final attempted = row.read<int>('attempted');
      if (attempted == 0) continue;
      final correct = row.read<int?>('correct') ?? 0;
      result[row.read<String>('subject_id')] = (correct / attempted) * 100;
    }
    return result;
  }

  Future<double?> _averageMockScore(String userId) async {
    final rows = await (_db.select(_db.mockTests)
          ..where((t) => t.userId.equals(userId) & t.score.isNotNull()))
        .get();
    if (rows.isEmpty) return null;
    final total = rows.fold<double>(0, (sum, r) => sum + (r.score ?? 0));
    return total / rows.length;
  }

  /// Syllabus for the generator, with each topic's live mastery attached.
  Future<List<SyllabusTopic>> _loadSyllabus(String examId, String userId) async {
    final subjects = await (_db.select(_db.subjects)
          ..where((t) => t.examId.equals(examId)))
        .get();
    if (subjects.isEmpty) return const [];

    final subjectIds = subjects.map((s) => s.subjectId).toList();
    final topics = await (_db.select(_db.topics)
          ..where((t) => t.subjectId.isIn(subjectIds)))
        .get();

    final mastery = await _topicMastery(userId);

    return topics
        .map((t) => SyllabusTopic(
              topicId: t.topicId,
              subjectId: t.subjectId,
              name: t.topicName,
              parentTopicId: t.parentTopicId,
              importanceScore: t.importanceScore,
              mastery: mastery[t.topicId] ?? 0,
            ))
        .toList();
  }

  Future<Map<String, double>> _topicMastery(String userId) async {
    final rows = await _db.customSelect(
      '''
      SELECT q.topic_id AS topic_id,
             COUNT(*) AS attempted,
             SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS correct
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
      GROUP BY q.topic_id
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    final result = <String, double>{};
    for (final row in rows) {
      final attempted = row.read<int>('attempted');
      if (attempted == 0) continue;
      final correct = row.read<int?>('correct') ?? 0;
      result[row.read<String>('topic_id')] = (correct / attempted) * 100;
    }
    return result;
  }

  /// Enum parsing that survives an unrecognised stored string rather than
  /// throwing — a value written by a future build must never crash an older
  /// one on downgrade.
  T _parseEnum<T extends Enum>(List<T> values, String stored, T fallback) {
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return fallback;
  }
}
