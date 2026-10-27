import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/planner/domain/entities/daily_plan.dart';
import 'package:prepnode/features/planner/domain/entities/planner_task.dart';
import 'package:prepnode/features/planner/domain/entities/study_session.dart';
import 'package:prepnode/features/planner/domain/entities/weekly_plan.dart';

/// Planner Repository Interface
/// Abstract contract for planner data operations
abstract class PlannerRepository {
  /// Get daily plan for a specific date
  Future<Either<Failure, DailyPlan>> getDailyPlan({
    required String userId,
    required DateTime date,
  });

  /// Get weekly plan
  Future<Either<Failure, WeeklyPlan>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  });

  /// Update task status
  Future<Either<Failure, PlannerTask>> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  });

  /// Reschedule task to new date
  Future<Either<Failure, PlannerTask>> rescheduleTask({
    required String taskId,
    required DateTime newDate,
  });

  /// Create a new manually-added study task
  Future<Either<Failure, PlannerTask>> createTask({
    required String userId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    required DateTime scheduledDate,
    String? reason,
  });

  /// Edit an existing task's details (title/duration/type/reason).
  /// The task's status and schedule date are left untouched — use
  /// [updateTaskStatus] / [rescheduleTask] for those.
  Future<Either<Failure, PlannerTask>> editTask({
    required String taskId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    String? reason,
  });

  /// Permanently delete a task/plan
  Future<Either<Failure, void>> deleteTask(String taskId);

  /// Complete task with session data, persisting a real study_sessions row
  Future<Either<Failure, StudySession>> completeTaskWithSession({
    required String userId,
    required String taskId,
    required String topicId,
    required DateTime startTime,
    required DateTime endTime,
    required int actualDurationMinutes,
    required SessionQuality quality,
    String? notes,
  });

  /// Get study sessions for a date range
  Future<Either<Failure, List<StudySession>>> getStudySessions({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generate adaptive plan based on progress
  Future<Either<Failure, DailyPlan>> generateAdaptivePlan({
    required String userId,
    required DateTime date,
  });

  /// Get smart break suggestion
  Future<Either<Failure, String>> getBreakSuggestion({
    required String userId,
    required int consecutiveStudyMinutes,
  });
}
