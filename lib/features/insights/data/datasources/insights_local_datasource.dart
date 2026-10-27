/// Insights Local Data Source
/// Handles local storage and caching for insights data
library;

import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:drift/drift.dart';

class InsightsLocalDataSource {
  final DatabaseService _databaseService;

  InsightsLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Save learner progress to local database
  Future<void> saveLearnerProgress({
    required String userId,
    required double prepNodeScore,
    required double topicCompletion,
    required double pyqPerformance,
    required double mockAccuracy,
    required double consistency,
    required double revisionDiscipline,
  }) async {
    final db = _databaseService.database;

    final existing = await db.customSelect(
      'SELECT user_id FROM user_analytics WHERE user_id = ? LIMIT 1',
      variables: [Variable<String>(userId)],
    ).getSingleOrNull();

    if (existing != null) {
      await db.customUpdate(
        '''
        UPDATE user_analytics
        SET prep_node_score = ?,
            topic_completion = ?,
            pyq_performance = ?,
            mock_accuracy = ?,
            consistency = ?,
            revision_discipline = ?,
            last_updated = ?
        WHERE user_id = ?
        ''',
        variables: [
          Variable<double>(prepNodeScore),
          Variable<double>(topicCompletion),
          Variable<double>(pyqPerformance),
          Variable<double>(mockAccuracy),
          Variable<double>(consistency),
          Variable<double>(revisionDiscipline),
          Variable<int>(DateTime.now().millisecondsSinceEpoch),
          Variable<String>(userId),
        ],
      );
    } else {
      await db.customInsert(
        '''
        INSERT INTO user_analytics (
          user_id,
          prep_node_score,
          topic_completion,
          pyq_performance,
          mock_accuracy,
          consistency,
          revision_discipline,
          last_updated
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable<String>(userId),
          Variable<double>(prepNodeScore),
          Variable<double>(topicCompletion),
          Variable<double>(pyqPerformance),
          Variable<double>(mockAccuracy),
          Variable<double>(consistency),
          Variable<double>(revisionDiscipline),
          Variable<int>(DateTime.now().millisecondsSinceEpoch),
        ],
      );
    }
  }

  /// Get learner progress from local database
  Future<Map<String, dynamic>?> getLearnerProgress(String userId) async {
    final db = _databaseService.database;
    final progress = await db.customSelect(
      '''
      SELECT user_id, prep_node_score, topic_completion, pyq_performance,
             mock_accuracy, consistency, revision_discipline, last_updated
      FROM user_analytics
      WHERE user_id = ?
      LIMIT 1
      ''',
      variables: [Variable<String>(userId)],
    ).getSingleOrNull();

    if (progress == null) return null;

    return {
      'userId': progress.read<String>('user_id'),
      'prepNodeScore': progress.read<double>('prep_node_score'),
      'topicCompletion': progress.read<double>('topic_completion'),
      'pyqPerformance': progress.read<double>('pyq_performance'),
      'mockAccuracy': progress.read<double>('mock_accuracy'),
      'consistency': progress.read<double>('consistency'),
      'revisionDiscipline': progress.read<double>('revision_discipline'),
      'lastUpdated': DateTime.fromMillisecondsSinceEpoch(progress.read<int>('last_updated')),
    };
  }

  /// Save topic mastery to local database
  Future<void> saveTopicMastery({
    required String userId,
    required String topicId,
    required double masteryPercentage,
    required String level,
    required int questionsAttempted,
    required int questionsCorrect,
    required int studyMinutes,
  }) async {
    final db = _databaseService.database;

    final existing = await db.customSelect(
      '''
      SELECT progress_id
      FROM user_topic_progress
      WHERE user_id = ? AND topic_id = ?
      LIMIT 1
      ''',
      variables: [Variable<String>(userId), Variable<String>(topicId)],
    ).getSingleOrNull();

    if (existing != null) {
      await db.customUpdate(
        '''
        UPDATE user_topic_progress
        SET mastery_percentage = ?,
            questions_attempted = ?,
            questions_correct = ?,
            study_minutes = ?,
            last_revision_date = ?
        WHERE user_id = ? AND topic_id = ?
        ''',
        variables: [
          Variable<double>(masteryPercentage),
          Variable<int>(questionsAttempted),
          Variable<int>(questionsCorrect),
          Variable<int>(studyMinutes),
          Variable<int>(DateTime.now().millisecondsSinceEpoch),
          Variable<String>(userId),
          Variable<String>(topicId),
        ],
      );
    } else {
      await db.customInsert(
        '''
        INSERT INTO user_topic_progress (
          progress_id,
          user_id,
          topic_id,
          mastery_percentage,
          questions_attempted,
          questions_correct,
          study_minutes,
          last_revision_date
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable<String>(DateTime.now().millisecondsSinceEpoch.toString()),
          Variable<String>(userId),
          Variable<String>(topicId),
          Variable<double>(masteryPercentage),
          Variable<int>(questionsAttempted),
          Variable<int>(questionsCorrect),
          Variable<int>(studyMinutes),
          Variable<int>(DateTime.now().millisecondsSinceEpoch),
        ],
      );
    }
  }

