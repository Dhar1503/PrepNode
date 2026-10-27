import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/mock_test_analytics.dart';

/// Mock Test Attempt Card
/// Displays individual mock test attempt details
class MockTestAttemptCard extends StatelessWidget {
  final MockTestAttempt attempt;
  final VoidCallback onTap;

  const MockTestAttemptCard({
    super.key,
    required this.attempt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(attempt.score);
    final dateStr = _formatDate(attempt.date);

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
                    attempt.subjectName,
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
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    attempt.score.toStringAsFixed(1),
                    'Score',
                    scoreColor,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: _buildStatItem(
                    '${(attempt.accuracy * 100).toInt()}%',
                    'Accuracy',
                    AppColors.sage500,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: _buildStatItem(
                    '${attempt.durationMinutes}m',
                    'Duration',
                    AppColors.ink500,
                  ),
                ),
              ],
            ),
            if (attempt.sectionScores.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spaceMd),
              _buildSectionBreakdown(attempt.sectionScores),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleMedium,
            fontWeight: FontWeight.w600,
            color: color,
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

  Widget _buildSectionBreakdown(List<SectionScore> sectionScores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section Breakdown',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            fontWeight: FontWeight.w500,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        ...sectionScores.map((section) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceXs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section.sectionName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${(section.sectionAccuracy * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w500,
                  color: _getAccuracyColor(section.sectionAccuracy),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return AppColors.sage500;
    if (score >= 60) return AppColors.marigold500;
    return AppColors.ink500;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.sage500;
    if (accuracy >= 0.6) return AppColors.marigold500;
    return AppColors.ink500;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


