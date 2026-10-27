/// Knowledge Graph Local Data Source
/// Handles local storage and caching for knowledge graph data
library;

import 'package:drift/drift.dart';
import 'package:prepnode/core/data/database/database.dart' hide Exam, Subject, Topic;
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/exam.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/subject.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/topic.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/topic_detail.dart';

class KnowledgeGraphLocalDataSource {
  final DatabaseService _databaseService;

  KnowledgeGraphLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Save exams to local database
  Future<void> saveExams(List<Exam> exams) async {
    final db = _databaseService.database;
    
    for (final exam in exams) {
      final existing = await (db.select(db.exams)
            ..where((tbl) => tbl.examId.equals(exam.id)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.exams)..where((tbl) => tbl.examId.equals(exam.id)))
            .write(ExamsCompanion(
          examName: Value(exam.name),
          description: Value(exam.description),
          conductingBody: Value(exam.conductingBody),
          comingSoon: Value(exam.comingSoon),
        ));
      } else {
        await db.into(db.exams).insert(ExamsCompanion.insert(
          examId: exam.id,
          examName: exam.name,
          description: Value(exam.description),
          conductingBody: Value(exam.conductingBody),
          comingSoon: Value(exam.comingSoon),
        ));
      }
    }
  }

  /// Get exams from local database
  Future<List<Exam>> getExams() async {
    final db = _databaseService.database;
    final exams = await db.select(db.exams).get();

    return exams.map((exam) => Exam(
      id: exam.examId,
      name: exam.examName,
      description: exam.description,
      conductingBody: exam.conductingBody,
      comingSoon: exam.comingSoon,
    )).toList();
  }

  /// Save subjects to local database
  Future<void> saveSubjects(List<Subject> subjects) async {
    final db = _databaseService.database;
    
    for (final subject in subjects) {
      final existing = await (db.select(db.subjects)
            ..where((tbl) => tbl.subjectId.equals(subject.id)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.subjects)..where((tbl) => tbl.subjectId.equals(subject.id)))
            .write(SubjectsCompanion(
          examId: Value(subject.examId),
          subjectName: Value(subject.name),
          importanceWeight: Value(subject.importanceWeight),
        ));
      } else {
        await db.into(db.subjects).insert(SubjectsCompanion.insert(
          subjectId: subject.id,
          examId: subject.examId,
          subjectName: subject.name,
          importanceWeight: Value(subject.importanceWeight),
        ));
      }
    }
  }

  /// Get subjects from local database
  Future<List<Subject>> getSubjects(String examId) async {
    final db = _databaseService.database;
    final subjects = await (db.select(db.subjects)
          ..where((tbl) => tbl.examId.equals(examId)))
        .get();

    return subjects.map((subject) => Subject(
      id: subject.subjectId,
      examId: subject.examId,
      name: subject.subjectName,
      importanceWeight: subject.importanceWeight,
    )).toList();
  }

  /// Save topics to local database
  Future<void> saveTopics(List<Topic> topics) async {
    final db = _databaseService.database;
    
    for (final topic in topics) {
      final existing = await (db.select(db.topics)
            ..where((tbl) => tbl.topicId.equals(topic.id)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.topics)..where((tbl) => tbl.topicId.equals(topic.id)))
            .write(TopicsCompanion(
          subjectId: Value(topic.subjectId),
          parentTopicId: Value(topic.parentTopicId),
          topicName: Value(topic.name),
          difficulty: Value(topic.difficulty ?? 'medium'),
          importanceScore: Value(topic.importanceScore),
        ));
      } else {
        await db.into(db.topics).insert(TopicsCompanion.insert(
          topicId: topic.id,
          subjectId: topic.subjectId,
          parentTopicId: Value(topic.parentTopicId),
          topicName: topic.name,
          difficulty: Value(topic.difficulty ?? 'medium'),
          importanceScore: Value(topic.importanceScore),
        ));
      }
    }
  }

  /// Get topics from local database.
  ///
  /// importanceScore is recomputed here from real PYQ question counts per
  /// topic rather than trusting the seeded column — that seed value is a
  /// hand-picked placeholder (0.95, 0.90, 0.85...), not derived from
  /// anything. "Important" should mean "this topic has actually appeared in
  /// past papers," which the questions table already records for real.
  Future<List<Topic>> getTopics(String subjectId) async {
    final db = _databaseService.database;
    final topics = await (db.select(db.topics)
          ..where((tbl) => tbl.subjectId.equals(subjectId)))
        .get();
    if (topics.isEmpty) return const [];

    final frequencyByTopic = <String, int>{};
    for (final topic in topics) {
      final count = await (db.select(db.questions)
            ..where((q) => q.topicId.equals(topic.topicId)))
          .get()
          .then((rows) => rows.length);
      frequencyByTopic[topic.topicId] = count;
    }
    final maxFrequency = frequencyByTopic.values.fold(0, (a, b) => a > b ? a : b);

    return topics.map((topic) {
      final frequency = frequencyByTopic[topic.topicId] ?? 0;
      final realImportance = maxFrequency > 0 ? frequency / maxFrequency : 0.0;
      return Topic(
        id: topic.topicId,
        subjectId: topic.subjectId,
        parentTopicId: topic.parentTopicId,
        name: topic.topicName,
        difficulty: topic.difficulty,
        importanceScore: realImportance,
      );
    }).toList();
  }

  /// Get topic from local database
  Future<Topic?> getTopic(String topicId) async {
    final db = _databaseService.database;
    final topic = await (db.select(db.topics)
          ..where((tbl) => tbl.topicId.equals(topicId)))
        .getSingleOrNull();

    if (topic == null) return null;

    return Topic(
      id: topic.topicId,
      subjectId: topic.subjectId,
      parentTopicId: topic.parentTopicId,
      name: topic.topicName,
      difficulty: topic.difficulty,
      importanceScore: topic.importanceScore,
    );
  }

  /// Save user topic progress
  Future<void> saveUserTopicProgress(String userId, String topicId, double masteryPercentage) async {
    final db = _databaseService.database;
    final existing = await (db.select(db.userTopicProgress)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.topicId.equals(topicId)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.userTopicProgress)
            ..where((tbl) => tbl.userId.equals(userId) & tbl.topicId.equals(topicId)))
          .write(UserTopicProgressCompanion(
        masteryPercentage: Value(masteryPercentage),
        lastRevisionDate: Value(DateTime.now()),
      ));
    } else {
      await db.into(db.userTopicProgress).insert(UserTopicProgressCompanion.insert(
        progressId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        topicId: topicId,
        masteryPercentage: Value(masteryPercentage),
      ));
    }
  }

  /// Get user topic progress
  Future<double?> getUserTopicProgress(String userId, String topicId) async {
    final db = _databaseService.database;
    final progress = await (db.select(db.userTopicProgress)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.topicId.equals(topicId)))
        .getSingleOrNull();

    return progress?.masteryPercentage;
  }

  /// Build graph data for a topic from the existing topic hierarchy
  /// (parent/child via topics.parentTopicId) and the concept_relationships
  /// table — the two existing data models this graph is derived from.
  Future<GraphData> getTopicGraph(String topicId, {int radius = 1}) async {
    final db = _databaseService.database;

    final centerRow = await (db.select(db.topics)
          ..where((tbl) => tbl.topicId.equals(topicId)))
        .getSingleOrNull();
    if (centerRow == null) {
      return const GraphData(nodes: [], edges: []);
    }

    final topicRows = {centerRow.topicId: centerRow};
    final edges = <GraphEdge>[];

    // Parent/child hierarchy
    final parentId = centerRow.parentTopicId;
    if (parentId != null) {
      final parentRow = await (db.select(db.topics)
            ..where((tbl) => tbl.topicId.equals(parentId)))
          .getSingleOrNull();
      if (parentRow != null) {
        topicRows[parentRow.topicId] = parentRow;
        edges.add(GraphEdge(
          id: '${parentRow.topicId}_$topicId',
          sourceNodeId: parentRow.topicId,
          targetNodeId: topicId,
          type: EdgeType.parentChild,
        ));
      }
    }

    final childRows = await (db.select(db.topics)
          ..where((tbl) => tbl.parentTopicId.equals(topicId)))
        .get();
    for (final child in childRows) {
      topicRows[child.topicId] = child;
      edges.add(GraphEdge(
        id: '${topicId}_${child.topicId}',
        sourceNodeId: topicId,
        targetNodeId: child.topicId,
        type: EdgeType.parentChild,
      ));
    }

    // Concept relationships (prerequisite / related / etc.)
    final relationRows = await (db.select(db.conceptRelationships)
          ..where((tbl) =>
              tbl.sourceTopicId.equals(topicId) | tbl.targetTopicId.equals(topicId)))
        .get();

    for (final relation in relationRows) {
      final otherId = relation.sourceTopicId == topicId
          ? relation.targetTopicId
          : relation.sourceTopicId;
      if (!topicRows.containsKey(otherId)) {
        final otherRow = await (db.select(db.topics)
              ..where((tbl) => tbl.topicId.equals(otherId)))
            .getSingleOrNull();
        if (otherRow != null) topicRows[otherId] = otherRow;
      }
      edges.add(GraphEdge(
        id: relation.relationId,
        sourceNodeId: relation.sourceTopicId,
        targetNodeId: relation.targetTopicId,
        type: _mapRelationshipType(relation.relationshipType),
      ));
    }

    final nodes = topicRows.values
        .map((row) => GraphNode(
              id: row.topicId,
              name: row.topicName,
              type: NodeType.topic,
              masteryState: MasteryState.notStarted,
              masteryPercentage: 0.0,
              estimatedStudyMinutes: 60,
              difficulty: _mapDifficulty(row.difficulty),
              importanceScore: row.importanceScore,
              parentId: row.parentTopicId,
            ))
        .toList();

    return GraphData(nodes: nodes, edges: edges, scopeTopicId: topicId, radius: radius);
  }

  /// Build full topic detail from the existing topic graph (parent/child +
  /// concept_relationships, via [getTopicGraph]) plus real PYQ/resource
  /// counts and this user's mastery — no live backend exists for this
  /// data, and every one of these tables is already read elsewhere.
  Future<TopicDetail?> getTopicDetailLocal(String topicId, {String? userId}) async {
    final db = _databaseService.database;
    final topicRow = await getTopic(topicId);
    if (topicRow == null) return null;

    final graphData = await getTopicGraph(topicId);
    final nodesById = {for (final node in graphData.nodes) node.id: node};

    final prerequisites = <TopicReference>[];
    final relatedTopics = <TopicReference>[];
    final nextTopics = <TopicReference>[];

    for (final edge in graphData.edges) {
      final otherId = edge.sourceNodeId == topicId ? edge.targetNodeId : edge.sourceNodeId;
      if (otherId == topicId) continue;
      final otherNode = nodesById[otherId];
      if (otherNode == null) continue;

      final reference = TopicReference(topicId: otherId, topicName: otherNode.name);
      switch (edge.type) {
        case EdgeType.prerequisite:
          // Prerequisite edges point prerequisite -> topic; this topic is
          // the prerequisite's *next* topic when it's the edge's source.
          if (edge.targetNodeId == topicId) {
            prerequisites.add(reference);
          } else {
            nextTopics.add(reference);
          }
          break;
        case EdgeType.recommendedNext:
          nextTopics.add(reference);
          break;
        case EdgeType.parentChild:
        case EdgeType.relatedTopic:
          relatedTopics.add(reference);
          break;
      }
    }

    final pyqCount = await (db.select(db.questions)..where((q) => q.topicId.equals(topicId)))
        .get()
        .then((rows) => rows.length);
    final resourceCount = await (db.select(db.resources)..where((r) => r.topicId.equals(topicId)))
        .get()
        .then((rows) => rows.length);

    // user_topic_progress.mastery_percentage is stored on a 0-100 scale
    // (see InsightsRepositoryImpl, which divides by 100 the same way) but
    // GraphNode.masteryPercentage / MasteryRing both expect 0.0-1.0.
    final rawMasteryPercentage =
        userId != null && userId.isNotEmpty ? await getUserTopicProgress(userId, topicId) : null;
    final resolvedMastery = (rawMasteryPercentage ?? 0.0) / 100;

    final node = GraphNode(
      id: topicRow.id,
      name: topicRow.name,
      type: NodeType.topic,
      masteryState: _mapMasteryState(resolvedMastery),
      masteryPercentage: resolvedMastery,
      estimatedStudyMinutes: 60,
      difficulty: _mapDifficulty(topicRow.difficulty),
      importanceScore: topicRow.importanceScore,
      parentId: topicRow.parentTopicId,
    );

    return TopicDetail(
      node: node,
      // No description field exists anywhere in the local schema for
      // topics, so this is left empty rather than inventing prose.
      description: '',
      prerequisites: prerequisites,
      relatedTopics: relatedTopics,
      nextTopics: nextTopics,
      pyqCount: pyqCount,
      resourceCount: resourceCount,
    );
  }

  /// [masteryPercentage] is expected on a 0.0-1.0 scale (see the
  /// conversion in getTopicDetailLocal above).
  MasteryState _mapMasteryState(double masteryPercentage) {
    if (masteryPercentage <= 0) return MasteryState.notStarted;
    if (masteryPercentage >= 0.7) return MasteryState.mastered;
    return MasteryState.inProgress;
  }

  EdgeType _mapRelationshipType(String type) {
    switch (type.toLowerCase()) {
      case 'prerequisite':
        return EdgeType.prerequisite;
      case 'frequently_asked':
      case 'recommended':
        return EdgeType.recommendedNext;
      case 'contains':
      case 'parent':
        return EdgeType.parentChild;
      default:
        return EdgeType.relatedTopic;
    }
  }

  DifficultyLevel _mapDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'hard':
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.intermediate;
    }
  }

  /// Builds the whole syllabus as a connected graph:
  /// Exam -> Subjects -> Topics -> Subtopics.
  ///
  /// This is what the Knowledge Graph screen renders. It replaces the
  /// previous approach of asking for a radius-1 neighbourhood around one
  /// topic, which returned a single node on this dataset (no
  /// ConceptRelationships rows are ever seeded) and so drew a lone dot.
  ///
  /// Every node is read from Drift — nothing here is hardcoded — and each
  /// one carries live mastery so the graph re-colours itself as the user
  /// answers questions.
  Future<GraphData> getSyllabusGraph({
    required String examId,
    String? userId,
  }) async {
    final db = _databaseService.database;

    final subjectRows = await (db.select(db.subjects)
          ..where((tbl) => tbl.examId.equals(examId)))
        .get();
    if (subjectRows.isEmpty) {
      return const GraphData(nodes: [], edges: []);
    }

    final subjectIds = subjectRows.map((s) => s.subjectId).toList();
    final topicRows = await (db.select(db.topics)
          ..where((tbl) => tbl.subjectId.isIn(subjectIds)))
        .get();

    final mastery = await _topicMastery(userId);
    final attempts = await _topicAttemptCounts(userId);

    final nodes = <GraphNode>[];
    final edges = <GraphEdge>[];

    final examRow = await (db.select(db.exams)
          ..where((tbl) => tbl.examId.equals(examId)))
        .getSingleOrNull();

    // Children first, so a parent can average what is underneath it.
    final childrenOf = <String, List<String>>{};
    for (final topic in topicRows) {
      if (topic.parentTopicId != null) {
        childrenOf.putIfAbsent(topic.parentTopicId!, () => []).add(topic.topicId);
      }
    }

    /// A parent topic has no attempts of its own — its mastery is whatever
    /// its subtopics add up to, so progress visibly rolls up the tree.
    double masteryFor(String topicId) {
      final own = mastery[topicId];
      final children = childrenOf[topicId];
      if (children == null || children.isEmpty) return own ?? 0.0;

      final childValues = children.map(masteryFor).toList();
      final childAverage =
          childValues.reduce((a, b) => a + b) / childValues.length;
      if (own == null) return childAverage;
      return (own + childAverage) / 2;
    }

    int attemptsFor(String topicId) {
      final own = attempts[topicId] ?? 0;
      final children = childrenOf[topicId] ?? const <String>[];
      return children.fold(own, (sum, child) => sum + attemptsFor(child));
    }

    for (final topic in topicRows) {
      final topicMastery = masteryFor(topic.topicId);
      nodes.add(GraphNode(
        id: topic.topicId,
        name: topic.topicName,
        type: topic.parentTopicId == null ? NodeType.topic : NodeType.subtopic,
        masteryState: _resolveMasteryState(
          topicMastery,
          attemptsFor(topic.topicId),
        ),
        masteryPercentage: topicMastery,
        difficulty: _mapDifficulty(topic.difficulty),
        importanceScore: topic.importanceScore,
        parentId: topic.parentTopicId ?? topic.subjectId,
      ));

      edges.add(GraphEdge(
        id: 'edge-${topic.parentTopicId ?? topic.subjectId}-${topic.topicId}',
        sourceNodeId: topic.parentTopicId ?? topic.subjectId,
        targetNodeId: topic.topicId,
        type: EdgeType.parentChild,
      ));
    }

    for (final subject in subjectRows) {
      final rootTopics = topicRows
          .where((t) => t.subjectId == subject.subjectId && t.parentTopicId == null)
          .toList();
      final subjectMastery = rootTopics.isEmpty
          ? 0.0
          : rootTopics.map((t) => masteryFor(t.topicId)).reduce((a, b) => a + b) /
              rootTopics.length;
      final subjectAttempts = rootTopics.fold<int>(
          0, (sum, t) => sum + attemptsFor(t.topicId));

      nodes.add(GraphNode(
        id: subject.subjectId,
        name: subject.subjectName,
        type: NodeType.subject,
        masteryState: _resolveMasteryState(subjectMastery, subjectAttempts),
        masteryPercentage: subjectMastery,
        importanceScore: subject.importanceWeight,
        parentId: examId,
      ));

      edges.add(GraphEdge(
        id: 'edge-$examId-${subject.subjectId}',
        sourceNodeId: examId,
        targetNodeId: subject.subjectId,
        type: EdgeType.parentChild,
      ));
    }

    final subjectNodes = nodes.where((n) => n.type == NodeType.subject).toList();
    final examMastery = subjectNodes.isEmpty
        ? 0.0
        : subjectNodes.map((n) => n.masteryPercentage).reduce((a, b) => a + b) /
            subjectNodes.length;

    nodes.add(GraphNode(
      id: examId,
      name: examRow?.examName ?? 'Exam',
      type: NodeType.exam,
      masteryState: _resolveMasteryState(
        examMastery,
        attempts.values.fold(0, (a, b) => a + b),
      ),
      masteryPercentage: examMastery,
    ));

    return GraphData(nodes: nodes, edges: edges);
  }

  /// Per-topic mastery, derived from what the user has actually answered.
  ///
  /// `user_topic_progress` is authoritative when a row exists (the planner
  /// and study sessions write it), but answering a PYQ only ever writes
  /// `user_question_attempts` — so accuracy over those attempts is used as
  /// the fallback. Without it, practising questions moved nothing on the
  /// graph.
  Future<Map<String, double>> _topicMastery(String? userId) async {
    if (userId == null || userId.isEmpty) return {};
    final db = _databaseService.database;

    final result = <String, double>{};

    final attemptRows = await db.customSelect(
      '''
      SELECT q.topic_id AS topic_id,
             COUNT(*) AS attempted,
             SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS correct
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
      GROUP BY q.topic_id
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    for (final row in attemptRows) {
      final attempted = row.read<int>('attempted');
      if (attempted == 0) continue;
      final correct = row.read<int?>('correct') ?? 0;
      result[row.read<String>('topic_id')] = (correct / attempted) * 100;
    }

    final progressRows = await (db.select(db.userTopicProgress)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
    for (final row in progressRows) {
      if (row.masteryPercentage > 0) {
        result[row.topicId] = row.masteryPercentage;
      }
    }

    return result;
  }

  /// How many questions the user has attempted per topic — the difference
  /// between "not started" (grey) and "weak" (warning colour).
  Future<Map<String, int>> _topicAttemptCounts(String? userId) async {
    if (userId == null || userId.isEmpty) return {};
    final db = _databaseService.database;

    final rows = await db.customSelect(
      '''
      SELECT q.topic_id AS topic_id, COUNT(*) AS attempted
      FROM user_question_attempts a
      JOIN questions q ON q.question_id = a.question_id
      WHERE a.user_id = ?
      GROUP BY q.topic_id
      ''',
      variables: [Variable.withString(userId)],
    ).get();

    return {
      for (final row in rows)
        row.read<String>('topic_id'): row.read<int>('attempted'),
    };
  }

  /// Untouched topics stay neutral rather than being painted as failures —
  /// a brand-new user should not open the graph to a wall of red.
  MasteryState _resolveMasteryState(double mastery, int attempted) {
    if (attempted == 0) return MasteryState.notStarted;
    if (mastery >= 75) return MasteryState.mastered;
    if (mastery < 50) return MasteryState.needsRevision;
    return MasteryState.inProgress;
  }

  /// Clear all cached knowledge graph data
  Future<void> clearCache() async {
    final db = _databaseService.database;
    await db.delete(db.exams).go();
    await db.delete(db.subjects).go();
    await db.delete(db.topics).go();
  }

  /// Check if cache is stale (older than 24 hours)
  Future<bool> isCacheStale() async {
    // For simplicity, we'll check if any data exists
    // In production, you'd check timestamps
    final db = _databaseService.database;
    final examCount = await db.select(db.exams).get().then((list) => list.length);
    return examCount == 0;
  }
}
