/// PYQ Remote Data Source
/// Handles all API calls for PYQ data
library;

import 'package:prepnode/core/network/api_client.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/models/requests/pyq_requests.dart';
import 'package:prepnode/core/network/models/api_response.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepnode/features/pyq/domain/entities/topic_pyq_summary.dart';

class PyqRemoteDataSource {
  final ApiClient _apiClient;

  PyqRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get topics with PYQ summaries for a subject
  Future<List<TopicPyqSummary>> getTopicSummaries({
    required String examId,
    required String subjectId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.subjects}/$subjectId${ApiConstants.topics}/pyq-summaries',
    );

    final summariesData = response.data!;
    final summariesList = summariesData as List<dynamic>;

    return summariesList.map((summaryData) {
      return TopicPyqSummary(
        topicId: summaryData['topicId'] as String,
        topicName: summaryData['topicName'] as String,
        totalQuestions: _parseToInt(summaryData['totalQuestions']),
        solvedQuestions: _parseToInt(summaryData['solvedQuestions']),
        bookmarkedQuestions: _parseToInt(summaryData['bookmarkedQuestions']),
        incorrectQuestions: _parseToInt(summaryData['incorrectQuestions']),
        averageAccuracy: (summaryData['averageAccuracy'] as num).toDouble(),
        lastYear: summaryData['lastYear'] != null ? _parseToInt(summaryData['lastYear']) : null,
        firstYear: summaryData['firstYear'] != null ? _parseToInt(summaryData['firstYear']) : null,
        frequencyCount: _parseToInt(summaryData['frequencyCount']),
        yearsAppeared: (summaryData['yearsAppeared'] as List<dynamic>)
            .map((year) => _parseToInt(year))
            .toList(),
      );
    }).toList();
  }

  /// Get PYQ questions for a topic
  Future<List<PyqQuestion>> getQuestions({
    required String examId,
    required String subjectId,
    required String topicId,
    Map<String, dynamic>? filter,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null) {
      queryParams.addAll(filter);
    }

    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.topics}/$topicId${ApiConstants.pyq}',
      queryParameters: queryParams,
    );

    final questionsData = response.data!;
    final questionsList = questionsData as List<dynamic>;

    return questionsList.map((questionData) {
      return PyqQuestion(
        id: questionData['questionId'] as String,
        examId: questionData['examId'] as String,
        subjectId: questionData['subjectId'] as String,
        topicId: questionData['topicId'] as String,
        year: _parseToInt(questionData['year']),
        questionText: questionData['questionText'] as String,
        options: [
          questionData['optionA'] as String,
          questionData['optionB'] as String,
          questionData['optionC'] as String,
          questionData['optionD'] as String,
        ],
        correctAnswerIndex: _mapCorrectAnswerIndex(questionData['correctAnswer'] as String?),
        explanation: questionData['explanation'] as String? ?? '',
        difficulty: _mapDifficulty(questionData['difficulty'] as String?),
        isSolved: questionData['isSolved'] as bool? ?? false,
        isBookmarked: questionData['isBookmarked'] as bool? ?? false,
        userNotes: questionData['userNotes'] as String?,
        lastAttemptedAt: questionData['lastAttemptedAt'] != null
            ? DateTime.parse(questionData['lastAttemptedAt'] as String)
            : null,
        wasCorrect: questionData['wasCorrect'] as bool?,
        timesAppeared: questionData['timesAppeared'] as int?,
        timesCorrectOverall: questionData['timesCorrectOverall'] as int?,
      );
    }).toList();
  }

  /// Search PYQ questions
  Future<List<PyqQuestion>> searchQuestions({
    required String examId,
    required String query,
    Map<String, dynamic>? filter,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (filter != null) {
      queryParams.addAll(filter);
    }

    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.pyq}/search',
      queryParameters: queryParams,
    );

    final questionsData = response.data!;
    final questionsList = questionsData as List<dynamic>;

    return questionsList.map((questionData) {
      return PyqQuestion(
        id: questionData['questionId'] as String,
        examId: questionData['examId'] as String,
        subjectId: questionData['subjectId'] as String,
        topicId: questionData['topicId'] as String,
        year: _parseToInt(questionData['year']),
        questionText: questionData['questionText'] as String,
        options: [
          questionData['optionA'] as String,
          questionData['optionB'] as String,
          questionData['optionC'] as String,
          questionData['optionD'] as String,
        ],
        correctAnswerIndex: _mapCorrectAnswerIndex(questionData['correctAnswer'] as String?),
        explanation: questionData['explanation'] as String? ?? '',
        difficulty: _mapDifficulty(questionData['difficulty'] as String?),
        isSolved: questionData['isSolved'] as bool? ?? false,
        isBookmarked: questionData['isBookmarked'] as bool? ?? false,
        userNotes: questionData['userNotes'] as String?,
        lastAttemptedAt: questionData['lastAttemptedAt'] != null
            ? DateTime.parse(questionData['lastAttemptedAt'] as String)
            : null,
        wasCorrect: questionData['wasCorrect'] as bool?,
        timesAppeared: questionData['timesAppeared'] as int?,
        timesCorrectOverall: questionData['timesCorrectOverall'] as int?,
      );
    }).toList();
  }

  /// Get incorrect questions for retry
  Future<List<PyqQuestion>> getIncorrectQuestions({
    required String userId,
    required String examId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.pyq}/incorrect?userId=$userId&examId=$examId',
    );

    final questionsData = response.data!;
    final questionsList = questionsData as List<dynamic>;

    return questionsList.map((questionData) {
      return PyqQuestion(
        id: questionData['questionId'] as String,
        examId: questionData['examId'] as String,
        subjectId: questionData['subjectId'] as String,
        topicId: questionData['topicId'] as String,
        year: _parseToInt(questionData['year']),
        questionText: questionData['questionText'] as String,
        options: [
          questionData['optionA'] as String,
          questionData['optionB'] as String,
          questionData['optionC'] as String,
          questionData['optionD'] as String,
        ],
        correctAnswerIndex: _mapCorrectAnswerIndex(questionData['correctAnswer'] as String?),
        explanation: questionData['explanation'] as String? ?? '',
        difficulty: _mapDifficulty(questionData['difficulty'] as String?),
        isSolved: questionData['isSolved'] as bool? ?? false,
        isBookmarked: questionData['isBookmarked'] as bool? ?? false,
        userNotes: questionData['userNotes'] as String?,
        lastAttemptedAt: questionData['lastAttemptedAt'] != null
            ? DateTime.parse(questionData['lastAttemptedAt'] as String)
            : null,
        wasCorrect: questionData['wasCorrect'] as bool?,
        timesAppeared: questionData['timesAppeared'] as int?,
        timesCorrectOverall: questionData['timesCorrectOverall'] as int?,
      );
    }).toList();
  }

  /// Get bookmarked questions
  Future<List<PyqQuestion>> getBookmarkedQuestions({
    required String userId,
    required String examId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.bookmarks}?userId=$userId&examId=$examId&entityType=question',
    );

    final questionsData = response.data!;
    final questionsList = questionsData as List<dynamic>;

    return questionsList.map((questionData) {
      return PyqQuestion(
        id: questionData['questionId'] as String,
        examId: questionData['examId'] as String,
        subjectId: questionData['subjectId'] as String,
        topicId: questionData['topicId'] as String,
        year: _parseToInt(questionData['year']),
        questionText: questionData['questionText'] as String,
        options: [
          questionData['optionA'] as String,
          questionData['optionB'] as String,
          questionData['optionC'] as String,
          questionData['optionD'] as String,
        ],
        correctAnswerIndex: _mapCorrectAnswerIndex(questionData['correctAnswer'] as String?),
        explanation: questionData['explanation'] as String? ?? '',
        difficulty: _mapDifficulty(questionData['difficulty'] as String?),
        isSolved: questionData['isSolved'] as bool? ?? false,
        isBookmarked: true,
        userNotes: questionData['userNotes'] as String?,
        lastAttemptedAt: questionData['lastAttemptedAt'] != null
            ? DateTime.parse(questionData['lastAttemptedAt'] as String)
            : null,
        wasCorrect: questionData['wasCorrect'] as bool?,
        timesAppeared: questionData['timesAppeared'] as int?,
        timesCorrectOverall: questionData['timesCorrectOverall'] as int?,
      );
    }).toList();
  }

  /// Toggle bookmark status
  Future<PyqQuestion> toggleBookmark({
    required String questionId,
  }) async {
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.bookmarks}/toggle',
      data: {'entityId': questionId, 'entityType': 'question'},
    );

    final questionData = response.data!;
    final data = questionData['data'] as Map<String, dynamic>;

    return PyqQuestion(
      id: data['questionId'] as String,
      examId: data['examId'] as String,
      subjectId: data['subjectId'] as String,
      topicId: data['topicId'] as String,
      year: data['year'] as int,
      questionText: data['questionText'] as String,
      options: [
        data['optionA'] as String,
        data['optionB'] as String,
        data['optionC'] as String,
        data['optionD'] as String,
      ],
      correctAnswerIndex: _mapCorrectAnswerIndex(data['correctAnswer'] as String?),
      explanation: data['explanation'] as String? ?? '',
      difficulty: _mapDifficulty(data['difficulty'] as String?),
      isSolved: data['isSolved'] as bool? ?? false,
      isBookmarked: data['isBookmarked'] as bool? ?? false,
      userNotes: data['userNotes'] as String?,
      lastAttemptedAt: data['lastAttemptedAt'] != null
          ? DateTime.parse(data['lastAttemptedAt'] as String)
          : null,
      wasCorrect: data['wasCorrect'] as bool?,
      timesAppeared: data['timesAppeared'] as int?,
      timesCorrectOverall: data['timesCorrectOverall'] as int?,
    );
  }

  /// Update user notes for a question
  Future<PyqQuestion> updateNotes({
    required String questionId,
    required String notes,
  }) async {
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.pyq}/$questionId/notes',
      data: {'notes': notes},
    );

    final questionData = response.data!;
    final data = questionData['data'] as Map<String, dynamic>;

    return PyqQuestion(
      id: data['questionId'] as String,
      examId: data['examId'] as String,
      subjectId: data['subjectId'] as String,
      topicId: data['topicId'] as String,
      year: data['year'] as int,
      questionText: data['questionText'] as String,
      options: [
        data['optionA'] as String,
        data['optionB'] as String,
        data['optionC'] as String,
        data['optionD'] as String,
      ],
      correctAnswerIndex: _mapCorrectAnswerIndex(data['correctAnswer'] as String?),
      explanation: data['explanation'] as String? ?? '',
      difficulty: _mapDifficulty(data['difficulty'] as String?),
      isSolved: data['isSolved'] as bool? ?? false,
      isBookmarked: data['isBookmarked'] as bool? ?? false,
      userNotes: data['userNotes'] as String?,
      lastAttemptedAt: data['lastAttemptedAt'] != null
          ? DateTime.parse(data['lastAttemptedAt'] as String)
          : null,
      wasCorrect: data['wasCorrect'] as bool?,
      timesAppeared: data['timesAppeared'] as int?,
      timesCorrectOverall: data['timesCorrectOverall'] as int?,
    );
  }

  /// Submit question attempt
  Future<QuestionAttempt> submitAttempt({
    required String questionId,
    required int selectedOptionIndex,
    required int timeTakenSeconds,
    String? confidenceRating,
    String? notes,
  }) async {
    final request = SubmitAttemptRequest(
      attemptId: DateTime.now().millisecondsSinceEpoch.toString(),
      questionId: questionId,
      selectedAnswer: String.fromCharCode(65 + selectedOptionIndex),
      timeTakenSeconds: timeTakenSeconds,
    );

    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.pyq}/attempts',
      data: request.toJson(),
    );

    final attemptData = response.data!;
    final data = attemptData['data'] as Map<String, dynamic>;

    return QuestionAttempt(
      id: data['attemptId'] as String,
      questionId: data['questionId'] as String,
      selectedOptionIndex: _mapCorrectAnswerIndex(data['selectedAnswer'] as String?),
      correctOptionIndex: _mapCorrectAnswerIndex(data['correctAnswer'] as String?),
      isCorrect: data['isCorrect'] as bool? ?? false,
      timeTakenSeconds: data['timeTakenSeconds'] as int,
      attemptedAt: DateTime.parse(data['attemptedAt'] as String),
      confidenceRating: _mapConfidenceRating(data['confidenceRating'] as String?),
      notes: data['notes'] as String?,
    );
  }

  /// Get weak topics based on PYQ performance
  Future<List<TopicPyqSummary>> getWeakTopics({
    required String userId,
    required String examId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.analytics}/weak-topics?userId=$userId&examId=$examId',
    );

    final summariesData = response.data!;
    final summariesList = summariesData as List<dynamic>;

    return summariesList.map((summaryData) {
      return TopicPyqSummary(
        topicId: summaryData['topicId'] as String,
        topicName: summaryData['topicName'] as String,
        totalQuestions: _parseToInt(summaryData['totalQuestions']),
        solvedQuestions: _parseToInt(summaryData['solvedQuestions']),
        bookmarkedQuestions: _parseToInt(summaryData['bookmarkedQuestions']),
        incorrectQuestions: _parseToInt(summaryData['incorrectQuestions']),
        averageAccuracy: (summaryData['averageAccuracy'] as num).toDouble(),
        lastYear: summaryData['lastYear'] != null ? _parseToInt(summaryData['lastYear']) : null,
        firstYear: summaryData['firstYear'] != null ? _parseToInt(summaryData['firstYear']) : null,
        frequencyCount: _parseToInt(summaryData['frequencyCount']),
        yearsAppeared: (summaryData['yearsAppeared'] as List<dynamic>)
            .map((year) => _parseToInt(year))
            .toList(),
      );
    }).toList();
  }

  // Helper methods for mapping

  int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DifficultyLevel _mapDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  ConfidenceRating _mapConfidenceRating(String? rating) {
    switch (rating?.toLowerCase()) {
      case 'very_high':
        return ConfidenceRating.veryHigh;
      case 'high':
        return ConfidenceRating.high;
      case 'medium':
        return ConfidenceRating.medium;
      case 'low':
        return ConfidenceRating.low;
      case 'very_low':
        return ConfidenceRating.veryLow;
      default:
        return ConfidenceRating.medium;
    }
  }

  int _mapCorrectAnswerIndex(String? correctAnswer) {
    switch (correctAnswer?.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }
}
