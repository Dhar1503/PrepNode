/// Mock Test Local Data Source
/// Handles local storage and caching for mock test data
library;

import 'package:drift/drift.dart';
import 'package:prepnode/core/data/database/database.dart' hide MockTest, MockTestQuestion;
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';

class MockTestLocalDataSource {
  final DatabaseService _databaseService;

  MockTestLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Build a real, honestly-sized mock test catalog directly from the
  /// local question bank — no live backend exists for this app, and
  /// MockTestType (topic/subject/full) already models exactly this
  /// tiering, so this generates real entries sized to whatever content
  /// actually exists rather than inventing any. Returns an empty list
  /// when the exam has no questions at all, so the UI's existing empty
  /// state renders honestly instead of a fabricated catalog.
  Future<List<MockTest>> getAvailableTestsLocal({
    required String examId,
    MockTestType? type,
  }) async {
    final db = _databaseService.database;
    final questions =
        await (db.select(db.questions)..where((q) => q.examId.equals(examId))).get();
    if (questions.isEmpty) return [];

    final ids = <String>{'local-full-$examId'};
    for (final question in questions) {
      ids.add('local-subject-${question.subjectId}');
      ids.add('local-topic-${question.topicId}');
    }

    final tests = <MockTest>[];
    for (final id in ids) {
      final test = await getTestConfigLocal(id);
      if (test != null) tests.add(test);
    }
    tests.sort((a, b) => a.title.compareTo(b.title));

    return type != null ? tests.where((t) => t.type == type).toList() : tests;
  }

  /// Reconstruct a single locally-generated test's config from its id
  /// alone (ids look like `local-topic-<topicId>`, `local-subject-<id>`,
  /// or `local-full-<examId>` — see [getAvailableTestsLocal]), so this
  /// also resolves deep-linked test ids without needing the exam known
  /// upfront. Returns null when nothing in the question bank matches.
  Future<MockTest?> getTestConfigLocal(String testId) async {
    final db = _databaseService.database;

    if (testId.startsWith('local-topic-')) {
      final topicId = testId.substring('local-topic-'.length);
      final questions =
          await (db.select(db.questions)..where((q) => q.topicId.equals(topicId))).get();
      if (questions.isEmpty) return null;

      final topicRow =
          await (db.select(db.topics)..where((t) => t.topicId.equals(topicId))).getSingleOrNull();
      final subjectRow = await (db.select(db.subjects)
            ..where((s) => s.subjectId.equals(questions.first.subjectId)))
          .getSingleOrNull();
      final topicName = topicRow?.topicName ?? topicId;
      final subjectName = subjectRow?.subjectName ?? questions.first.subjectId;

      return _buildMockTest(
        id: testId,
        examId: questions.first.examId,
        title: '$topicName — Topic Test',
        description: 'Practice questions from $topicName ($subjectName)',
        type: MockTestType.topic,
        questionCount: questions.length,
        subjectIds: [questions.first.subjectId],
        topicId: topicId,
      );
    }

    if (testId.startsWith('local-subject-')) {
      final subjectId = testId.substring('local-subject-'.length);
      final questions =
          await (db.select(db.questions)..where((q) => q.subjectId.equals(subjectId))).get();
      if (questions.isEmpty) return null;

      final subjectRow = await (db.select(db.subjects)..where((s) => s.subjectId.equals(subjectId)))
          .getSingleOrNull();
      final subjectName = subjectRow?.subjectName ?? subjectId;

      return _buildMockTest(
        id: testId,
        examId: questions.first.examId,
        title: '$subjectName — Subject Test',
        description: 'All available $subjectName questions',
        type: MockTestType.subject,
        questionCount: questions.length,
        subjectIds: [subjectId],
      );
    }

    if (testId.startsWith('local-full-')) {
      final examId = testId.substring('local-full-'.length);
      final questions =
          await (db.select(db.questions)..where((q) => q.examId.equals(examId))).get();
      if (questions.isEmpty) return null;

      final examRow =
          await (db.select(db.exams)..where((e) => e.examId.equals(examId))).getSingleOrNull();
      final subjectIds = questions.map((q) => q.subjectId).toSet().toList();

      return _buildMockTest(
        id: testId,
        examId: examId,
        title: '${examRow?.examName ?? examId} — Full Mock Test',
        description: 'Covers every subject with available questions',
        type: MockTestType.full,
        questionCount: questions.length,
        subjectIds: subjectIds,
      );
    }

    return null;
  }

  /// Real per-question marks used for every locally-generated test —
  /// matches the +2/correct rule already advertised on the Mock Test
  /// rules screen, rather than inventing a different scoring convention.
  static const _marksPerQuestion = 2;

