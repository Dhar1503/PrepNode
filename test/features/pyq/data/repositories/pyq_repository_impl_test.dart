// Unit tests for PyqRepositoryImpl. PYQ practice is the single shared
// question source behind PYQ practice, Mock Tests, and Insights/Mastery
// (see the Phase 1C gap assessment) — a filter or mapping bug here quietly
// affects all three. These tests target the repository's own pure logic
// (filter chaining, index<->letter conversion, cross-exam filtering, mode
// string fallback) with the local/remote datasources mocked out; no
// database is exercised.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/pyq/data/datasources/pyq_local_datasource.dart';
import 'package:prepgraph/features/pyq/data/datasources/pyq_remote_datasource.dart';
import 'package:prepgraph/features/pyq/data/repositories/pyq_repository_impl.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';

class MockPyqLocalDataSource extends Mock implements PyqLocalDataSource {}

class MockPyqRemoteDataSource extends Mock implements PyqRemoteDataSource {}

PyqQuestion _question(
  String id, {
  String examId = 'tnpsc-group2',
  bool isSolved = false,
  bool isBookmarked = false,
  DifficultyLevel difficulty = DifficultyLevel.medium,
  int year = 2023,
}) {
  return PyqQuestion(
    id: id,
    examId: examId,
    subjectId: 'subject-general-studies',
    topicId: 'topic-indian-constitution',
    questionText: 'Question $id',
    options: const ['A', 'B', 'C', 'D'],
    correctAnswerIndex: 0,
    explanation: 'because',
    year: year,
    difficulty: difficulty,
    isSolved: isSolved,
    isBookmarked: isBookmarked,
  );
}

