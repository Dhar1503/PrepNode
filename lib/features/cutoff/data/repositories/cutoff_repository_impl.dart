import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/auth/domain/repositories/profile_repository.dart';
import 'package:prepnode/features/cutoff/data/datasources/cutoff_local_datasource.dart';
import 'package:prepnode/features/cutoff/domain/entities/cutoff_analysis.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_scale.dart';
import 'package:prepnode/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepnode/features/cutoff/domain/entities/recommendation.dart';
import 'package:prepnode/features/cutoff/domain/repositories/cutoff_repository.dart';
import 'package:prepnode/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepnode/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepnode/features/insights/domain/repositories/insights_repository.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import 'package:prepnode/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepnode/features/pyq/domain/repositories/pyq_repository.dart';

/// Cutoff Repository Implementation
///
/// Readiness prediction and personalized recommendations used to depend
/// entirely on a remote analytics API that has no real backend behind it —
/// every call failed, so this "intelligence" never actually ran; screens
/// either showed a hard error or silently rendered nothing. There is no
/// separate readiness/recommendation engine to call: it's computed here,
/// directly, from the same local data the Insights and PYQ modules already
/// maintain (mastery per topic, mock test trend, real PYQ frequency counts)
/// crossed against the real seeded cutoff marks for the student's own
/// reservation category. This is the actual "cutoff intelligence."
class CutoffRepositoryImpl implements CutoffRepository {
  final CutoffLocalDataSource _localDataSource;
  final InsightsRepository _insightsRepository;
  final PyqRepository _pyqRepository;
  final KnowledgeGraphRepository _knowledgeGraphRepository;
  final ProfileRepository _profileRepository;

  CutoffRepositoryImpl({
    required CutoffLocalDataSource localDataSource,
    required InsightsRepository insightsRepository,
    required PyqRepository pyqRepository,
    required KnowledgeGraphRepository knowledgeGraphRepository,
    required ProfileRepository profileRepository,
  })  : _localDataSource = localDataSource,
        _insightsRepository = insightsRepository,
        _pyqRepository = pyqRepository,
        _knowledgeGraphRepository = knowledgeGraphRepository,
        _profileRepository = profileRepository;

