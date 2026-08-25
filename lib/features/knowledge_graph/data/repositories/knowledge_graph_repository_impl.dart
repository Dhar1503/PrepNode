import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/knowledge_graph/data/datasources/knowledge_graph_local_datasource.dart';
import 'package:prepgraph/features/knowledge_graph/data/datasources/knowledge_graph_remote_datasource.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/exam.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/subject.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic_detail.dart';
import 'package:prepgraph/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';

/// Production Knowledge Graph Repository Implementation
/// Uses remote API and local database with offline-first strategy
class KnowledgeGraphRepositoryImpl implements KnowledgeGraphRepository {
  final KnowledgeGraphRemoteDataSource _remoteDataSource;
  final KnowledgeGraphLocalDataSource _localDataSource;

  KnowledgeGraphRepositoryImpl({
    required KnowledgeGraphRemoteDataSource remoteDataSource,
    required KnowledgeGraphLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<GraphNode>>> getSubjects({
    required String examId,
  }) async {
    try {
      // Try to get from local cache first
      final cachedSubjects = await _localDataSource.getSubjects(examId);
      if (cachedSubjects.isNotEmpty) {
        // Fetch from API in background and update cache
        _fetchAndCacheSubjects(examId);
        return Right(cachedSubjects.map(_mapSubjectToGraphNode).toList());
      }

      // Fetch from API
      final subjects = await _remoteDataSource.getSubjects(examId: examId);
      
      // Cache locally
      await _localDataSource.saveSubjects(subjects);

      return Right(subjects.map(_mapSubjectToGraphNode).toList());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<GraphNode>>> getTopics({
    required String subjectId,
  }) async {
    try {
      // Try to get from local cache first
      final cachedTopics = await _localDataSource.getTopics(subjectId);
      if (cachedTopics.isNotEmpty) {
        // Fetch from API in background and update cache
        _fetchAndCacheTopics(subjectId);
        return Right(cachedTopics.map(_mapTopicToGraphNode).toList());
      }

      // Fetch from API
      final topics = await _remoteDataSource.getTopics(subjectId: subjectId);
      
      // Cache locally
      await _localDataSource.saveTopics(topics);

      return Right(topics.map(_mapTopicToGraphNode).toList());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TopicDetail>> getTopicDetail({
    required String topicId,
    String? userId,
  }) async {
    try {
      // No live backend exists for this app; build detail from the local
      // topic graph (parent/child + concept_relationships, already used by
      // getTopicGraph) plus real PYQ/resource counts and this user's
      // mastery, instead of a remote call that can never succeed.
      final topicDetail = await _localDataSource.getTopicDetailLocal(topicId, userId: userId);
      if (topicDetail == null) {
        return Left(DatabaseFailure.notFound(entity: 'Topic'));
      }

      return Right(topicDetail);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, GraphData>> getTopicGraph({
    required String topicId,
    int radius = 1,
  }) async {
    try {
      // Derive relationships from the local topic hierarchy and
      // concept_relationships table.
      final graphData = await _localDataSource.getTopicGraph(topicId, radius: radius);
      if (!graphData.isEmpty) {
        return Right(graphData);
      }

      // Topic not found locally; fall back to the remote API.
      final remoteGraphData = await _remoteDataSource.getTopicGraph(
        topicId: topicId,
        radius: radius,
      );

      return Right(remoteGraphData);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<GraphNode>>> searchTopics({
    required String query,
    String? subjectId,
  }) async {
    try {
      // Search from API
      final results = await _remoteDataSource.searchTopics(
        query: query,
        subjectId: subjectId,
      );
      
      return Right(results);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLearningPath({
    required String topicId,
  }) async {
    try {
      // Fetch from API
      final path = await _remoteDataSource.getLearningPath(topicId: topicId);
      
      return Right(path);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  // Background fetch methods
  Future<void> _fetchAndCacheSubjects(String examId) async {
    try {
      final subjects = await _remoteDataSource.getSubjects(examId: examId);
      await _localDataSource.saveSubjects(subjects);
    } catch (e) {
      // Silently fail on background refresh
    }
  }

  Future<void> _fetchAndCacheTopics(String subjectId) async {
    try {
      final topics = await _remoteDataSource.getTopics(subjectId: subjectId);
      await _localDataSource.saveTopics(topics);
    } catch (e) {
      // Silently fail on background refresh
    }
  }

  // Mapping methods
  GraphNode _mapSubjectToGraphNode(Subject subject) {
    return GraphNode(
      id: subject.id,
      name: subject.name,
      type: NodeType.subject,
      masteryState: MasteryState.notStarted,
      masteryPercentage: 0.0,
      estimatedStudyMinutes: 600,
      difficulty: DifficultyLevel.intermediate,
      importanceScore: subject.importanceWeight,
    );
  }

  GraphNode _mapTopicToGraphNode(Topic topic) {
    return GraphNode(
      id: topic.id,
      name: topic.name,
      type: NodeType.topic,
      masteryState: MasteryState.notStarted,
      masteryPercentage: 0.0,
      estimatedStudyMinutes: 60,
      difficulty: _mapDifficultyString(topic.difficulty),
      importanceScore: topic.importanceScore,
      parentId: topic.parentTopicId,
    );
  }

  DifficultyLevel _mapDifficultyString(String? difficulty) {
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

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
