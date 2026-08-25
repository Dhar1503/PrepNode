import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/insights/data/datasources/insights_local_datasource.dart';
import 'package:prepgraph/features/insights/data/datasources/insights_remote_datasource.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';
import 'package:prepgraph/features/insights/domain/repositories/insights_repository.dart';

/// Insights Repository Implementation
/// Every read is computed from the existing local Drift tables (attempts,
/// mock tests/answers, study sessions, study plans, topic progress) rather
/// than a remote API — there is no live backend for this app. Learner
/// progress and topic mastery are additionally cached into user_analytics /
/// user_topic_progress via [InsightsLocalDataSource] so repeated reads are
/// cheap; every other analytic is computed fresh each call since it's a
/// direct aggregation over data that already lives locally.
class InsightsRepositoryImpl implements InsightsRepository {
  // ignore: unused_field
  final InsightsRemoteDataSource _remoteDataSource;
  final InsightsLocalDataSource _localDataSource;

  InsightsRepositoryImpl({
    required InsightsRemoteDataSource remoteDataSource,
    required InsightsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, LearnerProgress>> getLearnerProgress(String userId) async {
    try {
      final components = await _localDataSource.computeScoreComponents(userId);

      await _localDataSource.saveLearnerProgress(
        userId: userId,
        prepGraphScore: components['prepGraphScore']!,
        topicCompletion: components['topicCompletion']!,
        pyqPerformance: components['pyqPerformance']!,
        mockAccuracy: components['mockAccuracy']!,
        consistency: components['consistency']!,
        revisionDiscipline: components['revisionDiscipline']!,
      );

      return Right(LearnerProgress(
        userId: userId,
        prepGraphScore: components['prepGraphScore']!,
        scoreComponents: ScoreComponents(
          topicCompletion: components['topicCompletion']!,
          pyqPerformance: components['pyqPerformance']!,
          mockAccuracy: components['mockAccuracy']!,
          consistency: components['consistency']!,
          revisionDiscipline: components['revisionDiscipline']!,
        ),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MasteryAnalytics>> getMasteryAnalytics(String userId) async {
    try {
      final masteries = await _localDataSource.getTopicMasteriesWithNames(userId);

      return Right(MasteryAnalytics(
        userId: userId,
        topicMasteries: masteries.map((m) {
          final percentage = (m['masteryPercentage'] as double) / 100;
          return TopicMastery(
            topicId: m['topicId'] as String,
            topicName: m['topicName'] as String,
            subjectId: m['subjectId'] as String,
            subjectName: m['subjectName'] as String,
            masteryPercentage: percentage,
            level: _mapMasteryLevelFromPercentage(percentage),
            questionsAttempted: m['questionsAttempted'] as int,
            questionsCorrect: m['questionsCorrect'] as int,
            studyMinutes: m['studyMinutes'] as int,
            lastStudied: m['lastRevisionDate'] as DateTime? ?? DateTime.now(),
          );
        }).toList(),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqPerformance>> getPyqPerformance(String userId) async {
    try {
      final subjectRows = await _localDataSource.getPyqPerformanceBySubject(userId);
      final overall = await _localDataSource.getOverallPyqStats(userId);

      return Right(PyqPerformance(
        userId: userId,
        subjectStats: subjectRows
            .map((s) => SubjectPyqStats(
                  subjectId: s['subjectId'] as String,
                  subjectName: s['subjectName'] as String,
                  totalQuestionsAttempted: s['totalQuestionsAttempted'] as int,
                  totalQuestionsCorrect: s['totalQuestionsCorrect'] as int,
                  accuracy: s['accuracy'] as double,
                  averageTimePerQuestion: s['averageTimePerQuestion'] as double,
                  topicsCovered: s['topicsCovered'] as int,
                  bookmarkedQuestions: s['bookmarkedQuestions'] as int,
                ))
            .toList(),
        overallStats: OverallPyqStats(
          totalQuestionsAttempted: overall['totalQuestionsAttempted'] as int,
          totalQuestionsCorrect: overall['totalQuestionsCorrect'] as int,
          overallAccuracy: overall['overallAccuracy'] as double,
          totalTimeSpentMinutes: overall['totalTimeSpentMinutes'] as double,
          uniqueTopicsCovered: overall['uniqueTopicsCovered'] as int,
          currentStreak: overall['currentStreak'] as int,
        ),
        // Daily trend granularity isn't tracked per-topic in the current
        // schema (only attempt_date per question, not rolled up by topic
        // per day), so this stays empty rather than being fabricated.
        topicTrends: const [],
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestAnalytics>> getMockTestAnalytics(String userId) async {
    try {
      final rows = await _localDataSource.getMockTestAttempts(userId);

      final attempts = rows
          .map((r) => MockTestAttempt(
                attemptId: r['attemptId'] as String,
                testType: r['testType'] as String,
                subjectId: r['subjectId'] as String,
                subjectName: r['subjectName'] as String,
                date: r['date'] as DateTime,
                score: r['score'] as double,
                accuracy: r['accuracy'] as double,
                totalQuestions: r['totalQuestions'] as int,
                correctAnswers: r['correctAnswers'] as int,
                durationMinutes: r['durationMinutes'] as int,
                // Section-wise breakdown isn't persisted (mock_test_answers
                // has no section id), so this stays empty rather than
                // fabricated.
                sectionScores: const [],
              ))
          .toList();

      return Right(MockTestAnalytics(
        userId: userId,
        attempts: attempts,
        subjectStats: _aggregateMockTestStats(attempts),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, StudyHabits>> getStudyHabits(String userId) async {
    try {
      final data = await _localDataSource.getStudyHabitsData(userId);
      final dayMinutes = data['dayMinutes'] as Map<String, int>;
      final dayTopicCounts = data['dayTopicCounts'] as Map<String, int>;
      final subjectMinutes = data['subjectMinutes'] as Map<String, int>;
      final subjectNames = data['subjectNames'] as Map<String, String>;
      final totalMinutes = data['totalMinutes'] as int;
      final activeDayKeys = data['activeDayKeys'] as List<String>;
      final currentStreak = data['currentStreak'] as int;

      final dailyData = dayMinutes.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return DailyStudyData(
          date: date,
          totalStudyMinutes: entry.value,
          subjectMinutes: const {},
          topicsCompleted: dayTopicCounts[entry.key] ?? 0,
          pyqsAttempted: 0,
          metDailyGoal: entry.value > 0,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final activeDays = activeDayKeys.length;
      final averageDaily = activeDays == 0 ? 0 : totalMinutes ~/ activeDays;

      final subjectTotal = subjectMinutes.values.fold<int>(0, (sum, m) => sum + m);
      final subjectEntries = subjectMinutes.entries
          .where((e) => e.key.isNotEmpty)
          .map((e) => SubjectTimeEntry(
                subjectId: e.key,
                subjectName: subjectNames[e.key] ?? '',
                totalMinutes: e.value,
                percentageOfTotal: subjectTotal == 0 ? 0.0 : (e.value / subjectTotal) * 100,
              ))
          .toList();

      return Right(StudyHabits(
        userId: userId,
        dailyData: dailyData,
        weeklyStats: WeeklyStudyStats(
          totalStudyMinutes: totalMinutes,
          averageDailyMinutes: averageDaily,
          activeStudyDays: activeDays,
          currentStreak: currentStreak,
          longestStreak: currentStreak,
          goalCompletionRate: 0.0,
        ),
        subjectDistribution: SubjectTimeDistribution(entries: subjectEntries),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, WeakArea>> getWeakAreas(String userId) async {
    try {
      final masteries = await _localDataSource.getTopicMasteriesWithNames(userId);

      final weakTopics = masteries
          .where((m) => (m['masteryPercentage'] as double) < 60 && (m['questionsAttempted'] as int) > 0)
          .map((m) {
            final accuracy = (m['questionsAttempted'] as int) == 0
                ? 0.0
                : (m['questionsCorrect'] as int) / (m['questionsAttempted'] as int);
            final percentage = m['masteryPercentage'] as double;
            return WeakTopic(
              topicId: m['topicId'] as String,
              topicName: m['topicName'] as String,
              subjectId: m['subjectId'] as String,
              subjectName: m['subjectName'] as String,
              currentAccuracy: accuracy,
              targetAccuracy: 0.8,
              attempts: m['questionsAttempted'] as int,
              severity: percentage < 30
                  ? WeaknessSeverity.significant
                  : percentage < 50
                      ? WeaknessSeverity.moderate
                      : WeaknessSeverity.mild,
              // No prerequisite-topic graph traversal is wired up here; an
              // empty list is honest, not a fabricated relation.
              prerequisiteTopics: const [],
            );
          })
          .toList()
        ..sort((a, b) => a.currentAccuracy.compareTo(b.currentAccuracy));

      final recommendations = _buildRecommendations(weakTopics);

      return Right(WeakArea(
        userId: userId,
        weakTopics: weakTopics,
        recommendations: recommendations,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MasteryAnalytics>> getSubjectMastery(
    String userId,
    String subjectId,
  ) async {
    try {
      final masteries = await _localDataSource.getTopicMasteriesWithNames(userId);
      final subjectMasteries = masteries.where((m) => m['subjectId'] == subjectId);

      return Right(MasteryAnalytics(
        userId: userId,
        topicMasteries: subjectMasteries.map((m) {
          final percentage = (m['masteryPercentage'] as double) / 100;
          return TopicMastery(
            topicId: m['topicId'] as String,
            topicName: m['topicName'] as String,
            subjectId: m['subjectId'] as String,
            subjectName: m['subjectName'] as String,
            masteryPercentage: percentage,
            level: _mapMasteryLevelFromPercentage(percentage),
            questionsAttempted: m['questionsAttempted'] as int,
            questionsCorrect: m['questionsCorrect'] as int,
            studyMinutes: m['studyMinutes'] as int,
            lastStudied: m['lastRevisionDate'] as DateTime? ?? DateTime.now(),
          );
        }).toList(),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqPerformance>> getSubjectPyqPerformance(
    String userId,
    String subjectId,
  ) async {
    try {
      final subjectRows = await _localDataSource.getPyqPerformanceBySubject(userId);
      final overall = await _localDataSource.getOverallPyqStats(userId);
      final matching = subjectRows.where((s) => s['subjectId'] == subjectId);

      return Right(PyqPerformance(
        userId: userId,
        subjectStats: matching
            .map((s) => SubjectPyqStats(
                  subjectId: s['subjectId'] as String,
                  subjectName: s['subjectName'] as String,
                  totalQuestionsAttempted: s['totalQuestionsAttempted'] as int,
                  totalQuestionsCorrect: s['totalQuestionsCorrect'] as int,
                  accuracy: s['accuracy'] as double,
                  averageTimePerQuestion: s['averageTimePerQuestion'] as double,
                  topicsCovered: s['topicsCovered'] as int,
                  bookmarkedQuestions: s['bookmarkedQuestions'] as int,
                ))
            .toList(),
        overallStats: OverallPyqStats(
          totalQuestionsAttempted: overall['totalQuestionsAttempted'] as int,
          totalQuestionsCorrect: overall['totalQuestionsCorrect'] as int,
          overallAccuracy: overall['overallAccuracy'] as double,
          totalTimeSpentMinutes: overall['totalTimeSpentMinutes'] as double,
          uniqueTopicsCovered: overall['uniqueTopicsCovered'] as int,
          currentStreak: overall['currentStreak'] as int,
        ),
        topicTrends: const [],
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> markRecommendationCompleted(
    String userId,
    String recommendationId,
  ) async {
    // Recommendations are computed fresh from weak-topic data each call
    // (see getWeakAreas) rather than stored as rows, so there is nothing to
    // persist here; dismissal is handled as session-local UI state by the
    // caller. Returning success keeps the existing repository contract
    // intact for callers that awaited a Right(null).
    return const Right(null);
  }

  SubjectMockTestStats _aggregateMockTestStats(List<MockTestAttempt> attempts) {
    if (attempts.isEmpty) {
      return const SubjectMockTestStats(
        subjectId: '',
        subjectName: '',
        totalAttempts: 0,
        averageScore: 0.0,
        averageAccuracy: 0.0,
        bestScore: 0.0,
        worstScore: 0.0,
        trend: ScoreTrend.stable,
      );
    }

    final scores = attempts.map((a) => a.score).toList();
    final accuracies = attempts.map((a) => a.accuracy).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final averageAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;

    // Attempts are ordered most-recent-first (see getMockTestAttempts);
    // compare the newer half's average score against the older half's.
    ScoreTrend trend = ScoreTrend.stable;
    if (attempts.length >= 4) {
      final half = attempts.length ~/ 2;
      final recent = attempts.sublist(0, half).map((a) => a.score);
      final older = attempts.sublist(half).map((a) => a.score);
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.reduce((a, b) => a + b) / older.length;
      if (recentAvg > olderAvg * 1.05) {
        trend = ScoreTrend.improving;
      } else if (recentAvg < olderAvg * 0.95) {
        trend = ScoreTrend.declining;
      }
    }

    final subjectFrequency = attempts
        .where((a) => a.subjectId.isNotEmpty)
        .map((a) => a.subjectId)
        .fold<Map<String, int>>({}, (map, id) => map..update(id, (v) => v + 1, ifAbsent: () => 1));
    String? mostCommonSubjectId;
    var highestCount = 0;
    for (final entry in subjectFrequency.entries) {
      if (entry.value > highestCount) {
        highestCount = entry.value;
        mostCommonSubjectId = entry.key;
      }
    }

    return SubjectMockTestStats(
      subjectId: mostCommonSubjectId ?? '',
      subjectName: attempts.firstWhere(
            (a) => a.subjectId == mostCommonSubjectId,
            orElse: () => attempts.first,
          ).subjectName,
      totalAttempts: attempts.length,
      averageScore: averageScore,
      averageAccuracy: averageAccuracy,
      bestScore: scores.reduce((a, b) => a > b ? a : b),
      worstScore: scores.reduce((a, b) => a < b ? a : b),
      trend: trend,
    );
  }

  /// Simple, rule-based recommendations from real weak-topic data — no
  /// LLM/external call, matching the same templating approach used for PYQ
  /// AI hints elsewhere in the app.
  List<Recommendation> _buildRecommendations(List<WeakTopic> weakTopics) {
    final now = DateTime.now();
    return weakTopics.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final topic = entry.value;
      final priority = topic.severity == WeaknessSeverity.significant
          ? 9
          : topic.severity == WeaknessSeverity.moderate
              ? 6
              : 3;
      return Recommendation(
        id: 'weak-${topic.topicId}',
        type: 'revision',
        title: 'Revise ${topic.topicName}',
        description:
            'Your accuracy in ${topic.topicName} is ${(topic.currentAccuracy * 100).toStringAsFixed(0)}%, '
            'below the ${(topic.targetAccuracy * 100).toStringAsFixed(0)}% target.',
        reason: '${topic.attempts} questions attempted with room to improve',
        topicId: topic.topicId,
        subjectId: topic.subjectId,
        priority: priority - index,
        createdAt: now,
        isCompleted: false,
      );
    }).toList();
  }

  MasteryLevel _mapMasteryLevelFromPercentage(double percentage) {
    if (percentage >= 0.8) return MasteryLevel.mastered;
    if (percentage >= 0.5) return MasteryLevel.building;
    if (percentage > 0) return MasteryLevel.inProgress;
    return MasteryLevel.notStarted;
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