  /// Get topic masteries from local database
  /// Mastery per topic.
  ///
  /// `user_topic_progress` is only written when a user explicitly marks
  /// progress in the Knowledge Graph or Planner — answering PYQs and mock
  /// tests never touched it. That left the Strength Map, weak areas and
  /// every other mastery-driven screen permanently empty no matter how much
  /// the student actually practised. When that table has nothing for this
  /// user, mastery is derived from their real answer history instead
  /// (user_question_attempts joined to each question's topic), which is the
  /// same data PYQ Practice already reports per topic.
  Future<List<Map<String, dynamic>>> getTopicMasteries(String userId) async {
    final db = _databaseService.database;
    final masteries = await db.customSelect(
      '''
      SELECT topic_id, mastery_percentage, questions_attempted, questions_correct, study_minutes, last_revision_date
      FROM user_topic_progress
      WHERE user_id = ?
      ORDER BY last_revision_date DESC
      ''',
      variables: [Variable<String>(userId)],
    ).get();

    if (masteries.isEmpty) {
      return _deriveTopicMasteriesFromAttempts(userId);
    }

    return masteries.map((mastery) {
      return {
        'topicId': mastery.read<String>('topic_id'),
        'masteryPercentage': mastery.read<double>('mastery_percentage'),
        'questionsAttempted': mastery.read<int>('questions_attempted'),
        'questionsCorrect': mastery.read<int>('questions_correct'),
        'studyMinutes': mastery.read<int>('study_minutes'),
        'lastRevisionDate': DateTime.fromMillisecondsSinceEpoch(mastery.read<int>('last_revision_date')),
      };
    }).toList();
  }

  /// Mastery computed straight from answered questions: accuracy per topic,
  /// counting only each question's most recent attempt so a retried question
  /// isn't double-counted. Returns an empty list when the user hasn't
  /// answered anything yet — which is a genuine "nothing practised yet"
  /// state, not a broken query.
  Future<List<Map<String, dynamic>>> _deriveTopicMasteriesFromAttempts(String userId) async {
    final db = _databaseService.database;
    final rows = await db.customSelect(
      '''
      SELECT q.topic_id            AS topic_id,
             COUNT(*)              AS attempted,
             SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS correct,
             MAX(a.attempt_date)   AS last_attempt
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
        AND a.attempt_date = (
          SELECT MAX(a2.attempt_date)
          FROM user_question_attempts a2
          WHERE a2.user_id = a.user_id AND a2.question_id = a.question_id
        )
      GROUP BY q.topic_id
      ORDER BY last_attempt DESC
      ''',
      variables: [Variable<String>(userId)],
    ).get();

    return rows.map((row) {
      final attempted = row.read<int>('attempted');
      final correct = row.read<int>('correct');
      final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;
      return {
        'topicId': row.read<String>('topic_id'),
        'masteryPercentage': accuracy,
        'questionsAttempted': attempted,
        'questionsCorrect': correct,
        // Study minutes aren't tracked per attempt, so this stays 0 rather
        // than inventing a duration.
        'studyMinutes': 0,
        'lastRevisionDate':
            DateTime.fromMillisecondsSinceEpoch(row.read<int>('last_attempt')),
      };
    }).toList();
  }

