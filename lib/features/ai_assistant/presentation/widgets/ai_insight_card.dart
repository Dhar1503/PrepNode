import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/ai_insight.dart';

/// AI Insight Card Widget
/// Displays an AI-generated insight about user performance
class AIInsightCard extends StatelessWidget {
  final AIInsight insight;
  final VoidCallback? onAction;

  const AIInsightCard({
    super.key,
    required this.insight,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: _getCategoryColor(insight.category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: _getCategoryColor(insight.category).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(insight.category),
                size: 20,
                color: _getCategoryColor(insight.category),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  insight.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
              ),
              if (insight.isActioned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm,
                    vertical: AppConstants.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sage500,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Actioned',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            insight.insight,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          if (insight.relatedTopics.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: AppConstants.spaceXs,
              runSpacing: AppConstants.spaceXs,
              children: insight.relatedTopics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm,
                    vertical: AppConstants.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    topic,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (insight.suggestedActions.isNotEmpty && !insight.isActioned) ...[
            const SizedBox(height: AppConstants.spaceMd),
            ...insight.suggestedActions.take(2).map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceXs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: _getCategoryColor(insight.category),
                    ),
                    const SizedBox(width: AppConstants.spaceXs),
                    Expanded(
                      child: Text(
                        action,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppConstants.spaceSm),
            if (onAction != null)
              TextButton.icon(
                onPressed: onAction,
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: _getCategoryColor(insight.category),
                ),
                label: Text(
                  'Mark as Actioned',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: _getCategoryColor(insight.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(InsightCategory category) {
    switch (category) {
      case InsightCategory.strength:
        return AppColors.sage500;
      case InsightCategory.weakness:
        return AppColors.rose500;
      case InsightCategory.trend:
        return AppColors.azure500;
      case InsightCategory.opportunity:
        return AppColors.marigold500;
      case InsightCategory.warning:
        return AppColors.amethyst500;
    }
  }

  IconData _getCategoryIcon(InsightCategory category) {
    switch (category) {
      case InsightCategory.strength:
        return Icons.trending_up;
      case InsightCategory.weakness:
        return Icons.warning;
      case InsightCategory.trend:
        return Icons.show_chart;
      case InsightCategory.opportunity:
        return Icons.star;
      case InsightCategory.warning:
        return Icons.info;
    }
  }
}
