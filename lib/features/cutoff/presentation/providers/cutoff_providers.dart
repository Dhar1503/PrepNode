import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/cutoff/data/datasources/cutoff_local_datasource.dart';
import 'package:prepgraph/features/cutoff/data/repositories/cutoff_repository_impl.dart';
import 'package:prepgraph/features/cutoff/domain/entities/cutoff_analysis.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepgraph/features/cutoff/domain/repositories/cutoff_repository.dart';
import 'package:prepgraph/features/cutoff/presentation/providers/cutoff_category_provider.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepgraph/features/pyq/presentation/providers/pyq_providers.dart';

export 'package:prepgraph/features/cutoff/presentation/providers/cutoff_category_provider.dart';

final cutoffLocalDataSourceProvider = Provider<CutoffLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CutoffLocalDataSource(databaseService: databaseService);
});

// Repository provider — composes Insights (mastery, mock test trend, real
// PrepGraph Score), PYQ (real per-topic exam-frequency counts) and
// Knowledge Graph (the syllabus' subject list), the same way
// DashboardRepositoryImpl composes existing repositories rather than
// standing up new analytics of its own. No remote data source: there is no
// backend for cutoff intelligence, and there never needs to be — everything
// it needs already lives in the local database.
final cutoffRepositoryProvider = Provider<CutoffRepository>((ref) {
  return CutoffRepositoryImpl(
    localDataSource: ref.watch(cutoffLocalDataSourceProvider),
    insightsRepository: ref.watch(insightsRepositoryProvider),
    pyqRepository: ref.watch(pyqRepositoryProvider),
    knowledgeGraphRepository: ref.watch(knowledgeGraphRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

// Available exams provider
final availableExamsProvider = FutureProvider<List<ExamCutoff>>((ref) async {
  final repository = ref.watch(cutoffRepositoryProvider);
  final result = await repository.getAvailableExams();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (exams) => exams,
  );
});

// Exam cutoff provider
final examCutoffProvider =
    FutureProvider.family<ExamCutoff, String>((ref, examId) async {
  final repository = ref.watch(cutoffRepositoryProvider);
  final result = await repository.getExamCutoff(examId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (cutoff) => cutoff,
  );
});

// Cutoff analysis provider — the real user, compared against their own
// selected reservation category (see selectedCutoffCategoryProvider).
final cutoffAnalysisProvider =
    FutureProvider.family<CutoffAnalysis, String>((ref, examId) async {
  final repository = ref.watch(cutoffRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  final category = ref.watch(selectedCutoffCategoryProvider);
  if (userId == null) {
    throw Exception('Not signed in');
  }
  final result = await repository.getCutoffAnalysis(userId, examId, category: category);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (analysis) => analysis,
  );
});

// Readiness prediction provider — same real user + selected category.
final readinessPredictionProvider =
    FutureProvider.family<ReadinessPrediction, String>((ref, examId) async {
  final repository = ref.watch(cutoffRepositoryProvider);
  final userId = ref.watch(authProvider).userId;
  final category = ref.watch(selectedCutoffCategoryProvider);
  if (userId == null) {
    throw Exception('Not signed in');
  }
  final result = await repository.getReadinessPrediction(userId, examId, category: category);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (prediction) => prediction,
  );
});
