import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';

/// Weak Topic Card
/// Displays a weak topic with severity and improvement suggestions
class WeakTopicCard extends StatelessWidget {
  final WeakTopic topic;
  final VoidCallback onTap;

  const WeakTopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(topic.severity);
    final severityLabel = _getSeverityLabel(topic.severity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceSm,
        ),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.topicName,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXs),
                      Text(
                        topic.subjectName,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm,
                    vertical: AppConstants.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                  ),
                  child: Text(
                    severityLabel,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w500,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                _buildStatItem(
                  '${(topic.currentAccuracy * 100).toInt()}%',
                  'Current',
                ),
                const SizedBox(width: AppConstants.spaceMd),
                _buildStatItem(
                  '${(topic.targetAccuracy * 100).toInt()}%',
                  'Target',
                ),
                const SizedBox(width: AppConstants.spaceMd),
                _buildStatItem(
                  '${topic.attempts}',
                  'Attempts',
                ),
              ],
            ),
            if (topic.prerequisiteTopics.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spaceMd),
              _buildPrerequisites(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildPrerequisites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Prerequisites',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            fontWeight: FontWeight.w500,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Wrap(
          spacing: AppConstants.spaceXs,
          runSpacing: AppConstants.spaceXs,
          children: topic.prerequisiteTopics.map((prereq) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceSm,
                vertical: AppConstants.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusXs),
              ),
              child: Text(
                prereq,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getSeverityColor(WeaknessSeverity severity) {
    switch (severity) {
      case WeaknessSeverity.mild:
        return AppColors.marigold500;
      case WeaknessSeverity.moderate:
        return AppColors.ink500;
      case WeaknessSeverity.significant:
        return AppColors.error;
    }
  }

  String _getSeverityLabel(WeaknessSeverity severity) {
    switch (severity) {
      case WeaknessSeverity.mild:
        return 'Needs Attention';
      case WeaknessSeverity.moderate:
        return 'Moderate';
      case WeaknessSeverity.significant:
        return 'Priority';
    }
  }
}
