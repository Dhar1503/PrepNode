import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/auth/domain/repositories/profile_repository.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/repositories/cutoff_repository.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/domain/repositories/insights_repository.dart';
import 'package:prepgraph/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import 'package:prepgraph/features/planner/domain/repositories/planner_repository.dart';
import 'package:prepgraph/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';
import 'package:prepgraph/features/strategy/domain/entities/roadmap.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_recommendation.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_summary.dart';
import 'package:prepgraph/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepgraph/features/strategy/domain/repositories/strategy_repository.dart';

/// Strategy Repository Implementation
///
/// The Strategy Engine is a synthesis layer, not a new data source: every
/// number here comes from InsightsRepository, PyqRepository,
/// PlannerRepository, CutoffRepository, KnowledgeGraphRepository or
/// ProfileRepository — the same repositories every other screen in the app
/// already uses. Nothing is fabricated; where a computation is a heuristic
/// (study-time estimates, score-impact projection) rather than a directly
/// observed number, that's documented at the point of computation.
class StrategyRepositoryImpl implements StrategyRepository {
  final InsightsRepository _insights;
  final PyqRepository _pyq;
  final PlannerRepository _planner;
  final CutoffRepository _cutoff;
  final KnowledgeGraphRepository _knowledgeGraph;
  final ProfileRepository _profile;

  StrategyRepositoryImpl({
    required InsightsRepository insightsRepository,
    required PyqRepository pyqRepository,
    required PlannerRepository plannerRepository,
    required CutoffRepository cutoffRepository,
    required KnowledgeGraphRepository knowledgeGraphRepository,
    required ProfileRepository profileRepository,
  })  : _insights = insightsRepository,
        _pyq = pyqRepository,
        _planner = plannerRepository,
        _cutoff = cutoffRepository,
        _knowledgeGraph = knowledgeGraphRepository,
        _profile = profileRepository;

