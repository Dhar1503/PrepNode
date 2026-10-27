import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepnode/features/pyq/domain/entities/topic_pyq_summary.dart';

/// PYQ Repository Interface
/// Abstract contract for PYQ data operations
abstract class PyqRepository {
  /// Get topics with PYQ summaries for a subject. [userId], when supplied,
  /// personalizes solved/incorrect/bookmarked/accuracy on each summary.
  Future<Either<Failure, List<TopicPyqSummary>>> getTopicSummaries({
    required String examId,
    required String subjectId,
    String? userId,
  });

  /// Get PYQ questions for a topic. [userId], when supplied, personalizes
  /// isBookmarked/isSolved on results (same as [searchQuestions]).
  Future<Either<Failure, List<PyqQuestion>>> getQuestions({
    required String examId,
    required String subjectId,
    required String topicId,
    String? userId,
    PyqFilter? filter,
  });

  /// Search PYQ questions. [subjectId]/[topicId] narrow the search scope and
  /// [userId], when supplied, personalizes isBookmarked/isSolved on results.
  Future<Either<Failure, List<PyqQuestion>>> searchQuestions({
    required String examId,
    required String query,
    String? subjectId,
    String? topicId,
    String? userId,
    PyqFilter? filter,
  });

  /// Get incorrect questions for retry
  Future<Either<Failure, List<PyqQuestion>>> getIncorrectQuestions({
    required String userId,
    required String examId,
  });

  /// Get bookmarked questions
  Future<Either<Failure, List<PyqQuestion>>> getBookmarkedQuestions({
    required String userId,
    required String examId,
  });

  /// Toggle bookmark status for a question, for a specific user
  Future<Either<Failure, PyqQuestion>> toggleBookmark({
    required String userId,
    required String questionId,
  });

  /// Update user notes for a question
  Future<Either<Failure, PyqQuestion>> updateNotes({
    required String questionId,
    required String notes,
  });

  /// Submit question attempt and persist it to attempt history. [isCorrect]
  /// and [correctOptionIndex] are supplied by the caller, which already
  /// knows the question's correct answer.
  Future<Either<Failure, QuestionAttempt>> submitAttempt({
    required String userId,
    required String questionId,
    required int selectedOptionIndex,
    required int correctOptionIndex,
    required bool isCorrect,
    required int timeTakenSeconds,
    ConfidenceRating? confidenceRating,
    String? notes,
  });

  /// Create a new practice session
  Future<Either<Failure, PyqSession>> createSession({
    required String userId,
    required String examId,
    required String subjectId,
    required String topicId,
    required String topicName,
    required SessionMode mode,
    required List<PyqQuestion> questions,
  });

  /// Update session progress
  Future<Either<Failure, PyqSession>> updateSession({
    required String sessionId,
    int? currentIndex,
    int? totalCorrect,
    int? totalAnswered,
    int? totalDurationSeconds,
    bool? isCompleted,
    List<QuestionAttempt>? attempts,
    List<String>? flaggedForRevision,
  });

  /// Get session by ID
  Future<Either<Failure, PyqSession>> getSession({
    required String sessionId,
  });

  /// Get active session for user
  Future<Either<Failure, PyqSession?>> getActiveSession({
    required String userId,
  });

  /// Get AI hint for a question
  Future<Either<Failure, String>> getAiHint({
    required String questionId,
  });

  /// Get weak topics based on PYQ performance
  Future<Either<Failure, List<TopicPyqSummary>>> getWeakTopics({
    required String userId,
    required String examId,
  });
}

/// PYQ Filter options
class PyqFilter {
  final List<int>? years;
  final List<DifficultyLevel>? difficulties;
  final bool? solvedOnly;
  final bool? unsolvedOnly;
  final bool? bookmarkedOnly;

  const PyqFilter({
    this.years,
    this.difficulties,
    this.solvedOnly,
    this.unsolvedOnly,
    this.bookmarkedOnly,
  });
}
