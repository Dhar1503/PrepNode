import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/pyq_performance.dart';

/// Subject PYQ Card
/// Displays PYQ performance for a specific subject
class SubjectPyqCard extends StatelessWidget {
  final SubjectPyqStats stat;
  final VoidCallback onTap;

  const SubjectPyqCard({
    super.key,
    required this.stat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyColor = _getAccuracyColor(stat.accuracy);

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
            color: AppColors.outlineVariant,
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
                  child: Text(
                    stat.subjectName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm,
                    vertical: AppConstants.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: accuracyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                  ),
                  child: Text(
                    '${(stat.accuracy * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: accuracyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                _buildStatItem(
                  '${stat.totalQuestionsAttempted}',
                  'Attempted',
                ),
                const SizedBox(width: AppConstants.spaceMd),
                _buildStatItem(
                  '${stat.totalQuestionsCorrect}',
                  'Correct',
                ),
                const SizedBox(width: AppConstants.spaceMd),
                _buildStatItem(
                  '${stat.averageTimePerQuestion}s',
                  'Avg Time',
                ),
              ],
            ),
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

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.sage500;
    if (accuracy >= 0.6) return AppColors.marigold500;
    return AppColors.ink500;
  }
}
