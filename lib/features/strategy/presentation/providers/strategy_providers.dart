import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/planner/presentation/providers/planner_providers.dart';
import 'package:prepnode/features/pyq/presentation/providers/pyq_providers.dart';
import 'package:prepnode/features/strategy/data/repositories/strategy_repository_impl.dart';
import 'package:prepnode/features/strategy/domain/entities/roadmap.dart';
import 'package:prepnode/features/strategy/domain/entities/strategy_recommendation.dart';
import 'package:prepnode/features/strategy/domain/entities/strategy_summary.dart';
import 'package:prepnode/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepnode/features/strategy/domain/repositories/strategy_repository.dart';

/// Composes existing repositories — no new datasource, no new database
/// table. Same pattern as DashboardRepositoryImpl / CutoffRepositoryImpl.
final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  return StrategyRepositoryImpl(
    insightsRepository: ref.watch(insightsRepositoryProvider),
    pyqRepository: ref.watch(pyqRepositoryProvider),
    plannerRepository: ref.watch(plannerRepositoryProvider),
    cutoffRepository: ref.watch(cutoffRepositoryProvider),
    knowledgeGraphRepository: ref.watch(knowledgeGraphRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

final studyCapacityProvider = FutureProvider<StudyCapacity>((ref) async {
  final repository = ref.watch(strategyRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  if (userId == null) throw Exception('Not signed in');
  final result = await repository.getStudyCapacity(userId);
  return result.fold((failure) => throw Exception(failure.message), (c) => c);
});

final nextBestTopicsProvider =
    FutureProvider.family<List<StrategyRecommendation>, String>((ref, examId) async {
  final repository = ref.watch(strategyRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  final category = ref.watch(selectedCutoffCategoryProvider);
  if (userId == null) throw Exception('Not signed in');
  final result = await repository.getNextBestTopics(userId: userId, examId: examId, category: category);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
});

/// Roadmap length in days, user-selectable (7/30/90), persisted only for
/// the current session — this is a view preference, not profile data.
final roadmapLengthProvider = StateProvider<int>((ref) => 30);

final roadmapProvider = FutureProvider.family<Roadmap, String>((ref, examId) async {
  final repository = ref.watch(strategyRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  final category = ref.watch(selectedCutoffCategoryProvider);
  final days = ref.watch(roadmapLengthProvider);
  if (userId == null) throw Exception('Not signed in');
  final result = await repository.getRoadmap(userId: userId, examId: examId, category: category, days: days);
  return result.fold((failure) => throw Exception(failure.message), (r) => r);
});

final strategySummaryProvider = FutureProvider.family<StrategySummary, String>((ref, examId) async {
  final repository = ref.watch(strategyRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  final category = ref.watch(selectedCutoffCategoryProvider);
  if (userId == null) throw Exception('Not signed in');
  final result = await repository.getStrategySummary(userId: userId, examId: examId, category: category);
  return result.fold((failure) => throw Exception(failure.message), (s) => s);
});
