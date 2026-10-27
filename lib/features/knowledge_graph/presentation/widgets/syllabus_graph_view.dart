import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_edge.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';

/// The interactive syllabus knowledge graph.
///
/// Everything drawn here comes from [GraphData], which is built from Drift —
/// there is no hardcoded node list. The layout is radial: the exam sits at
/// the centre, its subjects fan out around it, and each subject's topics
/// (then subtopics) occupy that subject's angular slice, so a branch never
/// crosses into a neighbour's space.
///
/// Zoom and pan come from [InteractiveViewer]. The tap handler is placed
/// *inside* the viewer, so hit-test coordinates arrive already in canvas
/// space and no inverse transform maths is needed.
class SyllabusGraphView extends StatefulWidget {
  final GraphData graph;
  final ValueChanged<GraphNode>? onNodeSelected;
  final ValueChanged<GraphNode>? onNodeOpened;

  const SyllabusGraphView({
    super.key,
    required this.graph,
    this.onNodeSelected,
    this.onNodeOpened,
  });

  @override
  State<SyllabusGraphView> createState() => SyllabusGraphViewState();
}

class SyllabusGraphViewState extends State<SyllabusGraphView> {
  /// The canvas is deliberately larger than any phone screen: the graph is
  /// laid out at a comfortable size and the user pans/zooms around it,
  /// rather than the layout being squeezed to fit and overlapping itself.
  static const double _canvasSize = 2200;
  static const Offset _centre = Offset(_canvasSize / 2, _canvasSize / 2);
  static const List<double> _ringRadius = [0, 300, 620, 860];

  final TransformationController _controller = TransformationController();

  /// Nodes whose children are currently drawn. Subjects start expanded so
  /// the graph opens as a real graph rather than a single dot; subtopics
  /// stay collapsed until asked for, which keeps the first view readable.
  final Set<String> _expanded = {};
  String? _selectedId;

  Map<String, GraphNode> _nodesById = {};
  Map<String, List<String>> _childrenOf = {};
  String? _rootId;

  /// Layout output, rebuilt whenever the data or the expansion set changes.
  Map<String, Offset> _positions = {};
  Map<String, double> _radii = {};
  Map<String, Color> _subjectColour = {};

  @override
  void initState() {
    super.initState();
    _indexGraph();
    _layout();
    // Start centred on the exam node instead of the canvas origin.
    WidgetsBinding.instance.addPostFrameCallback((_) => resetView());
  }

