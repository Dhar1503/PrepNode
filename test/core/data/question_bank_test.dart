import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/seed/question_bank.dart';

/// Quality gate for practice questions.
///
/// The rule this bank is written under is "never ship a question whose key
/// you are not sure of". These tests cannot check whether an answer is
/// factually right — only a human can — but they do catch the mechanical
/// mistakes that produce a wrong key: a duplicated option so two answers are
/// equally correct, a key pointing at an option that does not exist, or a
/// copy-pasted id that silently overwrites another question at seed time.
void main() {
  final bank = QuestionBank.all();

  test('the bank is substantial', () {
    expect(bank.length, greaterThanOrEqualTo(80));
  });

  test('every question id is unique', () {
    final ids = bank.map((q) => q.questionId).toList();
    final dupes = <String>{};
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) dupes.add(id);
    }
    expect(dupes, isEmpty,
        reason: 'a duplicate id silently overwrites the earlier question '
            'when seeded');
  });

  test('every answer key names a real option', () {
    for (final q in bank) {
      expect(['A', 'B', 'C', 'D'], contains(q.correctAnswer),
          reason: '${q.questionId} has key "${q.correctAnswer}"');
    }
  });

  test('no question has duplicate options', () {
    for (final q in bank) {
      final options = [q.optionA, q.optionB, q.optionC, q.optionD];
      expect(options.toSet().length, 4,
          reason: '${q.questionId} repeats an option, so more than one '
              'choice could be argued correct: $options');
    }
  });

  test('no option is blank', () {
    for (final q in bank) {
      for (final option in [q.optionA, q.optionB, q.optionC, q.optionD]) {
        expect(option.trim(), isNotEmpty, reason: '${q.questionId}');
      }
      expect(q.questionText.trim(), isNotEmpty, reason: '${q.questionId}');
    }
  });

  test('every question carries a real explanation', () {
    for (final q in bank) {
      expect(q.explanation, isNotNull, reason: '${q.questionId}');
      // Long enough to actually say why, not just restate the answer.
      expect(q.explanation!.trim().length, greaterThan(30),
          reason: '${q.questionId} has a token explanation');
    }
  });

  test('provenance is honest — nothing claims to be from a past paper', () {
    for (final q in bank) {
      expect(q.verificationStatus, 'unverified', reason: q.questionId);
      expect(q.source, isNotNull, reason: q.questionId);
      expect(q.source, contains('not from a specific past paper'),
          reason: '${q.questionId} must not imply official provenance');
    }
  });

  test('difficulty is one of the three recognised values', () {
    for (final q in bank) {
      expect(['easy', 'medium', 'hard'], contains(q.difficulty),
          reason: '${q.questionId} has difficulty "${q.difficulty}"');
    }
  });

  test('all four subjects are covered', () {
    final subjects = bank.map((q) => q.subjectId).toSet();
    expect(subjects, containsAll([
      'subject-general-studies',
      'subject-aptitude',
      'subject-general-tamil',
      'subject-general-english',
    ]));
  });

  test('every question belongs to the exam the app ships content for', () {
    for (final q in bank) {
      expect(q.examId, 'tnpsc-group2', reason: q.questionId);
    }
  });

  // The "at least 3 questions per topic" floor lives in
  // seed_integrity_test.dart, not here. It has to be checked against the
  // seeded database rather than this bank alone: seed_data.dart carries its
  // own questions on some of the same topics, so counting only the bank
  // would report a topic as thin when the database is fine, and could miss
  // a topic that only seed_data.dart touches.

  test('topics are not wildly unbalanced', () {
    final byTopic = <String, int>{};
    for (final q in bank) {
      byTopic[q.topicId] = (byTopic[q.topicId] ?? 0) + 1;
    }
    // A single topic hoarding the bank would make the "random" mock test
    // feel like it only ever asks about one thing.
    final largest = byTopic.values.reduce((a, b) => a > b ? a : b);
    expect(largest / bank.length, lessThan(0.15),
        reason: 'one topic holds $largest of ${bank.length} questions');
  });
}
