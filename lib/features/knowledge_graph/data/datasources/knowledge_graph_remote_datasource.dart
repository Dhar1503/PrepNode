/// Knowledge Graph Remote Data Source
/// Handles all API calls for knowledge graph data
library;

import 'package:prepnode/core/network/api_client.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/models/api_response.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/exam.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/subject.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/topic.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/topic_detail.dart';

class KnowledgeGraphRemoteDataSource {
  final ApiClient _apiClient;

  KnowledgeGraphRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get exams
  Future<List<Exam>> getExams() async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      ApiConstants.exams,
    );

    final examsList = response.data!;

    return examsList
        .map((examData) => Exam(
              id: examData['id'] as String,
              name: examData['name'] as String,
              description: examData['description'] as String?,
              conductingBody: examData['conductingBody'] as String?,
              comingSoon: examData['comingSoon'] as bool? ?? false,
            ))
        .toList();
  }

  /// Get subjects for an exam
  Future<List<Subject>> getSubjects({
    required String examId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.exams}/$examId${ApiConstants.subjects}',
    );

    final subjectsList = response.data!;

    return subjectsList
        .map((subjectData) => Subject(
              id: subjectData['id'] as String,
              examId: subjectData['examId'] as String,
              name: subjectData['subjectName'] as String,
              importanceWeight: (subjectData['importanceWeight'] as num).toDouble(),
            ))
        .toList();
  }

  /// Get topics for a subject
  Future<List<Topic>> getTopics({
    required String subjectId,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      '${ApiConstants.subjects}/$subjectId${ApiConstants.topics}',
    );

    final topicsList = response.data!;

    return topicsList
        .map((topicData) => Topic(
              id: topicData['id'] as String,
              subjectId: topicData['subjectId'] as String,
              parentTopicId: topicData['parentTopicId'] as String?,
              name: topicData['topicName'] as String,
              difficulty: topicData['difficulty'] as String?,
              importanceScore: (topicData['importanceScore'] as num).toDouble(),
            ))
        .toList();
  }

  /// Get topic detail
  Future<TopicDetail> getTopicDetail({
    required String topicId,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.topics}/$topicId',
    );

    final topicData = response.data!;
    final data = topicData['data'] as Map<String, dynamic>;

    final topic = Topic(
      id: data['id'] as String,
      subjectId: data['subjectId'] as String,
      parentTopicId: data['parentTopicId'] as String?,
      name: data['topicName'] as String,
      difficulty: data['difficulty'] as String?,
      importanceScore: (data['importanceScore'] as num).toDouble(),
    );

    final node = GraphNode(
      id: topic.id,
      name: topic.name,
      type: NodeType.topic,
      masteryState: _mapMasteryState(data['masteryPercentage'] as num?),
      masteryPercentage: (data['masteryPercentage'] as num?)?.toDouble() ?? 0.0,
      estimatedStudyMinutes: data['estimatedStudyMinutes'] as int? ?? 60,
      difficulty: _mapDifficulty(topic.difficulty),
      importanceScore: topic.importanceScore,
      parentId: topic.parentTopicId,
    );

    final prerequisites = (data['prerequisites'] as List<dynamic>?)
            ?.map((p) => TopicReference(
                  topicId: p['topicId'] as String,
                  topicName: p['topicName'] as String,
                  relationshipDescription: p['relationshipDescription'] as String?,
                  masteryState: _mapMasteryState(p['masteryPercentage'] as num?),
                ))
            .toList() ??
        [];

    final relatedTopics = (data['relatedTopics'] as List<dynamic>?)
            ?.map((r) => TopicReference(
                  topicId: r['topicId'] as String,
                  topicName: r['topicName'] as String,
                  relationshipDescription: r['relationshipDescription'] as String?,
                  masteryState: _mapMasteryState(r['masteryPercentage'] as num?),
                ))
            .toList() ??
        [];

    final nextTopics = (data['nextTopics'] as List<dynamic>?)
            ?.map((n) => TopicReference(
                  topicId: n['topicId'] as String,
                  topicName: n['topicName'] as String,
                  relationshipDescription: n['relationshipDescription'] as String?,
                  masteryState: _mapMasteryState(n['masteryPercentage'] as num?),
                ))
            .toList() ??
        [];

    return TopicDetail(
      node: node,
      description: data['description'] as String? ?? '',
      prerequisites: prerequisites,
      relatedTopics: relatedTopics,
      nextTopics: nextTopics,
      pyqCount: data['pyqCount'] as int? ?? 0,
      resourceCount: data['resourceCount'] as int? ?? 0,
      learningPathRecommendation: data['learningPathRecommendation'] as String?,
    );
  }

  /// Get graph data for a topic
  Future<GraphData> getTopicGraph({
    required String topicId,
    int radius = 1,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.topics}/$topicId${ApiConstants.graph}?radius=$radius',
    );

    final graphData = response.data!;
    final data = graphData['data'] as Map<String, dynamic>;

    final nodesData = data['nodes'] as List<dynamic>;
    final edgesData = data['edges'] as List<dynamic>;

    final nodes = nodesData
        .map((nodeData) => GraphNode(
              id: nodeData['id'] as String,
              name: nodeData['name'] as String,
              type: _mapNodeType(nodeData['type'] as String),
              masteryState: _mapMasteryState(nodeData['masteryPercentage'] as num?),
              masteryPercentage: (nodeData['masteryPercentage'] as num?)?.toDouble() ?? 0.0,
              estimatedStudyMinutes: nodeData['estimatedStudyMinutes'] as int? ?? 60,
              difficulty: _mapDifficulty(nodeData['difficulty'] as String?),
              importanceScore: (nodeData['importanceScore'] as num?)?.toDouble() ?? 0.5,
              parentId: nodeData['parentId'] as String?,
            ))
        .toList();

    final edges = edgesData
        .map((edgeData) => GraphEdge(
              id: edgeData['id'] as String,
              sourceNodeId: edgeData['sourceNodeId'] as String,
              targetNodeId: edgeData['targetNodeId'] as String,
              type: _mapEdgeType(edgeData['type'] as String),
              weight: (edgeData['weight'] as num?)?.toDouble() ?? 1.0,
            ))
        .toList();

    return GraphData(
      nodes: nodes,
      edges: edges,
      scopeTopicId: topicId,
      radius: radius,
    );
  }

  /// Search topics
  Future<List<GraphNode>> searchTopics({
    required String query,
    String? subjectId,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (subjectId != null) {
      queryParams['subjectId'] = subjectId;
    }

    final response = await _apiClient.get<ApiResponse<List<Map<String, dynamic>>>>(
      ApiConstants.searchTopics,
      queryParameters: queryParams,
    );

    final resultsList = response.data!;

    return resultsList
        .map((resultData) => GraphNode(
              id: resultData['id'] as String,
              name: resultData['name'] as String,
              type: _mapNodeType(resultData['type'] as String),
              masteryState: _mapMasteryState(resultData['masteryPercentage'] as num?),
              masteryPercentage: (resultData['masteryPercentage'] as num?)?.toDouble() ?? 0.0,
              estimatedStudyMinutes: resultData['estimatedStudyMinutes'] as int? ?? 60,
              difficulty: _mapDifficulty(resultData['difficulty'] as String?),
              importanceScore: (resultData['importanceScore'] as num?)?.toDouble() ?? 0.5,
              parentId: resultData['parentId'] as String?,
            ))
        .toList();
  }

  /// Get learning path recommendation
  Future<List<String>> getLearningPath({
    required String topicId,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.topics}/$topicId${ApiConstants.learningPath}',
    );

    final pathData = response.data!;
    final data = pathData['data'] as Map<String, dynamic>;

    final path = (data['path'] as List<dynamic>)
        .map((topicId) => topicId as String)
        .toList();

    return path;
  }

  // Helper methods for mapping

  MasteryState _mapMasteryState(num? percentage) {
    if (percentage == null) return MasteryState.notStarted;
    final p = percentage.toDouble();
    if (p >= 0.8) return MasteryState.mastered;
    if (p >= 0.5) return MasteryState.inProgress;
    if (p > 0) return MasteryState.inProgress;
    return MasteryState.notStarted;
  }

  DifficultyLevel _mapDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.intermediate;
    }
  }

  NodeType _mapNodeType(String type) {
    switch (type.toLowerCase()) {
      case 'exam':
        return NodeType.exam;
      case 'subject':
        return NodeType.subject;
      case 'topic':
        return NodeType.topic;
      default:
        return NodeType.topic;
    }
  }

  EdgeType _mapEdgeType(String type) {
    switch (type.toLowerCase()) {
      case 'prerequisite':
        return EdgeType.prerequisite;
      case 'recommended_next':
        return EdgeType.recommendedNext;
      case 'related_topic':
        return EdgeType.relatedTopic;
      default:
        return EdgeType.relatedTopic;
    }
  }
}