  /// Save study session to local database
  Future<void> saveStudySession({
    required String userId,
    required String topicId,
    required int durationMinutes,
    required DateTime date,
  }) async {
    final db = _databaseService.database;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.customInsert(
      '''
      INSERT INTO study_sessions (
        session_id,
        user_id,
        topic_id,
        start_time,
        end_time,
        actual_duration_minutes,
        quality
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(sessionId),
        Variable<String>(userId),
        Variable<String>(topicId),
        Variable<int>(date.millisecondsSinceEpoch),
        Variable<int>(date.add(Duration(minutes: durationMinutes)).millisecondsSinceEpoch),
        Variable<int>(durationMinutes),
        const Variable<String>('good'),
      ],
    );
  }

  /// Get study sessions for a date range
  Future<List<Map<String, dynamic>>> getStudySessionsForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = _databaseService.database;

    final sessions = await db.customSelect(
      '''
      SELECT session_id, topic_id, start_time, end_time, actual_duration_minutes
      FROM study_sessions
      WHERE user_id = ?
        AND start_time >= ?
        AND start_time <= ?
      ORDER BY start_time DESC
      ''',
      variables: [
        Variable<String>(userId),
        Variable<int>(startDate.millisecondsSinceEpoch),
        Variable<int>(endDate.millisecondsSinceEpoch),
      ],
    ).get();

    return sessions.map((session) {
      return {
        'sessionId': session.read<String>('session_id'),
        'topicId': session.read<String>('topic_id'),
        'startTime': DateTime.fromMillisecondsSinceEpoch(session.read<int>('start_time')),
        'endTime': DateTime.fromMillisecondsSinceEpoch(session.read<int>('end_time')),
        'actualDurationMinutes': session.read<int>('actual_duration_minutes'),
      };
    }).toList();
  }

  /// Clear all insights data for a user
  Future<void> clearInsightsData(String userId) async {
    final db = _databaseService.database;
    final safeUserId = userId.replaceAll("'", "''");
    await db.customStatement("DELETE FROM user_analytics WHERE user_id = '$safeUserId'");
    await db.customStatement("DELETE FROM user_topic_progress WHERE user_id = '$safeUserId'");
    await db.customStatement("DELETE FROM study_sessions WHERE user_id = '$safeUserId'");
  }

  // ==================== REAL DATA AGGREGATION ====================
  // The methods below compute analytics directly from existing tables
  // (user_question_attempts, mock_tests/mock_test_answers, study_plans,
  // user_topic_progress, topics/subjects) instead of relying on a remote
  // API or hand-entered numbers.

  /// Computes the five PrepNode Score components (0-100 scale each) from
  /// real user data, matching the weights documented on ScoreComponents:
  /// topic completion 30%, PYQ performance 25%, mock accuracy 20%,
  /// consistency 15%, revision discipline 10%.
  Future<Map<String, double>> computeScoreComponents(String userId) async {
    final db = _databaseService.database;

    // Topic completion: average mastery % already tracked per topic.
    final masteryRows = await (db.select(db.userTopicProgress)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
    final topicCompletion = masteryRows.isEmpty
        ? 0.0
        : masteryRows.map((m) => m.masteryPercentage).reduce((a, b) => a + b) /
            masteryRows.length;

    // PYQ performance: overall attempt accuracy.
    final attempts = await (db.select(db.userQuestionAttempts)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
    final pyqPerformance = attempts.isEmpty
        ? 0.0
        : (attempts.where((a) => a.isCorrect).length / attempts.length) * 100;

    // Mock accuracy: average per-attempt accuracy across completed tests.
    final mockTests = await (db.select(db.mockTests)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('completed')))
        .get();
    double mockAccuracy = 0.0;
    if (mockTests.isNotEmpty) {
      final perAttemptAccuracies = <double>[];
      for (final test in mockTests) {
        final answers = await (db.select(db.mockTestAnswers)
              ..where((tbl) => tbl.testId.equals(test.testId)))
            .get();
        if (answers.isEmpty) continue;
        final correct = answers.where((a) => a.isCorrect == true).length;
        perAttemptAccuracies.add((correct / answers.length) * 100);
      }
      if (perAttemptAccuracies.isNotEmpty) {
        mockAccuracy =
            perAttemptAccuracies.reduce((a, b) => a + b) / perAttemptAccuracies.length;
      }
    }

    // Consistency: fraction of the last 30 days with any recorded activity
    // (PYQ attempt or mock test), out of 30.
    final since = DateTime.now().subtract(const Duration(days: 30));
    final activeDays = <String>{};
    for (final attempt in attempts) {
      if (attempt.attemptDate.isAfter(since)) {
        activeDays.add(_dayKey(attempt.attemptDate));
      }
    }
    for (final test in mockTests) {
      if (test.startedAt.isAfter(since)) {
        activeDays.add(_dayKey(test.startedAt));
      }
    }
    final consistency = (activeDays.length / 30).clamp(0.0, 1.0) * 100;

    // Revision discipline: fraction of due study plans actually completed.
    final duePlans = await (db.select(db.studyPlans)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.isSmallerOrEqualValue(DateTime.now())))
        .get();
    final revisionDiscipline = duePlans.isEmpty
        ? 0.0
        : (duePlans.where((p) => p.status == 'completed').length / duePlans.length) * 100;

    return {
      'topicCompletion': topicCompletion,
      'pyqPerformance': pyqPerformance,
      'mockAccuracy': mockAccuracy,
      'consistency': consistency,
      'revisionDiscipline': revisionDiscipline,
      'prepNodeScore': topicCompletion * 0.30 +
          pyqPerformance * 0.25 +
          mockAccuracy * 0.20 +
          consistency * 0.15 +
          revisionDiscipline * 0.10,
    };
  }

  /// Resolves topic/subject names for a set of topic ids in one pass.
  Future<Map<String, ({String topicName, String subjectId, String subjectName})>>
      _resolveTopicNames(List<String> topicIds) async {
    if (topicIds.isEmpty) return {};
    final db = _databaseService.database;
    final topics = await (db.select(db.topics)..where((tbl) => tbl.topicId.isIn(topicIds))).get();
    final subjectIds = topics.map((t) => t.subjectId).toSet().toList();
    final subjects = subjectIds.isEmpty
        ? <Subject>[]
        : await (db.select(db.subjects)..where((tbl) => tbl.subjectId.isIn(subjectIds))).get();
    final subjectNameById = {for (final s in subjects) s.subjectId: s.subjectName};

    return {
      for (final t in topics)
        t.topicId: (
          topicName: t.topicName,
          subjectId: t.subjectId,
          subjectName: subjectNameById[t.subjectId] ?? '',
        ),
    };
  }

  /// Topic masteries enriched with real topic/subject names.
  Future<List<Map<String, dynamic>>> getTopicMasteriesWithNames(String userId) async {
    final masteries = await getTopicMasteries(userId);
    final names = await _resolveTopicNames(masteries.map((m) => m['topicId'] as String).toList());

    return masteries.map((m) {
      final topicId = m['topicId'] as String;
      final info = names[topicId];
      return {
        ...m,
        'topicName': info?.topicName ?? '',
        'subjectId': info?.subjectId ?? '',
        'subjectName': info?.subjectName ?? '',
      };
    }).toList();
  }

  /// PYQ performance grouped by subject, computed from real attempt history.
  Future<List<Map<String, dynamic>>> getPyqPerformanceBySubject(String userId) async {
    final db = _databaseService.database;
    final attempts = await (db.select(db.userQuestionAttempts)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
    if (attempts.isEmpty) return [];

    final questionIds = attempts.map((a) => a.questionId).toSet().toList();
    final questions =
        await (db.select(db.questions)..where((tbl) => tbl.questionId.isIn(questionIds))).get();
    final questionById = {for (final q in questions) q.questionId: q};

    final subjectIds = questions.map((q) => q.subjectId).toSet().toList();
    final subjects = subjectIds.isEmpty
        ? <Subject>[]
        : await (db.select(db.subjects)..where((tbl) => tbl.subjectId.isIn(subjectIds))).get();
    final subjectNameById = {for (final s in subjects) s.subjectId: s.subjectName};

    final bookmarks = await (db.select(db.bookmarks)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.entityType.equals('question')))
        .get();
    final bookmarkedQuestionIds = bookmarks.map((b) => b.entityId).toSet();

    final bySubject = <String, List<UserQuestionAttempt>>{};
    for (final attempt in attempts) {
      final question = questionById[attempt.questionId];
      if (question == null) continue;
      bySubject.putIfAbsent(question.subjectId, () => []).add(attempt);
    }

    return bySubject.entries.map((entry) {
      final subjectId = entry.key;
      final subjectAttempts = entry.value;
      final correct = subjectAttempts.where((a) => a.isCorrect).length;
      final topicsCovered = subjectAttempts
          .map((a) => questionById[a.questionId]?.topicId)
          .whereType<String>()
          .toSet()
          .length;
      final questionsInSubject =
          subjectAttempts.map((a) => a.questionId).where(bookmarkedQuestionIds.contains).length;
      final timesWithDuration =
          subjectAttempts.where((a) => a.timeTakenSeconds != null).toList();
      final avgTime = timesWithDuration.isEmpty
          ? 0.0
          : timesWithDuration.map((a) => a.timeTakenSeconds!).reduce((a, b) => a + b) /
              timesWithDuration.length;

      return {
        'subjectId': subjectId,
        'subjectName': subjectNameById[subjectId] ?? '',
        'totalQuestionsAttempted': subjectAttempts.length,
        'totalQuestionsCorrect': correct,
        'accuracy': subjectAttempts.isEmpty ? 0.0 : correct / subjectAttempts.length,
        'averageTimePerQuestion': avgTime,
        'topicsCovered': topicsCovered,
        'bookmarkedQuestions': questionsInSubject,
      };
    }).toList();
  }

  /// Overall PYQ stats (all subjects combined) from real attempt history.
  Future<Map<String, dynamic>> getOverallPyqStats(String userId) async {
    final db = _databaseService.database;
    final attempts = await (db.select(db.userQuestionAttempts)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();

    if (attempts.isEmpty) {
      return {
        'totalQuestionsAttempted': 0,
        'totalQuestionsCorrect': 0,
        'overallAccuracy': 0.0,
        'totalTimeSpentMinutes': 0.0,
        'uniqueTopicsCovered': 0,
        'currentStreak': 0,
      };
    }

    final correct = attempts.where((a) => a.isCorrect).length;
    final totalSeconds = attempts
        .where((a) => a.timeTakenSeconds != null)
        .fold<int>(0, (sum, a) => sum + a.timeTakenSeconds!);

    final questionIds = attempts.map((a) => a.questionId).toSet().toList();
    final questions =
        await (db.select(db.questions)..where((tbl) => tbl.questionId.isIn(questionIds))).get();
    final uniqueTopics = questions.map((q) => q.topicId).toSet().length;

    final activeDays = attempts.map((a) => _dayKey(a.attemptDate)).toSet().toList()..sort();
    final streak = _computeStreakFromDayKeys(activeDays);

    return {
      'totalQuestionsAttempted': attempts.length,
      'totalQuestionsCorrect': correct,
      'overallAccuracy': correct / attempts.length,
      'totalTimeSpentMinutes': totalSeconds / 60,
      'uniqueTopicsCovered': uniqueTopics,
      'currentStreak': streak,
    };
  }

  /// Completed mock test attempts with per-attempt accuracy, computed from
  /// mock_tests + mock_test_answers.
  Future<List<Map<String, dynamic>>> getMockTestAttempts(String userId) async {
    final db = _databaseService.database;
    final tests = await (db.select(db.mockTests)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('completed'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.submittedAt)]))
        .get();
    if (tests.isEmpty) return [];

    final subjectIds = tests.map((t) => t.subjectId).whereType<String>().toSet().toList();
    final subjects = subjectIds.isEmpty
        ? <Subject>[]
        : await (db.select(db.subjects)..where((tbl) => tbl.subjectId.isIn(subjectIds))).get();
    final subjectNameById = {for (final s in subjects) s.subjectId: s.subjectName};

    final result = <Map<String, dynamic>>[];
    for (final test in tests) {
      final answers = await (db.select(db.mockTestAnswers)
            ..where((tbl) => tbl.testId.equals(test.testId)))
          .get();
      final answered = answers.where((a) => a.selectedAnswer != null).toList();
      final correct = answers.where((a) => a.isCorrect == true).length;

      result.add({
        'attemptId': test.testId,
        'testType': test.type,
        'subjectId': test.subjectId ?? '',
        'subjectName': test.subjectId != null ? (subjectNameById[test.subjectId] ?? '') : '',
        'date': test.submittedAt ?? test.startedAt,
        'score': test.score ?? 0.0,
        'accuracy': answered.isEmpty ? 0.0 : correct / answered.length,
        'totalQuestions': answers.length,
        'correctAnswers': correct,
        'durationMinutes': test.durationMinutes,
      });
    }
    return result;
  }

  /// Study habit data: real study_sessions rows plus subject-level minutes
  /// resolved via topics.
  Future<Map<String, dynamic>> getStudyHabitsData(String userId) async {
    final db = _databaseService.database;
    final since = DateTime.now().subtract(const Duration(days: 30));

    final sessionRows = await db.customSelect(
      '''
      SELECT session_id, topic_id, start_time, actual_duration_minutes
      FROM study_sessions
      WHERE user_id = ? AND start_time >= ?
      ORDER BY start_time DESC
      ''',
      variables: [Variable<String>(userId), Variable<int>(since.millisecondsSinceEpoch)],
    ).get();

    final sessions = sessionRows
        .map((row) => (
              topicId: row.read<String>('topic_id'),
              startTime: DateTime.fromMillisecondsSinceEpoch(row.read<int>('start_time')),
              minutes: row.read<int>('actual_duration_minutes'),
            ))
        .toList();

    final topicIds = sessions.map((s) => s.topicId).toSet().toList();
    final names = await _resolveTopicNames(topicIds);

    final subjectMinutes = <String, int>{};
    final subjectNames = <String, String>{};
    final dayMinutes = <String, int>{};
    final dayTopics = <String, Set<String>>{};
    for (final session in sessions) {
      final info = names[session.topicId];
      final subjectId = info?.subjectId ?? '';
      subjectMinutes[subjectId] = (subjectMinutes[subjectId] ?? 0) + session.minutes;
      subjectNames[subjectId] = info?.subjectName ?? '';

      final day = _dayKey(session.startTime);
      dayMinutes[day] = (dayMinutes[day] ?? 0) + session.minutes;
      dayTopics.putIfAbsent(day, () => {}).add(session.topicId);
    }

    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.minutes);
    final activeDays = dayMinutes.keys.toList()..sort();

    return {
      'sessions': sessions,
      'subjectMinutes': subjectMinutes,
      'subjectNames': subjectNames,
      'dayMinutes': dayMinutes,
      'dayTopicCounts': dayTopics.map((k, v) => MapEntry(k, v.length)),
      'totalMinutes': totalMinutes,
      'activeDayKeys': activeDays,
      'currentStreak': _computeStreakFromDayKeys(activeDays),
    };
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Consecutive-day streak ending today (or yesterday, so a day still in
  /// progress doesn't reset the streak to zero), given sorted "yyyy-MM-dd"
  /// day keys.
  int _computeStreakFromDayKeys(List<String> sortedDayKeys) {
    if (sortedDayKeys.isEmpty) return 0;
    final daySet = sortedDayKeys.toSet();
    var cursor = DateTime.now();
    if (!daySet.contains(_dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!daySet.contains(_dayKey(cursor))) return 0;
    }
    var streak = 0;
    while (daySet.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
