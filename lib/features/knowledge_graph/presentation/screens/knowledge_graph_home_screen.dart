import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_text_field.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/subject_list_tile.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/syllabus_graph_view.dart';

/// Knowledge Graph Home Screen (S3.1)
/// Entry point to the knowledge graph - shows subject list
class KnowledgeGraphHomeScreen extends ConsumerStatefulWidget {
  const KnowledgeGraphHomeScreen({super.key});

  @override
  ConsumerState<KnowledgeGraphHomeScreen> createState() => _KnowledgeGraphHomeScreenState();
}

class _KnowledgeGraphHomeScreenState extends ConsumerState<KnowledgeGraphHomeScreen> {
  final _searchController = TextEditingController();
  final _graphKey = GlobalKey<SyllabusGraphViewState>();
  String _searchQuery = '';

  /// The graph is the flagship view, so it is what opens by default; the
  /// subject list stays one tap away for anyone who prefers to drill down.
  bool _showGraph = true;
  GraphNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSubjects);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _loadSubjects() {
    // TNPSC Group 2 is currently the only seeded/supported exam.
    ref.read(subjectsProvider.notifier).loadSubjects(examId: 'tnpsc-group2');
  }

  void _handleSubjectTap(GraphNode subject) {
    context.push('/learn/subject/${subject.id}?subjectName=${subject.name}');
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);
    final filteredSubjects = _searchQuery.isEmpty
        ? subjectsState.subjects
        : subjectsState.subjects
            .where((subject) =>
                subject.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        // titleMedium + scaleDown, not headlineSmall. Four action icons
        // (zoom in/out/fit/refresh) plus the list toggle leave roughly a
        // third of the bar for the title, and at a 1.3x font scale a 24pt
        // Fraunces title came out as "Knowled…".
        titleSpacing: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Knowledge Graph',
            maxLines: 1,
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeTitleMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        actions: [
          if (_showGraph) ...[
            IconButton(
              tooltip: 'Zoom in',
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _graphKey.currentState?.zoomIn(),
            ),
            IconButton(
              tooltip: 'Zoom out',
              icon: const Icon(Icons.zoom_out),
              onPressed: () => _graphKey.currentState?.zoomOut(),
            ),
            IconButton(
              tooltip: 'Fit to screen',
              icon: const Icon(Icons.fit_screen),
              onPressed: () => _graphKey.currentState?.resetView(),
            ),
            // The graph is built once and kept alive with this shell
            // branch, so mastery earned in Practice since it was last read
            // needs an explicit re-read.
            IconButton(
              tooltip: 'Refresh progress',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() => _selectedNode = null);
                ref.invalidate(syllabusGraphProvider);
              },
            ),
          ],
          IconButton(
            tooltip: _showGraph ? 'Subject list' : 'Graph view',
            icon: Icon(_showGraph ? Icons.view_list : Icons.account_tree),
            onPressed: () => setState(() {
              _showGraph = !_showGraph;
              _selectedNode = null;
            }),
          ),
        ],
      ),
      body: _showGraph
          ? _buildGraphView()
          : Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: AppConstants.spaceMd),
                Expanded(
                  child:
                      _buildSubjectList(subjectsState.isLoading, filteredSubjects),
                ),
              ],
            ),
    );
  }

  Widget _buildGraphView() {
    final graphAsync = ref.watch(syllabusGraphProvider);

    return graphAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                'Could not build the graph.\n$error',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.graphite700),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextButton(
                onPressed: () => ref.invalidate(syllabusGraphProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (graph) {
        if (graph.nodes.isEmpty) {
          return _buildEmptyState();
        }
        return Column(
          children: [
            Expanded(
              child: SyllabusGraphView(
                key: _graphKey,
                graph: graph,
                onNodeSelected: (node) => setState(() => _selectedNode = node),
                onNodeOpened: (node) => context.push('/learn/topic/${node.id}'),
              ),
            ),
            _buildGraphFooter(graph.nodes.length),
          ],
        );
      },
    );
  }

  /// Legend plus whatever is currently selected. Without this the colour
  /// coding is guesswork, and the graph is only useful if the user can read
  /// what green and orange actually mean.
  Widget _buildGraphFooter(int nodeCount) {
    final selected = _selectedNode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          top: BorderSide(color: AppColors.lightOutlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected != null) ...[
            Text(
              selected.name,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_describeType(selected.type)} · '
              '${selected.masteryPercentage.toStringAsFixed(0)}% mastery'
              '${selected.type == NodeType.topic || selected.type == NodeType.subtopic ? ' · double-tap to open' : ''}',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
          ] else ...[
            Text(
              'Tap a node to expand it · $nodeCount nodes · pinch to zoom',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
          ],
          Wrap(
            spacing: AppConstants.spaceMd,
            runSpacing: AppConstants.spaceXs,
            children: const [
              _LegendDot(color: Color(0xFF3F7D58), label: 'Mastered'),
              _LegendDot(color: Color(0xFFB4552F), label: 'Needs revision'),
              _LegendDot(color: Color(0xFF3A5A9B), label: 'In progress'),
              _LegendDot(color: Colors.white, label: 'Not started'),
            ],
          ),
        ],
      ),
    );
  }

  String _describeType(NodeType type) {
    return switch (type) {
      NodeType.exam => 'Exam',
      NodeType.subject => 'Subject',
      NodeType.unit => 'Unit',
      NodeType.topic => 'Topic',
      NodeType.subtopic => 'Subtopic',
    };
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: AppTextField(
        hint: 'Search subjects...',
        controller: _searchController,
      ),
    );
  }

  Widget _buildSubjectList(bool isLoading, List<GraphNode> subjects) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (subjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return SubjectListTile(
          subject: subjects[index],
          onTap: () => _handleSubjectTap(subjects[index]),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No subjects found',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}

/// One entry in the graph legend.
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.graphite700, width: 1),
          ),
        ),
        const SizedBox(width: 6),
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
}
