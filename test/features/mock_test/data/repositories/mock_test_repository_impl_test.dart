// Unit tests for MockTestRepositoryImpl. Chosen per the gap assessment:
// mock tests draw on the same shared question bank as PYQ practice, and
// submitTest() is the single most business-critical calculation in this
// repository (it's the actual reachable scoring path — the presentation
// layer's TestAttemptNotifier.updateQuestionAnswer is local-state-only and
// never calls this repository's updateQuestionAnswer, confirmed by reading
// mock_test_providers.dart). Unlike CutoffRepositoryImpl/ResourceRepositoryImpl/
// PyqRepositoryImpl (which fall back to local on *any* remote exception via
// bare `catch (_)`), this repository only falls back when the mapped
// failure is specifically a NetworkFailure — verified against
// ApiErrorMapper, which does map Dio's connectionError (the real "no
// backend" case) to NetworkFailure, so the pattern is valid, just distinct
// from its siblings.
//
// Follow-up pass: 3 defects found in the first pass (negative marking never
// applied; the offline test-history examId filter always returning [];
// updateQuestionAnswer's isCorrect check comparing against a literal 0
// instead of the real answer) have now been fixed in production code. The
// tests that used to document those defects as "KNOWN DEFECT" have been
// updated to assert the corrected behavior instead — see each group below.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/mock_test/data/datasources/mock_test_local_datasource.dart';
import 'package:prepgraph/features/mock_test/data/datasources/mock_test_remote_datasource.dart';
import 'package:prepgraph/features/mock_test/data/repositories/mock_test_repository_impl.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepgraph/features/mock_test/domain/repositories/mock_test_repository.dart';

class MockMockTestRemoteDataSource extends Mock implements MockTestRemoteDataSource {}

class MockMockTestLocalDataSource extends Mock implements MockTestLocalDataSource {}

MockTestQuestion _q(
  String id, {
  int? selectedOptionIndex,
  int correctAnswerIndex = 0,
  QuestionStatus status = QuestionStatus.notAnswered,
  bool isSkipped = false,
  int marks = 2,
  int? timeTakenSeconds,
  double negativeMarking = 0.0,
}) {
  return MockTestQuestion(
    id: id,
    testId: 'test-1',
    sectionId: 'main',
    questionText: 'Question $id',
    options: const ['A', 'B', 'C', 'D'],
    correctAnswerIndex: correctAnswerIndex,
    selectedOptionIndex: selectedOptionIndex,
    status: status,
    isSkipped: isSkipped,
    marks: marks,
    timeTakenSeconds: timeTakenSeconds,
    negativeMarking: negativeMarking,
  );
}

MockTest _testConfig({
  String id = 'local-full-tnpsc-group2',
  MockTestType type = MockTestType.full,
  int durationMinutes = 10,
}) {
  return MockTest(
    id: id,
    examId: 'tnpsc-group2',
    title: 'TNPSC Group 2 — Full Mock Test',
    type: type,
    durationMinutes: durationMinutes,
    totalQuestions: 5,
    totalMarks: 10,
    negativeMarking: 0.33,
    sections: const [],
    subjectIds: const ['subject-general-studies'],
  );
}

