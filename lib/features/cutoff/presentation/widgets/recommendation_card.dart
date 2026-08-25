import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/cutoff/domain/entities/recommendation.dart';

/// Card displaying a personalized recommendation
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(recommendation.priority);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                  vertical: AppConstants.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  recommendation.type.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  color: AppColors.graphite700,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            recommendation.title,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            recommendation.description,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              _buildImpactBadge('Impact: ${recommendation.estimatedImpact}'),
              const SizedBox(width: AppConstants.spaceSm),
              _buildImpactBadge('Time: ${recommendation.timeRequired}'),
            ],
          ),
          if (onAction != null) ...[
            const SizedBox(height: AppConstants.spaceMd),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: priorityColor,
                ),
                child: Text(
                  'Take Action',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImpactBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: AppConstants.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          color: AppColors.graphite700,
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.marigold500;
      case 2:
        return AppColors.sage500;
      case 3:
        return AppColors.ink500;
      default:
        return AppColors.graphite700;
    }
  }
}
