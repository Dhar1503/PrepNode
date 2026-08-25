/// Planner Local Data Source
/// Handles local storage and caching for planner data
library;

import 'package:drift/drift.dart';
import 'package:prepgraph/core/data/database/database.dart';
import 'package:prepgraph/core/data/database/database_service.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/domain/entities/study_session.dart';

class PlannerLocalDataSource {
  final DatabaseService _databaseService;

  PlannerLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Create or fully overwrite a study plan row in the real study_plans
  /// table (db.studyPlans has a generated accessor, unlike study_sessions).
  Future<void> saveStudyPlan({
    required String planId,
    required String userId,
    required String topicId,
    required DateTime date,
    required String title,
    required int durationMinutes,
    required String type,
    required String priority,
    String? reason,
    String status = 'pending',
  }) async {
    final db = _databaseService.database;
    await db.into(db.studyPlans).insertOnConflictUpdate(
          StudyPlansCompanion(
            planId: Value(planId),
            userId: Value(userId),
            topicId: Value(topicId),
            date: Value(date),
            title: Value(title),
            durationMinutes: Value(durationMinutes),
            type: Value(type),
            priority: Value(priority),
            reason: Value(reason),
            status: Value(status),
          ),
        );
  }

  /// Update only the editable details of an existing plan, preserving its
  /// current status (a plain [saveStudyPlan] upsert would reset status to
  /// its default and wipe a completed/skipped task back to pending).
  Future<void> updateStudyPlanDetails({
    required String planId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required String type,
    String? reason,
  }) async {
    final db = _databaseService.database;
    await (db.update(db.studyPlans)..where((t) => t.planId.equals(planId))).write(
      StudyPlansCompanion(
        topicId: Value(topicId),
        title: Value(title),
        durationMinutes: Value(durationMinutes),
        type: Value(type),
        reason: Value(reason),
      ),
    );
  }

  /// Get study plans for a user and date from the real study_plans table.
  Future<List<PlannerTask>> getStudyPlansForDate({
    required String userId,
    required DateTime date,
  }) async {
    final db = _databaseService.database;
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final query = db.select(db.studyPlans)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.date.isBiggerOrEqualValue(dayStart) &
            t.date.isSmallerThanValue(dayEnd),
      );
    final rows = await query.get();

    return rows.map(_mapRowToTask).toList();
  }

  /// Get a single study plan by id, used to return the up-to-date task
  /// after an update (e.g. edit) without duplicating its field mapping.
  Future<PlannerTask?> getStudyPlanById(String planId) async {
    final db = _databaseService.database;
    final query = db.select(db.studyPlans)..where((t) => t.planId.equals(planId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRowToTask(row);
  }

  PlannerTask _mapRowToTask(StudyPlan row) {
    return PlannerTask(
      id: row.planId,
      topicId: row.topicId,
      title: row.title,
      durationMinutes: row.durationMinutes,
      reason: row.reason ?? '',
      type: TaskType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => TaskType.learn,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => TaskStatus.pending,
      ),
      scheduledDate: row.date,
    );
  }

  /// Update study plan status
  Future<void> updateStudyPlanStatus({
    required String planId,
    required String status,
  }) async {
    final db = _databaseService.database;
    await (db.update(db.studyPlans)..where((t) => t.planId.equals(planId))).write(
      StudyPlansCompanion(status: Value(status)),
    );
  }

  /// Reschedule study plan to a new date
  Future<void> rescheduleStudyPlan({
    required String planId,
    required DateTime newDate,
  }) async {
    final db = _databaseService.database;
    await (db.update(db.studyPlans)..where((t) => t.planId.equals(planId))).write(
      StudyPlansCompanion(date: Value(newDate)),
    );
  }

  /// Delete study plan
  Future<void> deleteStudyPlan(String planId) async {
    final db = _databaseService.database;
    await (db.delete(db.studyPlans)..where((t) => t.planId.equals(planId))).go();
  }

  /// Save a completed study session to the real study_sessions table.
  /// study_sessions is declared in the Drift schema but predates the last
  /// codegen run, so (as elsewhere in this codebase, see
  /// InsightsLocalDataSource) it's written via raw SQL rather than a
  /// generated table accessor.
  Future<void> saveStudySession({
    required String userId,
    required String topicId,
    required DateTime startTime,
    required DateTime endTime,
    required int actualDurationMinutes,
    required String quality,
    String? notes,
  }) async {
    final db = _databaseService.database;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.customInsert(
      '''
      INSERT INTO study_sessions (
        session_id, user_id, topic_id, start_time, end_time,
        actual_duration_minutes, quality, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(sessionId),
        Variable<String>(userId),
        Variable<String>(topicId),
        Variable<int>(startTime.millisecondsSinceEpoch),
        Variable<int>(endTime.millisecondsSinceEpoch),
        Variable<int>(actualDurationMinutes),
        Variable<String>(quality),
        Variable<String>(notes),
      ],
    );
  }

  /// Get study sessions for a date range from the real study_sessions table.
  Future<List<StudySession>> getStudySessionsForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = _databaseService.database;
    final rows = await db.customSelect(
      '''
      SELECT session_id, topic_id, start_time, end_time,
             actual_duration_minutes, quality, notes
      FROM study_sessions
      WHERE user_id = ? AND start_time >= ? AND start_time <= ?
      ORDER BY start_time DESC
      ''',
      variables: [
        Variable<String>(userId),
        Variable<int>(startDate.millisecondsSinceEpoch),
        Variable<int>(endDate.millisecondsSinceEpoch),
      ],
    ).get();

    return rows.map((row) {
      final topicId = row.read<String>('topic_id');
      final actualDuration = row.read<int>('actual_duration_minutes');
      return StudySession(
        id: row.read<String>('session_id'),
        // Not persisted on study_sessions (no task_id column); the caller
        // that created the session already knows which task it came from.
        taskId: '',
        startTime: DateTime.fromMillisecondsSinceEpoch(row.read<int>('start_time')),
        endTime: DateTime.fromMillisecondsSinceEpoch(row.read<int>('end_time')),
        actualDurationMinutes: actualDuration,
        plannedDurationMinutes: actualDuration,
        quality: _mapQuality(row.read<String>('quality')),
        notes: row.readNullable<String>('notes'),
        topicIdsCovered: [topicId],
      );
    }).toList();
  }

  SessionQuality _mapQuality(String quality) {
    return SessionQuality.values.firstWhere(
      (q) => q.name == quality,
      orElse: () => SessionQuality.good,
    );
  }

  /// Get study sessions for a specific task (simplified stub — task id
  /// isn't persisted on study_sessions, see getStudySessionsForDateRange).
  Future<List<StudySession>> getStudySessionsForTask(String taskId) async {
    return [];
  }

  /// Clear all planner data for a user
  Future<void> clearPlannerData(String userId) async {
    final db = _databaseService.database;
    await (db.delete(db.studyPlans)..where((t) => t.userId.equals(userId))).go();
    final safeUserId = userId.replaceAll("'", "''");
    await db.customStatement("DELETE FROM study_sessions WHERE user_id = '$safeUserId'");
  }
}
