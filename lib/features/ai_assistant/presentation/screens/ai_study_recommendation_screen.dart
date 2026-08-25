import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/recommendation_card.dart';

/// AI Study Recommendation Screen
/// Displays AI-generated study recommendations with detailed explanations
class AiStudyRecommendationScreen extends ConsumerWidget {
  const AiStudyRecommendationScreen({super.key});

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
          'Study Recommendations',
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
                  color: AppColors.sage500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: AppColors.sage500.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.sage500,
                      size: 24,
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Text(
                        'These recommendations are based on your performance, study patterns, and TNPSC exam requirements.',
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
            
            // Recommendations List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Text(
                'Personalized for You',
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
                if (recommendations.isEmpty) {
                  return _buildEmptyState();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Column(
                    children: recommendations.map((rec) {
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
              Icons.lightbulb_outline,
              size: 64,
              color: AppColors.graphite700,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'No recommendations yet',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Complete more practice sessions to get personalized recommendations',
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
              'Unable to load recommendations',
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

  void _handleRecommendationTap(BuildContext context, dynamic recommendation) {
    // Navigate based on recommendation type
    switch (recommendation.targetModule) {
      case 'planner':
        context.push('/planner');
        break;
      case 'resources':
        context.push('/resources/recommended');
        break;
      case 'knowledge_graph':
        if (recommendation.targetId != null) {
          context.push('/learn/topic/${recommendation.targetId}');
        } else {
          context.go('/learn');
        }
        break;
      case 'pyq':
        context.go('/practice');
        break;
      default:
        // Open chat with context about the recommendation
        context.push('/ai-assistant/chat');
    }
  }
}
