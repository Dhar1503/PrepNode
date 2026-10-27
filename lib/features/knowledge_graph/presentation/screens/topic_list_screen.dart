import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/breadcrumb_navigation.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/topic_list_tile.dart';

/// Topic List Screen (S3.2)
/// Hierarchical syllabus browser within a subject
class TopicListScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;

  const TopicListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTopics);
  }

  void _loadTopics() {
    ref.read(topicsProvider.notifier).loadTopics(subjectId: widget.subjectId);
  }

  void _handleTopicTap(GraphNode topic) {
    context.push('/learn/topic/${topic.id}');
  }

  @override
  Widget build(BuildContext context) {
    final topicsState = ref.watch(topicsProvider);
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
          widget.subjectName,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: Column(
        children: [
          BreadcrumbNavigation(
            items: [
              const BreadcrumbItem(id: 'home', label: 'Knowledge Graph'),
              BreadcrumbItem(id: widget.subjectId, label: widget.subjectName),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Expanded(
            child: _buildTopicList(topicsState.isLoading, topicsState.topics),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicList(bool isLoading, List<GraphNode> topics) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (topics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicListTile(
          topic: topics[index],
          onTap: () => _handleTopicTap(topics[index]),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          height: 60,
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
            Icons.topic,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No topics available yet',
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
