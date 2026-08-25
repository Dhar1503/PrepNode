/// Knowledge Graph Local Data Source
/// Handles local storage and caching for knowledge graph data
library;

import 'package:drift/drift.dart';
import 'package:prepgraph/core/data/database/database.dart' hide Exam, Subject, Topic;
import 'package:prepgraph/core/data/database/database_service.dart';
import 'package:prepgraph/core/data/dtos/content_dto.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/exam.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/subject.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic_detail.dart';

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
