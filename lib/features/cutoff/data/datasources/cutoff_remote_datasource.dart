/// Cutoff Remote Data Source
/// Handles all API calls for cutoff intelligence data
library;

import 'package:prepnode/core/network/api_client.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/models/api_response.dart';
import 'package:prepnode/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/cutoff_analysis.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepnode/features/cutoff/domain/entities/recommendation.dart';
import 'package:prepnode/features/cutoff/domain/entities/yearly_trend.dart';

class CutoffRemoteDataSource {
  final ApiClient _apiClient;

  CutoffRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get historical cutoff data for a specific exam
  Future<ExamCutoff> getExamCutoff(String examId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.cutoff}/$examId',
    );

    final cutoffData = response.data!;
    final data = cutoffData['data'] as Map<String, dynamic>;

    final categoryCutoffsData = data['categoryCutoffs'] as List<dynamic>;
    final categoryCutoffs = categoryCutoffsData.map((cutoffData) {
      return CategoryCutoff(
        category: cutoffData['category'] as String,
        cutoffMark: (cutoffData['cutoffMark'] as num).toDouble(),
        vacancyCount: cutoffData['vacancyCount'] as int,
        year: cutoffData['year'] as int,
      );
    }).toList();

    final yearlyTrendsData = data['yearlyTrends'] as List<dynamic>;
    final yearlyTrends = yearlyTrendsData.map((trendData) {
      final categoryBreakdownData = trendData['categoryBreakdown'] as List<dynamic>;
      final categoryBreakdown = categoryBreakdownData.map((cutoffData) {
        return CategoryCutoff(
          category: cutoffData['category'] as String,
          cutoffMark: (cutoffData['cutoffMark'] as num).toDouble(),
          vacancyCount: cutoffData['vacancyCount'] as int,
          year: cutoffData['year'] as int,
        );
      }).toList();

      return YearlyTrend(
        year: trendData['year'] as int,
        averageCutoff: (trendData['averageCutoff'] as num).toDouble(),
        totalVacancies: trendData['totalVacancies'] as int,
        difficultyIndex: (trendData['difficultyIndex'] as num).toDouble(),
        categoryBreakdown: categoryBreakdown,
      );
    }).toList();

    return ExamCutoff(
      examId: data['examId'] as String,
      examName: data['examName'] as String,
      conductingBody: data['conductingBody'] as String,
      categoryCutoffs: categoryCutoffs,
      yearlyTrends: yearlyTrends,
    );
  }

  /// Get comprehensive cutoff analysis for a user
  Future<CutoffAnalysis> getCutoffAnalysis(
    String userId,
    String examId,
  ) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.cutoff}/analysis?userId=$userId&examId=$examId',
    );

    final analysisData = response.data!;
    final data = analysisData['data'] as Map<String, dynamic>;

    final examCutoffData = data['examCutoff'] as Map<String, dynamic>;
    final examCutoff = ExamCutoff(
      examId: examCutoffData['examId'] as String,
      examName: examCutoffData['examName'] as String,
      conductingBody: examCutoffData['conductingBody'] as String,
      categoryCutoffs: [],
      yearlyTrends: [],
    );

    final readinessPredictionData = data['readinessPrediction'] as Map<String, dynamic>;
    final readinessPrediction = ReadinessPrediction(
      userId: readinessPredictionData['userId'] as String,
      examId: readinessPredictionData['examId'] as String,
      currentScore: (readinessPredictionData['currentScore'] as num).toDouble(),
      predictedScore: (readinessPredictionData['predictedScore'] as num).toDouble(),
      targetCutoff: (readinessPredictionData['targetCutoff'] as num).toDouble(),
      readinessPercentage: (readinessPredictionData['readinessPercentage'] as num).toDouble(),
      readinessLevel: readinessPredictionData['readinessLevel'] as String,
      strongAreas: (readinessPredictionData['strongAreas'] as List<dynamic>).map((s) => s as String).toList(),
      weakAreas: (readinessPredictionData['weakAreas'] as List<dynamic>).map((s) => s as String).toList(),
      weeksUntilExam: readinessPredictionData['weeksUntilExam'] as int,
      recommendation: readinessPredictionData['recommendation'] as String,
    );

    final recommendationsData = data['personalizedRecommendations'] as List<dynamic>;
    final personalizedRecommendations = recommendationsData.map((recData) {
      return Recommendation(
        id: recData['id'] as String,
        type: recData['type'] as String,
        title: recData['title'] as String,
        description: recData['description'] as String,
        topicId: recData['topicId'] as String?,
        subjectId: recData['subjectId'] as String?,
        priority: recData['priority'] as int,
        estimatedImpact: recData['estimatedImpact'] as String,
        timeRequired: recData['timeRequired'] as String,
      );
    }).toList();

    return CutoffAnalysis(
      userId: userId,
      examId: examId,
      examCutoff: examCutoff,
      readinessPrediction: readinessPrediction,
      personalizedRecommendations: personalizedRecommendations,
    );
  }

  /// Get readiness prediction for a user
  Future<ReadinessPrediction> getReadinessPrediction(
    String userId,
    String examId,
  ) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.cutoff}/readiness?userId=$userId&examId=$examId',
    );

    final predictionData = response.data!;
    final data = predictionData['data'] as Map<String, dynamic>;

    return ReadinessPrediction(
      userId: data['userId'] as String,
      examId: data['examId'] as String,
      currentScore: (data['currentScore'] as num).toDouble(),
      predictedScore: (data['predictedScore'] as num).toDouble(),
      targetCutoff: (data['targetCutoff'] as num).toDouble(),
      readinessPercentage: (data['readinessPercentage'] as num).toDouble(),
      readinessLevel: data['readinessLevel'] as String,
      strongAreas: (data['strongAreas'] as List<dynamic>).map((s) => s as String).toList(),
      weakAreas: (data['weakAreas'] as List<dynamic>).map((s) => s as String).toList(),
      weeksUntilExam: data['weeksUntilExam'] as int,
      recommendation: data['recommendation'] as String,
    );
  }

  /// Get list of available exams with cutoff data
  Future<List<ExamCutoff>> getAvailableExams() async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      ApiConstants.cutoff,
    );

    final examsList = response.data!;

    return examsList.map((examData) {
      final categoryCutoffsData = examData['categoryCutoffs'] as List<dynamic>;
      final categoryCutoffs = categoryCutoffsData.map((cutoffData) {
        return CategoryCutoff(
          category: cutoffData['category'] as String,
          cutoffMark: (cutoffData['cutoffMark'] as num).toDouble(),
          vacancyCount: cutoffData['vacancyCount'] as int,
          year: cutoffData['year'] as int,
        );
      }).toList();

      final yearlyTrendsData = examData['yearlyTrends'] as List<dynamic>;
      final yearlyTrends = yearlyTrendsData.map((trendData) {
        final categoryBreakdownData = trendData['categoryBreakdown'] as List<dynamic>;
        final categoryBreakdown = categoryBreakdownData.map((cutoffData) {
          return CategoryCutoff(
            category: cutoffData['category'] as String,
            cutoffMark: (cutoffData['cutoffMark'] as num).toDouble(),
            vacancyCount: cutoffData['vacancyCount'] as int,
            year: cutoffData['year'] as int,
          );
        }).toList();

        return YearlyTrend(
          year: trendData['year'] as int,
          averageCutoff: (trendData['averageCutoff'] as num).toDouble(),
          totalVacancies: trendData['totalVacancies'] as int,
          difficultyIndex: (trendData['difficultyIndex'] as num).toDouble(),
          categoryBreakdown: categoryBreakdown,
        );
      }).toList();

      return ExamCutoff(
        examId: examData['examId'] as String,
        examName: examData['examName'] as String,
        conductingBody: examData['conductingBody'] as String,
        categoryCutoffs: categoryCutoffs,
        yearlyTrends: yearlyTrends,
      );
    }).toList();
  }
}