  @override
  Future<Either<Failure, ExamCutoff>> getExamCutoff(String examId) async {
    try {
      final cutoff = await _localDataSource.getExamCutoffLocal(examId);
      if (cutoff != null) {
        return Right(cutoff);
      }
      return Left(DatabaseFailure.notFound(entity: 'Exam Cutoff'));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ExamCutoff>>> getAvailableExams() async {
    try {
      final exams = await _localDataSource.getAvailableExamsLocal();
      return Right(exams);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ReadinessPrediction>> getReadinessPrediction(
    String userId,
    String examId, {
    String category = 'OC',
  }) async {
    try {
      // Benchmarks against the exam's OFFICIAL published qualifying mark,
      // not the cutoff_data table. Those cutoff rows were never sourced from
      // any TNPSC document, and this prediction is surfaced on Home, the
      // Planner and the Mock Test result screen — so it was quoting invented
      // targets to exam aspirants in four places at once. The qualifying
      // mark is a real, verified figure; it is a lower bar than an actual
      // cutoff, so every label calls it a qualifying mark, never "cutoff".
      final targetCutoff = ExamScale.qualifyingMarkFor(examId);
      if (targetCutoff == null) {
        return Left(DatabaseFailure.notFound(
          entity: 'Verified qualifying mark for this exam',
        ));
      }

      final progressResult = await _insightsRepository.getLearnerProgress(userId);
      final masteryResult = await _insightsRepository.getMasteryAnalytics(userId);
      final mockTestResult = await _insightsRepository.getMockTestAnalytics(userId);

      final prepNodeScore = progressResult.fold((_) => 0.0, (p) => p.prepNodeScore);
      final topicMasteries = masteryResult.fold((_) => <TopicMastery>[], (m) => m.topicMasteries);
      final mockTrend = mockTestResult.fold(
        (_) => null,
        (m) => m.attempts.isEmpty ? null : m.subjectStats.trend,
      );

      // CORRECTED (Phase 1B): TNPSC Group 2 Prelims is 200 questions for
      // 300 marks (100 Language + 75 General Studies + 25 Aptitude
      // questions), not 200 marks as previously assumed here — verified
      // against multiple independent sources. The composite 0-100
      // PrepNode Score (syllabus coverage + PYQ + mock accuracy +
      // consistency + revision, see ScoreComponents) is projected onto
      // the exam's real total-marks scale — looked up via [ExamScale] by
      // examId rather than a bare literal, since not every TNPSC exam
      // necessarily shares Group 2's 300-mark scale.
      final totalMarks = ExamScale.totalMarksFor(examId);
      final currentScore = prepNodeScore / 100 * totalMarks;

      // A bounded, honest nudge from real recent trend data — not a
      // fabricated growth curve. Capped so a short "improving" streak can't
      // imply an unrealistic jump.
      final weeksUntilExam = _weeksUntil(await _targetDate(userId));
      final trendAdjustmentPerWeek = switch (mockTrend) {
        ScoreTrend.improving => 1.5,
        ScoreTrend.declining => -1.0,
        _ => 0.0,
      };
      final predictedScore =
          (currentScore + trendAdjustmentPerWeek * weeksUntilExam.clamp(0, 12)).clamp(0.0, totalMarks);

      final readinessPercentage =
          targetCutoff > 0 ? (predictedScore / targetCutoff * 100).clamp(0.0, 100.0) : 0.0;
      final readinessLevel = _readinessLevel(readinessPercentage);

      final attempted = topicMasteries.where((t) => t.questionsAttempted > 0).toList();
      final sortedByMastery = [...attempted]
        ..sort((a, b) => b.masteryPercentage.compareTo(a.masteryPercentage));
      final strongAreas = sortedByMastery.take(3).map((t) => t.topicName).toList();
      final weakAreas = sortedByMastery.reversed.take(3).map((t) => t.topicName).toList();

      // Wording deliberately says "qualifying mark", not "cutoff": this is
      // the official minimum to qualify, which is a lower bar than the
      // actual selection cutoff. Calling it a cutoff would overstate how
      // ready the student is.
      final gap = targetCutoff - predictedScore;
      final recommendation = gap <= 0
          ? "You're projected ${gap.abs().toStringAsFixed(1)} marks above the official qualifying mark — keep up the consistency. Selection cutoffs run higher, so keep building."
          : weakAreas.isEmpty
              ? "You're ${gap.toStringAsFixed(1)} marks below the official qualifying mark. Attempt a few PYQ topics to build a mastery baseline."
              : "You're ${gap.toStringAsFixed(1)} marks below the official qualifying mark. ${weakAreas.first} is your lowest-mastery topic — start there.";

      return Right(ReadinessPrediction(
        userId: userId,
        examId: examId,
        currentScore: currentScore,
        predictedScore: predictedScore,
        targetCutoff: targetCutoff,
        readinessPercentage: readinessPercentage,
        readinessLevel: readinessLevel,
        strongAreas: strongAreas,
        weakAreas: weakAreas,
        weeksUntilExam: weeksUntilExam,
        recommendation: recommendation,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CutoffAnalysis>> getCutoffAnalysis(
    String userId,
    String examId, {
    String category = 'OC',
  }) async {
    try {
      final examCutoff = await _localDataSource.getExamCutoffLocal(examId);
      if (examCutoff == null) {
        return Left(DatabaseFailure.notFound(entity: 'Exam Cutoff'));
      }

      final predictionResult =
          await getReadinessPrediction(userId, examId, category: category);
      final readinessPrediction = predictionResult.fold(
        (failure) => throw failure,
        (prediction) => prediction,
      );

      final recommendations = await _buildGapClosingRecommendations(
        userId: userId,
        examId: examId,
      );

      return Right(CutoffAnalysis(
        userId: userId,
        examId: examId,
        examCutoff: examCutoff,
        readinessPrediction: readinessPrediction,
        personalizedRecommendations: recommendations,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  /// The actual "close the gap" engine: ranks every topic in the syllabus
  /// by (how often it has appeared in past papers) × (how far the student
  /// still is from mastering it), so the highest-leverage topics — the ones
  /// most likely to appear on the exam AND still weak — surface first.
  /// Built entirely from real local data (PyqRepository's topic summaries,
  /// InsightsRepository's mastery percentages); nothing here is fabricated.
  Future<List<Recommendation>> _buildGapClosingRecommendations({
    required String userId,
    required String examId,
  }) async {
    final subjectsResult = await _knowledgeGraphRepository.getSubjects(examId: examId);
    final subjects = subjectsResult.fold((_) => const <GraphNode>[], (s) => s);
    if (subjects.isEmpty) return const [];

    final masteryResult = await _insightsRepository.getMasteryAnalytics(userId);
    final masteryByTopic = <String, double>{
      for (final t in masteryResult.fold((_) => <TopicMastery>[], (m) => m.topicMasteries))
        t.topicId: t.masteryPercentage,
    };

    final scored = <_ScoredTopic>[];
    for (final subject in subjects) {
      final summariesResult = await _pyqRepository.getTopicSummaries(
        examId: examId,
        subjectId: subject.id,
        userId: userId,
      );
      final summaries = summariesResult.fold((_) => <TopicPyqSummary>[], (s) => s);
      for (final summary in summaries) {
        if (summary.frequencyCount == 0) continue;
        final mastery = masteryByTopic[summary.topicId] ?? 0.0;
        final gapScore = summary.frequencyCount * (1 - mastery);
        if (gapScore <= 0) continue;
        scored.add(_ScoredTopic(
          topicId: summary.topicId,
          topicName: summary.topicName,
          subjectId: subject.id,
          frequencyCount: summary.frequencyCount,
          mastery: mastery,
          gapScore: gapScore,
        ));
      }
    }

    scored.sort((a, b) => b.gapScore.compareTo(a.gapScore));

    return scored.take(5).toList().asMap().entries.map((entry) {
      final rank = entry.key;
      final topic = entry.value;
      final masteryPct = (topic.mastery * 100).toStringAsFixed(0);
      return Recommendation(
        id: 'gap-${topic.topicId}',
        type: 'focus',
        title: topic.topicName,
        description: 'Appeared in ${topic.frequencyCount} past-year question'
            '${topic.frequencyCount == 1 ? '' : 's'} — you\'re at $masteryPct% mastery here. '
            'High exam frequency, low mastery: the highest-leverage topic to study next.',
        topicId: topic.topicId,
        subjectId: topic.subjectId,
        // RecommendationCard maps priority 1/2/3 to marigold/sage/graphite,
        // 1 = highest — so the top-ranked gap topics stay visually distinct
        // instead of collapsing into the "everything else" gray.
        priority: rank < 2 ? 1 : (rank < 4 ? 2 : 3),
        estimatedImpact: topic.frequencyCount >= 3 ? 'High' : 'Medium',
        timeRequired: topic.mastery < 0.3 ? '45+ min' : '20-30 min',
      );
    }).toList();
  }

  // _latestCutoffMarkForCategory removed: readiness no longer benchmarks
  // against the unsourced cutoff_data rows. See getReadinessPrediction,
  // which uses the exam's official qualifying mark instead.

  Future<DateTime?> _targetDate(String userId) async {
    final result = await _profileRepository.getProfile(userId: userId);
    return result.fold((_) => null, (user) => user.targetDate);
  }

  int _weeksUntil(DateTime? targetDate) {
    if (targetDate == null) return 12;
    final days = targetDate.difference(DateTime.now()).inDays;
    return (days / 7).ceil().clamp(0, 208);
  }

  String _readinessLevel(double readinessPercentage) {
    if (readinessPercentage >= 100) return 'excellent';
    if (readinessPercentage >= 85) return 'good';
    if (readinessPercentage >= 70) return 'moderate';
    return 'needs_improvement';
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}

class _ScoredTopic {
  final String topicId;
  final String topicName;
  final String subjectId;
  final int frequencyCount;
  final double mastery;
  final double gapScore;

  const _ScoredTopic({
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    required this.frequencyCount,
    required this.mastery,
    required this.gapScore,
  });
}
