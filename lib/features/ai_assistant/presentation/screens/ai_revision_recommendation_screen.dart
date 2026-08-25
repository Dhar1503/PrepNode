import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/ai_recommendation.dart';
import 'package:prepgraph/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/recommendation_card.dart';

/// AI Revision Recommendation Screen
/// Displays AI-generated revision recommendations based on performance and forgetting curve
class AiRevisionRecommendationScreen extends ConsumerWidget {
  const AiRevisionRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Revision Recommendations',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(aiRecommendationsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            
            // Info Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                decoration: BoxDecoration(
                  color: AppColors.amethyst500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: AppColors.amethyst500.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: AppColors.amethyst500,
                      size: 24,
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Text(
                        'These topics need revision based on your performance and time since last study.',
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
            
            const SizedBox(height: AppConstants.spaceXl),
            
            // Revision Recommendations List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Text(
                'Topics to Revise',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeHeadlineSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            
            recommendationsAsync.when(
              data: (recommendations) {
                final revisionRecs = recommendations
                    .where((rec) => rec.type == RecommendationType.revision)
                    .toList();
                
                if (revisionRecs.isEmpty) {
                  return _buildEmptyState();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Column(
                    children: revisionRecs.map((rec) {
                      return RecommendationCard(
                        recommendation: rec,
                        onTap: () {
                          _handleRecommendationTap(context, rec);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spaceXl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => _buildErrorState(ref),
            ),
            
            const SizedBox(height: AppConstants.spaceXl),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeHeadlineSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Column(
                children: [
                  _buildQuickActionCard(
                    icon: Icons.quiz,
                    title: 'Practice Weak Topics',
                    description: 'Attempt PYQ for topics you\'re struggling with',
                    onTap: () => context.go('/practice'),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  _buildQuickActionCard(
                    icon: Icons.school,
                    title: 'Study from Resources',
                    description: 'Access recommended study materials',
                    onTap: () => context.push('/resources/recommended'),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  _buildQuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Ask AI for Help',
                    description: 'Get explanations for difficult concepts',
                    onTap: () => context.push('/ai-assistant/chat'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.sage500,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'All caught up!',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'You don\'t have any pending revision topics',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.rose500,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Unable to load revision recommendations',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ElevatedButton(
              onPressed: () => ref.invalidate(aiRecommendationsProvider),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.sage500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.sage500,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.graphite700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.graphite700,
            ),
          ],
        ),
      ),
    );
  }

  void _handleRecommendationTap(BuildContext context, dynamic recommendation) {
    // Navigate based on recommendation type
    switch (recommendation.targetModule) {
      case 'knowledge_graph':
        if (recommendation.targetId != null) {
          context.push('/learn/topic/${recommendation.targetId}');
        } else {
          context.go('/learn');
        }
        break;
      case 'resources':
        context.push('/resources/recommended');
        break;
      case 'pyq':
        context.go('/practice');
        break;
      default:
        context.push('/ai-assistant/chat');
    }
  }
}
