import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';

/// Mastery Topic Card
/// Displays individual topic mastery with visual indicator
class MasteryTopicCard extends StatelessWidget {
  final TopicMastery topic;
  final VoidCallback onTap;

  const MasteryTopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getMasteryColor(topic.level);
    final masteryPercent = (topic.masteryPercentage * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceXs,
        ),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Mastery Indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$masteryPercent%',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            // Topic Info
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
                  const SizedBox(height: AppConstants.spaceXs),
                  Row(
                    children: [
                      _buildStatChip(
                        '${topic.questionsAttempted} questions',
                        AppColors.graphite700,
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      _buildStatChip(
                        '${topic.studyMinutes} min',
                        AppColors.graphite700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Mastery Level Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceSm,
                vertical: AppConstants.spaceXs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusXs),
              ),
              child: Text(
                _getMasteryLabel(topic.level),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceXs,
        vertical: AppConstants.space2xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          color: color,
        ),
      ),
    );
  }

  Color _getMasteryColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.mastered:
        return AppColors.sage500;
      case MasteryLevel.building:
        return AppColors.marigold500;
      case MasteryLevel.inProgress:
        return AppColors.ink500;
      case MasteryLevel.notStarted:
        return AppColors.outlineVariant;
    }
  }

  String _getMasteryLabel(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.mastered:
        return 'Mastered';
      case MasteryLevel.building:
        return 'Building';
      case MasteryLevel.inProgress:
        return 'In Progress';
      case MasteryLevel.notStarted:
        return 'Not Started';
    }
  }
}
