import '../database/database.dart';
import '../dtos/practice_dto.dart';
import '../failures.dart';
import '../result.dart';
import 'local_datasource.dart';
import 'package:drift/drift.dart';

/// Local data source for Practice & Assessment operations
/// Handles User Question Attempts, Mock Tests, Mock Test Questions/Answers
class PracticeLocalDataSource extends BaseLocalDataSource {
  PracticeLocalDataSource(super.database);

  // ==================== USER QUESTION ATTEMPTS ====================

  /// Get user question attempts
  Future<Result<List<UserQuestionAttemptDto>>> getUserAttempts(
    String userId, {
    String? questionId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = database.select(database.userQuestionAttempts)
        ..where((tbl) => tbl.userId.equals(userId));

      if (questionId != null) {
        query.where((tbl) => tbl.questionId.equals(questionId));
      }
      if (startDate != null) {
        query.where((tbl) => tbl.attemptDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((tbl) => tbl.attemptDate.isSmallerOrEqualValue(endDate));
      }

      query.orderBy([(tbl) => OrderingTerm.desc(tbl.attemptDate)]);

      final results = await query.get();

      final dtos = results.map((a) => UserQuestionAttemptDto(
        attemptId: a.attemptId,
        userId: a.userId,
        questionId: a.questionId,
        selectedAnswer: a.selectedAnswer,
        isCorrect: a.isCorrect,
        timeTakenSeconds: a.timeTakenSeconds,
        attemptDate: a.attemptDate,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create user question attempt
  Future<Result<UserQuestionAttemptDto>> createAttempt(
    UserQuestionAttemptDto attempt,
  ) async {
    try {
      await database.into(database.userQuestionAttempts).insert(
        UserQuestionAttemptsCompanion.insert(
          attemptId: attempt.attemptId,
          userId: attempt.userId,
          questionId: attempt.questionId,
          selectedAnswer: attempt.selectedAnswer,
          isCorrect: attempt.isCorrect,
          timeTakenSeconds: Value(attempt.timeTakenSeconds),
        ),
      );

      return Result.success(attempt);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get attempt by ID
  Future<Result<UserQuestionAttemptDto>> getAttemptById(String attemptId) async {
    try {
      final result = await (database.select(database.userQuestionAttempts)
            ..where((tbl) => tbl.attemptId.equals(attemptId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Attempt'));
      }

      final dto = UserQuestionAttemptDto(
        attemptId: result.attemptId,
        userId: result.userId,
        questionId: result.questionId,
        selectedAnswer: result.selectedAnswer,
        isCorrect: result.isCorrect,
        timeTakenSeconds: result.timeTakenSeconds,
        attemptDate: result.attemptDate,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== MOCK TESTS ====================

  /// Get mock tests for a user
  Future<Result<List<MockTestDto>>> getMockTests(
    String userId, {
    String? status,
  }) async {
    try {
      final query = database.select(database.mockTests)
        ..where((tbl) => tbl.userId.equals(userId));

      if (status != null) {
        query.where((tbl) => tbl.status.equals(status));
      }

      query.orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]);

      final results = await query.get();

      final dtos = results.map((m) => MockTestDto(
        testId: m.testId,
        userId: m.userId,
        examId: m.examId,
        type: m.type,
        subjectId: m.subjectId,
        topicId: m.topicId,
        durationMinutes: m.durationMinutes,
        status: m.status,
        score: m.score,
        startedAt: m.startedAt,
        submittedAt: m.submittedAt,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get mock test by ID
  Future<Result<MockTestDto>> getMockTestById(String testId) async {
    try {
      final result = await (database.select(database.mockTests)
            ..where((tbl) => tbl.testId.equals(testId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Mock Test'));
      }

      final dto = MockTestDto(
        testId: result.testId,
        userId: result.userId,
        examId: result.examId,
        type: result.type,
        subjectId: result.subjectId,
        topicId: result.topicId,
        durationMinutes: result.durationMinutes,
        status: result.status,
        score: result.score,
        startedAt: result.startedAt,
        submittedAt: result.submittedAt,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create mock test
  Future<Result<MockTestDto>> createMockTest(MockTestDto test) async {
    try {
      await database.into(database.mockTests).insert(
        MockTestsCompanion.insert(
          testId: test.testId,
          userId: test.userId,
          examId: test.examId,
          type: test.type,
          subjectId: Value(test.subjectId),
          topicId: Value(test.topicId),
          durationMinutes: test.durationMinutes,
          status: Value(test.status),
        ),
      );

      return Result.success(test);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update mock test
  Future<Result<MockTestDto>> updateMockTest(MockTestDto test) async {
    try {
      await database.update(database.mockTests).replace(
        MockTestsCompanion(
          testId: Value(test.testId),
          userId: Value(test.userId),
          examId: Value(test.examId),
          type: Value(test.type),
          subjectId: Value(test.subjectId),
          topicId: Value(test.topicId),
          durationMinutes: Value(test.durationMinutes),
          status: Value(test.status),
          score: Value(test.score),
          startedAt: Value(test.startedAt),
          submittedAt: Value(test.submittedAt),
        ),
      );

      return Result.success(test);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update mock test status
  Future<Result<void>> updateMockTestStatus(
    String testId,
    String status,
  ) async {
    try {
      await (database.update(database.mockTests)
          ..where((tbl) => tbl.testId.equals(testId)))
          .write(
            MockTestsCompanion(
              status: Value(status),
            ),
          );

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== MOCK TEST QUESTIONS ====================

  /// Get questions for a mock test
  Future<Result<List<MockTestQuestionDto>>> getMockTestQuestions(
    String testId,
  ) async {
    try {
      final results = await (database.select(database.mockTestQuestions)
            ..where((tbl) => tbl.testId.equals(testId)))
          .get();

      final dtos = results.map((q) => MockTestQuestionDto(
        testId: q.testId,
        questionId: q.questionId,
        questionOrder: q.questionOrder,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Add question to mock test
  Future<Result<MockTestQuestionDto>> addMockTestQuestion(
    MockTestQuestionDto question,
  ) async {
    try {
      await database.into(database.mockTestQuestions).insert(
        MockTestQuestionsCompanion.insert(
          testId: question.testId,
          questionId: question.questionId,
          questionOrder: question.questionOrder,
        ),
      );

      return Result.success(question);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== MOCK TEST ANSWERS ====================

  /// Get answers for a mock test
  Future<Result<List<MockTestAnswerDto>>> getMockTestAnswers(
    String testId,
  ) async {
    try {
      final results = await (database.select(database.mockTestAnswers)
            ..where((tbl) => tbl.testId.equals(testId)))
          .get();

      final dtos = results.map((a) => MockTestAnswerDto(
        testId: a.testId,
        questionId: a.questionId,
        selectedAnswer: a.selectedAnswer,
        isCorrect: a.isCorrect,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Save mock test answer
  Future<Result<MockTestAnswerDto>> saveMockTestAnswer(
    MockTestAnswerDto answer,
  ) async {
    try {
      final existing = await (database.select(database.mockTestAnswers)
            ..where((tbl) => tbl.testId.equals(answer.testId))
            ..where((tbl) => tbl.questionId.equals(answer.questionId))
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.mockTestAnswers).replace(
          MockTestAnswersCompanion(
            testId: Value(answer.testId),
            questionId: Value(answer.questionId),
            selectedAnswer: Value(answer.selectedAnswer),
            isCorrect: Value(answer.isCorrect),
          ),
        );
      } else {
        await database.into(database.mockTestAnswers).insert(
          MockTestAnswersCompanion.insert(
            testId: answer.testId,
            questionId: answer.questionId,
            selectedAnswer: Value(answer.selectedAnswer),
            isCorrect: Value(answer.isCorrect),
          ),
        );
      }

      return Result.success(answer);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Save all mock test answers at once
  Future<Result<void>> saveAllMockTestAnswers(
    String testId,
    List<MockTestAnswerDto> answers,
  ) async {
    try {
      await database.transaction(() async {
        for (final answer in answers) {
          final result = await saveMockTestAnswer(answer);
          if (!result.isSuccess) {
            throw result.failure!;
          }
        }
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await database.delete(database.userQuestionAttempts).go();
      await database.delete(database.mockTests).go();
      await database.delete(database.mockTestQuestions).go();
      await database.delete(database.mockTestAnswers).go();
    } catch (e) {
      throw handleDatabaseError(e);
    }
  }
}
