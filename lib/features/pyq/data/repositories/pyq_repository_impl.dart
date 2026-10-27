import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/pyq/data/datasources/pyq_local_datasource.dart';
import 'package:prepnode/features/pyq/data/datasources/pyq_remote_datasource.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepnode/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepnode/features/pyq/domain/repositories/pyq_repository.dart';

/// Production PYQ Repository Implementation
/// Uses remote API and local database with offline-first strategy
class PyqRepositoryImpl implements PyqRepository {
  final PyqRemoteDataSource _remoteDataSource;
  final PyqLocalDataSource _localDataSource;

  PyqRepositoryImpl({
    required PyqRemoteDataSource remoteDataSource,
    required PyqLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<TopicPyqSummary>>> getTopicSummaries({
    required String examId,
    required String subjectId,
    String? userId,
  }) async {
    try {
      // No live backend exists for this app; compute summaries directly
      // from the local question bank + this user's attempt/bookmark
      // history instead of a remote call that can never succeed.
      final summaries = await _localDataSource.getTopicSummaries(
        examId: examId,
        subjectId: subjectId,
        userId: userId,
      );

      return Right(summaries);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PyqQuestion>>> getQuestions({
    required String examId,
    required String subjectId,
    required String topicId,
    String? userId,
    PyqFilter? filter,
  }) async {
    try {
      // No live backend exists for this app; PYQ questions are already
      // fully seeded locally and searchQuestions() already does exactly
      // this kind of filtered local read, so reuse it directly instead of
      // a remote call that can never succeed.
      final questions = await _localDataSource.searchQuestions(
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        years: filter?.years,
        difficulties: filter?.difficulties,
        userId: userId,
      );

      var results = questions;
      if (filter?.solvedOnly == true) {
        results = results.where((q) => q.isSolved).toList();
      }
      if (filter?.unsolvedOnly == true) {
        results = results.where((q) => !q.isSolved).toList();
      }
      if (filter?.bookmarkedOnly == true) {
        results = results.where((q) => q.isBookmarked).toList();
      }

      return Right(results);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PyqQuestion>>> searchQuestions({
    required String examId,
    required String query,
    String? subjectId,
    String? topicId,
    String? userId,
    PyqFilter? filter,
  }) async {
    try {
      // Filtered/searched directly against the local question bank.
      final questions = await _localDataSource.searchQuestions(
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        keyword: query,
        years: filter?.years,
        difficulties: filter?.difficulties,
        userId: userId,
      );

      var results = questions;
      if (filter?.solvedOnly == true) {
        results = results.where((q) => q.isSolved).toList();
      }
      if (filter?.unsolvedOnly == true) {
        results = results.where((q) => !q.isSolved).toList();
      }
      if (filter?.bookmarkedOnly == true) {
        results = results.where((q) => q.isBookmarked).toList();
      }

      return Right(results);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PyqQuestion>>> getIncorrectQuestions({
    required String userId,
    required String examId,
  }) async {
    try {
      // Derived from this user's stored attempt history rather than a
      // remote call — the most recently attempted questions this user got
      // wrong.
      final incorrectIds = await _localDataSource.getIncorrectQuestionIds(userId);
      final questions = await _localDataSource.getQuestionsByIds(
        incorrectIds,
        userId: userId,
      );

      return Right(questions.where((q) => q.examId == examId).toList());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PyqQuestion>>> getBookmarkedQuestions({
    required String userId,
    required String examId,
  }) async {
    try {
      final bookmarks = await _localDataSource.getBookmarks(
        userId: userId,
        entityType: 'question',
      );
      final ids = bookmarks.map((b) => b['entityId'] as String).toList();
      final questions = await _localDataSource.getQuestionsByIds(ids, userId: userId);

      return Right(questions.where((q) => q.examId == examId).toList());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqQuestion>> toggleBookmark({
    required String userId,
    required String questionId,
  }) async {
    try {
      final updatedQuestion = await _localDataSource.toggleQuestionBookmark(
        userId: userId,
        questionId: questionId,
      );

      if (updatedQuestion == null) {
        return Left(DatabaseFailure.notFound(entity: 'Question'));
      }

      return Right(updatedQuestion);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqQuestion>> updateNotes({
    required String questionId,
    required String notes,
  }) async {
    try {
      // Update via API
      final updatedQuestion = await _remoteDataSource.updateNotes(
        questionId: questionId,
        notes: notes,
      );

      return Right(updatedQuestion);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, QuestionAttempt>> submitAttempt({
    required String userId,
    required String questionId,
    required int selectedOptionIndex,
    required int correctOptionIndex,
    required bool isCorrect,
    required int timeTakenSeconds,
    ConfidenceRating? confidenceRating,
    String? notes,
  }) async {
    try {
      // Persisted locally only — no backend exists to submit this to, and
      // correctness is already known to the caller.
      await _localDataSource.saveQuestionAttempt(
        userId: userId,
        questionId: questionId,
        selectedAnswer: String.fromCharCode(65 + selectedOptionIndex),
        timeTakenSeconds: timeTakenSeconds,
        isCorrect: isCorrect,
      );

      return Right(QuestionAttempt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: questionId,
        selectedOptionIndex: selectedOptionIndex,
        correctOptionIndex: correctOptionIndex,
        isCorrect: isCorrect,
        timeTakenSeconds: timeTakenSeconds,
        confidenceRating: confidenceRating,
        attemptedAt: DateTime.now(),
        notes: notes,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqSession>> createSession({
    required String userId,
    required String examId,
    required String subjectId,
    required String topicId,
    required String topicName,
    required SessionMode mode,
    required List<PyqQuestion> questions,
  }) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Save session locally
      await _localDataSource.savePyqSession(
        sessionId: sessionId,
        userId: userId,
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        mode: mode.name,
      );

      final session = PyqSession(
        id: sessionId,
        userId: userId,
        examId: examId,
        subjectId: subjectId,
        topicId: topicId,
        topicName: topicName,
        mode: mode,
        questions: questions,
        currentIndex: 0,
        startedAt: DateTime.now(),
      );

      return Right(session);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqSession>> updateSession({
    required String sessionId,
    int? currentIndex,
    int? totalCorrect,
    int? totalAnswered,
    int? totalDurationSeconds,
    bool? isCompleted,
    List<QuestionAttempt>? attempts,
    List<String>? flaggedForRevision,
  }) async {
    try {
      // Update locally
      await _localDataSource.updatePyqSession(
        sessionId: sessionId,
        currentIndex: currentIndex,
        totalCorrect: totalCorrect,
        totalAnswered: totalAnswered,
        totalDurationSeconds: totalDurationSeconds,
        isCompleted: isCompleted,
      );

      // Get updated session
      final sessionData = await _localDataSource.getPyqSession(sessionId);
      if (sessionData == null) {
        return const Left(ServerFailure('Session not found'));
      }

      final session = PyqSession(
        id: sessionData['sessionId'] as String,
        userId: sessionData['userId'] as String,
        examId: sessionData['examId'] as String,
        subjectId: sessionData['subjectId'] as String,
        topicId: sessionData['topicId'] as String,
        topicName: '',
        mode: _mapSessionMode(sessionData['mode'] as String),
        questions: [],
        currentIndex: sessionData['currentIndex'] as int? ?? 0,
        startedAt: sessionData['startedAt'] as DateTime,
        totalCorrect: sessionData['totalCorrect'] as int? ?? 0,
        totalAnswered: sessionData['totalAnswered'] as int? ?? 0,
        totalDurationSeconds: sessionData['totalDurationSeconds'] as int? ?? 0,
        isCompleted: sessionData['isCompleted'] as bool? ?? false,
        attempts: attempts ?? [],
        flaggedForRevision: flaggedForRevision ?? [],
      );

      return Right(session);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqSession>> getSession({
    required String sessionId,
  }) async {
    try {
      // Get from local database
      final sessionData = await _localDataSource.getPyqSession(sessionId);
      if (sessionData == null) {
        return const Left(ServerFailure('Session not found'));
      }

      final session = PyqSession(
        id: sessionData['sessionId'] as String,
        userId: sessionData['userId'] as String,
        examId: sessionData['examId'] as String,
        subjectId: sessionData['subjectId'] as String,
        topicId: sessionData['topicId'] as String,
        topicName: '',
        mode: _mapSessionMode(sessionData['mode'] as String),
        questions: [],
        currentIndex: sessionData['currentIndex'] as int? ?? 0,
        startedAt: sessionData['startedAt'] as DateTime,
        totalCorrect: sessionData['totalCorrect'] as int? ?? 0,
        totalAnswered: sessionData['totalAnswered'] as int? ?? 0,
        totalDurationSeconds: sessionData['totalDurationSeconds'] as int? ?? 0,
        isCompleted: sessionData['isCompleted'] as bool? ?? false,
      );

      return Right(session);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PyqSession?>> getActiveSession({
    required String userId,
  }) async {
    try {
      // Get from local database
      final sessionData = await _localDataSource.getActivePyqSession(userId);
      if (sessionData == null) {
        return const Right(null);
      }

      final session = PyqSession(
        id: sessionData['sessionId'] as String,
        userId: sessionData['userId'] as String,
        examId: sessionData['examId'] as String,
        subjectId: sessionData['subjectId'] as String,
        topicId: sessionData['topicId'] as String,
        topicName: '',
        mode: _mapSessionMode(sessionData['mode'] as String),
        questions: [],
        currentIndex: sessionData['currentIndex'] as int? ?? 0,
        startedAt: sessionData['startedAt'] as DateTime,
        totalCorrect: sessionData['totalCorrect'] as int? ?? 0,
        totalAnswered: sessionData['totalAnswered'] as int? ?? 0,
        totalDurationSeconds: sessionData['totalDurationSeconds'] as int? ?? 0,
        isCompleted: sessionData['isCompleted'] as bool? ?? false,
      );

      return Right(session);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> getAiHint({
    required String questionId,
  }) async {
    try {
      // No LLM/external hint service exists in this project, so the hint is
      // generated from the question's own existing data (difficulty, year)
      // rather than a constant string.
      final question = await _localDataSource.getQuestionById(questionId);
      if (question == null) {
        return Left(DatabaseFailure.notFound(entity: 'Question'));
      }

      return Right(_buildHint(question));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  String _buildHint(PyqQuestion question) {
    final difficultyTip = switch (question.difficulty) {
      DifficultyLevel.easy =>
        'This is usually answered directly from standard reference material — recall the core fact before guessing.',
      DifficultyLevel.medium =>
        'Start by eliminating the options that are clearly unrelated, then weigh the remaining choices carefully.',
      DifficultyLevel.hard =>
        'This one often hinges on a specific exception or recent update — check whether the general rule has a documented exception.',
    };
    return '$difficultyTip This question appeared in the ${question.year} paper.';
  }

  @override
  Future<Either<Failure, List<TopicPyqSummary>>> getWeakTopics({
    required String userId,
    required String examId,
  }) async {
    try {
      // Fetch from API
      final weakTopics = await _remoteDataSource.getWeakTopics(
        userId: userId,
        examId: examId,
      );

      return Right(weakTopics);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  // Helper methods

  SessionMode _mapSessionMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'single':
        return SessionMode.single;
      case 'batch':
        return SessionMode.batch;
      case 'incorrect_retry':
        return SessionMode.incorrectRetry;
      case 'bookmarked':
        return SessionMode.bookmarked;
      default:
        return SessionMode.single;
    }
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
