import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/weak_area.dart';

/// Recommendation Card
/// Displays personalized AI recommendations with "Why this?" explanation
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onDismiss,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(recommendation.type);
    final typeIcon = _getTypeIcon(recommendation.type);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      recommendation.description,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          // "Why this?" explanation
          _buildWhyThisSection(),
          
          const SizedBox(height: AppConstants.spaceMd),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: typeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                  child: Text(
                    _getActionLabel(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyThisSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.graphite700,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this?',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  recommendation.reason,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'revision':
        return AppColors.marigold500;
      case 'practice':
        return AppColors.sage500;
      case 'learn':
        return AppColors.ink500;
      case 'rest':
        return AppColors.graphite700;
      default:
        return AppColors.ink500;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'revision':
        return Icons.refresh;
      case 'practice':
        return Icons.quiz;
      case 'learn':
        return Icons.school;
      case 'rest':
        return Icons.self_improvement;
      default:
        return Icons.lightbulb;
    }
  }

  String _getActionLabel() {
    switch (recommendation.type) {
      case 'revision':
        return 'Revise';
      case 'practice':
        return 'Practice';
      case 'learn':
        return 'Learn';
      case 'rest':
        return 'Take Break';
      default:
        return 'View';
    }
  }
}
