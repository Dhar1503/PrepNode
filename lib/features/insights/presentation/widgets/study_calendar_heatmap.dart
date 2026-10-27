import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/study_habits.dart';

/// Study Calendar Heatmap
/// Visual representation of study consistency over time
class StudyCalendarHeatmap extends StatelessWidget {
  final List<DailyStudyData> dailyData;

  const StudyCalendarHeatmap({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    // Get last 30 days
    final recentData = dailyData.take(30).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Week labels
          _buildWeekLabels(),
          const SizedBox(height: AppConstants.spaceSm),
          // Heatmap grid
          _buildHeatmapGrid(recentData),
          const SizedBox(height: AppConstants.spaceSm),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildWeekLabels() {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          for (var day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
            Expanded(
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(List<DailyStudyData> data) {
    // Organize by weeks (rows of 7 days)
    final weeks = <List<DailyStudyData>>[];
    for (var i = 0; i < data.length; i += 7) {
      final end = (i + 7).clamp(0, data.length);
      weeks.add(data.sublist(i, end));
    }

    return Column(
      children: weeks.map((week) {
        return Row(
          children: [
            // Week number
            SizedBox(
              width: 24,
              child: Text(
                'W${weeks.indexOf(week) + 1}',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            // Days
            ...List.generate(7, (dayIndex) {
              if (dayIndex < week.length) {
                final dayData = week[dayIndex];
                return Expanded(
                  child: _buildDayCell(dayData),
                );
              } else {
                return const Expanded(child: SizedBox());
              }
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(DailyStudyData data) {
    final color = _getStudyColor(data.totalStudyMinutes);
    
    return Container(
      margin: const EdgeInsets.all(2),
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Less', AppColors.surfaceVariant),
        _buildLegendItem('', AppColors.marigold500.withValues(alpha: 0.3)),
        _buildLegendItem('', AppColors.marigold500.withValues(alpha: 0.6)),
        _buildLegendItem('More', AppColors.marigold500),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppConstants.radiusXs),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: AppConstants.spaceXs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ],
    );
  }

  Color _getStudyColor(int minutes) {
    if (minutes == 0) return AppColors.surfaceVariant;
    if (minutes < 60) return AppColors.marigold500.withValues(alpha: 0.3);
    if (minutes < 120) return AppColors.marigold500.withValues(alpha: 0.6);
    return AppColors.marigold500;
  }
}
