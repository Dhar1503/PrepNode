import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/datasources/planner_local_datasource.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:prepgraph/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/planner/presentation/providers/planner_providers.dart';

/// Dashboard Repository Provider
/// Composes Progress Summary / Recent Activity / Upcoming Schedule from
/// data already produced by Insights, Planner and PYQ — no new analytics
/// or datasources of its own.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DashboardRepositoryImpl(
    plannerLocalDataSource: PlannerLocalDataSource(databaseService.database),
    databaseService: databaseService,
    insightsRepository: ref.watch(insightsRepositoryProvider),
    plannerRepository: ref.watch(plannerRepositoryProvider),
    pyqLocalDataSource: ref.watch(pyqLocalDataSourceProvider),
  );
});

/// Dashboard State Provider
/// Manages dashboard data loading and state
class DashboardState {
  final bool isLoadingPlan;
  final bool isLoadingProgress;
  final bool isLoadingActivities;
  final bool isLoadingSchedule;
  final String? errorMessage;
  final dynamic dailyPlan;
  final dynamic progressSummary;
  final dynamic recentActivities;
  final dynamic upcomingSchedule;

  const DashboardState({
    this.isLoadingPlan = true,
    this.isLoadingProgress = true,
    this.isLoadingActivities = true,
    this.isLoadingSchedule = true,
    this.errorMessage,
    this.dailyPlan,
    this.progressSummary,
    this.recentActivities,
    this.upcomingSchedule,
  });

  DashboardState copyWith({
    bool? isLoadingPlan,
    bool? isLoadingProgress,
    bool? isLoadingActivities,
    bool? isLoadingSchedule,
    String? errorMessage,
    dynamic dailyPlan,
    dynamic progressSummary,
    dynamic recentActivities,
    dynamic upcomingSchedule,
  }) {
    return DashboardState(
      isLoadingPlan: isLoadingPlan ?? this.isLoadingPlan,
      isLoadingProgress: isLoadingProgress ?? this.isLoadingProgress,
      isLoadingActivities: isLoadingActivities ?? this.isLoadingActivities,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      errorMessage: errorMessage,
      dailyPlan: dailyPlan ?? this.dailyPlan,
      progressSummary: progressSummary ?? this.progressSummary,
      recentActivities: recentActivities ?? this.recentActivities,
      upcomingSchedule: upcomingSchedule ?? this.upcomingSchedule,
    );
  }
}

/// Dashboard State Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardNotifier(this._dashboardRepository) : super(const DashboardState());

  Future<void> loadDashboardData({required String userId}) async {
    // Load all data in parallel
    final results = await Future.wait([
      _loadDailyPlan(userId),
      _loadProgressSummary(userId),
      _loadRecentActivities(userId),
      _loadUpcomingSchedule(userId),
    ]);

    final planResult = results[0];
    final progressResult = results[1];
    final activitiesResult = results[2];
    final scheduleResult = results[3];

    state = state.copyWith(
      isLoadingPlan: false,
      isLoadingProgress: false,
      isLoadingActivities: false,
      isLoadingSchedule: false,
      dailyPlan: planResult,
      progressSummary: progressResult,
      recentActivities: activitiesResult,
      upcomingSchedule: scheduleResult,
    );
  }

  Future<dynamic> _loadDailyPlan(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await _dashboardRepository.getDailyPlan(
      userId: userId,
      date: today,
    );
    return result.fold(
      (failure) => null,
      (plan) => plan,
    );
  }

  Future<dynamic> _loadProgressSummary(String userId) async {
    final result = await _dashboardRepository.getProgressSummary(
      userId: userId,
    );
    return result.fold(
      (failure) => null,
      (progress) => progress,
    );
  }

  Future<dynamic> _loadRecentActivities(String userId) async {
    final result = await _dashboardRepository.getRecentActivities(
      userId: userId,
      limit: 5,
    );
    return result.fold(
      (failure) => null,
      (activities) => activities,
    );
  }

  Future<dynamic> _loadUpcomingSchedule(String userId) async {
    final result = await _dashboardRepository.getUpcomingSchedule(
      userId: userId,
      limit: 3,
    );
    return result.fold(
      (failure) => null,
      (schedule) => schedule,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Dashboard State Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(dashboardRepository);
});
