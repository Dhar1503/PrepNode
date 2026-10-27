import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/topic_detail.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/breadcrumb_navigation.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/mastery_ring.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepnode/features/resources/presentation/widgets/resource_card.dart';

/// Topic Detail Screen (S3.3)
/// Concept summary, mastery state, related PYQs, resources, prerequisite links
class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicDetailScreen({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  TopicDetail? _topicDetail;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTopicDetail);
  }

  void _loadTopicDetail() {
    // TODO: Integrate with Cutoff Intelligence - highlight important topics based on cutoff analysis
    // TODO: Display cutoff-impact indicator for high-frequency topics in historical data
    final userId = ref.read(authProvider).userId;
    ref.read(topicDetailProvider.notifier).loadTopicDetail(topicId: widget.topicId, userId: userId);
  }

  // _handleViewInGraph removed along with the "View in Graph" button — see
  // the comment at that button's former location for why. Restore both
  // together when the graph canvas is confirmed rendering.

  void _handlePracticePYQs() {
    context.go('/practice');
  }

  void _handleViewResources() {
    // M9 Integration: full topic-scoped resource list. This used to go()
    // to '/resources/subject/:subjectId' passing this screen's topicId —
    // that route strictly filters by subjectId, so it always rendered an
    // empty list. Reuses the same relatedResourcesProvider(topicId) +
    // bottom-sheet pattern already used for this exact relationship
    // elsewhere (see Planner's task resources sheet).
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopicResourcesSheet(topicId: widget.topicId),
    );
  }

  void _handleAskAI() {
    // M12 Integration: Navigate to AI Assistant with topic context
    final topicName = _topicDetail?.node.name ?? 'this topic';
    final question = 'Can you explain $topicName in detail for TNPSC preparation?';
    context.push(
      '/ai-assistant/explain?topicId=${widget.topicId}&initialQuestion=${Uri.encodeComponent(question)}',
    );
  }

  void _handleAddToPlanner() {
    // M4 Integration: Add topic to planner
    final topicName = _topicDetail?.node.name ?? 'this topic';
    context.push(
      '/planner?addTopic=${widget.topicId}&topicName=${Uri.encodeComponent(topicName)}',
    );
  }

  void _handleTopicTap(String topicId) {
    context.push('/learn/topic/$topicId');
  }

  @override
  Widget build(BuildContext context) {
    final topicDetailState = ref.watch(topicDetailProvider);
    _topicDetail = topicDetailState.topicDetail;

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
          _topicDetail?.node.name ?? 'Topic Detail',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: topicDetailState.isLoading ? _buildLoadingSkeleton() : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_topicDetail == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbNavigation(
            items: const [
              BreadcrumbItem(id: 'home', label: 'Knowledge Graph'),
              BreadcrumbItem(id: 'subject', label: 'Indian Polity'),
              BreadcrumbItem(id: 'topic', label: 'Fundamental Rights'),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildTopicHeader(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildDescription(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildPrerequisites(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildRelatedTopics(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildNextTopics(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildLearningPath(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildLearningResources(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildStatsAndActions(),
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildTopicHeader() {
    final node = _topicDetail!.node;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          MasteryRing(
            masteryPercentage: node.masteryPercentage,
            masteryState: node.masteryState,
            size: 48,
            strokeWidth: 3,
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: GoogleFonts.fraunces(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightOnPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(node.masteryPercentage * 100).toInt()}% mastered',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Text(
        _topicDetail!.description,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodyMedium,
          color: AppColors.graphite700,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPrerequisites() {
    if (_topicDetail!.prerequisites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prerequisites',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ..._topicDetail!.prerequisites.map((prereq) {
            return _buildTopicChip(prereq);
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedTopics() {
    if (_topicDetail!.relatedTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Topics',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ..._topicDetail!.relatedTopics.map((topic) {
            return _buildTopicChip(topic);
          }),
        ],
      ),
    );
  }

  Widget _buildNextTopics() {
    if (_topicDetail!.nextTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Next',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ..._topicDetail!.nextTopics.map((topic) {
            return _buildTopicChip(topic);
          }),
        ],
      ),
    );
  }

  Widget _buildTopicChip(TopicReference topic) {
    return GestureDetector(
      onTap: () => _handleTopicTap(topic.topicId),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Row(
          children: [
            if (topic.masteryState != null)
              MasteryRing(
                masteryPercentage: 0.5,
                masteryState: topic.masteryState!,
                size: 20,
                strokeWidth: 1.5,
              ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topicName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink900,
                    ),
                  ),
                  if (topic.relationshipDescription != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      topic.relationshipDescription!,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.graphite700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPath() {
    if (_topicDetail!.learningPathRecommendation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.sage500),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: AppColors.sage500,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              _topicDetail!.learningPathRecommendation!,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.ink900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // M9 Integration: Learning Resources Section
  Widget _buildLearningResources() {
    final relatedResourcesAsync = ref.watch(relatedResourcesProvider(widget.topicId));

    return relatedResourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Learning Resources',
                      style: GoogleFonts.fraunces(
                        fontSize: AppConstants.fontSizeHeadlineSmall,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleViewResources,
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppColors.sage500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ...resources.take(3).map((resource) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                child: ResourceCard(
                  resource: resource,
                  onTap: () => context.push('/resources/${resource.id}'),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatsAndActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('PYQs', '${_topicDetail!.pyqCount}', Icons.quiz),
              const SizedBox(width: AppConstants.spaceMd),
              _buildStatCard('Resources', '${_topicDetail!.resourceCount}', Icons.menu_book),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLg),
          // "View in Graph" removed: the graph canvas rendered an empty
          // bordered box on device and the cause was not identified within
          // the time available (data reaches the widget and node positions
          // compute correctly, so it is a paint/layout issue, not missing
          // data). An empty box reads as broken, so the entry point is
          // withdrawn rather than shipped. The route, screen and
          // InteractiveGraphView all remain in the repo — restore this
          // button once the canvas is confirmed rendering on a device.
          AppButton(
            label: 'Practice PYQs',
            onPressed: _handlePracticePYQs,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'View Resources',
            onPressed: _handleViewResources,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'Ask AI About This Topic',
            onPressed: _handleAskAI,
            icon: const Icon(Icons.psychology, size: 20),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'Add to Study Plan',
            onPressed: _handleAddToPlanner,
            icon: const Icon(Icons.calendar_today, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.ink900),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Could not load topic details',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              color: AppColors.graphite700,
            ),
          ),
 const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Retry',
            onPressed: _loadTopicDetail,
          ),
        ],
      ),
    );
  }
}

/// Full topic-scoped resources list, opened from "See All"/"View
/// Resources" — same relatedResourcesProvider(topicId) the inline preview
/// section already uses, just without the take(3) cap.
class _TopicResourcesSheet extends ConsumerWidget {
  final String topicId;

  const _TopicResourcesSheet({required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(relatedResourcesProvider(topicId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.graphite700.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Learning Resources',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: resourcesAsync.when(
              data: (resources) {
                if (resources.isEmpty) {
                  return Center(
                    child: Text(
                      'No resources available for this topic yet',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppColors.graphite700,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      child: ResourceCard(
                        resource: resource,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/resources/${resource.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  'Unable to load resources',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
