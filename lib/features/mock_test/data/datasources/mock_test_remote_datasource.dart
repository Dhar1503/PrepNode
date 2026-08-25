/// Mock Test Remote Data Source
/// Handles all API calls for mock test data
library;

import 'package:prepgraph/core/network/api_client.dart';
import 'package:prepgraph/core/network/api_constants.dart';
import 'package:prepgraph/core/network/models/requests/mock_test_requests.dart';
import 'package:prepgraph/core/network/models/api_response.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_result.dart';

class MockTestRemoteDataSource {
  final ApiClient _apiClient;

  MockTestRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get available mock tests for an exam
  Future<List<MockTest>> getMockTests({
    required String examId,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{'examId': examId};
    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      ApiConstants.mockTests,
      queryParameters: queryParams,
    );

    final testsList = response.data!;

    return testsList.map((testData) {
      final sectionsData = testData['sections'] as List<dynamic>;
      final sections = sectionsData.map((sectionData) {
        return TestSection(
          id: sectionData['sectionId'] as String,
          name: sectionData['sectionName'] as String,
          questionCount: sectionData['questionCount'] as int,
          marks: sectionData['marks'] as int,
          durationMinutes: sectionData['durationMinutes'] as int,
          subjectId: sectionData['subjectId'] as String?,
        );
      }).toList();

      return MockTest(
        id: testData['testId'] as String,
        examId: testData['examId'] as String,
        title: testData['title'] as String,
        description: testData['description'] as String?,
        type: _mapTestType(testData['type'] as String),
        durationMinutes: testData['durationMinutes'] as int,
        totalQuestions: testData['totalQuestions'] as int,
        totalMarks: testData['totalMarks'] as int,
        negativeMarking: (testData['negativeMarking'] as num).toDouble(),
        sections: sections,
        subjectIds: (testData['subjectIds'] as List<dynamic>).map((id) => id as String).toList(),
      );
    }).toList();
  }

  /// Get mock test configuration
  Future<MockTest> getTestConfig({
    required String testId,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/$testId',
    );

    final testData = response.data!;
    final data = testData['data'] as Map<String, dynamic>;

    final sectionsData = data['sections'] as List<dynamic>;
    final sections = sectionsData.map((sectionData) {
      return TestSection(
        id: sectionData['sectionId'] as String,
        name: sectionData['sectionName'] as String,
        questionCount: sectionData['questionCount'] as int,
        marks: sectionData['marks'] as int,
        durationMinutes: sectionData['durationMinutes'] as int,
        subjectId: sectionData['subjectId'] as String?,
      );
    }).toList();

    return MockTest(
      id: data['testId'] as String,
      examId: data['examId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      type: _mapTestType(data['type'] as String),
      durationMinutes: data['durationMinutes'] as int,
      totalQuestions: data['totalQuestions'] as int,
      totalMarks: data['totalMarks'] as int,
      negativeMarking: (data['negativeMarking'] as num).toDouble(),
      sections: sections,
      subjectIds: (data['subjectIds'] as List<dynamic>).map((id) => id as String).toList(),
    );
  }

  /// Start a new mock test attempt
  Future<MockTestAttempt> startTest({
    required String userId,
    required String testId,
  }) async {
    final request = StartTestRequest(
      examId: testId,
      type: 'full',
    );
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/start',
      data: request.toJson(),
    );

    final attemptData = response.data!;
    final data = attemptData['data'] as Map<String, dynamic>;

    return MockTestAttempt(
      id: data['attemptId'] as String,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      startedAt: DateTime.parse(data['startedAt'] as String),
      status: _mapAttemptStatus(data['status'] as String),
      currentSectionIndex: data['currentSectionIndex'] as int? ?? 0,
      currentQuestionIndex: data['currentQuestionIndex'] as int? ?? 0,
      timeRemainingSeconds: data['timeRemainingSeconds'] as int? ?? 0,
    );
  }

  /// Resume a paused test attempt
  Future<MockTestAttempt> resumeTest({
    required String attemptId,
  }) async {
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/resume',
    );

    final attemptData = response.data!;
    final data = attemptData['data'] as Map<String, dynamic>;

