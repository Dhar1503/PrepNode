import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';

/// Card displaying exam cutoff summary — the entry point into Cutoff
/// Intelligence, so it needs to read as more than "one card, one year": it
/// carries the latest cutoff, year-over-year movement, and the full
/// multi-year range at a glance, all from real seeded data (see
/// CutoffLocalDataSource.getExamCutoffLocal).
class CutoffCard extends StatelessWidget {
  final ExamCutoff examCutoff;
  final VoidCallback? onTap;

  const CutoffCard({
    super.key,
    required this.examCutoff,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // yearlyTrends is sorted ascending by year, so the latest year is the
    // *last* entry, not the first.
    final trends = examCutoff.yearlyTrends;
    final latestYear = trends.last;
    final avgCutoff = latestYear.averageCutoff;
    final previousYear = trends.length > 1 ? trends[trends.length - 2] : null;
    final delta = previousYear == null ? null : avgCutoff - previousYear.averageCutoff;

    final allAverages = trends.map((t) => t.averageCutoff);
    final highest = allAverages.reduce((a, b) => a > b ? a : b);
    final lowest = allAverages.reduce((a, b) => a < b ? a : b);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceSm,
        ),
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
              children: [
                Expanded(
                  child: Text(
                    examCutoff.examName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    maxLines: 1,
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
                    color: AppColors.sage500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    '${latestYear.year}',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sage500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Row(
              children: [
                Text(
                  examCutoff.conductingBody,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
                if (trends.length > 1) ...[
                  Text(
                    ' · ${trends.length} years of data',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg Cutoff',
                    avgCutoff.toStringAsFixed(1),
                    AppColors.ink500,
                    delta: delta,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: _buildStatItem(
                    'Vacancies',
                    '${latestYear.totalVacancies}',
                    AppColors.marigold500,
                  ),
                ),
              ],
            ),
            if (trends.length > 1) ...[
              const SizedBox(height: AppConstants.spaceMd),
              Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  _buildRangeChip('High', highest.toStringAsFixed(0), AppColors.sage500),
                  const SizedBox(width: AppConstants.spaceSm),
                  _buildRangeChip('Low', lowest.toStringAsFixed(0), AppColors.graphite700),
                  const Spacer(),
                  Icon(Icons.insights, size: 16, color: AppColors.ink500),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'View trend',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        '$label $value',
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {double? delta}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeTitleMedium,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (delta != null && delta.abs() >= 0.05) ...[
              const SizedBox(width: 4),
              Icon(
                delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: delta > 0 ? AppColors.sage500 : AppColors.error,
              ),
              Text(
                delta.abs().toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w500,
                  color: delta > 0 ? AppColors.sage500 : AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