void main() {
  late MockPyqLocalDataSource localDataSource;
  late MockPyqRemoteDataSource remoteDataSource;
  late PyqRepository repository;

  setUp(() {
    localDataSource = MockPyqLocalDataSource();
    remoteDataSource = MockPyqRemoteDataSource();
    repository = PyqRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  group('getQuestions — client-side filter chaining', () {
    setUp(() {
      when(() => localDataSource.searchQuestions(
            examId: any(named: 'examId'),
            subjectId: any(named: 'subjectId'),
            topicId: any(named: 'topicId'),
            years: any(named: 'years'),
            difficulties: any(named: 'difficulties'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => [
            _question('q-solved-bookmarked', isSolved: true, isBookmarked: true),
            _question('q-unsolved-bookmarked', isSolved: false, isBookmarked: true),
            _question('q-solved-unbookmarked', isSolved: true, isBookmarked: false),
            _question('q-unsolved-unbookmarked', isSolved: false, isBookmarked: false),
          ]);
    });

    Future<List<String>> idsFor(PyqFilter filter) async {
      final result = await repository.getQuestions(
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-indian-constitution',
        filter: filter,
      );
      return result.getOrElse(() => throw StateError('expected Right')).map((q) => q.id).toList();
    }

    test('solvedOnly keeps only solved questions', () async {
      final ids = await idsFor(const PyqFilter(solvedOnly: true));
      expect(ids, unorderedEquals(['q-solved-bookmarked', 'q-solved-unbookmarked']));
    });

    test('unsolvedOnly keeps only unsolved questions', () async {
      final ids = await idsFor(const PyqFilter(unsolvedOnly: true));
      expect(ids, unorderedEquals(['q-unsolved-bookmarked', 'q-unsolved-unbookmarked']));
    });

    test('bookmarkedOnly + unsolvedOnly compose as AND, not OR', () async {
      final ids = await idsFor(const PyqFilter(unsolvedOnly: true, bookmarkedOnly: true));
      expect(ids, ['q-unsolved-bookmarked']);
    });

    test('no filter returns everything unfiltered', () async {
      final ids = await idsFor(const PyqFilter());
      expect(ids.length, 4);
    });
  });

  group('submitAttempt — option index to answer letter', () {
    setUp(() {
      when(() => localDataSource.saveQuestionAttempt(
            userId: any(named: 'userId'),
            questionId: any(named: 'questionId'),
            selectedAnswer: any(named: 'selectedAnswer'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: any(named: 'isCorrect'),
          )).thenAnswer((_) async {});
    });

    Future<void> submit(int selectedIndex) => repository.submitAttempt(
          userId: 'u1',
          questionId: 'q1',
          selectedOptionIndex: selectedIndex,
          correctOptionIndex: 0,
          isCorrect: selectedIndex == 0,
          timeTakenSeconds: 10,
        );

    test('index 0 -> "A", index 3 -> "D"', () async {
      await submit(0);
      var captured = verify(() => localDataSource.saveQuestionAttempt(
            userId: any(named: 'userId'),
            questionId: any(named: 'questionId'),
            selectedAnswer: captureAny(named: 'selectedAnswer'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: any(named: 'isCorrect'),
          )).captured;
      expect(captured.single, 'A');

      await submit(3);
      captured = verify(() => localDataSource.saveQuestionAttempt(
            userId: any(named: 'userId'),
            questionId: any(named: 'questionId'),
            selectedAnswer: captureAny(named: 'selectedAnswer'),
            timeTakenSeconds: any(named: 'timeTakenSeconds'),
            isCorrect: any(named: 'isCorrect'),
          )).captured;
      expect(captured.single, 'D');
    });

    test('result carries through the correctness the caller computed', () async {
      final result = await submit(2).then((_) => repository.submitAttempt(
            userId: 'u1',
            questionId: 'q1',
            selectedOptionIndex: 1,
            correctOptionIndex: 0,
            isCorrect: false,
            timeTakenSeconds: 5,
          ));
      final attempt = result.getOrElse(() => throw StateError('expected Right'));
      expect(attempt.selectedOptionIndex, 1);
      expect(attempt.isCorrect, isFalse);
    });
  });

  group('getIncorrectQuestions / getBookmarkedQuestions — cross-exam filtering', () {
    test('getIncorrectQuestions drops questions belonging to a different exam', () async {
      when(() => localDataSource.getIncorrectQuestionIds(any())).thenAnswer((_) async => ['q1', 'q2']);
      when(() => localDataSource.getQuestionsByIds(any(), userId: any(named: 'userId'))).thenAnswer(
        (_) async => [
          _question('q1', examId: 'tnpsc-group2'),
          _question('q2', examId: 'tnpsc-group4'), // different exam
        ],
      );

      final result = await repository.getIncorrectQuestions(userId: 'u1', examId: 'tnpsc-group2');

      final questions = result.getOrElse(() => throw StateError('expected Right'));
      expect(questions.map((q) => q.id), ['q1']);
    });

    test('getBookmarkedQuestions drops questions belonging to a different exam', () async {
      when(() => localDataSource.getBookmarks(userId: any(named: 'userId'), entityType: any(named: 'entityType')))
          .thenAnswer((_) async => [
                {'entityId': 'q1'},
                {'entityId': 'q2'},
              ]);
      when(() => localDataSource.getQuestionsByIds(any(), userId: any(named: 'userId'))).thenAnswer(
        (_) async => [
          _question('q1', examId: 'tnpsc-group2'),
          _question('q2', examId: 'tnpsc-group4'),
        ],
      );

      final result = await repository.getBookmarkedQuestions(userId: 'u1', examId: 'tnpsc-group2');

      final questions = result.getOrElse(() => throw StateError('expected Right'));
      expect(questions.map((q) => q.id), ['q1']);
    });
  });

  group('getAiHint', () {
    test('hint text is difficulty-specific and cites the question\'s year', () async {
      when(() => localDataSource.getQuestionById(any())).thenAnswer(
        (_) async => _question('q1', difficulty: DifficultyLevel.hard, year: 2021),
      );

      final result = await repository.getAiHint(questionId: 'q1');

      final hint = result.getOrElse(() => throw StateError('expected Right'));
      expect(hint, contains('exception'));
      expect(hint, contains('2021'));
    });

    test('returns a not-found failure when the question does not exist', () async {
      when(() => localDataSource.getQuestionById(any())).thenAnswer((_) async => null);

      final result = await repository.getAiHint(questionId: 'missing');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<DatabaseFailure>()), (_) => fail('expected Left'));
    });
  });

  group('updateSession — unknown session-mode strings fall back safely', () {
    test('an unrecognized stored mode string maps to SessionMode.single '
        'instead of throwing', () async {
      when(() => localDataSource.updatePyqSession(
            sessionId: any(named: 'sessionId'),
            currentIndex: any(named: 'currentIndex'),
            totalCorrect: any(named: 'totalCorrect'),
            totalAnswered: any(named: 'totalAnswered'),
            totalDurationSeconds: any(named: 'totalDurationSeconds'),
            isCompleted: any(named: 'isCompleted'),
          )).thenAnswer((_) async {});
      when(() => localDataSource.getPyqSession(any())).thenAnswer((_) async => {
            'sessionId': 's1',
            'userId': 'u1',
            'examId': 'tnpsc-group2',
            'subjectId': 'subject-general-studies',
            'topicId': 'topic-indian-constitution',
            'mode': 'not_a_real_mode',
            'startedAt': DateTime(2024, 1, 1),
          });

      final result = await repository.updateSession(sessionId: 's1');

      final session = result.getOrElse(() => throw StateError('expected Right'));
      expect(session.mode, SessionMode.single);
    });
  });
}
