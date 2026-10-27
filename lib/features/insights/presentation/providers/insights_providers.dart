import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/core/network/providers/network_providers.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/insights/data/datasources/insights_local_datasource.dart';
import 'package:prepnode/features/insights/data/datasources/insights_remote_datasource.dart';
import 'package:prepnode/features/insights/data/repositories/insights_repository_impl.dart';
import 'package:prepnode/features/insights/domain/entities/learner_progress.dart';
import 'package:prepnode/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepnode/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepnode/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepnode/features/insights/domain/entities/study_habits.dart';
import 'package:prepnode/features/insights/domain/entities/weak_area.dart';
import 'package:prepnode/features/insights/domain/repositories/insights_repository.dart';

// Remote Data Source Provider
final insightsRemoteDataSourceProvider = Provider<InsightsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InsightsRemoteDataSource(apiClient: apiClient);
});

// Local Data Source Provider
final insightsLocalDataSourceProvider = Provider<InsightsLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return InsightsLocalDataSource(databaseService: databaseService);
});

// Repository Provider
final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return InsightsRepositoryImpl(
    remoteDataSource: ref.watch(insightsRemoteDataSourceProvider),
    localDataSource: ref.watch(insightsLocalDataSourceProvider),
  );
});

// Current user id, read from the real auth session.
final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userId ?? '';
});

// Learner Progress Provider
final learnerProgressProvider = FutureProvider<LearnerProgress>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getLearnerProgress(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (progress) => progress,
  );
});

// Mastery Analytics Provider
final masteryAnalyticsProvider = FutureProvider<MasteryAnalytics>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getMasteryAnalytics(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

// PYQ Performance Provider
final pyqPerformanceProvider = FutureProvider<PyqPerformance>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getPyqPerformance(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (performance) => performance,
  );
});

// Mock Test Analytics Provider
final mockTestAnalyticsProvider = FutureProvider<MockTestAnalytics>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getMockTestAnalytics(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analytics) => analytics,
  );
});

// Study Habits Provider
final studyHabitsProvider = FutureProvider<StudyHabits>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getStudyHabits(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (habits) => habits,
  );
});

/// Ids of recommendations the user has dismissed/completed this session.
/// Recommendations are computed fresh from weak-topic data on every read
/// (see InsightsRepositoryImpl.getWeakAreas) rather than stored as rows, so
/// there's nothing to persist server- or DB-side for "completed" — this
/// keeps the dismissal itself real (it sticks for the session) without
/// inventing a table for ephemeral, re-derivable UI state.
final dismissedRecommendationIdsProvider = StateProvider<Set<String>>((ref) => const {});

// Weak Areas Provider
final weakAreasProvider = FutureProvider<WeakArea>((ref) async {
  final repository = ref.watch(insightsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final result = await repository.getWeakAreas(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (areas) => areas,
  );
});

// Subject Mastery Provider (for specific subject)
final subjectMasteryProvider = FutureProvider.family<MasteryAnalytics, String>(
  (ref, subjectId) async {
    final repository = ref.watch(insightsRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);
    final result = await repository.getSubjectMastery(userId, subjectId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (analytics) => analytics,
    );
  },
);

// Subject PYQ Performance Provider (for specific subject)
final subjectPyqPerformanceProvider = FutureProvider.family<PyqPerformance, String>(
  (ref, subjectId) async {
    final repository = ref.watch(insightsRepositoryProvider);
    final userId = ref.watch(currentUserIdProvider);
    final result = await repository.getSubjectPyqPerformance(userId, subjectId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (performance) => performance,
    );
  },
);
