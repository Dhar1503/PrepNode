/// Insights Remote Data Source
/// Handles all API calls for insights and analytics data
library;

import 'package:prepgraph/core/network/api_client.dart';
import 'package:prepgraph/core/network/api_constants.dart';
import 'package:prepgraph/core/network/models/api_response.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';

class InsightsRemoteDataSource {
  final ApiClient _apiClient;

  InsightsRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get learner progress including PrepGraph Score
  Future<LearnerProgress> getLearnerProgress(String userId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/progress?userId=$userId',
    );

    final progressData = response.data!;
    final data = progressData['data'] as Map<String, dynamic>;

    final scoreComponentsData = data['scoreComponents'] as Map<String, dynamic>;
    final scoreComponents = ScoreComponents(
      topicCompletion: (scoreComponentsData['topicCompletion'] as num).toDouble(),
      pyqPerformance: (scoreComponentsData['pyqPerformance'] as num).toDouble(),
      mockAccuracy: (scoreComponentsData['mockAccuracy'] as num).toDouble(),
      consistency: (scoreComponentsData['consistency'] as num).toDouble(),
      revisionDiscipline: (scoreComponentsData['revisionDiscipline'] as num).toDouble(),
    );

    return LearnerProgress(
      userId: userId,
      prepGraphScore: (data['prepGraphScore'] as num).toDouble(),
      scoreComponents: scoreComponents,
      lastUpdated: DateTime.parse(data['lastUpdated'] as String),
    );
  }

  /// Get mastery analytics across all topics
  Future<MasteryAnalytics> getMasteryAnalytics(String userId) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.analytics}/mastery?userId=$userId',
    );

    final masteriesList = response.data!;

    final topicMasteries = masteriesList.map((masteryData) {
      return TopicMastery(
        topicId: masteryData['topicId'] as String,
        topicName: masteryData['topicName'] as String,
        subjectId: masteryData['subjectId'] as String,
        subjectName: masteryData['subjectName'] as String,
        masteryPercentage: (masteryData['masteryPercentage'] as num).toDouble(),
        level: _mapMasteryLevel(masteryData['level'] as String),
        questionsAttempted: masteryData['questionsAttempted'] as int,
        questionsCorrect: masteryData['questionsCorrect'] as int,
        studyMinutes: masteryData['studyMinutes'] as int,
        lastStudied: DateTime.parse(masteryData['lastStudied'] as String),
      );
    }).toList();

    return MasteryAnalytics(
      userId: userId,
      topicMasteries: topicMasteries,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get PYQ performance analytics
  Future<PyqPerformance> getPyqPerformance(String userId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/pyq-performance?userId=$userId',
    );

    final performanceData = response.data!;
    final data = performanceData['data'] as Map<String, dynamic>;

    final subjectStatsData = data['subjectStats'] as List<dynamic>;
    final subjectStats = subjectStatsData.map((statData) {
      return SubjectPyqStats(
        subjectId: statData['subjectId'] as String,
        subjectName: statData['subjectName'] as String,
        totalQuestionsAttempted: statData['totalQuestionsAttempted'] as int,
        totalQuestionsCorrect: statData['totalQuestionsCorrect'] as int,
        accuracy: (statData['accuracy'] as num).toDouble(),
        averageTimePerQuestion: (statData['averageTimePerQuestion'] as num).toDouble(),
        topicsCovered: statData['topicsCovered'] as int,
        bookmarkedQuestions: statData['bookmarkedQuestions'] as int,
      );
    }).toList();

    final overallStatsData = data['overallStats'] as Map<String, dynamic>;
    final overallStats = OverallPyqStats(
      totalQuestionsAttempted: overallStatsData['totalQuestionsAttempted'] as int,
      totalQuestionsCorrect: overallStatsData['totalQuestionsCorrect'] as int,
      overallAccuracy: (overallStatsData['overallAccuracy'] as num).toDouble(),
      totalTimeSpentMinutes: (overallStatsData['totalTimeSpentMinutes'] as num).toDouble(),
      uniqueTopicsCovered: overallStatsData['uniqueTopicsCovered'] as int,
      currentStreak: overallStatsData['currentStreak'] as int,
    );

    final topicTrendsData = data['topicTrends'] as List<dynamic>;
    final topicTrends = topicTrendsData.map((trendData) {
      final dailyDataList = trendData['dailyData'] as List<dynamic>;
      final dailyData = dailyDataList.map((dailyDataItem) {
        return DailyPyqData(
          date: DateTime.parse(dailyDataItem['date'] as String),
          questionsAttempted: dailyDataItem['questionsAttempted'] as int,
          questionsCorrect: dailyDataItem['questionsCorrect'] as int,
          accuracy: (dailyDataItem['accuracy'] as num).toDouble(),
          timeSpentMinutes: dailyDataItem['timeSpentMinutes'] as int,
        );
      }).toList();

      return TopicPyqTrend(
        topicId: trendData['topicId'] as String,
        topicName: trendData['topicName'] as String,
        dailyData: dailyData,
      );
    }).toList();

    return PyqPerformance(
      userId: userId,
      subjectStats: subjectStats,
      overallStats: overallStats,
      topicTrends: topicTrends,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get mock test analytics
  Future<MockTestAnalytics> getMockTestAnalytics(String userId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/mock-performance?userId=$userId',
    );

    final analyticsData = response.data!;
    final data = analyticsData['data'] as Map<String, dynamic>;

    final attemptsData = data['attempts'] as List<dynamic>;
    final attempts = attemptsData.map((attemptData) {
      final sectionScoresData = attemptData['sectionScores'] as List<dynamic>;
      final sectionScores = sectionScoresData.map((sectionData) {
        return SectionScore(
          sectionName: sectionData['sectionName'] as String,
          questionsInSection: sectionData['questionsInSection'] as int,
          correctInSection: sectionData['correctInSection'] as int,
          sectionAccuracy: (sectionData['sectionAccuracy'] as num).toDouble(),
        );
      }).toList();

      return MockTestAttempt(
        attemptId: attemptData['attemptId'] as String,
        testType: attemptData['testType'] as String,
        subjectId: attemptData['subjectId'] as String,
        subjectName: attemptData['subjectName'] as String,
        date: DateTime.parse(attemptData['date'] as String),
        score: (attemptData['score'] as num).toDouble(),
        accuracy: (attemptData['accuracy'] as num).toDouble(),
        totalQuestions: attemptData['totalQuestions'] as int,
        correctAnswers: attemptData['correctAnswers'] as int,
        durationMinutes: attemptData['durationMinutes'] as int,
        sectionScores: sectionScores,
      );
    }).toList();

    final subjectStatsData = data['subjectStats'] as Map<String, dynamic>;
    final subjectStats = SubjectMockTestStats(
      subjectId: subjectStatsData['subjectId'] as String,
      subjectName: subjectStatsData['subjectName'] as String,
      totalAttempts: subjectStatsData['totalAttempts'] as int,
      averageScore: (subjectStatsData['averageScore'] as num).toDouble(),
      averageAccuracy: (subjectStatsData['averageAccuracy'] as num).toDouble(),
      bestScore: (subjectStatsData['bestScore'] as num).toDouble(),
      worstScore: (subjectStatsData['worstScore'] as num).toDouble(),
      trend: _mapScoreTrend(subjectStatsData['trend'] as String),
    );

    return MockTestAnalytics(
      userId: userId,
      attempts: attempts,
      subjectStats: subjectStats,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get study habits and time analytics
  Future<StudyHabits> getStudyHabits(String userId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/study-habits?userId=$userId',
    );

    final habitsData = response.data!;
    final data = habitsData['data'] as Map<String, dynamic>;

    final dailyDataList = data['dailyData'] as List<dynamic>;
    final dailyData = dailyDataList.map((dailyDataItem) {
      final subjectMinutesData = dailyDataItem['subjectMinutes'] as Map<String, dynamic>;
      final subjectMinutes = subjectMinutesData.map((key, value) => MapEntry(key, value as int));

      return DailyStudyData(
        date: DateTime.parse(dailyDataItem['date'] as String),
        totalStudyMinutes: dailyDataItem['totalStudyMinutes'] as int,
        subjectMinutes: subjectMinutes,
        topicsCompleted: dailyDataItem['topicsCompleted'] as int,
        pyqsAttempted: dailyDataItem['pyqsAttempted'] as int,
        metDailyGoal: dailyDataItem['metDailyGoal'] as bool,
      );
    }).toList();

    final weeklyStatsData = data['weeklyStats'] as Map<String, dynamic>;
    final weeklyStats = WeeklyStudyStats(
      totalStudyMinutes: weeklyStatsData['totalStudyMinutes'] as int,
      averageDailyMinutes: weeklyStatsData['averageDailyMinutes'] as int,
      activeStudyDays: weeklyStatsData['activeStudyDays'] as int,
      currentStreak: weeklyStatsData['currentStreak'] as int,
      longestStreak: weeklyStatsData['longestStreak'] as int,
      goalCompletionRate: (weeklyStatsData['goalCompletionRate'] as num).toDouble(),
    );

    final subjectDistributionData = data['subjectDistribution'] as Map<String, dynamic>;
    final entriesData = subjectDistributionData['entries'] as List<dynamic>;
    final entries = entriesData.map((entryData) {
      return SubjectTimeEntry(
        subjectId: entryData['subjectId'] as String,
        subjectName: entryData['subjectName'] as String,
        totalMinutes: entryData['totalMinutes'] as int,
        percentageOfTotal: (entryData['percentageOfTotal'] as num).toDouble(),
      );
    }).toList();

    final subjectDistribution = SubjectTimeDistribution(entries: entries);

    return StudyHabits(
      userId: userId,
      dailyData: dailyData,
      weeklyStats: weeklyStats,
      subjectDistribution: subjectDistribution,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get weak areas and recommendations
  Future<WeakArea> getWeakAreas(String userId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/weak-areas?userId=$userId',
    );

    final weakAreaData = response.data!;
    final data = weakAreaData['data'] as Map<String, dynamic>;

    final weakTopicsData = data['weakTopics'] as List<dynamic>;
    final weakTopics = weakTopicsData.map((topicData) {
      final prerequisiteTopicsData = topicData['prerequisiteTopics'] as List<dynamic>;
      final prerequisiteTopics = prerequisiteTopicsData.map((p) => p as String).toList();

      return WeakTopic(
        topicId: topicData['topicId'] as String,
        topicName: topicData['topicName'] as String,
        subjectId: topicData['subjectId'] as String,
        subjectName: topicData['subjectName'] as String,
        currentAccuracy: (topicData['currentAccuracy'] as num).toDouble(),
        targetAccuracy: (topicData['targetAccuracy'] as num).toDouble(),
        attempts: topicData['attempts'] as int,
        severity: _mapWeaknessSeverity(topicData['severity'] as String),
        prerequisiteTopics: prerequisiteTopics,
      );
    }).toList();

    final recommendationsData = data['recommendations'] as List<dynamic>;
    final recommendations = recommendationsData.map((recData) {
      return Recommendation(
        id: recData['id'] as String,
        type: recData['type'] as String,
        title: recData['title'] as String,
        description: recData['description'] as String,
        reason: recData['reason'] as String,
        topicId: recData['topicId'] as String?,
        subjectId: recData['subjectId'] as String?,
        priority: recData['priority'] as int,
        createdAt: DateTime.parse(recData['createdAt'] as String),
        isCompleted: recData['isCompleted'] as bool,
      );
    }).toList();

    return WeakArea(
      userId: userId,
      weakTopics: weakTopics,
      recommendations: recommendations,
      lastUpdated: DateTime.now(),
    );
  }

  /// Mark a recommendation as completed
  Future<void> markRecommendationCompleted(
    String userId,
    String recommendationId,
  ) async {
    await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.analytics}/recommendations/$recommendationId/complete',
      data: {'userId': userId},
    );
  }

  // Helper methods for mapping

  MasteryLevel _mapMasteryLevel(String level) {
    switch (level.toLowerCase()) {
      case 'mastered':
        return MasteryLevel.mastered;
      case 'building':
        return MasteryLevel.building;
      case 'in_progress':
        return MasteryLevel.inProgress;
      case 'not_started':
        return MasteryLevel.notStarted;
      default:
        return MasteryLevel.inProgress;
    }
  }

  ScoreTrend _mapScoreTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return ScoreTrend.improving;
      case 'declining':
        return ScoreTrend.declining;
      case 'stable':
        return ScoreTrend.stable;
      default:
        return ScoreTrend.stable;
    }
  }

  WeaknessSeverity _mapWeaknessSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'significant':
        return WeaknessSeverity.significant;
      case 'moderate':
        return WeaknessSeverity.moderate;
      case 'mild':
        return WeaknessSeverity.mild;
      default:
        return WeaknessSeverity.moderate;
    }
  }
}
