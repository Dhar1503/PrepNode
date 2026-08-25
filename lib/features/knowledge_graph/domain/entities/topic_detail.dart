import 'graph_node.dart';

/// Topic Detail Entity
/// Detailed information about a specific topic
class TopicDetail {
  final GraphNode node;
  final String description;
  final List<TopicReference> prerequisites;
  final List<TopicReference> relatedTopics;
  final List<TopicReference> nextTopics;
  final int pyqCount;
  final int resourceCount;
  final String? learningPathRecommendation;

  const TopicDetail({
    required this.node,
    required this.description,
    required this.prerequisites,
    required this.relatedTopics,
    required this.nextTopics,
    required this.pyqCount,
    required this.resourceCount,
    this.learningPathRecommendation,
  });

  TopicDetail copyWith({
    GraphNode? node,
    String? description,
    List<TopicReference>? prerequisites,
    List<TopicReference>? relatedTopics,
    List<TopicReference>? nextTopics,
    int? pyqCount,
    int? resourceCount,
    String? learningPathRecommendation,
  }) {
    return TopicDetail(
      node: node ?? this.node,
      description: description ?? this.description,
      prerequisites: prerequisites ?? this.prerequisites,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      nextTopics: nextTopics ?? this.nextTopics,
      pyqCount: pyqCount ?? this.pyqCount,
      resourceCount: resourceCount ?? this.resourceCount,
      learningPathRecommendation: learningPathRecommendation ?? this.learningPathRecommendation,
    );
  }
}

/// Topic Reference Entity
/// Reference to another topic with relationship context
class TopicReference {
  final String topicId;
  final String topicName;
  final String? relationshipDescription;
  final MasteryState? masteryState;

  const TopicReference({
    required this.topicId,
    required this.topicName,
    this.relationshipDescription,
    this.masteryState,
  });

  TopicReference copyWith({
    String? topicId,
    String? topicName,
    String? relationshipDescription,
    MasteryState? masteryState,
  }) {
    return TopicReference(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      relationshipDescription: relationshipDescription ?? this.relationshipDescription,
      masteryState: masteryState ?? this.masteryState,
    );
  }
}
