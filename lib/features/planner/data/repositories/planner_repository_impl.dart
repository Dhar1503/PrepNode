import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:prepnode/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:prepnode/features/planner/domain/entities/daily_plan.dart';
import 'package:prepnode/features/planner/domain/entities/planner_task.dart';
import 'package:prepnode/features/planner/domain/entities/study_session.dart';
import 'package:prepnode/features/planner/domain/entities/weekly_plan.dart';
import 'package:prepnode/features/planner/domain/repositories/planner_repository.dart';

/// Production Planner Repository Implementation
/// Uses remote API and local database with offline-first strategy
class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource _remoteDataSource;
  final PlannerLocalDataSource _localDataSource;

  PlannerRepositoryImpl({
    required PlannerRemoteDataSource remoteDataSource,
    required PlannerLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, DailyPlan>> getDailyPlan({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // No live planner backend exists (see PlannerRemoteDataSource — real
      // Dio calls with no server behind them), so the local study_plans
      // table is the actual source of truth rather than a cache in front
      // of a remote fetch. This also fixes persistence across app restart:
      // previously an empty local cache always fell through to a doomed
      // remote call that failed and surfaced as an error state.
      final tasks = await _localDataSource.getStudyPlansForDate(
        userId: userId,
        date: date,
      );

      return Right(DailyPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        tasks: tasks,
        totalStudyMinutes: tasks.fold(0, (sum, task) => sum + task.durationMinutes),
        completedMinutes: tasks
            .where((task) => task.status == TaskStatus.completed)
            .fold(0, (sum, task) => sum + task.durationMinutes),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, WeeklyPlan>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  }) async {
    try {
      // Fetch from API (weekly plans change frequently)
      final weeklyPlan = await _remoteDataSource.getWeeklyPlan(
        userId: userId,
        weekStart: weekStart,
      );

      return Right(weeklyPlan);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PlannerTask>> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    // Local-first, deliberately. `study_plans` is already the source of
    // truth that getDailyPlan reads back, and this app ships with no
    // backend, so the previous "call the API, fall back on NetworkFailure"
    // shape had two problems: every tick of a checkbox waited out a DNS
    // failure first, and any error that did not map to NetworkFailure
    // (which is most of them) returned Left without ever writing the
    // status — so the task un-ticked itself on the next restart.
    return _updateTaskStatusLocally(taskId: taskId, status: status);
  }

  Future<Either<Failure, PlannerTask>> _updateTaskStatusLocally({
    required String taskId,
    required TaskStatus status,
  }) async {
    try {
      await _localDataSource.updateStudyPlanStatus(planId: taskId, status: status.name);
      final task = await _localDataSource.getStudyPlanById(taskId);
      if (task == null) {
        return Left(DatabaseFailure.notFound(entity: 'Task'));
      }
      return Right(task);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PlannerTask>> rescheduleTask({
    required String taskId,
    required DateTime newDate,
  }) async {
    try {
      // Reschedule via API
      final rescheduledTask = await _remoteDataSource.rescheduleTask(
        taskId: taskId,
        newDate: newDate,
      );

      // Update local cache
      await _localDataSource.rescheduleStudyPlan(
        planId: taskId,
        newDate: newDate,
      );

      return Right(rescheduledTask);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      // Backend unreachable — same local-source-of-truth reasoning as
      // updateTaskStatus above.
      try {
        await _localDataSource.rescheduleStudyPlan(planId: taskId, newDate: newDate);
        final task = await _localDataSource.getStudyPlanById(taskId);
        if (task == null) {
          return Left(DatabaseFailure.notFound(entity: 'Task'));
        }
        return Right(task);
      } catch (e2) {
        return Left(_mapErrorToFailure(e2));
      }
    }
  }

  @override
  Future<Either<Failure, StudySession>> completeTaskWithSession({
    required String userId,
    required String taskId,
    required String topicId,
    required DateTime startTime,
    required DateTime endTime,
    required int actualDurationMinutes,
    required SessionQuality quality,
    String? notes,
  }) async {
    try {
      // Save session locally — this is what makes the session visible to
      // Insights (study habits, consistency) and Dashboard.
      await _localDataSource.saveStudySession(
        userId: userId,
        topicId: topicId,
        startTime: startTime,
        endTime: endTime,
        actualDurationMinutes: actualDurationMinutes,
        quality: quality.name,
        notes: notes,
      );

      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        startTime: startTime,
        endTime: endTime,
        actualDurationMinutes: actualDurationMinutes,
        plannedDurationMinutes: actualDurationMinutes,
        quality: quality,
        notes: notes,
        topicIdsCovered: [topicId],
      );

      return Right(session);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getStudySessions({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get from local database
      final sessions = await _localDataSource.getStudySessionsForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(sessions);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, DailyPlan>> generateAdaptivePlan({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Generate via API
      final adaptivePlan = await _remoteDataSource.generateAdaptivePlan(
        userId: userId,
        date: date,
      );

      // Cache locally
      for (final task in adaptivePlan.tasks) {
        await _localDataSource.saveStudyPlan(
          planId: task.id,
          userId: userId,
          topicId: task.topicId,
          date: task.scheduledDate,
          title: task.title,
          durationMinutes: task.durationMinutes,
          type: task.type.name,
          priority: 'medium',
          reason: task.reason,
          status: task.status.name,
        );
      }

      return Right(adaptivePlan);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PlannerTask>> createTask({
    required String userId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    required DateTime scheduledDate,
    String? reason,
  }) async {
    try {
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      await _localDataSource.saveStudyPlan(
        planId: taskId,
        userId: userId,
        topicId: topicId,
        date: scheduledDate,
        title: title,
        durationMinutes: durationMinutes,
        type: type.name,
        priority: 'medium',
        reason: reason,
        status: TaskStatus.pending.name,
      );

      return Right(PlannerTask(
        id: taskId,
        topicId: topicId,
        title: title,
        durationMinutes: durationMinutes,
        reason: reason ?? '',
        type: type,
        status: TaskStatus.pending,
        scheduledDate: scheduledDate,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PlannerTask>> editTask({
    required String taskId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    String? reason,
  }) async {
    try {
      await _localDataSource.updateStudyPlanDetails(
        planId: taskId,
        topicId: topicId,
        title: title,
        durationMinutes: durationMinutes,
        type: type.name,
        reason: reason,
      );

      final updatedTask = await _localDataSource.getStudyPlanById(taskId);
      if (updatedTask == null) {
        return Left(UnknownFailure('Task not found after update'));
      }
      return Right(updatedTask);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _localDataSource.deleteStudyPlan(taskId);
      return const Right(null);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> getBreakSuggestion({
    required String userId,
    required int consecutiveStudyMinutes,
  }) async {
    try {
      // Get from API
      final suggestion = await _remoteDataSource.getBreakSuggestion(
        userId: userId,
        consecutiveStudyMinutes: consecutiveStudyMinutes,
      );

      return Right(suggestion);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
