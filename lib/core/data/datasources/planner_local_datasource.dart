import '../database/database.dart';
import '../dtos/planning_dto.dart';
import '../failures.dart';
import '../result.dart';
import 'local_datasource.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Local data source for Planner-related operations
/// Handles Study Plans, User Topic Progress, Confidence Check-ins
class PlannerLocalDataSource extends BaseLocalDataSource {
  PlannerLocalDataSource(super.database);

  // ==================== STUDY PLANS ====================

  /// Get study plans for a user for a specific date range
  Future<Result<List<StudyPlanDto>>> getStudyPlans(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = database.select(database.studyPlans)
        ..where((tbl) => tbl.userId.equals(userId));

      if (startDate != null) {
        query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
      }

      query.orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);

      final results = await query.get();

      final dtos = results.map((p) => StudyPlanDto(
        planId: p.planId,
        userId: p.userId,
        topicId: p.topicId,
        date: p.date,
        title: p.title,
        durationMinutes: p.durationMinutes,
        type: p.type,
        priority: p.priority,
        reason: p.reason,
        status: p.status,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get study plan for a specific date
  Future<Result<List<StudyPlanDto>>> getStudyPlansForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getStudyPlans(
        userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get study plan by ID
  Future<Result<StudyPlanDto>> getStudyPlanById(String planId) async {
    try {
      final result = await (database.select(database.studyPlans)
            ..where((tbl) => tbl.planId.equals(planId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Study Plan'));
      }

      final dto = StudyPlanDto(
        planId: result.planId,
        userId: result.userId,
        topicId: result.topicId,
        date: result.date,
        title: result.title,
        durationMinutes: result.durationMinutes,
        type: result.type,
        priority: result.priority,
        reason: result.reason,
        status: result.status,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create study plan
  Future<Result<StudyPlanDto>> createStudyPlan(StudyPlanDto plan) async {
    try {
      await database.into(database.studyPlans).insert(
        StudyPlansCompanion.insert(
          planId: plan.planId,
          userId: plan.userId,
          topicId: plan.topicId,
          date: plan.date,
          title: plan.title,
          durationMinutes: plan.durationMinutes,
          type: plan.type,
          priority: Value(plan.priority),
          reason: Value(plan.reason),
          status: Value(plan.status),
        ),
      );

      return Result.success(plan);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update study plan
  Future<Result<StudyPlanDto>> updateStudyPlan(StudyPlanDto plan) async {
    try {
      await database.update(database.studyPlans).replace(
        StudyPlansCompanion(
          planId: Value(plan.planId),
          userId: Value(plan.userId),
          topicId: Value(plan.topicId),
          date: Value(plan.date),
          title: Value(plan.title),
          durationMinutes: Value(plan.durationMinutes),
          type: Value(plan.type),
          priority: Value(plan.priority),
          reason: Value(plan.reason),
          status: Value(plan.status),
        ),
      );

      return Result.success(plan);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update study plan status
  Future<Result<void>> updateStudyPlanStatus(
    String planId,
    String status,
  ) async {
    try {
      await (database.update(database.studyPlans)
          ..where((tbl) => tbl.planId.equals(planId)))
          .write(
            StudyPlansCompanion(
              status: Value(status),
            ),
          );

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Delete study plan
  Future<Result<void>> deleteStudyPlan(String planId) async {
    try {
      await (database.delete(database.studyPlans)
            ..where((tbl) => tbl.planId.equals(planId)))
          .go();

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== USER TOPIC PROGRESS ====================

  /// Get user topic progress
  Future<Result<UserTopicProgressDto>> getUserTopicProgress(
    String userId,
    String topicId,
  ) async {
    try {
      final result = await (database.select(database.userTopicProgress)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.topicId.equals(topicId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        // Create default progress
        final defaultProgress = UserTopicProgressDto(
          progressId: const Uuid().v4(),
          userId: userId,
          topicId: topicId,
          masteryPercentage: 0.0,
          accuracy: null,
          lastRevisionDate: null,
        );

        await database.into(database.userTopicProgress).insert(
          UserTopicProgressCompanion.insert(
            progressId: defaultProgress.progressId,
            userId: defaultProgress.userId,
            topicId: defaultProgress.topicId,
          ),
        );

        return Result.success(defaultProgress);
      }

      final dto = UserTopicProgressDto(
        progressId: result.progressId,
        userId: result.userId,
        topicId: result.topicId,
        masteryPercentage: result.masteryPercentage,
        accuracy: result.accuracy,
        lastRevisionDate: result.lastRevisionDate,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get all user topic progress
  Future<Result<List<UserTopicProgressDto>>> getAllUserTopicProgress(
    String userId,
  ) async {
    try {
      final results = await (database.select(database.userTopicProgress)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      final dtos = results.map((p) => UserTopicProgressDto(
        progressId: p.progressId,
        userId: p.userId,
        topicId: p.topicId,
        masteryPercentage: p.masteryPercentage,
        accuracy: p.accuracy,
        lastRevisionDate: p.lastRevisionDate,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update user topic progress
  Future<Result<UserTopicProgressDto>> updateUserTopicProgress(
    UserTopicProgressDto progress,
  ) async {
    try {
      final existing = await (database.select(database.userTopicProgress)
            ..where((tbl) => tbl.progressId.equals(progress.progressId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.userTopicProgress).replace(
          UserTopicProgressCompanion(
            progressId: Value(progress.progressId),
            userId: Value(progress.userId),
            topicId: Value(progress.topicId),
            masteryPercentage: Value(progress.masteryPercentage),
            accuracy: Value(progress.accuracy),
            lastRevisionDate: Value(progress.lastRevisionDate),
          ),
        );
      } else {
        await database.into(database.userTopicProgress).insert(
          UserTopicProgressCompanion.insert(
            progressId: progress.progressId,
            userId: progress.userId,
            topicId: progress.topicId,
            masteryPercentage: Value(progress.masteryPercentage),
          ),
        );
      }

      return Result.success(progress);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== CONFIDENCE CHECK-INS ====================

  /// Get confidence check-ins for a user
  Future<Result<List<ConfidenceCheckinDto>>> getConfidenceCheckins(
    String userId, {
    String? topicId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = database.select(database.confidenceCheckins)
        ..where((tbl) => tbl.userId.equals(userId));

      if (topicId != null) {
        query.where((tbl) => tbl.topicId.equals(topicId));
      }
      if (startDate != null) {
        query.where((tbl) => tbl.weekOf.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((tbl) => tbl.weekOf.isSmallerOrEqualValue(endDate));
      }

      query.orderBy([(tbl) => OrderingTerm.desc(tbl.weekOf)]);

      final results = await query.get();

      final dtos = results.map((c) => ConfidenceCheckinDto(
        checkinId: c.checkinId,
        userId: c.userId,
        topicId: c.topicId,
        confidenceLevel: c.confidenceLevel,
        weekOf: c.weekOf,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create confidence check-in
  Future<Result<ConfidenceCheckinDto>> createConfidenceCheckin(
    ConfidenceCheckinDto checkin,
  ) async {
    try {
      await database.into(database.confidenceCheckins).insert(
        ConfidenceCheckinsCompanion.insert(
          checkinId: checkin.checkinId,
          userId: checkin.userId,
          topicId: checkin.topicId,
          confidenceLevel: checkin.confidenceLevel,
          weekOf: checkin.weekOf,
        ),
      );

      return Result.success(checkin);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await database.delete(database.studyPlans).go();
      await database.delete(database.userTopicProgress).go();
      await database.delete(database.confidenceCheckins).go();
    } catch (e) {
      throw handleDatabaseError(e);
    }
  }
}
