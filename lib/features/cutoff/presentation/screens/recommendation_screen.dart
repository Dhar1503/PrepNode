import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/recommendation_card.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepnode/features/resources/presentation/widgets/resource_card.dart';

/// Dismissed recommendation IDs, session-scoped (resets on app restart) —
/// recommendations are recomputed fresh from real data on every call (see
/// CutoffRepositoryImpl._buildGapClosingRecommendations), there's no stored
/// row to persist a dismissal flag on, so this is the same honest
/// session-local pattern used for insight dismissal elsewhere.
final dismissedRecommendationIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Personalized Recommendation Screen
/// Displays AI-powered recommendations based on cutoff analysis
class RecommendationScreen extends ConsumerWidget {
  final String examId;

  const RecommendationScreen({
    super.key,
    required this.examId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(cutoffAnalysisProvider(examId));

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Personalized Recommendations',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: analysisAsync.when(
        data: (analysis) => _buildContent(context, ref, analysis),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, analysis) {
    final dismissedIds = ref.watch(dismissedRecommendationIdsProvider);
    final recommendations = analysis.personalizedRecommendations
        .where((r) => !dismissedIds.contains(r.id))
        .toList();

    if (recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Summary banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.sage500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(
                  color: AppColors.sage500.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 24,
                    color: AppColors.sage500,
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Text(
                      'Based on your current performance and historical cutoff data, here are personalized recommendations to help you reach your target.',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Priority filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Recommendations',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          ...recommendations.map((rec) => RecommendationCard(
            recommendation: rec,
            onDismiss: () {
              ref.read(dismissedRecommendationIdsProvider.notifier).update(
                    (ids) => {...ids, rec.id},
                  );
            },
            onAction: () {
              _handleRecommendationAction(context, rec);
            },
          )),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // M9 Integration: High-priority resources for important topics
          _buildHighPriorityResources(context, ref),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  void _handleRecommendationAction(BuildContext context, recommendation) {
    switch (recommendation.type) {
      case 'study':
        if (recommendation.topicId != null) {
          context.push('/learn/topic/${recommendation.topicId}');
        }
        break;
      case 'practice':
        if (recommendation.topicId != null) {
          context.go('/practice');
        }
        break;
      case 'revision':
        if (recommendation.topicId != null) {
          context.push('/learn/topic/${recommendation.topicId}');
        }
        break;
      case 'focus':
        if (recommendation.topicId != null) {
          context.push('/learn/topic/${recommendation.topicId}');
        }
        break;
    }
  }

  // M9 Integration: High-priority resources for important topics
  Widget _buildHighPriorityResources(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedResourcesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Icon(
                Icons.priority_high,
                color: AppColors.marigold500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'High-Priority Resources',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/resources/recommended'),
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
        const SizedBox(height: AppConstants.spaceSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'These resources cover high-impact topics based on cutoff analysis:',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        // Show high-priority recommended resources
        recommendedAsync.when(
          data: (recommendations) {
            if (recommendations.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              children: recommendations.take(3).map((rec) {
                return ResourceCard(
                  resource: rec.resource,
                  onTap: () => context.push('/resources/${rec.resource.id}'),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.sage500,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'You\'re on track!',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'No new recommendations at this time.',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Unable to load recommendations',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}