  /// Matches the "-0.33 marks" rule advertised on the Mock Test rules
  /// screen (mock_test_home_screen.dart). Single source of truth used both
  /// for the test's own [MockTest.negativeMarking] and for each generated
  /// [MockTestQuestion.negativeMarking] below, rather than the literal
  /// 0.33 appearing in more than one place.
  static const _negativeMarkingPerQuestion = 0.33;

  MockTest _buildMockTest({
    required String id,
    required String examId,
    required String title,
    required String description,
    required MockTestType type,
    required int questionCount,
    required List<String> subjectIds,
    String? topicId,
  }) {
    // No stored per-question duration exists, so this uses a 1-minute-per-
    // question pacing estimate — an honest sizing derived from the real
    // question count, not fabricated content.
    const minutesPerQuestion = 1;
    return MockTest(
      id: id,
      examId: examId,
      title: title,
      description: description,
      type: type,
      durationMinutes: questionCount * minutesPerQuestion,
      totalQuestions: questionCount,
      totalMarks: questionCount * _marksPerQuestion,
      negativeMarking: _negativeMarkingPerQuestion,
      sections: const [],
      subjectIds: subjectIds,
      topicId: topicId,
    );
  }

  /// Build the real question list for a locally-generated test id, pulled
  /// straight from the question bank — the same rows PYQ already reads.
  Future<List<MockTestQuestion>> getQuestionsForTestLocal(String testId) async {
    final db = _databaseService.database;
    List<Question> rows;

    if (testId.startsWith('local-topic-')) {
      final topicId = testId.substring('local-topic-'.length);
      rows = await (db.select(db.questions)..where((q) => q.topicId.equals(topicId))).get();
    } else if (testId.startsWith('local-subject-')) {
      final subjectId = testId.substring('local-subject-'.length);
      rows = await (db.select(db.questions)..where((q) => q.subjectId.equals(subjectId))).get();
    } else if (testId.startsWith('local-full-')) {
      final examId = testId.substring('local-full-'.length);
      rows = await (db.select(db.questions)..where((q) => q.examId.equals(examId))).get();
    } else {
      return [];
    }

    var order = 0;
    return rows.map((row) {
      order++;
      return MockTestQuestion(
        id: row.questionId,
        testId: testId,
        sectionId: 'main',
        subjectId: row.subjectId,
        topicId: row.topicId,
        questionText: row.questionText,
        options: [row.optionA, row.optionB, row.optionC, row.optionD],
        correctAnswerIndex: _answerLetterToIndex(row.correctAnswer),
        explanation: row.explanation ?? '',
        marks: _marksPerQuestion,
        order: order,
        status: QuestionStatus.notAnswered,
        negativeMarking: _negativeMarkingPerQuestion,
      );
    }).toList();
  }

  int _answerLetterToIndex(String letter) {
    final upper = letter.trim().toUpperCase();
    if (upper.isEmpty) return 0;
    final index = upper.codeUnitAt(0) - 'A'.codeUnitAt(0);
    return index.clamp(0, 3);
  }

  /// Resolves the real exam id for a domain test id (e.g.
  /// 'local-full-tnpsc-group2' -> 'tnpsc-group2'), the same way
  /// [getTestConfigLocal] already does when building a [MockTest]. Falls
  /// back to the test id itself when it doesn't parse as a known local
  /// test id (e.g. a hypothetical remote-issued id) — a best-effort
  /// default, not a fabricated exam.
  Future<String> _resolveExamId(String testId) async {
    final config = await getTestConfigLocal(testId);
    return config?.examId ?? testId;
  }

  /// Save mock test attempt to local database.
  ///
  /// [testId] is the domain test id (e.g. 'local-full-tnpsc-group2' —
  /// which specific catalog entry). `examId` on the `mock_tests` row is a
  /// real FK to `exams`, so it must hold the actual exam id, not this
  /// value — see [_resolveExamId]. The domain test id itself is preserved
  /// separately in `domainTestId` so getTestHistory can still report which
  /// test was taken, not just which exam.
  Future<void> saveMockTestAttempt({
    required String attemptId,
    required String userId,
    required String testId,
    required DateTime startedAt,
  }) async {
    final db = _databaseService.database;
    final examId = await _resolveExamId(testId);

    await db.into(db.mockTests).insert(MockTestsCompanion.insert(
      testId: attemptId,
      userId: userId,
      examId: examId,
      type: 'full',
      durationMinutes: 0,
      startedAt: Value(startedAt),
      status: Value('in_progress'),
      domainTestId: Value(testId),
    ));
  }

  /// Update mock test attempt status
  Future<void> updateMockTestAttemptStatus({
    required String attemptId,
    required String status,
  }) async {
    final db = _databaseService.database;
    await (db.update(db.mockTests)..where((tbl) => tbl.testId.equals(attemptId)))
        .write(MockTestsCompanion(status: Value(status)));
  }

