import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/skeleton_loader.dart';
import 'package:prepnode/features/dashboard/domain/entities/progress_summary.dart';

/// Daily Progress Section
/// Shows study hours, completed tasks, and circular progress indicator
class DailyProgressSection extends StatelessWidget {
  final ProgressSummary progress;
  final bool isLoading;

  const DailyProgressSection({
    super.key,
    required this.progress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCircularProgress(),
          const SizedBox(width: AppConstants.spaceLg),
          Expanded(
            child: _buildStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: progress.syllabusCoveragePercent,
                  color: AppColors.ink900,
                  radius: 16,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 1 - progress.syllabusCoveragePercent,
                  color: AppColors.lightOutlineVariant,
                  radius: 16,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress.syllabusCoveragePercent * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeHeadlineSmall,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink900,
                ),
              ),
              Text(
                'Complete',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem(
          icon: Icons.local_fire_department,
          label: 'Current Streak',
          value: '${progress.currentStreak} days',
          color: AppColors.marigold500,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        _buildStatItem(
          icon: Icons.calendar_today,
          label: 'Total Study Days',
          value: '${progress.totalStudyDays} days',
          color: AppColors.sage500,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          SkeletonCard(
            height: 100,
            width: 100,
            margin: EdgeInsets.zero,
          ),
          const SizedBox(width: AppConstants.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
