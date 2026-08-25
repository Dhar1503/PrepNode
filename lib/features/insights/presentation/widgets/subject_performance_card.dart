import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Subject Performance Card
/// Displays performance summary for a subject
class SubjectPerformanceCard extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final double masteryPercentage;
  final int topicsCount;
  final VoidCallback onTap;

  const SubjectPerformanceCard({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.masteryPercentage,
    required this.topicsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getMasteryColor(masteryPercentage);

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
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Center(
                child: Text(
                  '${(masteryPercentage * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeTitleMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    '$topicsCount topics',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
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

  Color _getMasteryColor(double mastery) {
    if (mastery >= 0.8) return AppColors.sage500;
    if (mastery >= 0.6) return AppColors.marigold500;
    return AppColors.ink500;
  }
}
