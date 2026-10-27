import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/data/datasources/planner_local_datasource.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/dashboard/domain/entities/daily_plan.dart';
import 'package:prepnode/features/dashboard/domain/entities/daily_task.dart';
import 'package:prepnode/features/dashboard/domain/entities/progress_summary.dart' as domain;
import 'package:prepnode/features/dashboard/domain/entities/recent_activity.dart' as domain;
import 'package:prepnode/features/dashboard/domain/entities/upcoming_schedule.dart' as domain;
import 'package:prepnode/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:prepnode/features/insights/domain/repositories/insights_repository.dart';
import 'package:prepnode/features/planner/domain/entities/study_session.dart';
import 'package:prepnode/features/planner/domain/repositories/planner_repository.dart';
import 'package:prepnode/features/pyq/data/datasources/pyq_local_datasource.dart';

/// Dashboard Repository Implementation
/// getDailyPlan/updateTaskStatus are backed by the local Drift database
/// (study_plans table, via the existing core PlannerLocalDataSource).
/// getProgressSummary/getRecentActivities/getUpcomingSchedule are composed
/// entirely from data already produced elsewhere — Insights (topic
/// completion + streak), Planner (study sessions, upcoming study plans),
/// PYQ (attempt history) and Mock Tests (completed attempts) — rather than
/// computing new analytics of their own.
class DashboardRepositoryImpl implements DashboardRepository {
  final PlannerLocalDataSource _plannerLocalDataSource;
  final DatabaseService _databaseService;
  final InsightsRepository _insightsRepository;
  final PlannerRepository _plannerRepository;
  final PyqLocalDataSource _pyqLocalDataSource;

  DashboardRepositoryImpl({
    required PlannerLocalDataSource plannerLocalDataSource,
    required DatabaseService databaseService,
    required InsightsRepository insightsRepository,
    required PlannerRepository plannerRepository,
    required PyqLocalDataSource pyqLocalDataSource,
  })  : _plannerLocalDataSource = plannerLocalDataSource,
        _databaseService = databaseService,
        _insightsRepository = insightsRepository,
        _plannerRepository = plannerRepository,
        _pyqLocalDataSource = pyqLocalDataSource;

  @override
  Future<Either<Failure, DailyPlan>> getDailyPlan({
    required String userId,
    required String date,
  }) async {
    final result = await _plannerLocalDataSource.getStudyPlansForDate(
      userId,
      DateTime.parse(date),
    );

    return result.fold(
      onSuccess: (plans) {
        final tasks = plans
            .map((plan) => DailyTask(
                  id: plan.planId,
                  topicName: plan.title,
                  durationMinutes: plan.durationMinutes,
                  reason: plan.reason ?? '',
                  status: TaskStatus.values.firstWhere(
                    (s) => s.name == plan.status,
                    orElse: () => TaskStatus.pending,
                  ),
                  // study_plans.type also carries 'break_'/'mockTest' (from
                  // the Planner feature's own, larger TaskType enum) which
                  // this Dashboard-local TaskType doesn't have entries for.
                  type: TaskType.values.firstWhere(
                    (t) => t.name == plan.type,
                    orElse: () => TaskType.learn,
                  ),
                ))
            .toList();

        return Right(DailyPlan(date: date, tasks: tasks));
      },
      onFailure: (failure) => Left(DatabaseFailure.queryFailed(originalError: failure)),
    );
  }

