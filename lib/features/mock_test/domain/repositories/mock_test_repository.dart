import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_result.dart';

/// Mock Test Repository Interface
/// Abstract contract for mock test operations
abstract class MockTestRepository {
  /// Get available mock tests for an exam
  Future<Either<Failure, List<MockTest>>> getMockTests({
    required String examId,
    MockTestType? type,
  });

  /// Get mock test configuration
  Future<Either<Failure, MockTest>> getTestConfig({
    required String testId,
  });

  /// Start a new mock test attempt
  Future<Either<Failure, MockTestAttempt>> startTest({
    required String userId,
    required String testId,
  });

  /// Resume a paused test attempt
  Future<Either<Failure, MockTestAttempt>> resumeTest({
    required String attemptId,
  });

  /// Update question answer
  Future<Either<Failure, MockTestQuestion>> updateQuestionAnswer({
    required String attemptId,
    required String questionId,
    required int selectedOptionIndex,
    int? timeTakenSeconds,
  });

  /// Mark question for review
  Future<Either<Failure, MockTestQuestion>> markForReview({
    required String attemptId,
    required String questionId,
    required bool isMarked,
  });

  /// Skip question
  Future<Either<Failure, MockTestQuestion>> skipQuestion({
    required String attemptId,
    required String questionId,
  });

  /// Pause test attempt
  Future<Either<Failure, MockTestAttempt>> pauseTest({
    required String attemptId,
  });

  /// Submit test attempt. Takes the full attempt (not just its id) because
  /// the score is calculated from its answered questions.
  Future<Either<Failure, MockTestResult>> submitTest({
    required MockTestAttempt attempt,
  });

  /// Get test result
  Future<Either<Failure, MockTestResult>> getTestResult({
    required String attemptId,
  });

  /// Get user's test history
  Future<Either<Failure, List<MockTestResult>>> getTestHistory({
    required String userId,
    String? examId,
  });

  /// Get incorrect questions from a test
  Future<Either<Failure, List<MockTestQuestion>>> getIncorrectQuestions({
    required String attemptId,
  });

  /// Get AI performance summary
  Future<Either<Failure, String>> getAiSummary({
    required String attemptId,
  });
}
