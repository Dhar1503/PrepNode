import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/mastery_analytics.dart';

/// Strength Map Preview
/// Preview of mastery visualization
class StrengthMapPreview extends StatelessWidget {
  final List<TopicMastery> topicMasteries;
  final VoidCallback onTap;
  final Function(String)? onTopicTap;

  const StrengthMapPreview({
    super.key,
    required this.topicMasteries,
    required this.onTap,
    this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group by subject for preview
    final subjectGroups = <String, List<TopicMastery>>{};
    for (var topic in topicMasteries) {
      subjectGroups.putIfAbsent(topic.subjectId, () => []);
      subjectGroups[topic.subjectId]!.add(topic);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Strength Map',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.graphite700,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            _buildSubjectGrid(subjectGroups),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectGrid(Map<String, List<TopicMastery>> subjectGroups) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppConstants.spaceSm,
        mainAxisSpacing: AppConstants.spaceSm,
      ),
      itemCount: subjectGroups.length,
      itemBuilder: (context, index) {
        final entry = subjectGroups.entries.elementAt(index);
        final subjectTopics = entry.value;
        final avgMastery = subjectTopics
            .map((t) => t.masteryPercentage)
            .reduce((a, b) => a + b) / subjectTopics.length;
        
        return _buildSubjectChip(
          subjectTopics.first.subjectName,
          avgMastery,
        );
      },
    );
  }

  Widget _buildSubjectChip(String subjectName, double mastery) {
    final color = _getMasteryColor(mastery);
    
    return Container(
      // Tighter horizontal inset than vertical: two chips per row leave little
      // width, and at spaceSm the subject name was ellipsised down to a single
      // letter ("G… 100%").
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceXs,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              subjectName,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(mastery * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMasteryColor(double mastery) {
    if (mastery >= 0.8) return AppColors.sage500;
    if (mastery >= 0.6) return AppColors.marigold500;
    return AppColors.ink500;
  }
}
