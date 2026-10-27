import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/widgets/error_state.dart';
import 'package:prepnode/core/widgets/skeleton_loader.dart';
import 'package:prepnode/features/insights/domain/entities/learner_progress.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';

/// Score Detail Screen (from S8.1's PrepNode Score card)
/// Breaks the real PrepNode Score down into its five real weighted
/// components (LearnerProgress.scoreComponents, already computed by
/// InsightsRepository) — replaces the former "Coming Soon" placeholder.
class ScoreDetailScreen extends ConsumerWidget {
  const ScoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learnerProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Score Breakdown',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: progressAsync.when(
        data: (progress) => _buildContent(progress),
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => ErrorStates.generic(
          message: error.toString(),
          onRetry: () => ref.invalidate(learnerProgressProvider),
        ),
      ),
    );
  }

  Widget _buildContent(LearnerProgress progress) {
    final components = <(String, double, double)>[
      ('Topic Completion', progress.scoreComponents.topicCompletion, 0.30),
      ('PYQ Performance', progress.scoreComponents.pyqPerformance, 0.25),
      ('Mock Accuracy', progress.scoreComponents.mockAccuracy, 0.20),
      ('Consistency', progress.scoreComponents.consistency, 0.15),
      ('Revision Discipline', progress.scoreComponents.revisionDiscipline, 0.10),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: AppColors.ink900,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: Column(
            children: [
              Text(
                progress.prepNodeScore.toStringAsFixed(0),
                style: GoogleFonts.fraunces(
                  fontSize: 56,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightOnPrimary,
                ),
              ),
              Text(
                'PrepNode Score',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Text(
          'How this is calculated',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...components.map((c) => _buildComponentRow(c.$1, c.$2, c.$3)),
      ],
    );
  }

  Widget _buildComponentRow(String label, double value, double weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${value.toStringAsFixed(0)}% • ${(weight * 100).toStringAsFixed(0)}% weight',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.lightOutlineVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: const [
        SkeletonCard(height: 140),
        SizedBox(height: AppConstants.spaceLg),
        SkeletonCard(height: 60),
        SizedBox(height: AppConstants.spaceMd),
        SkeletonCard(height: 60),
        SizedBox(height: AppConstants.spaceMd),
        SkeletonCard(height: 60),
      ],
    );
  }
}
