import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_text_field.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/widgets/subject_list_tile.dart';

/// Knowledge Graph Home Screen (S3.1)
/// Entry point to the knowledge graph - shows subject list
class KnowledgeGraphHomeScreen extends ConsumerStatefulWidget {
  const KnowledgeGraphHomeScreen({super.key});

  @override
  ConsumerState<KnowledgeGraphHomeScreen> createState() => _KnowledgeGraphHomeScreenState();
}

class _KnowledgeGraphHomeScreenState extends ConsumerState<KnowledgeGraphHomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
        title: Text(
          'Knowledge Graph',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: AppConstants.spaceMd),
          Expanded(
            child: _buildSubjectList(subjectsState.isLoading, filteredSubjects),
          ),
        ],
      ),
    );
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