    return MockTestAttempt(
      id: data['attemptId'] as String,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      startedAt: DateTime.parse(data['startedAt'] as String),
      status: _mapAttemptStatus(data['status'] as String),
      currentSectionIndex: data['currentSectionIndex'] as int? ?? 0,
      currentQuestionIndex: data['currentQuestionIndex'] as int? ?? 0,
      timeRemainingSeconds: data['timeRemainingSeconds'] as int? ?? 0,
    );
  }

  /// Update question answer
  Future<MockTestQuestion> updateQuestionAnswer({
    required String attemptId,
    required String questionId,
    required int selectedOptionIndex,
    int? timeTakenSeconds,
  }) async {
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/answers',
      data: {
        'attemptId': attemptId,
        'questionId': questionId,
        'selectedAnswer': String.fromCharCode(65 + selectedOptionIndex),
        if (timeTakenSeconds != null) 'timeTakenSeconds': timeTakenSeconds,
      },
    );

    final questionData = response.data!;
    final data = questionData['data'] as Map<String, dynamic>;

    return MockTestQuestion(
      id: data['questionId'] as String,
      testId: (data['testId'] as String?) ?? attemptId,
      sectionId: data['sectionId'] as String,
      questionText: data['questionText'] as String,
      options: [
        data['optionA'] as String,
        data['optionB'] as String,
        data['optionC'] as String,
        data['optionD'] as String,
      ],
      selectedOptionIndex: data['selectedAnswer'] != null
          ? (data['selectedAnswer'].toString().codeUnitAt(0)) - 65
          : null,
      timeTakenSeconds: data['timeTakenSeconds'] as int?,
      isMarkedForReview: data['isMarkedForReview'] as bool? ?? false,
      isSkipped: data['isSkipped'] as bool? ?? false,
    );
  }

  /// Mark question for review
  Future<MockTestQuestion> markForReview({
    required String attemptId,
    required String questionId,
    required bool isMarked,
  }) async {
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/questions/$questionId/review',
      data: {'isMarked': isMarked},
    );

    final questionData = response.data!;
    final data = questionData['data'] as Map<String, dynamic>;

    return MockTestQuestion(
      id: data['questionId'] as String,
      testId: (data['testId'] as String?) ?? attemptId,
      sectionId: data['sectionId'] as String,
      questionText: data['questionText'] as String,
      options: [
        data['optionA'] as String,
        data['optionB'] as String,
        data['optionC'] as String,
        data['optionD'] as String,
      ],
      selectedOptionIndex: data['selectedAnswer'] != null
          ? (data['selectedAnswer'].toString().codeUnitAt(0)) - 65
          : null,
      timeTakenSeconds: data['timeTakenSeconds'] as int?,
      isMarkedForReview: isMarked,
      isSkipped: data['isSkipped'] as bool? ?? false,
    );
  }

  /// Skip question
  Future<MockTestQuestion> skipQuestion({
    required String attemptId,
    required String questionId,
  }) async {
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/questions/$questionId/skip',
    );

    final questionData = response.data!;
    final data = questionData['data'] as Map<String, dynamic>;

    return MockTestQuestion(
      id: data['questionId'] as String,
      testId: (data['testId'] as String?) ?? attemptId,
      sectionId: data['sectionId'] as String,
      questionText: data['questionText'] as String,
      options: [
        data['optionA'] as String,
        data['optionB'] as String,
        data['optionC'] as String,
        data['optionD'] as String,
      ],
      selectedOptionIndex: data['selectedAnswer'] != null
          ? (data['selectedAnswer'].toString().codeUnitAt(0)) - 65
          : null,
      timeTakenSeconds: data['timeTakenSeconds'] as int?,
      isMarkedForReview: data['isMarkedForReview'] as bool? ?? false,
      isSkipped: true,
    );
  }

  /// Pause test attempt
  Future<MockTestAttempt> pauseTest({
    required String attemptId,
  }) async {
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/pause',
    );

    final attemptData = response.data!;
    final data = attemptData['data'] as Map<String, dynamic>;

    return MockTestAttempt(
      id: data['attemptId'] as String,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      startedAt: DateTime.parse(data['startedAt'] as String),
      status: _mapAttemptStatus(data['status'] as String),
      currentSectionIndex: data['currentSectionIndex'] as int? ?? 0,
      currentQuestionIndex: data['currentQuestionIndex'] as int? ?? 0,
      timeRemainingSeconds: data['timeRemainingSeconds'] as int? ?? 0,
    );
  }

  /// Submit test attempt
  Future<MockTestResult> submitTest({
    required String attemptId,
  }) async {
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/submit',
    );

    final resultData = response.data!;
    final data = resultData['data'] as Map<String, dynamic>;

    final sectionResultsData = data['sectionResults'] as List<dynamic>;
    final sectionResults = sectionResultsData.map((sectionData) {
      return SectionResult(
        sectionId: sectionData['sectionId'] as String,
        sectionName: sectionData['sectionName'] as String,
        correct: sectionData['correct'] as int,
        incorrect: sectionData['incorrect'] as int,
        skipped: sectionData['skipped'] as int,
        marks: sectionData['marks'] as int,
      );
    }).toList();

    return MockTestResult(
      id: data['resultId'] as String,
      attemptId: data['attemptId'] as String,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      submittedAt: DateTime.parse(data['submittedAt'] as String),
      totalScore: (data['totalScore'] as num).toDouble(),
      maxScore: data['maxScore'] as int,
      percentage: (data['percentage'] as num).toDouble(),
      rank: data['rank'] as int?,
      correct: data['correct'] as int,
      incorrect: data['incorrect'] as int,
      skipped: data['skipped'] as int,
      timeTakenSeconds: data['timeTakenSeconds'] as int,
      sectionResults: sectionResults,
    );
  }

  /// Get test result
  Future<MockTestResult> getTestResult({
    required String attemptId,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/result',
    );

    final resultData = response.data!;
    final data = resultData['data'] as Map<String, dynamic>;

    final sectionResultsData = data['sectionResults'] as List<dynamic>;
    final sectionResults = sectionResultsData.map((sectionData) {
      return SectionResult(
        sectionId: sectionData['sectionId'] as String,
        sectionName: sectionData['sectionName'] as String,
        correct: sectionData['correct'] as int,
        incorrect: sectionData['incorrect'] as int,
        skipped: sectionData['skipped'] as int,
        marks: sectionData['marks'] as int,
      );
    }).toList();

    return MockTestResult(
      id: data['resultId'] as String,
      attemptId: data['attemptId'] as String,
      userId: data['userId'] as String,
      testId: data['testId'] as String,
      submittedAt: DateTime.parse(data['submittedAt'] as String),
      totalScore: (data['totalScore'] as num).toDouble(),
      maxScore: data['maxScore'] as int,
      percentage: (data['percentage'] as num).toDouble(),
      rank: data['rank'] as int?,
      correct: data['correct'] as int,
      incorrect: data['incorrect'] as int,
      skipped: data['skipped'] as int,
      timeTakenSeconds: data['timeTakenSeconds'] as int,
      sectionResults: sectionResults,
    );
  }

  /// Get user's test history
  Future<List<MockTestResult>> getTestHistory({
    required String userId,
    String? examId,
  }) async {
    final queryParams = <String, dynamic>{'userId': userId};
    if (examId != null) {
      queryParams['examId'] = examId;
    }

    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.mockTests}/history',
      queryParameters: queryParams,
    );

    final resultsList = response.data!;

    return resultsList.map((resultData) {
      final sectionResultsData = resultData['sectionResults'] as List<dynamic>;
      final sectionResults = sectionResultsData.map((sectionData) {
        return SectionResult(
          sectionId: sectionData['sectionId'] as String,
          sectionName: sectionData['sectionName'] as String,
          correct: sectionData['correct'] as int,
          incorrect: sectionData['incorrect'] as int,
          skipped: sectionData['skipped'] as int,
          marks: sectionData['marks'] as int,
        );
      }).toList();

      return MockTestResult(
        id: resultData['resultId'] as String,
        attemptId: resultData['attemptId'] as String,
        userId: resultData['userId'] as String,
        testId: resultData['testId'] as String,
        submittedAt: DateTime.parse(resultData['submittedAt'] as String),
        totalScore: (resultData['totalScore'] as num).toDouble(),
        maxScore: resultData['maxScore'] as int,
        percentage: (resultData['percentage'] as num).toDouble(),
        rank: resultData['rank'] as int?,
        correct: resultData['correct'] as int,
        incorrect: resultData['incorrect'] as int,
        skipped: resultData['skipped'] as int,
        timeTakenSeconds: resultData['timeTakenSeconds'] as int,
        sectionResults: sectionResults,
      );
    }).toList();
  }

  /// Get incorrect questions from a test
  Future<List<MockTestQuestion>> getIncorrectQuestions({
    required String attemptId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/incorrect',
    );

    final questionsList = response.data!;

    return questionsList.map((questionData) {
      return MockTestQuestion(
        id: questionData['questionId'] as String,
        testId: (questionData['testId'] as String?) ?? attemptId,
        sectionId: questionData['sectionId'] as String,
        questionText: questionData['questionText'] as String,
        options: [
          questionData['optionA'] as String,
          questionData['optionB'] as String,
          questionData['optionC'] as String,
          questionData['optionD'] as String,
        ],
        selectedOptionIndex: questionData['selectedAnswer'] != null
            ? (questionData['selectedAnswer'].toString().codeUnitAt(0)) - 65
            : null,
        timeTakenSeconds: questionData['timeTakenSeconds'] as int?,
        isMarkedForReview: questionData['isMarkedForReview'] as bool? ?? false,
        isSkipped: questionData['isSkipped'] as bool? ?? false,
      );
    }).toList();
  }

  /// Get AI performance summary
  Future<String> getAiSummary({
    required String attemptId,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.mockTests}/attempts/$attemptId/ai-summary',
    );

    final data = response.data!;
    return data['data']['summary'] as String;
  }

  // Helper methods for mapping

  MockTestType _mapTestType(String type) {
    switch (type.toLowerCase()) {
      case 'full':
        return MockTestType.full;
      case 'sectional':
        return MockTestType.sectional;
      case 'topic':
        return MockTestType.topic;
      default:
        return MockTestType.full;
    }
  }

  AttemptStatus _mapAttemptStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return AttemptStatus.inProgress;
      case 'paused':
        return AttemptStatus.paused;
      case 'submitted':
        return AttemptStatus.submitted;
      case 'completed':
        return AttemptStatus.completed;
      default:
        return AttemptStatus.inProgress;
    }
  }
}
