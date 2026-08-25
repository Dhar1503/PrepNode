import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_data.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/widgets/breadcrumb_navigation.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/widgets/interactive_graph_view.dart';

/// Graph View Screen (S3.4)
/// Full interactive knowledge graph with zoom, pan, and node tap
class GraphViewScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicName;

  const GraphViewScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  ConsumerState<GraphViewScreen> createState() => _GraphViewState();
}

class _GraphViewState extends ConsumerState<GraphViewScreen> {
  final _graphViewKey = GlobalKey<InteractiveGraphViewState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadGraphData);
  }

  void _loadGraphData() {
    ref.read(graphDataProvider.notifier).loadGraphData(topicId: widget.topicId);
  }

  void _handleNodeTap(GraphNode node) {
    context.push('/learn/topic/${node.id}');
  }

  @override
  Widget build(BuildContext context) {
    final graphDataState = ref.watch(graphDataProvider);
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Knowledge Graph',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _graphViewKey.currentState?.zoomIn(),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _graphViewKey.currentState?.zoomOut(),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: () => _graphViewKey.currentState?.resetView(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Derived from the graph's own centre node instead of the old
          // hardcoded "Indian Polity / Fundamental Rights", which showed
          // those labels no matter which topic you opened.
          BreadcrumbNavigation(
            items: [
              const BreadcrumbItem(id: 'home', label: 'Knowledge Graph'),
              BreadcrumbItem(
                id: 'topic',
                label: _centreTopicLabel(graphDataState.graphData),
              ),
              const BreadcrumbItem(id: 'graph', label: 'Graph View'),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildGraphLegend(),
          const SizedBox(height: AppConstants.spaceSm),
          Expanded(
            child: _buildGraphView(graphDataState.isLoading, graphDataState.graphData),
          ),
        ],
      ),
    );
  }

  /// Name of the topic this graph is centred on. Falls back to a neutral
  /// label rather than a wrong topic name while data is still loading.
  String _centreTopicLabel(GraphData? graphData) {
    if (graphData == null || graphData.nodes.isEmpty) return 'Topic';
    final centre = graphData.nodes.firstWhere(
      (n) => n.id == widget.topicId,
      orElse: () => graphData.nodes.first,
    );
    return centre.name;
  }

  Widget _buildGraphLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.lightOutline),
      ),
      // Wrap, not Row: the three labels are a hair wider than a narrow
      // phone can fit (overflowed by 0.255px), and a Row has no way to
      // recover. Wrap simply moves the last item to a second line on
      // devices where it doesn't fit, and looks identical where it does.
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: AppConstants.spaceMd,
        runSpacing: AppConstants.spaceXs,
        children: [
          _buildLegendItem('Mastered', AppColors.sage500),
          _buildLegendItem('In Progress', AppColors.marigold500),
          _buildLegendItem('Not Started', AppColors.graphite700),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildGraphView(bool isLoading, GraphData? graphData) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (graphData == null || graphData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: InteractiveGraphView(
        key: _graphViewKey,
        graphData: graphData,
        onNodeTap: _handleNodeTap,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Loading graph...',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No graph data available',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'View as list instead',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.ink900,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
