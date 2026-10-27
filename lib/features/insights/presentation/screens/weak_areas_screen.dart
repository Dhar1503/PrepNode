import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/empty_state.dart';
import 'package:prepnode/features/insights/domain/entities/weak_area.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/insights/presentation/widgets/weak_topic_card.dart';
import 'package:prepnode/features/insights/presentation/widgets/recommendation_card.dart';

/// Weak Areas and Recommendations Screen
/// Displays weak topics and personalized recommendations
class WeakAreasScreen extends ConsumerWidget {
  const WeakAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakAreasAsync = ref.watch(weakAreasProvider);
    final dismissedIds = ref.watch(dismissedRecommendationIdsProvider);

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
          'Weak Areas & Recommendations',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: weakAreasAsync.when(
        data: (areas) => _buildContent(context, ref, areas, dismissedIds),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    WeakArea areas,
    Set<String> dismissedIds,
  ) {
    final activeRecommendations =
        areas.recommendations.where((r) => !dismissedIds.contains(r.id)).toList();

    // Both sections empty meant two headers floating above blank space.
    if (areas.weakTopics.isEmpty && activeRecommendations.isEmpty) {
      return EmptyStates.needsPractice(
        icon: Icons.track_changes_outlined,
        title: 'No weak areas identified yet',
        subtitle:
            'Once you answer questions, the topics you get wrong most often '
            'will appear here with suggestions for what to revise.',
        onAction: () => context.go('/practice'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),

          // Each section hides its own header when it has nothing to list.
          if (areas.weakTopics.isNotEmpty) ...[
            _buildWeakTopicsSection(areas.weakTopics),
            const SizedBox(height: AppConstants.spaceLg),
          ],

          if (activeRecommendations.isNotEmpty) ...[
            _buildRecommendationsSection(context, ref, activeRecommendations),
          ],

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildWeakTopicsSection(List<WeakTopic> weakTopics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Areas to Focus On',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...weakTopics.map((topic) => WeakTopicCard(
          topic: topic,
          onTap: () {
            // Navigate to topic detail
          },
        )),
      ],
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    WidgetRef ref,
    List<Recommendation> recommendations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Personalized Recommendations',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...recommendations.map((recommendation) => RecommendationCard(
          recommendation: recommendation,
          onDismiss: () {
            ref.read(dismissedRecommendationIdsProvider.notifier).update(
                  (ids) => {...ids, recommendation.id},
                );
          },
          onAction: () {
            // Handle recommendation action
            _handleRecommendationAction(context, recommendation);
          },
        )),
      ],
    );
  }

  void _handleRecommendationAction(BuildContext context, Recommendation recommendation) {
    switch (recommendation.type) {
      case 'revision':
        if (recommendation.topicId != null) {
          context.push('/learn/topic/${recommendation.topicId}');
        }
        break;
      case 'practice':
        if (recommendation.topicId != null) {
          context.go('/practice');
        }
        break;
      case 'learn':
        if (recommendation.topicId != null) {
          context.push('/learn/topic/${recommendation.topicId}');
        }
        break;
      case 'rest':
        // Show rest suggestion dialog
        break;
    }
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


