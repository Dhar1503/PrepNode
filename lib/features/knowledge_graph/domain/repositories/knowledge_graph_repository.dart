import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/topic_detail.dart';

/// Knowledge Graph Repository Interface
/// Abstract contract for knowledge graph data operations
abstract class KnowledgeGraphRepository {
  /// Get subjects for an exam
  Future<Either<Failure, List<GraphNode>>> getSubjects({
    required String examId,
  });

  /// Get topics for a subject
  Future<Either<Failure, List<GraphNode>>> getTopics({
    required String subjectId,
  });

  /// Get topic detail. [userId], when supplied, personalizes the node's
  /// mastery state/percentage.
  Future<Either<Failure, TopicDetail>> getTopicDetail({
    required String topicId,
    String? userId,
  });

  /// Get graph data for a topic
  Future<Either<Failure, GraphData>> getTopicGraph({
    required String topicId,
    int radius = 1,
  });

  /// Search topics
  Future<Either<Failure, List<GraphNode>>> searchTopics({
    required String query,
    String? subjectId,
  });

  /// Get learning path recommendation
  Future<Either<Failure, List<String>>> getLearningPath({
    required String topicId,
  });
}
