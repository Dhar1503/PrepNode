import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/seed/seed_data.dart';

/// Referential-integrity audit of the shipped content.
///
/// SQLite does not enforce foreign keys unless the pragma is switched on,
/// and it is not, so a typo'd topic id in the seed would sit in the database
/// silently and surface as an empty screen rather than an error. These tests
/// are the enforcement: they fail the build instead of the user's session.
void main() {
  late PrepNodeDatabase db;

  setUpAll(() async {
    db = PrepNodeDatabase(NativeDatabase.memory());
    await SeedData.seedDatabase(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('exam ids are consistent across every content table', () async {
    final examIds = await db.select(db.exams).get().then(
        (rows) => rows.map((e) => e.examId).toSet());
    expect(examIds, isNotEmpty);

    final subjects = await db.select(db.subjects).get();
    for (final subject in subjects) {
      expect(examIds, contains(subject.examId),
          reason: '${subject.subjectName} points at unknown exam '
              '"${subject.examId}"');
    }

    final questions = await db.select(db.questions).get();
    for (final question in questions) {
      expect(examIds, contains(question.examId),
          reason: '${question.questionId} points at unknown exam '
              '"${question.examId}"');
    }

    final cutoffs = await db.select(db.cutoffData).get();
    for (final cutoff in cutoffs) {
      expect(examIds, contains(cutoff.examId),
          reason: 'cutoff row points at unknown exam "${cutoff.examId}"');
    }
  });

  test('every topic belongs to a real subject and a real parent topic',
      () async {
    final subjectIds = await db.select(db.subjects).get().then(
        (rows) => rows.map((s) => s.subjectId).toSet());
    final topics = await db.select(db.topics).get();
    final topicIds = topics.map((t) => t.topicId).toSet();

    for (final topic in topics) {
      expect(subjectIds, contains(topic.subjectId),
          reason: '${topic.topicName} points at unknown subject '
              '"${topic.subjectId}"');
      if (topic.parentTopicId != null) {
        expect(topicIds, contains(topic.parentTopicId),
            reason: '${topic.topicName} points at unknown parent '
                '"${topic.parentTopicId}"');
        expect(topic.parentTopicId, isNot(topic.topicId),
            reason: '${topic.topicName} is its own parent');
      }
    }
  });

  test('a subtopic sits under a parent from the same subject', () async {
    final topics = await db.select(db.topics).get();
    final subjectOf = {for (final t in topics) t.topicId: t.subjectId};

    for (final topic in topics.where((t) => t.parentTopicId != null)) {
      expect(subjectOf[topic.parentTopicId], topic.subjectId,
          reason: '${topic.topicName} is filed under a parent that belongs '
              'to a different subject');
    }
  });

  test('the topic hierarchy has no cycles', () async {
    final topics = await db.select(db.topics).get();
    final parentOf = {for (final t in topics) t.topicId: t.parentTopicId};

    for (final topic in topics) {
      final seen = <String>{topic.topicId};
      var current = parentOf[topic.topicId];
      var depth = 0;
      while (current != null) {
        expect(seen.add(current), isTrue,
            reason: 'cycle in the hierarchy at ${topic.topicName}');
        current = parentOf[current];
        expect(++depth, lessThan(10), reason: 'hierarchy is implausibly deep');
      }
    }
  });

  test('every question points at a real subject and topic', () async {
    final subjectIds = await db.select(db.subjects).get().then(
        (rows) => rows.map((s) => s.subjectId).toSet());
    final topicIds = await db.select(db.topics).get().then(
        (rows) => rows.map((t) => t.topicId).toSet());

    final questions = await db.select(db.questions).get();
    expect(questions, isNotEmpty);

    for (final question in questions) {
      expect(subjectIds, contains(question.subjectId),
          reason: '${question.questionId} has fictional subject '
              '"${question.subjectId}"');
      expect(topicIds, contains(question.topicId),
          reason: '${question.questionId} has fictional topic '
              '"${question.topicId}"');
      expect(['A', 'B', 'C', 'D'], contains(question.correctAnswer),
          reason: '${question.questionId} has an unusable answer key '
              '"${question.correctAnswer}"');
    }
  });

  test('every resource points at a real topic and a usable link', () async {
    final topicIds = await db.select(db.topics).get().then(
        (rows) => rows.map((t) => t.topicId).toSet());
    final subjectIds = await db.select(db.subjects).get().then(
        (rows) => rows.map((s) => s.subjectId).toSet());

    final resources = await db.select(db.resources).get();
    expect(resources, isNotEmpty);

    for (final resource in resources) {
      expect(topicIds, contains(resource.topicId),
          reason: '"${resource.title}" points at unknown topic '
              '"${resource.topicId}"');
      if (resource.subjectId != null && resource.subjectId!.isNotEmpty) {
        expect(subjectIds, contains(resource.subjectId),
            reason: '"${resource.title}" points at unknown subject '
                '"${resource.subjectId}"');
      }

      final uri = Uri.tryParse(resource.link);
      expect(uri, isNotNull, reason: '"${resource.title}" has an unparseable link');
      expect(['http', 'https'], contains(uri!.scheme),
          reason: '"${resource.title}" link is not openable: ${resource.link}');
      expect(uri.host, isNotEmpty,
          reason: '"${resource.title}" link has no host: ${resource.link}');
      // A placeholder that would open a 404 in the user's browser.
      expect(uri.host, isNot(contains('example.com')),
          reason: '"${resource.title}" still points at a placeholder host');
    }
  });

  test('no duplicate ids in any content table', () async {
    Future<void> assertUnique<T>(
      String label,
      Future<List<T>> rows,
      String Function(T) id,
    ) async {
      final values = (await rows).map(id).toList();
      expect(values.toSet().length, values.length,
          reason: 'duplicate $label ids in the seed');
    }

    await assertUnique('exam', db.select(db.exams).get(), (e) => e.examId);
    await assertUnique('subject', db.select(db.subjects).get(), (s) => s.subjectId);
    await assertUnique('topic', db.select(db.topics).get(), (t) => t.topicId);
    await assertUnique('question', db.select(db.questions).get(), (q) => q.questionId);
    await assertUnique('resource', db.select(db.resources).get(), (r) => r.resourceId);
  });

  test('every subject has at least one topic, and the graph is not flat',
      () async {
    final subjects = await db.select(db.subjects).get();
    final topics = await db.select(db.topics).get();

    for (final subject in subjects) {
      final owned = topics.where((t) => t.subjectId == subject.subjectId);
      expect(owned, isNotEmpty,
          reason: '${subject.subjectName} has no topics, so it renders as an '
              'empty screen');
      expect(owned.where((t) => t.parentTopicId != null), isNotEmpty,
          reason: '${subject.subjectName} has no subtopics, so its branch of '
              'the knowledge graph is a single dot');
    }
  });

  test('no topic in the database has too few questions for a topic test',
      () async {
    // Mock tests are generated one per topic that has questions, so a topic
    // holding a single question yields a one-question "test". This checks
    // the seeded total, not just the practice bank — seed_data.dart carries
    // its own questions and they count toward the same topic.
    final questions = await db.select(db.questions).get();
    final byTopic = <String, int>{};
    for (final q in questions) {
      byTopic[q.topicId] = (byTopic[q.topicId] ?? 0) + 1;
    }

    final thin = byTopic.entries.where((e) => e.value < 3).map((e) => e.key);
    expect(thin, isEmpty,
        reason: 'topics that would generate a trivial mock test: '
            '${thin.join(', ')}');
  });

  test('the question bank is large enough to build real mock tests', () async {
    final questions = await db.select(db.questions).get();
    expect(questions.length, greaterThanOrEqualTo(100));

    final bySubject = <String, int>{};
    for (final q in questions) {
      bySubject[q.subjectId] = (bySubject[q.subjectId] ?? 0) + 1;
    }
    // Every subject needs enough for a subject-level test to be meaningful.
    for (final entry in bySubject.entries) {
      expect(entry.value, greaterThanOrEqualTo(5),
          reason: '${entry.key} has only ${entry.value} questions');
    }
    expect(bySubject.length, 4, reason: 'all four subjects should be covered');
  });

  test('seeding twice does not duplicate anything', () async {
    final before = await db.select(db.topics).get().then((r) => r.length);
    await SeedData.seedDatabase(db);
    final after = await db.select(db.topics).get().then((r) => r.length);

    expect(after, before,
        reason: 'seedDatabase runs on every launch — it must be idempotent');
  });
}
