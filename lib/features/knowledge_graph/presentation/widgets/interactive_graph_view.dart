import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';

/// Interactive Graph View Widget
/// Custom-painted interactive graph with zoom and pan
class InteractiveGraphView extends StatefulWidget {
  final GraphData graphData;
  final Function(GraphNode)? onNodeTap;
  final double initialScale;

  const InteractiveGraphView({
    super.key,
    required this.graphData,
    this.onNodeTap,
    this.initialScale = 1.0,
  });

  @override
  State<InteractiveGraphView> createState() => InteractiveGraphViewState();
}

/// Public so a parent screen can hold a [GlobalKey] to this state and drive
/// zoom in/out/reset imperatively (e.g. from AppBar actions), reusing the
/// same scale/offset state the pinch-zoom and pan gestures already update.
class InteractiveGraphViewState extends State<InteractiveGraphView> {
  static const double _minScale = 0.5;
  static const double _maxScale = 3.0;

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset? _startPanOffset;
  double? _startScale;
  Offset? _lastFocalPoint;
  double _gestureMovement = 0.0;
  double _gestureScaleDelta = 0.0;

  final Map<String, Offset> _nodePositions = {};
  final double _nodeSize = 60.0;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale;
    // Positions are computed in build() via LayoutBuilder, where the real
    // canvas size is known — there is no meaningful size to lay out against
    // here.
  }

  /// Lays nodes out inside [canvasSize] rather than a hardcoded 600×400.
  ///
  /// The old version centred on (300, 200) with radius 150 while the canvas
  /// was clipped to the container's real width (~344dp on this phone), so
  /// most nodes landed outside the visible area and the graph looked empty.
  /// Positions are now derived from the actual constraints, with the radius
  /// scaled to whichever dimension is smaller so nothing spills out.
  void _calculateNodePositions(Size canvasSize) {
    _nodePositions.clear();
    if (widget.graphData.isEmpty) return;
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;

    final nodes = widget.graphData.nodes;
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    // Leave a node-radius of margin so circles/labels aren't clipped at the
    // edge, and never go negative on a very small canvas.
    final maxRadius = (math.min(canvasSize.width, canvasSize.height) / 2) - _nodeSize;
    final radius = maxRadius.clamp(0.0, double.infinity);

    // A single node belongs in the middle, not orbiting an empty centre.
    if (nodes.length == 1) {
      _nodePositions[nodes.first.id] = Offset(centerX, centerY);
      return;
    }

    for (int i = 0; i < nodes.length; i++) {
      final angle = (2 * math.pi * i) / nodes.length;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      _nodePositions[nodes[i].id] = Offset(x, y);
    }
  }

  void zoomIn() {
    setState(() {
      _scale = (_scale * 1.25).clamp(_minScale, _maxScale);
    });
  }

  void zoomOut() {
    setState(() {
      _scale = (_scale / 1.25).clamp(_minScale, _maxScale);
    });
  }

  void resetView() {
    setState(() {
      _scale = widget.initialScale;
      _offset = Offset.zero;
    });
  }

  void _handleTap(Offset screenPoint) {
    // Undo the Transform applied to the painted canvas to get the point in
    // graph space, then hit-test against the node positions used to paint.
    final graphPoint = (screenPoint - _offset) / _scale;

    for (final entry in _nodePositions.entries) {
      final node = widget.graphData.nodes.firstWhere((n) => n.id == entry.key);
      if ((entry.value - graphPoint).distance <= _radiusForNode(node)) {
        widget.onNodeTap?.call(node);
        return;
      }
    }
  }

  /// Node radius scaled by real PYQ importance (see
  /// KnowledgeGraphLocalDataSource.getTopics, which now derives
  /// importanceScore from actual past-year question counts rather than a
  /// hand-typed placeholder) — a topic that actually appears often on the
  /// exam should visually read as more important, not just more "difficult."
  /// Scaled to 70%-130% of the base size so low-importance nodes stay
  /// legible and high-importance ones don't overlap their neighbors.
  double _radiusForNode(GraphNode node) {
    final importance = (node.importanceScore ?? 0.0).clamp(0.0, 1.0);
    return (_nodeSize / 2) * (0.7 + importance * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _startPanOffset = _offset;
        _startScale = _scale;
        _lastFocalPoint = details.localFocalPoint;
        _gestureMovement = 0.0;
        _gestureScaleDelta = 0.0;
      },
      onScaleUpdate: (details) {
        _gestureMovement += details.focalPointDelta.distance;
        _gestureScaleDelta = (details.scale - 1.0).abs();
        _lastFocalPoint = details.localFocalPoint;
        setState(() {
          _scale = ((_startScale ?? 1.0) * details.scale).clamp(_minScale, _maxScale);
          _offset = _startPanOffset! + details.focalPointDelta;
        });
      },
      onScaleEnd: (details) {
        // A gesture that barely moved and barely scaled is a tap rather
        // than a pan/pinch, so resolve node selection from it here instead
        // of adding a separate, competing tap recognizer.
        if (_gestureMovement < 8.0 && _gestureScaleDelta < 0.05 && _lastFocalPoint != null) {
          _handleTap(_lastFocalPoint!);
        }
        _startPanOffset = null;
        _startScale = null;
        _lastFocalPoint = null;
      },
      // LayoutBuilder so the graph is laid out for the space it actually
      // has. Previously the canvas was a fixed 600×400 inside a ~344dp-wide
      // container, pushing most nodes outside the clip rect.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : 600,
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400,
          );
          _calculateNodePositions(canvasSize);

          return ClipRect(
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(0, 3, _offset.dx)
                ..setEntry(1, 3, _offset.dy)
                ..setEntry(0, 0, _scale)
                ..setEntry(1, 1, _scale),
              child: CustomPaint(
                size: canvasSize,
                painter: _GraphPainter(
                  graphData: widget.graphData,
                  nodePositions: _nodePositions,
                  nodeSize: _nodeSize,
                  onNodeTap: widget.onNodeTap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final GraphData graphData;
  final Map<String, Offset> nodePositions;
  final double nodeSize;
  final Function(GraphNode)? onNodeTap;

  _GraphPainter({
    required this.graphData,
    required this.nodePositions,
    required this.nodeSize,
    this.onNodeTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges first (behind nodes)
    for (final edge in graphData.edges) {
      _drawEdge(canvas, edge);
    }

    // Draw nodes on top
    for (final node in graphData.nodes) {
      _drawNode(canvas, node);
    }
  }

  double _radiusForNode(GraphNode node) {
    final importance = (node.importanceScore ?? 0.0).clamp(0.0, 1.0);
    return (nodeSize / 2) * (0.7 + importance * 0.6);
  }

  void _drawEdge(Canvas canvas, GraphEdge edge) {
    final sourcePos = nodePositions[edge.sourceNodeId];
    final targetPos = nodePositions[edge.targetNodeId];

    if (sourcePos == null || targetPos == null) return;

    final paint = Paint()
      ..color = _getEdgeColor(edge.type)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(sourcePos, targetPos, paint);

    // Draw arrow for directed edges
    if (edge.type == EdgeType.prerequisite || edge.type == EdgeType.recommendedNext) {
      final targetNode = graphData.nodes.firstWhere(
        (n) => n.id == edge.targetNodeId,
        orElse: () => graphData.nodes.first,
      );
      _drawArrow(canvas, sourcePos, targetPos, paint.color, _radiusForNode(targetNode));
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, double targetRadius) {
    final direction = (end - start);
    final angle = direction.direction;
    final arrowSize = 10.0;

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowEnd = end - Offset.fromDirection(angle) * targetRadius;
    final arrowPoint1 = arrowEnd - Offset.fromDirection(angle + 2.6) * arrowSize;
    final arrowPoint2 = arrowEnd - Offset.fromDirection(angle - 2.6) * arrowSize;

    final path = Path()
      ..moveTo(arrowEnd.dx, arrowEnd.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawNode(Canvas canvas, GraphNode node) {
    final position = nodePositions[node.id];
    if (position == null) return;

    final color = _getNodeColor(node.masteryState);
    final radius = _radiusForNode(node);

    // Draw node circle
    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, nodePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, radius, borderPaint);

    // Draw node label (simplified - in production would use TextPainter)
    final labelPaint = Paint()
      ..color = AppColors.lightOnPrimary
      ..style = PaintingStyle.fill;

    // Draw simplified label as a small dot
    canvas.drawCircle(position, 4, labelPaint);
  }

  Color _getNodeColor(MasteryState state) {
    switch (state) {
      case MasteryState.mastered:
        return AppColors.sage500;
      case MasteryState.inProgress:
        return AppColors.marigold500;
      case MasteryState.notStarted:
        return AppColors.graphite700;
      case MasteryState.needsRevision:
        return AppColors.marigold500;
    }
  }

  Color _getEdgeColor(EdgeType type) {
    switch (type) {
      case EdgeType.prerequisite:
        return AppColors.ink900;
      case EdgeType.relatedTopic:
        return AppColors.graphite700;
      case EdgeType.recommendedNext:
        return AppColors.marigold500;
      case EdgeType.parentChild:
        return AppColors.sage500;
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) {
    return oldDelegate.graphData != graphData ||
        oldDelegate.nodePositions != nodePositions;
  }
}
