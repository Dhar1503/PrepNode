/// PYQ Local Data Source
/// Handles local storage and caching for PYQ data
library;

import 'package:drift/drift.dart';
import 'package:prepgraph/core/data/database/database_service.dart';
import 'package:prepgraph/core/data/database/database.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/topic_pyq_summary.dart';

class PyqLocalDataSource {
  final DatabaseService _databaseService;

  PyqLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Save question attempt to local database
  Future<void> saveQuestionAttempt({
    required String userId,
    required String questionId,
    required String selectedAnswer,
    required int timeTakenSeconds,
    required bool isCorrect,
  }) async {
    final db = _databaseService.database;
    final attemptId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.into(db.userQuestionAttempts).insert(
      UserQuestionAttemptsCompanion(
        attemptId: Value(attemptId),
        userId: Value(userId),
        questionId: Value(questionId),
        selectedAnswer: Value(selectedAnswer),
        timeTakenSeconds: Value(timeTakenSeconds),
        isCorrect: Value(isCorrect),
      ),
    );
  }

  /// Get question attempts for a user
  Future<List<Map<String, dynamic>>> getQuestionAttempts(String userId) async {
    final db = _databaseService.database;
    final attempts = await (db.select(db.userQuestionAttempts)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();

    return attempts.map((attempt) {
      return {
        'attemptId': attempt.attemptId,
        'questionId': attempt.questionId,
        'selectedAnswer': attempt.selectedAnswer,
        'isCorrect': attempt.isCorrect,
        'timeTakenSeconds': attempt.timeTakenSeconds,
        'attemptDate': attempt.attemptDate,
      };
    }).toList();
  }

  /// Save bookmark to local database
  Future<void> saveBookmark({
    required String userId,
    required String entityId,
    required String entityType,
  }) async {
    final db = _databaseService.database;
    final bookmarkId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.into(db.bookmarks).insert(
      BookmarksCompanion(
        bookmarkId: Value(bookmarkId),
        userId: Value(userId),
        entityType: Value(entityType),
        entityId: Value(entityId),
      ),
    );
  }

  /// Get bookmarks for a user
  Future<List<Map<String, dynamic>>> getBookmarks({
    required String userId,
    String? entityType,
  }) async {
    final db = _databaseService.database;
    
    final query = db.select(db.bookmarks)..where((tbl) => tbl.userId.equals(userId));
    if (entityType != null) {
      query.where((tbl) => tbl.entityType.equals(entityType));
    }

    final bookmarks = await query.get();

    return bookmarks.map((bookmark) {
      return {
        'bookmarkId': bookmark.bookmarkId,
        'userId': bookmark.userId,
        'entityType': bookmark.entityType,
        'entityId': bookmark.entityId,
        'createdAt': bookmark.createdAt,
      };
    }).toList();
  }

  /// Delete bookmark
  Future<void> deleteBookmark(String bookmarkId) async {
    final db = _databaseService.database;
    await (db.delete(db.bookmarks)..where((tbl) => tbl.bookmarkId.equals(bookmarkId))).go();
  }

  /// Save PYQ session to local database (simplified stub)
  Future<void> savePyqSession({
    required String sessionId,
    required String userId,
    required String examId,
    required String subjectId,
    required String topicId,
    required String mode,
  }) async {
    // Stub implementation - would use actual database tables
    // For now, this is a no-op since pyqSessions table doesn't exist in schema
  }

  /// Update PYQ session (simplified stub)
  Future<void> updatePyqSession({
    required String sessionId,
    int? currentIndex,
    int? totalCorrect,
    int? totalAnswered,
    int? totalDurationSeconds,
    bool? isCompleted,
  }) async {
    // Stub implementation
  }

  /// Get PYQ session by ID (simplified stub)
  Future<Map<String, dynamic>?> getPyqSession(String sessionId) async {
    // Stub implementation - returns null since pyqSessions table doesn't exist
    return null;
  }

  /// Get active PYQ session for user (simplified stub)
  Future<Map<String, dynamic>?> getActivePyqSession(String userId) async {
    // Stub implementation - returns null
    return null;
  }

  /// Get full question records for a set of ids, enriched with this user's
  /// bookmark/attempt state.
  Future<List<PyqQuestion>> getQuestionsByIds(
    List<String> questionIds, {
    required String userId,
  }) async {
    if (questionIds.isEmpty) return [];
    final db = _databaseService.database;
    final rows = await (db.select(db.questions)
          ..where((tbl) => tbl.questionId.isIn(questionIds)))
        .get();
    return _enrichQuestions(rows, userId);
  }

  /// Get a single question by id, without per-user enrichment.
  Future<PyqQuestion?> getQuestionById(String questionId) async {
    final questions = await getQuestionsByIds([questionId], userId: '');
    return questions.isEmpty ? null : questions.first;
  }

  /// Ids of questions whose most recent attempt by this user was incorrect,
  /// derived from the existing user_question_attempts history.
  Future<List<String>> getIncorrectQuestionIds(String userId) async {
    final db = _databaseService.database;
    final rows = await (db.select(db.userQuestionAttempts)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.attemptDate)]))
        .get();

    final latestResultByQuestion = <String, bool>{};
    for (final row in rows) {
      latestResultByQuestion.putIfAbsent(row.questionId, () => row.isCorrect);
    }

    return latestResultByQuestion.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Compute per-topic PYQ summaries (question counts, years appeared, and
  /// this user's solved/incorrect/bookmarked/accuracy stats) directly from
  /// the local question bank plus this user's attempt/bookmark history —
  /// no live backend exists for this app, and this is the same underlying
  /// data searchQuestions()/getIncorrectQuestionIds() already read.
  Future<List<TopicPyqSummary>> getTopicSummaries({
    required String examId,
    required String subjectId,
    String? userId,
  }) async {
    final db = _databaseService.database;

    final topics =
        await (db.select(db.topics)..where((t) => t.subjectId.equals(subjectId))).get();
    if (topics.isEmpty) return [];

    final summaries = <TopicPyqSummary>[];
    for (final topic in topics) {
      final questions = await (db.select(db.questions)
            ..where((q) => q.examId.equals(examId) & q.topicId.equals(topic.topicId)))
          .get();
      if (questions.isEmpty) continue;

      final questionIds = questions.map((q) => q.questionId).toList();
      final years = questions.map((q) => q.year).toSet().toList()..sort();

      var solvedQuestions = 0;
      var incorrectQuestions = 0;
      var bookmarkedQuestions = 0;
      var averageAccuracy = 0.0;

      if (userId != null && userId.isNotEmpty) {
        final attempts = await (db.select(db.userQuestionAttempts)
              ..where((a) => a.userId.equals(userId) & a.questionId.isIn(questionIds))
              ..orderBy([(a) => OrderingTerm.desc(a.attemptDate)]))
            .get();

        // Only this user's most recent attempt per question counts toward
        // solved/incorrect, matching getIncorrectQuestionIds' convention.
        final latestByQuestion = <String, bool>{};
        for (final attempt in attempts) {
          latestByQuestion.putIfAbsent(attempt.questionId, () => attempt.isCorrect);
        }
        solvedQuestions = latestByQuestion.length;
        incorrectQuestions = latestByQuestion.values.where((correct) => !correct).length;
        averageAccuracy = solvedQuestions > 0
            ? latestByQuestion.values.where((correct) => correct).length / solvedQuestions
            : 0.0;

        final bookmarks = await (db.select(db.bookmarks)
              ..where((b) =>
                  b.userId.equals(userId) &
                  b.entityType.equals('question') &
                  b.entityId.isIn(questionIds)))
            .get();
        bookmarkedQuestions = bookmarks.length;
      }

      summaries.add(TopicPyqSummary(
        topicId: topic.topicId,
        topicName: topic.topicName,
        totalQuestions: questions.length,
        solvedQuestions: solvedQuestions,
        bookmarkedQuestions: bookmarkedQuestions,
        incorrectQuestions: incorrectQuestions,
        averageAccuracy: averageAccuracy,
        lastYear: years.isEmpty ? null : years.last,
        firstYear: years.isEmpty ? null : years.first,
        frequencyCount: questions.length,
        yearsAppeared: years,
      ));
    }

    return summaries;
  }

  /// Search/filter questions directly against the local question bank.
  Future<List<PyqQuestion>> searchQuestions({
    required String examId,
    String? subjectId,
    String? topicId,
    List<int>? years,
    List<DifficultyLevel>? difficulties,
    String? keyword,
    String? userId,
  }) async {
    final db = _databaseService.database;
    final query = db.select(db.questions)..where((tbl) => tbl.examId.equals(examId));

    if (subjectId != null) {
      query.where((tbl) => tbl.subjectId.equals(subjectId));
    }
    if (topicId != null) {
      query.where((tbl) => tbl.topicId.equals(topicId));
    }
    if (years != null && years.isNotEmpty) {
      query.where((tbl) => tbl.year.isIn(years));
    }
    if (difficulties != null && difficulties.isNotEmpty) {
      query.where((tbl) => tbl.difficulty.isIn(difficulties.map((d) => d.name)));
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      query.where((tbl) => tbl.questionText.contains(keyword.trim()));
    }

    final rows = await query.get();
    return _enrichQuestions(rows, userId ?? '');
  }

  /// Toggle bookmark status for a question, reusing the existing
  /// save/delete/get bookmark methods above.
  Future<PyqQuestion?> toggleQuestionBookmark({
    required String userId,
    required String questionId,
  }) async {
    final db = _databaseService.database;
    final existing = await (db.select(db.bookmarks)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.entityType.equals('question') &
              tbl.entityId.equals(questionId)))
        .getSingleOrNull();

    if (existing != null) {
      await deleteBookmark(existing.bookmarkId);
    } else {
      await saveBookmark(userId: userId, entityId: questionId, entityType: 'question');
    }

    return getQuestionById(questionId).then((q) async {
      if (q == null) return null;
      final bookmarked = await (db.select(db.bookmarks)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.entityType.equals('question') &
                tbl.entityId.equals(questionId)))
          .getSingleOrNull();
      return q.copyWith(isBookmarked: bookmarked != null);
    });
  }

  Future<List<PyqQuestion>> _enrichQuestions(List<Question> rows, String userId) async {
    if (rows.isEmpty) return [];
    final db = _databaseService.database;
    final ids = rows.map((r) => r.questionId).toList();

    final bookmarkedIds = <String>{};
    if (userId.isNotEmpty) {
      final bookmarkRows = await (db.select(db.bookmarks)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.entityType.equals('question') &
                tbl.entityId.isIn(ids)))
          .get();
      bookmarkedIds.addAll(bookmarkRows.map((b) => b.entityId));
    }

    final latestAttempt = <String, UserQuestionAttempt>{};
    final attemptCounts = <String, int>{};
    final correctCounts = <String, int>{};
    if (userId.isNotEmpty) {
      final attemptRows = await (db.select(db.userQuestionAttempts)
            ..where((tbl) => tbl.userId.equals(userId) & tbl.questionId.isIn(ids))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.attemptDate)]))
          .get();
      for (final row in attemptRows) {
        latestAttempt.putIfAbsent(row.questionId, () => row);
        attemptCounts[row.questionId] = (attemptCounts[row.questionId] ?? 0) + 1;
        if (row.isCorrect) {
          correctCounts[row.questionId] = (correctCounts[row.questionId] ?? 0) + 1;
        }
      }
    }

    return rows.map((row) {
      final latest = latestAttempt[row.questionId];
      return PyqQuestion(
        id: row.questionId,
        examId: row.examId,
        subjectId: row.subjectId,
        topicId: row.topicId,
        questionText: row.questionText,
        options: [row.optionA, row.optionB, row.optionC, row.optionD],
        correctAnswerIndex: _mapCorrectAnswerIndex(row.correctAnswer),
        explanation: row.explanation ?? '',
        year: row.year,
        difficulty: _mapDifficulty(row.difficulty),
        isSolved: latest != null,
        isBookmarked: bookmarkedIds.contains(row.questionId),
        lastAttemptedAt: latest?.attemptDate,
        wasCorrect: latest?.isCorrect,
        timesAppeared: attemptCounts[row.questionId],
        timesCorrectOverall: correctCounts[row.questionId],
        language: row.language,
        source: row.source,
        verificationStatus: row.verificationStatus,
      );
    }).toList();
  }

  int _mapCorrectAnswerIndex(String correctAnswer) {
    switch (correctAnswer.toUpperCase()) {
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

  DifficultyLevel _mapDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  /// Clear all PYQ data for a user
  Future<void> clearPyqData(String userId) async {
    final db = _databaseService.database;
    await (db.delete(db.userQuestionAttempts)..where((tbl) => tbl.userId.equals(userId))).go();
  }
}
