import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/mock_test/data/datasources/mock_test_local_datasource.dart';
import 'package:prepnode/features/mock_test/data/datasources/mock_test_remote_datasource.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepnode/features/mock_test/domain/repositories/mock_test_repository.dart';

/// Production Mock Test Repository Implementation
/// Uses remote API and local database with offline-first strategy
class MockTestRepositoryImpl implements MockTestRepository {
  final MockTestRemoteDataSource _remoteDataSource;
  final MockTestLocalDataSource _localDataSource;

  MockTestRepositoryImpl({
    required MockTestRemoteDataSource remoteDataSource,
    required MockTestLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<MockTest>>> getMockTests({
    required String examId,
    MockTestType? type,
  }) async {
    try {
      // Fetch from API
      final tests = await _remoteDataSource.getMockTests(
        examId: examId,
        type: type?.name,
      );

      return Right(tests);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      // Backend unreachable — build the catalog from the local question
      // bank instead (see MockTestLocalDataSource.getAvailableTestsLocal).
      try {
        final tests = await _localDataSource.getAvailableTestsLocal(
          examId: examId,
          type: type,
        );
        return Right(tests);
      } catch (e2) {
        return Left(_mapErrorToFailure(e2));
      }
    }
  }

  @override
  Future<Either<Failure, MockTest>> getTestConfig({
    required String testId,
  }) async {
    try {
      // Fetch from API
      final test = await _remoteDataSource.getTestConfig(testId: testId);

      return Right(test);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      try {
        final test = await _localDataSource.getTestConfigLocal(testId);
        if (test == null) {
          return Left(DatabaseFailure.notFound(entity: 'Mock Test'));
        }
        return Right(test);
      } catch (e2) {
        return Left(_mapErrorToFailure(e2));
      }
    }
  }

  @override
  Future<Either<Failure, MockTestAttempt>> startTest({
    required String userId,
    required String testId,
  }) async {
    try {
      // Start via API
      final attempt = await _remoteDataSource.startTest(
        userId: userId,
        testId: testId,
      );

      // Save locally
      await _localDataSource.saveMockTestAttempt(
        attemptId: attempt.id,
        userId: userId,
        testId: testId,
        startedAt: attempt.startedAt,
      );

      return Right(attempt);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      return _startTestLocally(userId: userId, testId: testId);
    }
  }

  /// Builds a real attempt entirely from the local question bank — the
  /// same catalog/questions getMockTests()/getTestConfig() already read.
  Future<Either<Failure, MockTestAttempt>> _startTestLocally({
    required String userId,
    required String testId,
  }) async {
    try {
      final test = await _localDataSource.getTestConfigLocal(testId);
      if (test == null) {
        return Left(DatabaseFailure.notFound(entity: 'Mock Test'));
      }

      final questions = await _localDataSource.getQuestionsForTestLocal(testId);
      if (questions.isEmpty) {
        return Left(DatabaseFailure.notFound(entity: 'Questions for this test'));
      }

      final attemptId = DateTime.now().millisecondsSinceEpoch.toString();
      final startedAt = DateTime.now();

      await _localDataSource.saveMockTestAttempt(
        attemptId: attemptId,
        userId: userId,
        testId: testId,
        startedAt: startedAt,
      );

      final totalMarks = questions.fold<double>(0, (sum, q) => sum + q.marks);

      return Right(MockTestAttempt(
        id: attemptId,
        userId: userId,
        testId: testId,
        testType: test.type,
        startedAt: startedAt,
        durationSeconds: test.durationMinutes * 60,
        timeRemainingSeconds: test.durationMinutes * 60,
        totalQuestions: questions.length,
        totalMarks: totalMarks,
        questions: questions,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestAttempt>> resumeTest({
    required String attemptId,
  }) async {
    try {
      // Resume via API
      final attempt = await _remoteDataSource.resumeTest(attemptId: attemptId);

      // Update locally
      await _localDataSource.updateMockTestAttemptStatus(
        attemptId: attemptId,
        status: attempt.status.name,
      );

      return Right(attempt);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestQuestion>> updateQuestionAnswer({
    required String attemptId,
    required String questionId,
    required int selectedOptionIndex,
    int? timeTakenSeconds,
  }) async {
    try {
      // Update via API
      final question = await _remoteDataSource.updateQuestionAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedOptionIndex: selectedOptionIndex,
        timeTakenSeconds: timeTakenSeconds,
      );

      // Save locally. `question.isCorrect` compares the returned question's
      // own selectedOptionIndex against its correctAnswerIndex (see
      // MockTestQuestion) — the previous `selectedOptionIndex == 0` check
      // incorrectly assumed option A (index 0) was always the correct answer.
      await _localDataSource.saveMockTestAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedAnswer: String.fromCharCode(65 + selectedOptionIndex),
        timeTakenSeconds: timeTakenSeconds ?? 0,
        isCorrect: question.isCorrect,
      );

      return Right(question);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestQuestion>> markForReview({
    required String attemptId,
    required String questionId,
    required bool isMarked,
  }) async {
    try {
      // Mark via API
      final question = await _remoteDataSource.markForReview(
        attemptId: attemptId,
        questionId: questionId,
        isMarked: isMarked,
      );

      return Right(question);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestQuestion>> skipQuestion({
    required String attemptId,
    required String questionId,
  }) async {
    try {
      // Skip via API
      final question = await _remoteDataSource.skipQuestion(
        attemptId: attemptId,
        questionId: questionId,
      );

      return Right(question);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestAttempt>> pauseTest({
    required String attemptId,
  }) async {
    try {
      // Pause via API
      final attempt = await _remoteDataSource.pauseTest(attemptId: attemptId);

      // Update locally
      await _localDataSource.updateMockTestAttemptStatus(
        attemptId: attemptId,
        status: attempt.status.name,
      );

      return Right(attempt);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestResult>> submitTest({
    required MockTestAttempt attempt,
  }) async {
    try {
      // No live backend exists for this app (offline-first, local Drift DB
      // is the source of truth), so the score is calculated here from the
      // attempt's own answered questions rather than an API response.
      final questions = attempt.questions;

      final correctAnswers = questions.where((q) => q.isAnswered && q.isCorrect).length;
      final incorrectAnswers = questions.where((q) => q.isAnswered && !q.isCorrect).length;
      final skippedQuestions = questions.where((q) => q.isSkipped).length;
      final unanswered = questions.length - correctAnswers - incorrectAnswers - skippedQuestions;
      final obtainedMarks = questions.fold<double>(0, (sum, q) => sum + q.obtainedMarks);
      final totalMarks = questions.fold<double>(0, (sum, q) => sum + q.marks);
      final answeredCount = correctAnswers + incorrectAnswers;
      final accuracy = answeredCount > 0 ? correctAnswers / answeredCount : 0.0;
      final percentage = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0.0;
      final timeTakenSeconds = questions.fold<int>(0, (sum, q) => sum + (q.timeTakenSeconds ?? 0));
      final submittedAt = DateTime.now();

      for (final question in questions) {
        final selected = question.selectedOptionIndex;
        if (selected == null) continue;
        await _localDataSource.saveMockTestAnswer(
          attemptId: attempt.id,
          questionId: question.id,
          selectedAnswer: String.fromCharCode(65 + selected),
          timeTakenSeconds: question.timeTakenSeconds ?? 0,
          isCorrect: question.isCorrect,
        );
      }

      await _localDataSource.saveMockTestResult(
        resultId: attempt.id,
        attemptId: attempt.id,
        userId: attempt.userId,
        testId: attempt.testId,
        submittedAt: submittedAt,
        totalScore: obtainedMarks,
        maxScore: totalMarks.round(),
        percentage: percentage,
        correct: correctAnswers,
        incorrect: incorrectAnswers,
        skipped: skippedQuestions + unanswered,
        timeTakenSeconds: timeTakenSeconds,
      );

      return Right(MockTestResult(
        attemptId: attempt.id,
        testId: attempt.testId,
        userId: attempt.userId,
        obtainedMarks: obtainedMarks,
        totalMarks: totalMarks,
        percentage: percentage,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        skippedQuestions: skippedQuestions + unanswered,
        totalQuestions: questions.length,
        accuracy: accuracy,
        timeTakenSeconds: timeTakenSeconds,
        submittedAt: submittedAt,
        completedAt: submittedAt,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MockTestResult>> getTestResult({
    required String attemptId,
  }) async {
    try {
      // Fetch from API
      final result = await _remoteDataSource.getTestResult(attemptId: attemptId);

      return Right(result);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MockTestResult>>> getTestHistory({
    required String userId,
    String? examId,
  }) async {
    try {
      // Fetch from API
      final results = await _remoteDataSource.getTestHistory(
        userId: userId,
        examId: examId,
      );

      return Right(results);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      // Backend unreachable — rebuild history from the same local rows
      // submitTest() already writes (mock_tests + mock_test_answers).
      return _getTestHistoryLocally(userId: userId, examId: examId);
    }
  }

  Future<Either<Failure, List<MockTestResult>>> _getTestHistoryLocally({
    required String userId,
    String? examId,
  }) async {
    try {
      final rows = await _localDataSource.getMockTestResults(userId);

      final results = <MockTestResult>[];
      for (final row in rows) {
        final attemptId = row['attemptId'] as String;
        final testId = row['testId'] as String;
        // Filter on the row's real exam id, not its domain test id — see
        // MockTestLocalDataSource.saveMockTestResult's doc for why those
        // are two different values now (schema v5). Filtering on `testId`
        // here would never match a real examId and always return [].
        final rowExamId = row['examId'] as String?;
        if (examId != null && rowExamId != examId) continue;

        final answers = await _localDataSource.getMockTestAnswers(attemptId);
        final correctAnswers = answers.where((a) => a['isCorrect'] == true).length;
        final incorrectAnswers = answers.where((a) => a['isCorrect'] == false).length;
        // Unanswered/skipped questions never get a mock_test_answers row
        // (submitTest only writes one per answered question), so they
        // can't be reconstructed here — history shows answered questions
        // only, which is the data that's actually real.
        final totalAnswered = correctAnswers + incorrectAnswers;
        final obtainedMarks = (row['totalScore'] as double?) ?? 0.0;
        // marks-per-question isn't stored on mock_tests, so total marks is
        // estimated as one mark per answered question (this codebase's
        // seeded mock questions are single-mark) rather than fabricated.
        final totalMarks = totalAnswered.toDouble();
        final percentage = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0.0;

        results.add(MockTestResult(
          attemptId: attemptId,
          testId: testId,
          userId: userId,
          obtainedMarks: obtainedMarks,
          totalMarks: totalMarks,
          percentage: percentage,
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          skippedQuestions: 0,
          totalQuestions: totalAnswered,
          accuracy: totalAnswered > 0 ? correctAnswers / totalAnswered : 0.0,
          timeTakenSeconds: 0,
          sectionResults: const [],
          weakTopics: const [],
          flaggedForRevision: const [],
          aiSummary: '',
          submittedAt: row['submittedAt'] as DateTime?,
          completedAt: row['submittedAt'] as DateTime?,
        ));
      }

      return Right(results);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MockTestQuestion>>> getIncorrectQuestions({
    required String attemptId,
  }) async {
    try {
      // Fetch from API
      final questions = await _remoteDataSource.getIncorrectQuestions(
        attemptId: attemptId,
      );

      return Right(questions);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> getAiSummary({
    required String attemptId,
  }) async {
    try {
      // Fetch from API
      final summary = await _remoteDataSource.getAiSummary(attemptId: attemptId);

      return Right(summary);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