  /// Save mock test answer
  Future<void> saveMockTestAnswer({
    required String attemptId,
    required String questionId,
    required String selectedAnswer,
    required int timeTakenSeconds,
    required bool isCorrect,
  }) async {
    final db = _databaseService.database;

    await db.into(db.mockTestAnswers).insert(MockTestAnswersCompanion.insert(
      testId: attemptId,
      questionId: questionId,
      selectedAnswer: Value(selectedAnswer),
      isCorrect: Value(isCorrect),
    ));
  }

  /// Get mock test attempt by ID
  Future<Map<String, dynamic>?> getMockTestAttempt(String attemptId) async {
    final db = _databaseService.database;
    final attempt = await (db.select(db.mockTests)
          ..where((tbl) => tbl.testId.equals(attemptId)))
        .getSingleOrNull();

    if (attempt == null) return null;

    return {
      'attemptId': attempt.testId,
      'userId': attempt.userId,
      'testId': attempt.domainTestId ?? attempt.examId,
      'examId': attempt.examId,
      'startedAt': attempt.startedAt,
      'status': attempt.status,
      'submittedAt': attempt.submittedAt,
    };
  }

  /// Get active mock test attempt for user
  Future<Map<String, dynamic>?> getActiveMockTestAttempt(String userId) async {
    final db = _databaseService.database;
    final attempt = await (db.select(db.mockTests)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('in_progress'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .getSingleOrNull();

    if (attempt == null) return null;

    return {
      'attemptId': attempt.testId,
      'userId': attempt.userId,
      'testId': attempt.domainTestId ?? attempt.examId,
      'examId': attempt.examId,
      'startedAt': attempt.startedAt,
      'status': attempt.status,
      'submittedAt': attempt.submittedAt,
    };
  }

  /// Get mock test answers for an attempt
  Future<List<Map<String, dynamic>>> getMockTestAnswers(String attemptId) async {
    final db = _databaseService.database;
    final answers = await (db.select(db.mockTestAnswers)
          ..where((tbl) => tbl.testId.equals(attemptId)))
        .get();

    return answers.map((answer) {
      return {
        'answerId': '${answer.testId}_${answer.questionId}',
        'attemptId': answer.testId,
        'questionId': answer.questionId,
        'selectedAnswer': answer.selectedAnswer,
        'isCorrect': answer.isCorrect,
        'timeTakenSeconds': 0,
      };
    }).toList();
  }

  /// Save mock test result. Upserts so this works even if the attempt row
  /// was never created via [saveMockTestAttempt] (startTest currently isn't
  /// wired into the test-taking flow) — on conflict only the result fields
  /// are updated, leaving startedAt untouched for rows that do exist.
  ///
  /// [testId] is the domain test id — see [saveMockTestAttempt]'s doc for
  /// why `examId` must hold the real exam id instead, resolved the same
  /// way via [_resolveExamId].
  Future<void> saveMockTestResult({
    required String resultId,
    required String attemptId,
    required String userId,
    required String testId,
    required DateTime submittedAt,
    required double totalScore,
    required int maxScore,
    required double percentage,
    required int correct,
    required int incorrect,
    required int skipped,
    required int timeTakenSeconds,
  }) async {
    final db = _databaseService.database;
    final examId = await _resolveExamId(testId);
    await db.into(db.mockTests).insertOnConflictUpdate(
      MockTestsCompanion.insert(
        testId: attemptId,
        userId: userId,
        examId: examId,
        type: 'full',
        durationMinutes: 0,
        status: const Value('completed'),
        score: Value(totalScore),
        submittedAt: Value(submittedAt),
        domainTestId: Value(testId),
      ),
    );
  }

  /// Get mock test results for a user
  Future<List<Map<String, dynamic>>> getMockTestResults(String userId) async {
    final db = _databaseService.database;
    final results = await (db.select(db.mockTests)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('completed'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.submittedAt)]))
        .get();

    return results.map((result) {
      return {
        'resultId': result.testId,
        'attemptId': result.testId,
        'userId': result.userId,
        'testId': result.domainTestId ?? result.examId,
        'examId': result.examId,
        'submittedAt': result.submittedAt,
        'totalScore': result.score,
        'maxScore': null,
        'percentage': null,
      };
    }).toList();
  }

  /// Clear all mock test data for a user
  Future<void> clearMockTestData(String userId) async {
    final db = _databaseService.database;
    final attempts = await (db.select(db.mockTests)..where((tbl) => tbl.userId.equals(userId))).get();
    for (final attempt in attempts) {
      await (db.delete(db.mockTestAnswers)..where((tbl) => tbl.testId.equals(attempt.testId))).go();
    }
    await (db.delete(db.mockTests)..where((tbl) => tbl.userId.equals(userId))).go();
  }
}