  @override
  Future<Either<Failure, StudyCapacity>> getStudyCapacity(String userId) async {
    try {
      final progress = (await _insights.getLearnerProgress(userId)).fold((_) => null, (p) => p);
      final mastery = (await _insights.getMasteryAnalytics(userId)).fold((_) => null, (m) => m);
      final mockTests = (await _insights.getMockTestAnalytics(userId)).fold((_) => null, (m) => m);
      final habits = (await _insights.getStudyHabits(userId)).fold((_) => null, (h) => h);

      final components = progress?.scoreComponents;
      final topicCompletion = (components?.topicCompletion ?? 0) / 100;
      final pyqPerformance = (components?.pyqPerformance ?? 0) / 100;
      final mockAccuracy = (components?.mockAccuracy ?? 0) / 100;
      final consistency = (components?.consistency ?? 0) / 100;
      final revisionDiscipline = (components?.revisionDiscipline ?? 0) / 100;

      final attemptedTopics = mastery?.topicMasteries.where((t) => t.questionsAttempted > 0).toList() ?? const [];
      final masteryDepth = attemptedTopics.isEmpty
          ? 0.0
          : attemptedTopics.map((t) => t.masteryPercentage).reduce((a, b) => a + b) / attemptedTopics.length;

      final mockAttempts = mockTests?.attempts ?? const [];
      final mockTrend = mockAttempts.length >= 4
          ? switch (mockTests!.subjectStats.trend) {
              ScoreTrend.improving => 1.0,
              ScoreTrend.declining => 0.0,
              ScoreTrend.stable => 0.5,
            }
          : 0.5; // not enough attempts for a real trend read — neutral, not penalized

      final streak = ((habits?.weeklyStats.currentStreak ?? 0) / 14).clamp(0.0, 1.0);

      // Real missed/on-time task tracking from this week's plan — separate
      // from the composite "consistency" score above, which measures
      // minutes studied vs. planned rather than whether tasks were actually
      // completed on their scheduled day.
      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final weeklyPlan = (await _planner.getWeeklyPlan(userId: userId, weekStart: weekStart)).fold((_) => null, (w) => w);
      final scheduledSoFar = weeklyPlan?.plans
              .expand((d) => d.tasks)
              .where((t) => !t.isBreak && !t.scheduledDate.isAfter(now))
              .toList() ??
          const [];
      final onTimeCompletion = scheduledSoFar.isEmpty
          ? 0.5 // no scheduled tasks yet this week — neutral, not penalized
          : scheduledSoFar.where((t) => t.isCompleted).length / scheduledSoFar.length;

      // How much real activity backs this read — gates the "buildingMomentum"
      // fallback so a brand-new account isn't confidently mislabeled.
      final dataPoints = mockAttempts.length + attemptedTopics.length +
          (habits?.weeklyStats.activeStudyDays ?? 0);

      final factors = <String, double>{
        'Syllabus Coverage': topicCompletion,
        'PYQ Accuracy': pyqPerformance,
        'Mock Test Accuracy': mockAccuracy,
        'Planner Consistency': consistency,
        'On-Time Task Completion': onTimeCompletion,
        'Revision Discipline': revisionDiscipline,
        'Mastery Depth': masteryDepth,
        'Improvement Trend': mockTrend,
        'Study Streak': streak,
      };

      final capacityScore = (topicCompletion * 18 +
              pyqPerformance * 18 +
              mockAccuracy * 14 +
              consistency * 12 +
              onTimeCompletion * 10 +
              revisionDiscipline * 10 +
              masteryDepth * 10 +
              mockTrend * 4 +
              streak * 4)
          .clamp(0.0, 100.0);

      // Blend on-time completion into the consistency signal used for
      // classification — a student who studies the planned minutes but
      // constantly reschedules tasks late isn't "consistent" in the sense
      // that matters for exam prep.
      final blendedConsistency = (consistency + onTimeCompletion) / 2;

      final profile = _classifyCapacity(
        dataPoints: dataPoints,
        consistency: blendedConsistency,
        pyqPerformance: pyqPerformance,
        masteryDepth: masteryDepth,
        topicCompletion: topicCompletion,
        revisionDiscipline: revisionDiscipline,
        mockTrend: mockTrend,
      );

      return Right(StudyCapacity(
        userId: userId,
        profile: profile,
        capacityScore: capacityScore,
        factors: factors,
        summary: _capacitySummary(profile),
        dataPoints: dataPoints,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  /// Multi-factor decision tree, not a single hardcoded label. Thresholds
  /// are intentionally coarse (0.3/0.4/0.7) — this classifies a study
  /// pattern, not a precise score, and real data is noisy.
  CapacityProfile _classifyCapacity({
    required int dataPoints,
    required double consistency,
    required double pyqPerformance,
    required double masteryDepth,
    required double topicCompletion,
    required double revisionDiscipline,
    required double mockTrend,
  }) {
    if (dataPoints < 5) return CapacityProfile.buildingMomentum;

    if (consistency >= 0.7 && pyqPerformance >= 0.7 && masteryDepth >= 0.7 && mockTrend >= 0.5) {
      return CapacityProfile.examReady;
    }
    if (pyqPerformance >= 0.7 && topicCompletion < 0.4) {
      return CapacityProfile.highAccuracyLowCoverage;
    }
    if (mockTrend >= 0.8 && masteryDepth >= 0.4) {
      return CapacityProfile.fastLearner;
    }
    if (consistency >= 0.7 && mockTrend < 0.5) {
      return CapacityProfile.slowConsistent;
    }
    if (revisionDiscipline < 0.3 && masteryDepth >= 0.4) {
      return CapacityProfile.needsRevision;
    }
    if (masteryDepth < 0.3 && pyqPerformance < 0.4) {
      return CapacityProfile.weakFoundation;
    }
    if (masteryDepth < 0.4 && topicCompletion < 0.4) {
      return CapacityProfile.needsConceptBuilding;
    }
    if (consistency < 0.4) {
      return CapacityProfile.lowConsistency;
    }
    return CapacityProfile.highPotential;
  }

  String _capacitySummary(CapacityProfile profile) {
    switch (profile) {
      case CapacityProfile.buildingMomentum:
        return "Not enough activity yet for a confident read — a few more PYQ sessions and a mock test will sharpen this.";
      case CapacityProfile.fastLearner:
        return "You pick up new topics quickly and your mock scores are trending up fast.";
      case CapacityProfile.slowConsistent:
        return "You study reliably, but your scores are improving gradually rather than in jumps — steady wins here.";
      case CapacityProfile.examReady:
        return "Strong coverage, accuracy, and consistency together — you're close to exam-ready.";
      case CapacityProfile.needsRevision:
        return "You've built real mastery but aren't revisiting topics enough to keep it — revision is your biggest lever.";
      case CapacityProfile.highPotential:
        return "Solid signals across the board without one standout weakness — keep the current pace.";
      case CapacityProfile.weakFoundation:
        return "Accuracy and mastery are both low right now — focus on concept-building before speed.";
      case CapacityProfile.needsConceptBuilding:
        return "Coverage and depth are both limited — this is the stage to build foundations, not chase marks.";
      case CapacityProfile.lowConsistency:
        return "Your planner completion rate is low — irregular study is likely costing you more than topic gaps are.";
      case CapacityProfile.highAccuracyLowCoverage:
        return "You're accurate on what you've studied, but haven't covered enough of the syllabus yet.";
    }
  }

  @override
  Future<Either<Failure, List<StrategyRecommendation>>> getNextBestTopics({
    required String userId,
    required String examId,
    required String category,
    int limit = 5,
  }) async {
    try {
      final recommendations = await _buildRecommendations(userId: userId, examId: examId, category: category);
      return Right(recommendations.take(limit).toList());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  /// Ranks every topic in the syllabus by real PYQ frequency crossed with
  /// real mastery gap, then attaches an expected-score-impact estimate
  /// derived from that topic's share of total syllabus PYQ volume applied
  /// to the real target cutoff mark. estimatedStudyMinutes is the one
  /// genuinely heuristic number here (there's no recorded "time to master a
  /// topic" anywhere in the schema) — documented inline.
  Future<List<StrategyRecommendation>> _buildRecommendations({
    required String userId,
    required String examId,
    required String category,
  }) async {
    final subjects = (await _knowledgeGraph.getSubjects(examId: examId)).fold((_) => const [], (s) => s);
    if (subjects.isEmpty) return const [];

    final masteryByTopic = <String, MapEntry<double, int>>{}; // topicId -> (mastery%, attempts)
    final masteryResult = await _insights.getMasteryAnalytics(userId);
    masteryResult.fold((_) {}, (m) {
      for (final t in m.topicMasteries) {
        masteryByTopic[t.topicId] = MapEntry(t.masteryPercentage, t.questionsAttempted);
      }
    });

    final examCutoff = (await _cutoff.getExamCutoff(examId)).fold((_) => null, (c) => c);
    final targetCutoff = examCutoff == null ? 0.0 : _latestCutoffForCategory(examCutoff, category);

    final allSummaries = <String, TopicPyqSummary>{};
    final subjectByTopic = <String, String>{};
    for (final subject in subjects) {
      final summaries = (await _pyq.getTopicSummaries(examId: examId, subjectId: subject.id, userId: userId))
          .fold((_) => <TopicPyqSummary>[], (s) => s);
      for (final s in summaries) {
        allSummaries[s.topicId] = s;
        subjectByTopic[s.topicId] = subject.id;
      }
    }

    final totalFrequency = allSummaries.values.fold<int>(0, (sum, s) => sum + s.frequencyCount);
    if (totalFrequency == 0) return const [];

    // (recommendation, gapScore) — gapScore is only a sort key, not part of
    // the public entity, so it's carried alongside as a local tuple rather
    // than a field on the class.
    final scored = <(StrategyRecommendation, double)>[];
    for (final summary in allSummaries.values) {
      if (summary.frequencyCount == 0) continue;
      final masteryEntry = masteryByTopic[summary.topicId];
      final masteryPct = masteryEntry?.key ?? 0.0;
      final attempts = masteryEntry?.value ?? 0;
      final gap = 1 - masteryPct;
      if (gap <= 0) continue;

      final frequencyShare = summary.frequencyCount / totalFrequency;
      final gapScore = summary.frequencyCount * gap;

      // Heuristic: closer a topic is to mastered, the less new-concept time
      // it needs and the more it's just practice — not a measured duration.
      final estimatedMinutes = (gap * 90).clamp(20, 180).round();

      final expectedImpact = frequencyShare * targetCutoff * gap;

      final difficulty = masteryPct >= 0.6
          ? 'Quick Win'
          : masteryPct >= 0.3
              ? 'Medium'
              : 'Needs Foundation';

      final confidence = attempts == 0 ? 0.2 : (attempts / 8).clamp(0.2, 1.0);

      final subjectId = subjectByTopic[summary.topicId] ?? '';
      final subjectName = subjects.firstWhere((s) => s.id == subjectId, orElse: () => subjects.first).name;

      scored.add((
        StrategyRecommendation(
          topicId: summary.topicId,
          topicName: summary.topicName,
          subjectId: subjectId,
          subjectName: subjectName,
          rank: 0, // assigned after sort
          masteryPercentage: masteryPct,
          pyqFrequency: summary.frequencyCount,
          pyqFrequencyShare: frequencyShare,
          estimatedStudyMinutes: estimatedMinutes,
          expectedScoreImpact: expectedImpact,
          difficulty: difficulty,
          confidence: confidence,
          reason: _buildReason(
            frequencyShare: frequencyShare,
            masteryPct: masteryPct,
            estimatedMinutes: estimatedMinutes,
            expectedImpact: expectedImpact,
          ),
        ),
        gapScore,
      ));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.asMap().entries.map((entry) {
      final r = entry.value.$1;
      return StrategyRecommendation(
        topicId: r.topicId,
        topicName: r.topicName,
        subjectId: r.subjectId,
        subjectName: r.subjectName,
        rank: entry.key + 1,
        masteryPercentage: r.masteryPercentage,
        pyqFrequency: r.pyqFrequency,
        pyqFrequencyShare: r.pyqFrequencyShare,
        estimatedStudyMinutes: r.estimatedStudyMinutes,
        expectedScoreImpact: r.expectedScoreImpact,
        difficulty: r.difficulty,
        confidence: r.confidence,
        reason: r.reason,
      );
    }).toList();
  }

  String _buildReason({
    required double frequencyShare,
    required double masteryPct,
    required int estimatedMinutes,
    required double expectedImpact,
  }) {
    final freqPct = (frequencyShare * 100).toStringAsFixed(0);
    final masteryDisplay = (masteryPct * 100).toStringAsFixed(0);
    final hours = (estimatedMinutes / 60);
    final timeText = hours >= 1 ? '${hours.toStringAsFixed(1)} hr' : '$estimatedMinutes min';
    final impactText = expectedImpact >= 0.5 ? expectedImpact.toStringAsFixed(1) : '<1';
    return 'Appears in ~$freqPct% of this subject\'s PYQ volume. You\'re only $masteryDisplay% mastered here. '
        'Estimated $timeText to close the gap. Could improve your expected score by around $impactText marks.';
  }

  double _latestCutoffForCategory(ExamCutoff examCutoff, String category) {
    final matches = examCutoff.categoryCutoffs.where((c) => c.category == category).toList();
    if (matches.isEmpty) {
      if (examCutoff.categoryCutoffs.isEmpty) return 0.0;
      final latestYear = examCutoff.categoryCutoffs.map((c) => c.year).reduce((a, b) => a > b ? a : b);
      final thatYear = examCutoff.categoryCutoffs.where((c) => c.year == latestYear);
      return thatYear.map((c) => c.cutoffMark).reduce((a, b) => a + b) / thatYear.length;
    }
    matches.sort((a, b) => b.year.compareTo(a.year));
    return matches.first.cutoffMark;
  }

  @override
  Future<Either<Failure, Roadmap>> getRoadmap({
    required String userId,
    required String examId,
    required String category,
    required int days,
  }) async {
    try {
      final recommendations = await _buildRecommendations(userId: userId, examId: examId, category: category);
      if (recommendations.isEmpty) {
        return Right(Roadmap(label: _roadmapLabel(days), totalDays: days, weeksUntilExam: 0, days: const []));
      }

      final profileResult = await _profile.getProfile(userId: userId);
      final dailyStudyHours = profileResult.fold((_) => 2, (u) => u.dailyStudyHours ?? 2);
      final targetDate = profileResult.fold((_) => null, (u) => u.targetDate);
      final dailyMinutes = (dailyStudyHours * 60).clamp(30, 600);

      final weeksUntilExam = targetDate == null
          ? 0
          : (targetDate.difference(DateTime.now()).inDays / 7).ceil().clamp(0, 208);

      final roadmapDays = <RoadmapDay>[];
      var recIndex = 0;
      final today = DateTime.now();

      for (var dayNum = 1; dayNum <= days; dayNum++) {
        final date = today.add(Duration(days: dayNum - 1));
        final items = <RoadmapItem>[];
        var minutesLeft = dailyMinutes;

        // Every 4th day is a pure revision day over already-scheduled
        // topics — real spaced repetition of the same ranked list, not new
        // content, matching how revisionDiscipline factors into capacity.
        final isRevisionDay = dayNum % 4 == 0 && roadmapDays.isNotEmpty;

        if (isRevisionDay) {
          final priorTopics = roadmapDays
              .expand((d) => d.items)
              .where((i) => i.activityType == RoadmapActivityType.learn)
              .toList();
          final toRevise = priorTopics.length > 3
              ? priorTopics.sublist(priorTopics.length - 3)
              : priorTopics;
          for (final t in toRevise) {
            if (minutesLeft <= 0) break;
            final duration = (minutesLeft < 30 ? minutesLeft : 30);
            items.add(RoadmapItem(
              topicId: t.topicId,
              topicName: t.topicName,
              subjectName: t.subjectName,
              durationMinutes: duration,
              activityType: RoadmapActivityType.revision,
            ));
            minutesLeft -= duration;
          }
        } else {
          while (minutesLeft > 15 && recommendations.isNotEmpty) {
            final rec = recommendations[recIndex % recommendations.length];
            final duration = rec.estimatedStudyMinutes > minutesLeft ? minutesLeft : rec.estimatedStudyMinutes;
            items.add(RoadmapItem(
              topicId: rec.topicId,
              topicName: rec.topicName,
              subjectName: rec.subjectName,
              durationMinutes: duration,
              activityType: RoadmapActivityType.learn,
            ));
            minutesLeft -= duration;
            recIndex++;
            if (recIndex % recommendations.length == 0) break; // one full pass per day max
          }
        }

        roadmapDays.add(RoadmapDay(
          date: date,
          dayNumber: dayNum,
          items: items,
          totalMinutes: dailyMinutes - minutesLeft,
        ));
      }

      return Right(Roadmap(
        label: _roadmapLabel(days),
        totalDays: days,
        weeksUntilExam: weeksUntilExam,
        days: roadmapDays,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  String _roadmapLabel(int days) {
    if (days <= 7) return '7-Day Crash Plan';
    if (days <= 30) return '30-Day Strategy';
    return '90-Day Strategy';
  }

  @override
  Future<Either<Failure, StrategySummary>> getStrategySummary({
    required String userId,
    required String examId,
    required String category,
  }) async {
    try {
      final capacity = await getStudyCapacity(userId);
      final capacityProfile = capacity.fold((_) => CapacityProfile.buildingMomentum, (c) => c.profile);

      final readiness = await _cutoff.getReadinessPrediction(userId, examId, category: category);
      final readinessPct = readiness.fold((_) => 0.0, (r) => r.readinessPercentage);
      final readinessLevel = readiness.fold((_) => 'needs_improvement', (r) => r.readinessLevel);
      final currentScore = readiness.fold((_) => 0.0, (r) => r.predictedScore);
      final targetCutoff = readiness.fold((_) => 0.0, (r) => r.targetCutoff);
      final weeksUntilExam = readiness.fold((_) => 0, (r) => r.weeksUntilExam);

      final topics = await getNextBestTopics(userId: userId, examId: examId, category: category, limit: 1);
      final nextTopic = topics.fold((_) => null, (list) => list.isEmpty ? null : list.first);

      final scoreGap = targetCutoff - currentScore;
      final headline = nextTopic == null
          ? "You're on track — no urgent gaps found in your PYQ-weighted analysis right now."
          : 'Focus on ${nextTopic.topicName} today — it\'s your highest-leverage topic right now.';

      return Right(StrategySummary(
        capacityProfile: capacityProfile,
        readinessPercentage: readinessPct,
        readinessLevel: readinessLevel,
        nextBestTopic: nextTopic,
        currentScore: currentScore,
        targetCutoff: targetCutoff,
        scoreGap: scoreGap,
        category: category,
        weeksUntilExam: weeksUntilExam,
        todaysFocusHeadline: headline,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) return error;
    return UnknownFailure(error.toString());
  }
}
