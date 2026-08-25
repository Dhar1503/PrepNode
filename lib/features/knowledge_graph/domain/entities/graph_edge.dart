/// Graph Edge Entity
/// Represents a relationship between two nodes in the knowledge graph
class GraphEdge {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final EdgeType type;
  final double? weight;

  const GraphEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.type,
    this.weight,
  });

  GraphEdge copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    EdgeType? type,
    double? weight,
  }) {
    return GraphEdge(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
    );
  }
}

enum EdgeType {
  prerequisite,
  relatedTopic,
  recommendedNext,
  parentChild,
}