  @override
  void didUpdateWidget(covariant SyllabusGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mastery changes arrive as a new GraphData; re-index and re-lay-out so
    // colours and node sizes follow the user's latest practice.
    if (!identical(oldWidget.graph, widget.graph)) {
      _indexGraph();
      _layout();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _indexGraph() {
    _nodesById = {for (final node in widget.graph.nodes) node.id: node};

    final children = <String, List<String>>{};
    for (final edge in widget.graph.edges) {
      if (edge.type != EdgeType.parentChild) continue;
      children.putIfAbsent(edge.sourceNodeId, () => []).add(edge.targetNodeId);
    }
    // Stable, meaningful ordering: the heaviest part of the syllabus first,
    // so the graph does not reshuffle between rebuilds.
    for (final list in children.values) {
      list.sort((a, b) {
        final byImportance = (_nodesById[b]?.importanceScore ?? 0)
            .compareTo(_nodesById[a]?.importanceScore ?? 0);
        if (byImportance != 0) return byImportance;
        return (_nodesById[a]?.name ?? a).compareTo(_nodesById[b]?.name ?? b);
      });
    }
    _childrenOf = children;

    GraphNode? root;
    for (final node in widget.graph.nodes) {
      if (node.type == NodeType.exam) {
        root = node;
        break;
      }
    }
    _rootId = root?.id;

    _expanded
      ..clear()
      ..addAll([
        if (_rootId != null) _rootId!,
        // Subjects expanded by default -> topics visible on first open.
        ...widget.graph.nodes
            .where((n) => n.type == NodeType.subject)
            .map((n) => n.id),
      ]);

    _assignSubjectColours();
  }

  /// One hue per subject, so a whole branch reads as belonging together.
  void _assignSubjectColours() {
    const palette = [
      Color(0xFF3A5A9B), // indigo
      Color(0xFF5C8A72), // sage
      Color(0xFFB07A2E), // marigold, darkened for contrast on paper
      Color(0xFF7A4E7E), // plum
      Color(0xFF2F7F86), // teal
      Color(0xFF9B5340), // clay
    ];

    final subjects = widget.graph.nodes
        .where((n) => n.type == NodeType.subject)
        .map((n) => n.id)
        .toList();

    _subjectColour = {
      for (var i = 0; i < subjects.length; i++)
        subjects[i]: palette[i % palette.length],
    };
  }

  /// Walks up to the subject a node belongs to, so topics and subtopics
  /// inherit their subject's colour.
  Color _colourForBranch(String nodeId) {
    var current = nodeId;
    for (var guard = 0; guard < 8; guard++) {
      if (_subjectColour.containsKey(current)) return _subjectColour[current]!;
      final parent = _nodesById[current]?.parentId;
      if (parent == null) break;
      current = parent;
    }
    return AppColors.ink900;
  }

  bool _hasChildren(String id) => (_childrenOf[id] ?? const []).isNotEmpty;

  /// Radial layout. Each node is handed an angular sector; it sits in the
  /// middle of that sector at the radius for its depth, and divides the
  /// sector among its visible children. Sectors never overlap, so branches
  /// stay visually separate however many topics a subject has.
  void _layout() {
    final positions = <String, Offset>{};
    final radii = <String, double>{};

    final rootId = _rootId;
    if (rootId == null) {
      setState(() {
        _positions = positions;
        _radii = radii;
      });
      return;
    }

    positions[rootId] = _centre;
    radii[rootId] = _radiusForNode(_nodesById[rootId]!);

    void place(String parentId, double startAngle, double sweep, int depth) {
      if (!_expanded.contains(parentId)) return;
      final children = _childrenOf[parentId] ?? const <String>[];
      if (children.isEmpty) return;

      final ringIndex = math.min(depth, _ringRadius.length - 1);
      final ring = _ringRadius[ringIndex];
      final childSweep = sweep / children.length;

      for (var i = 0; i < children.length; i++) {
        final childId = children[i];
        final node = _nodesById[childId];
        if (node == null) continue;

        final angle = startAngle + childSweep * (i + 0.5);
        positions[childId] = Offset(
          _centre.dx + ring * math.cos(angle),
          _centre.dy + ring * math.sin(angle),
        );
        radii[childId] = _radiusForNode(node);

        place(childId, startAngle + childSweep * i, childSweep, depth + 1);
      }
    }

    // Start at -90 degrees so the first subject sits at the top.
    place(rootId, -math.pi / 2, math.pi * 2, 1);

    setState(() {
      _positions = positions;
      _radii = radii;
    });
  }

  /// Node size encodes two things at once: what kind of node it is, and how
  /// far the user has got with it. A mastered topic is visibly bigger than
  /// an untouched one.
  double _radiusForNode(GraphNode node) {
    final base = switch (node.type) {
      NodeType.exam => 46.0,
      NodeType.subject => 34.0,
      NodeType.unit => 26.0,
      NodeType.topic => 24.0,
      NodeType.subtopic => 17.0,
    };
    final masteryBonus = (node.masteryPercentage.clamp(0, 100) / 100) * 8;
    return base + masteryBonus;
  }

  /// The chain of ids from the root down to [nodeId] — drawn highlighted so
  /// the user can see the learning path to whatever they selected.
  Set<String> _pathToRoot(String? nodeId) {
    if (nodeId == null) return {};
    final path = <String>{};
    var current = nodeId;
    for (var guard = 0; guard < 12; guard++) {
      path.add(current);
      final parent = _nodesById[current]?.parentId;
      if (parent == null || !_nodesById.containsKey(parent)) break;
      current = parent;
    }
    return path;
  }

  void _handleTapDown(TapDownDetails details) {
    final hit = _nodeAt(details.localPosition);
    if (hit == null) return;

    setState(() {
      _selectedId = hit;
      // Tapping a node with children toggles that branch open or shut.
      if (_hasChildren(hit)) {
        if (_expanded.contains(hit)) {
          _collapseSubtree(hit);
        } else {
          _expanded.add(hit);
        }
      }
    });
    _layout();

    final node = _nodesById[hit];
    if (node != null) widget.onNodeSelected?.call(node);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final hit = _nodeAt(details.localPosition);
    if (hit == null) return;
    final node = _nodesById[hit];
    // Only leaf-level content is worth opening a detail screen for.
    if (node != null &&
        (node.type == NodeType.topic || node.type == NodeType.subtopic)) {
      widget.onNodeOpened?.call(node);
    }
  }

  /// Collapsing hides descendants too, otherwise re-expanding would restore
  /// a branch the user had already closed several levels down.
  void _collapseSubtree(String id) {
    _expanded.remove(id);
    for (final child in _childrenOf[id] ?? const <String>[]) {
      _collapseSubtree(child);
    }
  }

  String? _nodeAt(Offset point) {
    String? best;
    var bestDistance = double.infinity;
    for (final entry in _positions.entries) {
      final radius = _radii[entry.key] ?? 20;
      final distance = (entry.value - point).distance;
      // A small margin makes small subtopic nodes comfortably tappable.
      if (distance <= radius + 8 && distance < bestDistance) {
        best = entry.key;
        bestDistance = distance;
      }
    }
    return best;
  }

  void zoomIn() => _scaleBy(1.25);

  void zoomOut() => _scaleBy(0.8);

  void _scaleBy(double factor) {
    final current = _controller.value.getMaxScaleOnAxis();
    _applyView((current * factor).clamp(0.2, 2.5));
  }

  Size _viewportSize = const Size(400, 600);

  /// Frames the exam node in the middle of the viewport at a scale that
  /// shows the subject ring.
  void resetView() => _applyView(0.42);

  /// Builds the scale-then-centre matrix by hand rather than via
  /// `Matrix4.translate`/`scale`, whose signatures have shifted between
  /// vector_math versions.
  void _applyView(double scale) {
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(2, 2, scale)
      ..setEntry(0, 3, -_centre.dx * scale + _viewportSize.width / 2)
      ..setEntry(1, 3, -_centre.dy * scale + _viewportSize.height / 2);
  }

  /// Opens every branch, including subtopics.
  void expandAll() {
    setState(() {
      _expanded.addAll(_nodesById.keys.where(_hasChildren));
    });
    _layout();
  }

  /// Back to the default view: subjects open, subtopics closed.
  void collapseToSubjects() {
    setState(() {
      _expanded
        ..clear()
        ..addAll([
          if (_rootId != null) _rootId!,
          ..._nodesById.values
              .where((n) => n.type == NodeType.subject)
              .map((n) => n.id),
        ]);
      _selectedId = null;
    });
    _layout();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.graph.nodes.isEmpty) {
      return const Center(child: Text('No syllabus data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        return InteractiveViewer(
          transformationController: _controller,
          minScale: 0.2,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(400),
          constrained: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onDoubleTapDown: _handleDoubleTapDown,
            // Required for onDoubleTapDown to fire.
            onDoubleTap: () {},
            child: CustomPaint(
              size: const Size(_canvasSize, _canvasSize),
              painter: _SyllabusGraphPainter(
                nodesById: _nodesById,
                childrenOf: _childrenOf,
                positions: _positions,
                radii: _radii,
                expanded: _expanded,
                selectedId: _selectedId,
                highlightedPath: _pathToRoot(_selectedId),
                colourForBranch: _colourForBranch,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SyllabusGraphPainter extends CustomPainter {
  final Map<String, GraphNode> nodesById;
  final Map<String, List<String>> childrenOf;
  final Map<String, Offset> positions;
  final Map<String, double> radii;
  final Set<String> expanded;
  final String? selectedId;
  final Set<String> highlightedPath;
  final Color Function(String) colourForBranch;

  _SyllabusGraphPainter({
    required this.nodesById,
    required this.childrenOf,
    required this.positions,
    required this.radii,
    required this.expanded,
    required this.selectedId,
    required this.highlightedPath,
    required this.colourForBranch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintEdges(canvas);
    _paintNodes(canvas);
  }

  void _paintEdges(Canvas canvas) {
    for (final entry in childrenOf.entries) {
      final from = positions[entry.key];
      if (from == null) continue;

      for (final childId in entry.value) {
        final to = positions[childId];
        if (to == null) continue;

        final onPath = highlightedPath.contains(entry.key) &&
            highlightedPath.contains(childId);
        final colour = colourForBranch(childId);

        final paint = Paint()
          ..color = onPath
              ? colour
              : colour.withValues(alpha: 0.28)
          ..strokeWidth = onPath ? 5.0 : 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        // A gentle curve rather than a straight spoke, so edges leaving the
        // same parent stay distinguishable where they bunch up.
        final control = Offset(
          (from.dx + to.dx) / 2 + (to.dy - from.dy) * 0.08,
          (from.dy + to.dy) / 2 - (to.dx - from.dx) * 0.08,
        );
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _paintNodes(Canvas canvas) {
    for (final entry in positions.entries) {
      final node = nodesById[entry.key];
      if (node == null) continue;

      final centre = entry.value;
      final radius = radii[entry.key] ?? 20;
      final branchColour = colourForBranch(entry.key);
      final isSelected = entry.key == selectedId;

      // Fill carries mastery, ring carries subject identity — so a node
      // says both "this is Aptitude" and "you are weak here" at once.
      final fill = switch (node.masteryState) {
        MasteryState.mastered => const Color(0xFF3F7D58),
        MasteryState.needsRevision => const Color(0xFFB4552F),
        MasteryState.inProgress => branchColour,
        MasteryState.notStarted => Colors.white,
      };

      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = isSelected ? AppColors.ink900 : branchColour
          ..strokeWidth = isSelected ? 5 : 2.5
          ..style = PaintingStyle.stroke,
      );

      // A collapsed node with children gets a "+" so it is obvious there is
      // more of the syllabus underneath it.
      if ((childrenOf[entry.key] ?? const []).isNotEmpty &&
          !expanded.contains(entry.key)) {
        _paintExpandBadge(canvas, centre, radius, branchColour);
      }

      _paintLabel(canvas, node, centre, radius, fill);
    }
  }

  void _paintExpandBadge(
      Canvas canvas, Offset centre, double radius, Color colour) {
    final badgeCentre = Offset(centre.dx + radius * 0.72, centre.dy - radius * 0.72);
    const badgeRadius = 9.0;

    canvas.drawCircle(
      badgeCentre,
      badgeRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      badgeCentre,
      badgeRadius,
      Paint()
        ..color = colour
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final tick = Paint()
      ..color = colour
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(badgeCentre.dx - 4, badgeCentre.dy),
      Offset(badgeCentre.dx + 4, badgeCentre.dy),
      tick,
    );
    canvas.drawLine(
      Offset(badgeCentre.dx, badgeCentre.dy - 4),
      Offset(badgeCentre.dx, badgeCentre.dy + 4),
      tick,
    );
  }

  void _paintLabel(
    Canvas canvas,
    GraphNode node,
    Offset centre,
    double radius,
    Color fill,
  ) {
    final isBigNode =
        node.type == NodeType.exam || node.type == NodeType.subject;
    // Big nodes carry their label inside; smaller ones sit under the circle
    // where there is room for it.
    final insideNode = isBigNode && fill != Colors.white;

    final painter = TextPainter(
      text: TextSpan(
        text: node.name,
        style: GoogleFonts.inter(
          fontSize: switch (node.type) {
            NodeType.exam => 20,
            NodeType.subject => 17,
            NodeType.unit => 15,
            NodeType.topic => 14,
            NodeType.subtopic => 12,
          },
          fontWeight: isBigNode ? FontWeight.w700 : FontWeight.w600,
          color: insideNode ? Colors.white : AppColors.ink900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: math.max(radius * 4.5, 130));

    final offset = insideNode
        ? Offset(centre.dx - painter.width / 2, centre.dy - painter.height / 2)
        : Offset(centre.dx - painter.width / 2, centre.dy + radius + 6);

    if (!insideNode) {
      // Paper-coloured plate behind outside labels so they stay readable
      // where they cross an edge.
      final plate = Rect.fromLTWH(
        offset.dx - 5,
        offset.dy - 2,
        painter.width + 10,
        painter.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(plate, const Radius.circular(5)),
        Paint()..color = AppColors.paper50.withValues(alpha: 0.88),
      );
    }

    painter.paint(canvas, offset);
  }

  /// Always repaints. Every field here is a mutable collection rebuilt in
  /// place by the parent state, so comparing them against the previous
  /// delegate compares each object with itself and always reports "no
  /// change" — the bug that left the previous graph frozen on its first
  /// frame. The graph is a few dozen nodes, so unconditional repaint costs
  /// nothing measurable.
  @override
  bool shouldRepaint(covariant _SyllabusGraphPainter oldDelegate) => true;
}
