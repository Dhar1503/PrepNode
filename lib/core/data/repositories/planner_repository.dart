import '../datasources/planner_local_datasource.dart';
import '../dtos/planning_dto.dart';
import '../result.dart';
import 'base_repository.dart';
import 'package:uuid/uuid.dart';

// Task types and statuses (matching domain entities)
enum TaskType {
  learn,
  pyq,
  revision,
  break_,
  mockTest,
}

enum TaskStatus {
  pending,
  completed,
  skipped,
  inProgress,
}

/// Repository for Planner-related operations
/// Handles Study Plans, User Topic Progress, Confidence Check-ins
class PlannerRepository extends BaseRepositoryImpl {
  final PlannerLocalDataSource _localDataSource;

  PlannerRepository(this._localDataSource);

  // ==================== STUDY PLANS ====================

  /// Get study plans for a user for a specific date range
  Future<Result<List<StudyPlanDto>>> getStudyPlans(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _localDataSource.getStudyPlans(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get study plan for a specific date
  Future<Result<List<StudyPlanDto>>> getStudyPlansForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final result = await _localDataSource.getStudyPlansForDate(userId, date);
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get study plan by ID
  Future<Result<StudyPlanDto>> getStudyPlanById(String planId) async {
    try {
      final result = await _localDataSource.getStudyPlanById(planId);
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create study plan
  Future<Result<StudyPlanDto>> createStudyPlan({
    required String userId,
    required String topicId,
    required DateTime date,
    required String title,
    required int durationMinutes,
    required TaskType type,
    String priority = 'medium',
    String? reason,
    TaskStatus status = TaskStatus.pending,
  }) async {
    try {
      final dto = StudyPlanDto(
        planId: const Uuid().v4(),
        userId: userId,
        topicId: topicId,
        date: date,
        title: title,
        durationMinutes: durationMinutes,
        type: _taskTypeToString(type),
        priority: priority,
        reason: reason,
        status: _taskStatusToString(status),
      );

      final result = await _localDataSource.createStudyPlan(dto);
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update study plan
  Future<Result<StudyPlanDto>> updateStudyPlan(StudyPlanDto plan) async {
    try {
      final result = await _localDataSource.updateStudyPlan(plan);
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update study plan status
  Future<Result<void>> updateStudyPlanStatus(
    String planId,
    TaskStatus status,
  ) async {
    try {
      final result = await _localDataSource.updateStudyPlanStatus(
        planId,
        _taskStatusToString(status),
      );
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Delete study plan
  Future<Result<void>> deleteStudyPlan(String planId) async {
    try {
      return await _localDataSource.deleteStudyPlan(planId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== USER TOPIC PROGRESS ====================

  /// Get user topic progress
  Future<Result<Map<String, dynamic>>> getUserTopicProgress(
    String userId,
    String topicId,
  ) async {
    try {
      final result = await _localDataSource.getUserTopicProgress(userId, topicId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toJson()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get all user topic progress
  Future<Result<List<Map<String, dynamic>>>> getAllUserTopicProgress(
    String userId,
  ) async {
    try {
      final result = await _localDataSource.getAllUserTopicProgress(userId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toJson()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update user topic progress
  Future<Result<void>> updateUserTopicProgress(
    String userId,
    String topicId, {
    double? masteryPercentage,
    double? accuracy,
    DateTime? lastRevisionDate,
  }) async {
    try {
      // Get existing progress first
      final existingResult = await _localDataSource.getUserTopicProgress(userId, topicId);
      
      return existingResult.fold(
        onSuccess: (existing) {
          final updated = UserTopicProgressDto(
            progressId: existing.progressId,
            userId: userId,
            topicId: topicId,
            masteryPercentage: masteryPercentage ?? existing.masteryPercentage,
            accuracy: accuracy ?? existing.accuracy,
            lastRevisionDate: lastRevisionDate ?? existing.lastRevisionDate,
          );
          return _localDataSource.updateUserTopicProgress(updated);
        },
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== CONFIDENCE CHECK-INS ====================

  /// Get confidence check-ins for a user
  Future<Result<List<Map<String, dynamic>>>> getConfidenceCheckins(
    String userId, {
    String? topicId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _localDataSource.getConfidenceCheckins(
        userId,
        topicId: topicId,
        startDate: startDate,
        endDate: endDate,
      );
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toJson()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create confidence check-in
  Future<Result<void>> createConfidenceCheckin({
    required String userId,
    required String topicId,
    required int confidenceLevel,
    required DateTime weekOf,
  }) async {
    try {
      final dto = ConfidenceCheckinDto(
        checkinId: const Uuid().v4(),
        userId: userId,
        topicId: topicId,
        confidenceLevel: confidenceLevel,
        weekOf: weekOf,
      );

      final result = await _localDataSource.createConfidenceCheckin(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // Helper methods
  String _taskTypeToString(TaskType type) {
    switch (type) {
      case TaskType.learn:
        return 'learn';
      case TaskType.pyq:
        return 'pyq';
      case TaskType.revision:
        return 'revision';
      case TaskType.mockTest:
        return 'mock';
      case TaskType.break_:
        return 'break';
    }
  }

  String _taskStatusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.skipped:
        return 'skipped';
      case TaskStatus.inProgress:
        return 'in_progress';
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _localDataSource.clearAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }
}
