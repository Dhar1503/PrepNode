import '../datasources/practice_local_datasource.dart';
import '../dtos/practice_dto.dart';
import '../result.dart';
import 'base_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository for Practice & Assessment operations
/// Handles User Question Attempts, Mock Tests
class PracticeRepository extends BaseRepositoryImpl {
  final PracticeLocalDataSource _localDataSource;

  PracticeRepository(this._localDataSource);

  // ==================== USER QUESTION ATTEMPTS ====================

  /// Get user question attempts
  Future<Result<List<Map<String, dynamic>>>> getUserAttempts(
    String userId, {
    String? questionId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _localDataSource.getUserAttempts(
        userId,
        questionId: questionId,
        startDate: startDate,
        endDate: endDate,
      );
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create user question attempt
  Future<Result<void>> createAttempt({
    required String userId,
    required String questionId,
    required String selectedAnswer,
    required bool isCorrect,
    int? timeTakenSeconds,
  }) async {
    try {
      final dto = UserQuestionAttemptDto(
        attemptId: const Uuid().v4(),
        userId: userId,
        questionId: questionId,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        timeTakenSeconds: timeTakenSeconds,
        attemptDate: DateTime.now(),
      );

      final result = await _localDataSource.createAttempt(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get attempt by ID
  Future<Result<Map<String, dynamic>>> getAttemptById(String attemptId) async {
    try {
      final result = await _localDataSource.getAttemptById(attemptId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toDomainMap()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== MOCK TESTS ====================

  /// Get mock tests for a user
  Future<Result<List<Map<String, dynamic>>>> getMockTests(
    String userId, {
    String? status,
  }) async {
    try {
      final result = await _localDataSource.getMockTests(userId, status: status);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get mock test by ID
  Future<Result<Map<String, dynamic>>> getMockTestById(String testId) async {
    try {
      final result = await _localDataSource.getMockTestById(testId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toDomainMap()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create mock test
  Future<Result<String>> createMockTest({
    required String userId,
    required String examId,
    required String type,
    required int durationMinutes,
    String? subjectId,
    String? topicId,
  }) async {
    try {
      final testId = const Uuid().v4();
      final dto = MockTestDto(
        testId: testId,
        userId: userId,
        examId: examId,
        type: type,
        subjectId: subjectId,
        topicId: topicId,
        durationMinutes: durationMinutes,
        status: 'in_progress',
        startedAt: DateTime.now(),
      );

      final result = await _localDataSource.createMockTest(dto);
      return result.fold(
        onSuccess: (_) => Result.success(testId),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update mock test
  Future<Result<void>> updateMockTest({
    required String testId,
    String? status,
    double? score,
    DateTime? submittedAt,
  }) async {
    try {
      // Get existing test first
      final existingResult = await _localDataSource.getMockTestById(testId);
      
      return existingResult.fold(
        onSuccess: (existing) {
          final updated = MockTestDto(
            testId: testId,
            userId: existing.userId,
            examId: existing.examId,
            type: existing.type,
            subjectId: existing.subjectId,
            topicId: existing.topicId,
            durationMinutes: existing.durationMinutes,
            status: status ?? existing.status,
            score: score ?? existing.score,
            startedAt: existing.startedAt,
            submittedAt: submittedAt ?? existing.submittedAt,
          );
          return _localDataSource.updateMockTest(updated);
        },
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update mock test status
  Future<Result<void>> updateMockTestStatus(
    String testId,
    String status,
  ) async {
    try {
      final result = await _localDataSource.updateMockTestStatus(testId, status);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== MOCK TEST QUESTIONS ====================

  /// Get questions for a mock test
  Future<Result<List<Map<String, dynamic>>>> getMockTestQuestions(
    String testId,
  ) async {
    try {
      final result = await _localDataSource.getMockTestQuestions(testId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Add question to mock test
  Future<Result<void>> addMockTestQuestion({
    required String testId,
    required String questionId,
    required int questionOrder,
  }) async {
    try {
      final dto = MockTestQuestionDto(
        testId: testId,
        questionId: questionId,
        questionOrder: questionOrder,
      );

      final result = await _localDataSource.addMockTestQuestion(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== MOCK TEST ANSWERS ====================

  /// Get answers for a mock test
  Future<Result<List<Map<String, dynamic>>>> getMockTestAnswers(
    String testId,
  ) async {
    try {
      final result = await _localDataSource.getMockTestAnswers(testId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Save mock test answer
  Future<Result<void>> saveMockTestAnswer({
    required String testId,
    required String questionId,
    String? selectedAnswer,
    bool? isCorrect,
  }) async {
    try {
      final dto = MockTestAnswerDto(
        testId: testId,
        questionId: questionId,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
      );

      final result = await _localDataSource.saveMockTestAnswer(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Save all mock test answers at once
  Future<Result<void>> saveAllMockTestAnswers(
    String testId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final answerDtos = answers.map((a) => MockTestAnswerDto(
        testId: testId,
        questionId: a['questionId'] as String,
        selectedAnswer: a['selectedAnswer'] as String?,
        isCorrect: a['isCorrect'] as bool?,
      )).toList();

      final result = await _localDataSource.saveAllMockTestAnswers(testId, answerDtos);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _localDataSource.clearAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }
}