void main() {
  late MockMockTestRemoteDataSource remoteDataSource;
  late MockMockTestLocalDataSource localDataSource;
  late MockTestRepository repository;

  setUp(() {
    remoteDataSource = MockMockTestRemoteDataSource();
    localDataSource = MockMockTestLocalDataSource();
    repository = MockTestRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
    when(() => localDataSource.saveMockTestAnswer(
          attemptId: any(named: 'attemptId'),
          questionId: any(named: 'questionId'),
          selectedAnswer: any(named: 'selectedAnswer'),
          timeTakenSeconds: any(named: 'timeTakenSeconds'),
          isCorrect: any(named: 'isCorrect'),
        )).thenAnswer((_) async {});
    when(() => localDataSource.saveMockTestResult(
          resultId: any(named: 'resultId'),
          attemptId: any(named: 'attemptId'),
          userId: any(named: 'userId'),
          testId: any(named: 'testId'),
          submittedAt: any(named: 'submittedAt'),
          totalScore: any(named: 'totalScore'),
          maxScore: any(named: 'maxScore'),
          percentage: any(named: 'percentage'),
          correct: any(named: 'correct'),
          incorrect: any(named: 'incorrect'),
          skipped: any(named: 'skipped'),
          timeTakenSeconds: any(named: 'timeTakenSeconds'),
        )).thenAnswer((_) async {});
  });

  group('submitTest — scoring', () {
    test('computes correct/incorrect/skipped/unanswered counts and '
        'obtained/total marks from the attempt\'s own questions', () async {
      final attempt = MockTestAttempt(
        id: 'attempt-1',
        userId: 'user-1',
        testId: 'test-1',
        startedAt: DateTime(2024, 1, 1),
        questions: [
          _q('q1', selectedOptionIndex: 0, correctAnswerIndex: 0, status: QuestionStatus.answered), // correct
          _q('q2', selectedOptionIndex: 1, correctAnswerIndex: 2, status: QuestionStatus.answered), // incorrect
          _q('q3', isSkipped: true, status: QuestionStatus.skipped), // skipped
          _q('q4'), // never touched -> unanswered
        ],
      );

      final result = await repository.submitTest(attempt: attempt);

      expect(result.isRight(), isTrue);
      final r = result.getOrElse(() => throw StateError('expected Right'));
      expect(r.correctAnswers, 1);
      expect(r.incorrectAnswers, 1);
      expect(r.skippedQuestions, 2, reason: '1 explicit skip + 1 unanswered');
      expect(r.totalQuestions, 4);
      expect(r.obtainedMarks, 2.0, reason: 'only q1 is correct, at 2 marks');
      expect(r.totalMarks, 8.0, reason: '4 questions x 2 marks each');
      expect(r.percentage, 25.0);
      expect(r.accuracy, 0.5, reason: '1 correct out of 2 answered (q1, q2)');
    });

    test(
      'FIXED: incorrect answers now deduct MockTestQuestion.negativeMarking, '
      'matching the "-0.33 marks" rule advertised on the Mock Test rules '
      'screen (mock_test_home_screen.dart). Correct still earns +marks; '
      'skipped/unanswered earn/lose nothing (see the next test).',
      () async {
        final attempt = MockTestAttempt(
          id: 'attempt-1',
          userId: 'user-1',
          testId: 'test-1',
          startedAt: DateTime(2024, 1, 1),
          questions: [
            _q('q1',
                selectedOptionIndex: 0,
                correctAnswerIndex: 0,
                status: QuestionStatus.answered,
                marks: 2,
                negativeMarking: 0.33),
            _q('q2',
                selectedOptionIndex: 1,
                correctAnswerIndex: 2,
                status: QuestionStatus.answered,
                marks: 2,
                negativeMarking: 0.33),
          ],
        );

        final result = await repository.submitTest(attempt: attempt);

        final r = result.getOrElse(() => throw StateError('expected Right'));
        // q1 correct: +2.0. q2 incorrect: -0.33. Total: 1.67.
        expect(r.obtainedMarks, closeTo(1.67, 0.001));
      },
    );

    test('skipped and unanswered questions incur no negative marking, even '
        'when the test has a configured negative-marking rate — only an '
        'answered-and-wrong question is penalized', () async {
      final attempt = MockTestAttempt(
        id: 'attempt-1',
        userId: 'user-1',
        testId: 'test-1',
        startedAt: DateTime(2024, 1, 1),
        questions: [
          _q('q1', isSkipped: true, status: QuestionStatus.skipped, marks: 2, negativeMarking: 0.33),
          _q('q2', marks: 2, negativeMarking: 0.33), // never touched
        ],
      );

      final result = await repository.submitTest(attempt: attempt);

      final r = result.getOrElse(() => throw StateError('expected Right'));
      expect(r.obtainedMarks, 0.0);
    });

    test('persists a saved answer only for questions that were actually '
        'answered, converting the option index to a letter', () async {
      final attempt = MockTestAttempt(
        id: 'attempt-1',
        userId: 'user-1',
        testId: 'test-1',
        startedAt: DateTime(2024, 1, 1),
        questions: [
          _q('q1', selectedOptionIndex: 3, correctAnswerIndex: 3, status: QuestionStatus.answered),
          _q('q2'), // untouched, no selectedOptionIndex
        ],
      );

      await repository.submitTest(attempt: attempt);

      verify(() => localDataSource.saveMockTestAnswer(
            attemptId: 'attempt-1',
            questionId: 'q1',
            selectedAnswer: 'D',
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: true,
          )).called(1);
      verifyNever(() => localDataSource.saveMockTestAnswer(
            attemptId: any(named: 'attemptId'),
            questionId: 'q2',
            selectedAnswer: any(named: 'selectedAnswer'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: any(named: 'isCorrect'),
          ));
    });

    test('an attempt with zero questions produces a zeroed, non-crashing result', () async {
      final attempt = MockTestAttempt(
        id: 'attempt-1',
        userId: 'user-1',
        testId: 'test-1',
        startedAt: DateTime(2024, 1, 1),
      );

      final result = await repository.submitTest(attempt: attempt);

      final r = result.getOrElse(() => throw StateError('expected Right'));
      expect(r.totalMarks, 0.0);
      expect(r.percentage, 0.0);
      expect(r.accuracy, 0.0);
    });
  });

  group('startTest — NetworkFailure-only local fallback', () {
    test('returns the remote attempt and saves it locally when remote succeeds', () async {
      final remoteAttempt = MockTestAttempt(
        id: 'attempt-remote',
        userId: 'user-1',
        testId: 'test-1',
        startedAt: DateTime(2024, 1, 1),
      );
      when(() => remoteDataSource.startTest(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
          )).thenAnswer((_) async => remoteAttempt);
      when(() => localDataSource.saveMockTestAttempt(
            attemptId: any(named: 'attemptId'),
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
            startedAt: any(named: 'startedAt'),
          )).thenAnswer((_) async {});

      final result = await repository.startTest(userId: 'user-1', testId: 'test-1');

      expect(result.isRight(), isTrue);
      verify(() => localDataSource.saveMockTestAttempt(
            attemptId: 'attempt-remote',
            userId: 'user-1',
            testId: 'test-1',
            startedAt: any(named: 'startedAt'),
          )).called(1);
      verifyNever(() => localDataSource.getTestConfigLocal(any()));
    });

    test('builds a real attempt from the local catalog when remote throws a '
        'NetworkFailure', () async {
      when(() => remoteDataSource.startTest(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
          )).thenThrow(NetworkFailure.noConnection());
      when(() => localDataSource.getTestConfigLocal(any())).thenAnswer((_) async => _testConfig());
      when(() => localDataSource.getQuestionsForTestLocal(any())).thenAnswer(
        (_) async => [_q('q1', marks: 2), _q('q2', marks: 2), _q('q3', marks: 2)],
      );
      when(() => localDataSource.saveMockTestAttempt(
            attemptId: any(named: 'attemptId'),
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
            startedAt: any(named: 'startedAt'),
          )).thenAnswer((_) async {});

      final result = await repository.startTest(userId: 'user-1', testId: 'local-full-tnpsc-group2');

      final attempt = result.getOrElse(() => throw StateError('expected Right'));
      expect(attempt.totalQuestions, 3);
      expect(attempt.totalMarks, 6.0, reason: '3 questions x 2 marks');
      expect(attempt.durationSeconds, 10 * 60);
      expect(attempt.timeRemainingSeconds, 10 * 60);
    });

    test('returns not-found when the local fallback test config does not exist', () async {
      when(() => remoteDataSource.startTest(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
          )).thenThrow(NetworkFailure.noConnection());
      when(() => localDataSource.getTestConfigLocal(any())).thenAnswer((_) async => null);

      final result = await repository.startTest(userId: 'user-1', testId: 'does-not-exist');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<DatabaseFailure>()), (_) => fail('expected Left'));
    });

    test('returns not-found when the test config exists locally but has no questions', () async {
      when(() => remoteDataSource.startTest(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
          )).thenThrow(NetworkFailure.noConnection());
      when(() => localDataSource.getTestConfigLocal(any())).thenAnswer((_) async => _testConfig());
      when(() => localDataSource.getQuestionsForTestLocal(any())).thenAnswer((_) async => []);

      final result = await repository.startTest(userId: 'user-1', testId: 'local-full-tnpsc-group2');

      expect(result.isLeft(), isTrue);
    });

    test('does NOT fall back to local when the remote failure is not a '
        'NetworkFailure (e.g. a real server error) — a real backend failure '
        'should surface as an error, not silently substitute local content', () async {
      when(() => remoteDataSource.startTest(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
          )).thenThrow(const ServerFailure('Internal server error'));

      final result = await repository.startTest(userId: 'user-1', testId: 'test-1');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
      verifyNever(() => localDataSource.getTestConfigLocal(any()));
    });
  });

  group('getMockTests — NetworkFailure-only local fallback', () {
    test('falls back to the local catalog on NetworkFailure', () async {
      when(() => remoteDataSource.getMockTests(
            examId: any(named: 'examId'),
            type: any(named: 'type'),
          )).thenThrow(NetworkFailure.noConnection());
      when(() => localDataSource.getAvailableTestsLocal(
            examId: any(named: 'examId'),
            type: any(named: 'type'),
          )).thenAnswer((_) async => [_testConfig()]);

      final result = await repository.getMockTests(examId: 'tnpsc-group2');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).length, 1);
    });

    test('propagates a non-network failure without falling back to local', () async {
      when(() => remoteDataSource.getMockTests(
            examId: any(named: 'examId'),
            type: any(named: 'type'),
          )).thenThrow(const ValidationFailure('bad request'));

      final result = await repository.getMockTests(examId: 'tnpsc-group2');

      expect(result.isLeft(), isTrue);
      verifyNever(() => localDataSource.getAvailableTestsLocal(
            examId: any(named: 'examId'),
            type: any(named: 'type'),
          ));
    });
  });

  group('getTestHistory / local reconstruction', () {
    // Schema v5: MockTestLocalDataSource now stores the real exam id under
    // 'examId' and the domain test id (e.g. 'local-full-tnpsc-group2')
    // under 'testId' in the maps it returns — two distinct values, where
    // before the fix 'testId' held the domain id and no real examId was
    // stored anywhere. These rows model that corrected shape.
    Map<String, dynamic> row({
      required String attemptId,
      required String domainTestId,
      required String realExamId,
      required double totalScore,
      DateTime? submittedAt,
    }) {
      return {
        'attemptId': attemptId,
        'testId': domainTestId,
        'examId': realExamId,
        'submittedAt': submittedAt ?? DateTime(2024, 1, 1),
        'totalScore': totalScore,
      };
    }

    setUp(() {
      when(() => remoteDataSource.getTestHistory(
            userId: any(named: 'userId'),
            examId: any(named: 'examId'),
          )).thenThrow(NetworkFailure.noConnection());
    });

    test('reconstructs results from local rows, deriving correct/incorrect '
        'from saved answers and marks from row.totalScore', () async {
      when(() => localDataSource.getMockTestResults(any())).thenAnswer(
        (_) async => [
          row(attemptId: 'attempt-1', domainTestId: 'local-full-tnpsc-group2', realExamId: 'tnpsc-group2', totalScore: 4.0),
        ],
      );
      when(() => localDataSource.getMockTestAnswers('attempt-1')).thenAnswer(
        (_) async => [
          {'isCorrect': true},
          {'isCorrect': true},
          {'isCorrect': false},
        ],
      );

      final result = await repository.getTestHistory(userId: 'user-1');

      final results = result.getOrElse(() => throw StateError('expected Right'));
      expect(results.length, 1);
      expect(results.first.correctAnswers, 2);
      expect(results.first.incorrectAnswers, 1);
      expect(results.first.obtainedMarks, 4.0);
    });

    test('FIXED (a): a matching examId returns the matching history entry', () async {
      when(() => localDataSource.getMockTestResults(any())).thenAnswer(
        (_) async => [
          row(attemptId: 'attempt-1', domainTestId: 'local-full-tnpsc-group2', realExamId: 'tnpsc-group2', totalScore: 4.0),
        ],
      );
      when(() => localDataSource.getMockTestAnswers(any())).thenAnswer((_) async => [{'isCorrect': true}]);

      final result = await repository.getTestHistory(userId: 'user-1', examId: 'tnpsc-group2');

      final results = result.getOrElse(() => throw StateError('expected Right'));
      expect(results.length, 1);
      expect(results.first.attemptId, 'attempt-1');
    });

    test('FIXED (b): a non-matching examId excludes that result', () async {
      when(() => localDataSource.getMockTestResults(any())).thenAnswer(
        (_) async => [
          row(attemptId: 'attempt-1', domainTestId: 'local-full-tnpsc-group2', realExamId: 'tnpsc-group2', totalScore: 4.0),
        ],
      );
      when(() => localDataSource.getMockTestAnswers(any())).thenAnswer((_) async => [{'isCorrect': true}]);

      final result = await repository.getTestHistory(userId: 'user-1', examId: 'tnpsc-group4');

      final results = result.getOrElse(() => throw StateError('expected Right'));
      expect(results, isEmpty);
    });

    test('FIXED (c): a null examId still returns all local history, '
        'unfiltered', () async {
      when(() => localDataSource.getMockTestResults(any())).thenAnswer(
        (_) async => [
          row(attemptId: 'attempt-1', domainTestId: 'local-full-tnpsc-group2', realExamId: 'tnpsc-group2', totalScore: 4.0),
          row(attemptId: 'attempt-2', domainTestId: 'local-full-tnpsc-group4', realExamId: 'tnpsc-group4', totalScore: 2.0),
        ],
      );
      when(() => localDataSource.getMockTestAnswers(any())).thenAnswer((_) async => [{'isCorrect': true}]);

      final result = await repository.getTestHistory(userId: 'user-1');

      final results = result.getOrElse(() => throw StateError('expected Right'));
      expect(results.length, 2);
    });

    test('FIXED (d): multiple attempts across different exams do not '
        'cross-contaminate — each result keeps its own exam\'s data when '
        'filtered', () async {
      when(() => localDataSource.getMockTestResults(any())).thenAnswer(
        (_) async => [
          row(attemptId: 'attempt-1', domainTestId: 'local-full-tnpsc-group2', realExamId: 'tnpsc-group2', totalScore: 4.0),
          row(attemptId: 'attempt-2', domainTestId: 'local-topic-x', realExamId: 'tnpsc-group2', totalScore: 6.0),
          row(attemptId: 'attempt-3', domainTestId: 'local-full-tnpsc-group4', realExamId: 'tnpsc-group4', totalScore: 8.0),
        ],
      );
      when(() => localDataSource.getMockTestAnswers('attempt-1')).thenAnswer((_) async => [{'isCorrect': true}]);
      when(() => localDataSource.getMockTestAnswers('attempt-2')).thenAnswer(
        (_) async => [{'isCorrect': true}, {'isCorrect': true}, {'isCorrect': true}],
      );
      when(() => localDataSource.getMockTestAnswers('attempt-3')).thenAnswer((_) async => [{'isCorrect': false}]);

      final result = await repository.getTestHistory(userId: 'user-1', examId: 'tnpsc-group2');

      final results = result.getOrElse(() => throw StateError('expected Right'));
      expect(results.map((r) => r.attemptId), unorderedEquals(['attempt-1', 'attempt-2']));
      expect(results.any((r) => r.attemptId == 'attempt-3'), isFalse);
      // Each surviving result keeps its own obtainedMarks — group 4's data
      // never leaks into group 2's rows.
      final byAttempt = {for (final r in results) r.attemptId: r};
      expect(byAttempt['attempt-1']!.obtainedMarks, 4.0);
      expect(byAttempt['attempt-2']!.obtainedMarks, 6.0);
    });
  });

  group('updateQuestionAnswer', () {
    // Not currently reachable from the UI — TestAttemptNotifier.updateQuestionAnswer
    // (mock_test_providers.dart) is local-state-only and never calls this
    // repository method — but the method's own correctness still matters
    // for whatever does call it (or will, if this ever gets wired up).
    Future<List<dynamic>> submitAndCapture(MockTestQuestion returnedQuestion, int selectedOptionIndex) async {
      when(() => remoteDataSource.updateQuestionAnswer(
            attemptId: any(named: 'attemptId'),
            questionId: any(named: 'questionId'),
            selectedOptionIndex: any(named: 'selectedOptionIndex'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
          )).thenAnswer((_) async => returnedQuestion);

      await repository.updateQuestionAnswer(
        attemptId: 'attempt-1',
        questionId: 'q1',
        selectedOptionIndex: selectedOptionIndex,
      );

      return verify(() => localDataSource.saveMockTestAnswer(
            attemptId: any(named: 'attemptId'),
            questionId: any(named: 'questionId'),
            selectedAnswer: any(named: 'selectedAnswer'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: captureAny(named: 'isCorrect'),
          )).captured;
    }

    test('FIXED: a correct answer at option index 2 (not option A) is now '
        'persisted as correct — isCorrect is derived from the question\'s '
        'own correctAnswerIndex via MockTestQuestion.isCorrect, not a '
        'literal comparison against 0', () async {
      final returnedQuestion = _q('q1', selectedOptionIndex: 2, correctAnswerIndex: 2);

      final captured = await submitAndCapture(returnedQuestion, 2);

      expect(captured.single, isTrue);
    });

    test('FIXED: a correct answer at option index 3 is also persisted as '
        'correct, ruling out any remaining hardcoded index', () async {
      final returnedQuestion = _q('q1', selectedOptionIndex: 3, correctAnswerIndex: 3);

      final captured = await submitAndCapture(returnedQuestion, 3);

      expect(captured.single, isTrue);
    });

    test('an actually-incorrect selection is still persisted as incorrect', () async {
      final returnedQuestion = _q('q1', selectedOptionIndex: 1, correctAnswerIndex: 2);

      final captured = await submitAndCapture(returnedQuestion, 1);

      expect(captured.single, isFalse);
    });
  });
}
