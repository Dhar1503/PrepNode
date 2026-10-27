import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/data/seed/seed_data.dart';
import 'package:prepnode/features/knowledge_graph/data/datasources/knowledge_graph_local_datasource.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';

class TestDatabaseService implements DatabaseService {
  final PrepNodeDatabase _db;

  TestDatabaseService(this._db);

  @override
  PrepNodeDatabase get database => _db;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PrepNodeDatabase db;
  late KnowledgeGraphLocalDataSource dataSource;

  const examId = 'tnpsc-group2';
  const userId = 'test-user';

  setUp(() async {
    db = PrepNodeDatabase(NativeDatabase.memory());
    await SeedData.seedDatabase(db);
    await db.into(db.users).insert(UsersCompanion.insert(
          userId: userId,
          name: 'Test Aspirant',
          email: 'graph@example.com',
          passwordHash: 'x',
        ));
    dataSource = KnowledgeGraphLocalDataSource(
      databaseService: TestDatabaseService(db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('syllabus graph structure', () {
    test('builds a connected Exam -> Subject -> Topic -> Subtopic tree',
        () async {
      final graph = await dataSource.getSyllabusGraph(examId: examId);

      final byType = <NodeType, int>{};
      for (final node in graph.nodes) {
        byType[node.type] = (byType[node.type] ?? 0) + 1;
      }

      expect(byType[NodeType.exam], 1, reason: 'exactly one root');
      expect(byType[NodeType.subject], 4,
          reason: 'all four TNPSC subjects should be present');
      expect(byType[NodeType.topic] ?? 0, greaterThan(5));
      expect(byType[NodeType.subtopic] ?? 0, greaterThan(15),
          reason: 'the graph is only a graph if topics have children — this '
              'is what a flat seed used to fail');

      // Every node except the root must be reachable from the root, or the
      // graph would render disconnected islands.
      final childrenOf = <String, List<String>>{};
      for (final edge in graph.edges) {
        expect(edge.type, EdgeType.parentChild);
        childrenOf.putIfAbsent(edge.sourceNodeId, () => []).add(edge.targetNodeId);
      }

      final reachable = <String>{examId};
      final queue = <String>[examId];
      while (queue.isNotEmpty) {
        final current = queue.removeLast();
        for (final child in childrenOf[current] ?? const <String>[]) {
          if (reachable.add(child)) queue.add(child);
        }
      }

      expect(reachable.length, graph.nodes.length,
          reason: 'every node must be reachable from the exam root');
    });

    test('every edge points at nodes that actually exist', () async {
      final graph = await dataSource.getSyllabusGraph(examId: examId);
      final ids = graph.nodes.map((n) => n.id).toSet();

      for (final edge in graph.edges) {
        expect(ids, contains(edge.sourceNodeId),
            reason: 'dangling edge source ${edge.sourceNodeId}');
        expect(ids, contains(edge.targetNodeId),
            reason: 'dangling edge target ${edge.targetNodeId}');
      }
    });

    test('each subtopic has a real parent topic, not a subject', () async {
      final graph = await dataSource.getSyllabusGraph(examId: examId);
      final topicIds = graph.nodes
          .where((n) => n.type == NodeType.topic)
          .map((n) => n.id)
          .toSet();

      final subtopics = graph.nodes.where((n) => n.type == NodeType.subtopic);
      expect(subtopics, isNotEmpty);
      for (final subtopic in subtopics) {
        expect(topicIds, contains(subtopic.parentId),
            reason: '${subtopic.name} should hang off a topic');
      }
    });

    test('an unknown exam yields an empty graph rather than throwing',
        () async {
      final graph = await dataSource.getSyllabusGraph(examId: 'no-such-exam');
      expect(graph.nodes, isEmpty);
      expect(graph.edges, isEmpty);
    });
  });

  group('mastery reacts to what the user has answered', () {
    /// Records an attempt against a real seeded question so mastery is
    /// derived the same way the app derives it.
    Future<void> attempt(String questionId, {required bool correct}) async {
      await db.into(db.userQuestionAttempts).insert(
            UserQuestionAttemptsCompanion.insert(
              attemptId: 'attempt-$questionId-${correct ? 'c' : 'w'}',
              userId: userId,
              questionId: questionId,
              selectedAnswer: correct ? 'A' : 'B',
              isCorrect: correct,
            ),
          );
    }

    test('a fresh user sees every node as not started', () async {
      final graph = await dataSource.getSyllabusGraph(
        examId: examId,
        userId: userId,
      );

      expect(
        graph.nodes.every((n) => n.masteryState == MasteryState.notStarted),
        isTrue,
        reason: 'nothing should be red or green before any practice',
      );
    });

    test('correct answers raise the topic mastery and roll up to its parents',
        () async {
      final question = await db.select(db.questions).get().then((rows) =>
          rows.firstWhere((q) => q.topicId == 'topic-fundamental-rights'));
      await attempt(question.questionId, correct: true);

      final graph = await dataSource.getSyllabusGraph(
        examId: examId,
        userId: userId,
      );

      final topic =
          graph.nodes.firstWhere((n) => n.id == 'topic-fundamental-rights');
      expect(topic.masteryPercentage, 100);
      expect(topic.masteryState, MasteryState.mastered);

      // The parent topic has no attempts of its own; its mastery comes from
      // what sits under it.
      final parent =
          graph.nodes.firstWhere((n) => n.id == 'topic-indian-constitution');
      expect(parent.masteryPercentage, greaterThan(0),
          reason: 'progress must roll up the tree, not stop at the leaf');

      final subject =
          graph.nodes.firstWhere((n) => n.id == 'subject-general-studies');
      expect(subject.masteryPercentage, greaterThan(0));

      final exam = graph.nodes.firstWhere((n) => n.id == examId);
      expect(exam.masteryPercentage, greaterThan(0));
    });

    test('a topic answered mostly wrong is flagged as needing revision',
        () async {
      final questions = await db.select(db.questions).get().then((rows) =>
          rows.where((q) => q.topicId == 'topic-fundamental-rights').toList());
      expect(questions.length, greaterThanOrEqualTo(2),
          reason: 'this test needs at least two questions on the topic');

      await attempt(questions[0].questionId, correct: false);
      await attempt(questions[1].questionId, correct: false);

      final graph = await dataSource.getSyllabusGraph(
        examId: examId,
        userId: userId,
      );

      final topic =
          graph.nodes.firstWhere((n) => n.id == 'topic-fundamental-rights');
      expect(topic.masteryState, MasteryState.needsRevision,
          reason: 'weak topics must surface in the warning colour');
    });

    test('a stored user_topic_progress row takes precedence over accuracy',
        () async {
      await db.into(db.userTopicProgress).insert(
            UserTopicProgressCompanion.insert(
              progressId: 'progress-1',
              userId: userId,
              topicId: 'topic-geometry',
              masteryPercentage: const Value(80.0),
            ),
          );

      final graph = await dataSource.getSyllabusGraph(
        examId: examId,
        userId: userId,
      );

      final topic = graph.nodes.firstWhere((n) => n.id == 'topic-geometry');
      expect(topic.masteryPercentage, 80.0);
    });
  });
}