  @override
  Future<Either<Failure, domain.ProgressSummary>> getProgressSummary({
    required String userId,
  }) async {
    try {
      final progressResult = await _insightsRepository.getLearnerProgress(userId);
      final habitsResult = await _insightsRepository.getStudyHabits(userId);

      return progressResult.fold(
        (failure) => Left(failure),
        (learnerProgress) => habitsResult.fold(
          (failure) => Left(failure),
          (habits) {
            // Reconstruct a full 30-day window (habits.dailyData only
            // contains days that actually had a session) so the streak
            // calendar has one entry per day, same shape the UI expects.
            final minutesByDay = {
              for (final day in habits.dailyData) _dayKey(day.date): day.totalStudyMinutes,
            };
            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final streakData = List.generate(30, (index) {
              final date = todayStart.subtract(Duration(days: 29 - index));
              final minutes = minutesByDay[_dayKey(date)];
              return domain.StreakDay(
                date: date,
                studied: (minutes ?? 0) > 0,
                minutesStudied: minutes,
              );
            });

            return Right(domain.ProgressSummary(
              syllabusCoveragePercent:
                  (learnerProgress.scoreComponents.topicCompletion / 100).clamp(0.0, 1.0),
              streakData: streakData,
              currentStreak: habits.weeklyStats.currentStreak,
              totalStudyDays: streakData.where((d) => d.studied).length,
            ));
          },
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  @override
  Future<Either<Failure, List<domain.RecentActivity>>> getRecentActivities({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final sessionActivities = await _buildSessionActivities(userId, limit);
      final pyqActivities = await _buildPyqActivities(userId, limit);
      final mockTestActivities = await _buildMockTestActivities(userId, limit);

      final all = [...sessionActivities, ...pyqActivities, ...mockTestActivities]
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      return Right(all.take(limit).toList());
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  /// Recent completed Planner study sessions (real study_sessions rows via
  /// the existing PlannerRepository — same source Insights' study-habit
  /// streak comes from).
  Future<List<domain.RecentActivity>> _buildSessionActivities(String userId, int limit) async {
    try {
      final since = DateTime.now().subtract(const Duration(days: 30));
      final result = await _plannerRepository.getStudySessions(
        userId: userId,
        startDate: since,
        endDate: DateTime.now(),
      );

      final sessions = result.fold((_) => const <StudySession>[], (list) => list);
      final sorted = [...sessions]..sort((a, b) => b.endTime.compareTo(a.endTime));

      final activities = <domain.RecentActivity>[];
      for (final session in sorted.take(limit)) {
        final topicId = session.topicIdsCovered.isNotEmpty ? session.topicIdsCovered.first : null;
        final topicName = topicId == null ? null : await _resolveTopicName(topicId);

        activities.add(domain.RecentActivity(
          id: session.id,
          title: topicName != null ? 'Studied: $topicName' : 'Study Session Completed',
          subtitle: _describeSessionQuality(session.quality),
          completedAt: session.endTime,
          type: domain.ActivityType.topicCompleted,
          durationMinutes: session.actualDurationMinutes,
        ));
      }
      return activities;
    } catch (_) {
      return const [];
    }
  }

  /// Recent PYQ attempts (real user_question_attempts rows via the existing
  /// PyqLocalDataSource).
  Future<List<domain.RecentActivity>> _buildPyqActivities(String userId, int limit) async {
    try {
      final attempts = await _pyqLocalDataSource.getQuestionAttempts(userId);
      final sorted = [...attempts]
        ..sort((a, b) => (b['attemptDate'] as DateTime).compareTo(a['attemptDate'] as DateTime));

      final activities = <domain.RecentActivity>[];
      for (final attempt in sorted.take(limit)) {
        final questionId = attempt['questionId'] as String;
        final question = await _pyqLocalDataSource.getQuestionById(questionId);
        final isCorrect = attempt['isCorrect'] as bool;
        final timeTakenSeconds = attempt['timeTakenSeconds'] as int;

        activities.add(domain.RecentActivity(
          id: attempt['attemptId'] as String,
          title: 'PYQ Practice',
          subtitle: question != null
              ? _truncate(question.questionText)
              : (isCorrect ? 'Correct answer' : 'Incorrect answer'),
          completedAt: attempt['attemptDate'] as DateTime,
          type: domain.ActivityType.pyqPractice,
          durationMinutes: (timeTakenSeconds / 60).round(),
        ));
      }
      return activities;
    } catch (_) {
      return const [];
    }
  }

  /// Recently completed Mock Tests (real mock_tests rows, queried directly
  /// the same way InsightsLocalDataSource does — MockTestRepository's own
  /// getTestHistory() is remote-only and has no backend to reach).
  Future<List<domain.RecentActivity>> _buildMockTestActivities(String userId, int limit) async {
    try {
      final db = _databaseService.database;
      final query = db.select(db.mockTests)
        ..where((t) => t.userId.equals(userId) & t.status.equals('completed'))
        ..orderBy([(t) => OrderingTerm.desc(t.submittedAt)])
        ..limit(limit);
      final tests = await query.get();

      return tests
          .where((t) => t.submittedAt != null)
          .map((test) => domain.RecentActivity(
                id: test.testId,
                title: 'Mock Test Completed',
                subtitle: test.score != null ? 'Score: ${test.score!.toStringAsFixed(0)}%' : null,
                completedAt: test.submittedAt!,
                type: domain.ActivityType.mockTest,
                durationMinutes: test.durationMinutes,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Either<Failure, List<domain.UpcomingSchedule>>> getUpcomingSchedule({
    required String userId,
    int limit = 3,
  }) async {
    try {
      final now = DateTime.now();
      final startOfTomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final horizon = startOfTomorrow.add(const Duration(days: 30));

      // Upcoming schedule is exactly the user's own future Planner tasks —
      // Planner is already the source of truth for what's scheduled ahead.
      final result = await _plannerLocalDataSource.getStudyPlans(
        userId,
        startDate: startOfTomorrow,
        endDate: horizon,
      );

      return result.fold(
        onSuccess: (plans) {
          final items = plans
              .map((plan) => domain.UpcomingSchedule(
                    id: plan.planId,
                    title: plan.title,
                    scheduledAt: plan.date,
                    type: _mapScheduleType(plan.type),
                    description: plan.reason,
                  ))
              .take(limit)
              .toList();
          return Right(items);
        },
        onFailure: (failure) => Left(DatabaseFailure.queryFailed(originalError: failure)),
      );
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  domain.ScheduleType _mapScheduleType(String type) {
    switch (type) {
      case 'mockTest':
        return domain.ScheduleType.mockTest;
      case 'revision':
        return domain.ScheduleType.revision;
      default:
        return domain.ScheduleType.milestone;
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final result = await _plannerLocalDataSource.updateStudyPlanStatus(taskId, status);

    return result.fold(
      onSuccess: (_) => const Right(null),
      onFailure: (failure) => Left(DatabaseFailure.queryFailed(originalError: failure)),
    );
  }

  Future<String?> _resolveTopicName(String topicId) async {
    final db = _databaseService.database;
    final row =
        await (db.select(db.topics)..where((t) => t.topicId.equals(topicId))).getSingleOrNull();
    return row?.topicName;
  }

  String _describeSessionQuality(SessionQuality quality) {
    switch (quality) {
      case SessionQuality.excellent:
        return 'Excellent focus';
      case SessionQuality.good:
        return 'Good session';
      case SessionQuality.fair:
        return 'Fair session';
      case SessionQuality.poor:
        return 'Difficult session';
    }
  }

  String _truncate(String text, [int maxLength = 60]) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
