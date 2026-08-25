import 'graph_edge.dart';
import 'graph_node.dart';

/// Graph Data Entity
/// Complete graph data for a subject or topic scope
class GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? scopeTopicId;
  final int radius;

  const GraphData({
    required this.nodes,
    required this.edges,
    this.scopeTopicId,
    this.radius = 1,
  });

  GraphData copyWith({
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    String? scopeTopicId,
    int? radius,
  }) {
    return GraphData(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      scopeTopicId: scopeTopicId ?? this.scopeTopicId,
      radius: radius ?? this.radius,
    );
  }

  bool get isEmpty => nodes.isEmpty;
}
