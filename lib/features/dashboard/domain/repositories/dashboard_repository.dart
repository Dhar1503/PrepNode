import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/dashboard/domain/entities/daily_plan.dart';
import 'package:prepnode/features/dashboard/domain/entities/progress_summary.dart';
import 'package:prepnode/features/dashboard/domain/entities/recent_activity.dart';
import 'package:prepnode/features/dashboard/domain/entities/upcoming_schedule.dart';

/// Dashboard Repository Interface
/// Abstract contract for dashboard data operations
abstract class DashboardRepository {
  /// Get daily plan for a specific date
  Future<Either<Failure, DailyPlan>> getDailyPlan({
    required String userId,
    required String date,
  });

  /// Get progress summary
  Future<Either<Failure, ProgressSummary>> getProgressSummary({
    required String userId,
  });

  /// Get recent activities
  Future<Either<Failure, List<RecentActivity>>> getRecentActivities({
    required String userId,
    int limit = 5,
  });

  /// Get upcoming schedule
  Future<Either<Failure, List<UpcomingSchedule>>> getUpcomingSchedule({
    required String userId,
    int limit = 3,
  });

  /// Update task status
  Future<Either<Failure, void>> updateTaskStatus({
    required String taskId,
    required String status,
  });
}
