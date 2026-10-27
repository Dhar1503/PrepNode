import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Headline Stats Row
/// Displays key statistics in a horizontal row
class HeadlineStatsRow extends StatelessWidget {
  final int weeklyStudyMinutes;
  final int topicsMastered;
  final int currentStreak;
  final VoidCallback onTapTimeInvested;
  final VoidCallback onTapMastery;

  const HeadlineStatsRow({
    super.key,
    required this.weeklyStudyMinutes,
    required this.topicsMastered,
    required this.currentStreak,
    required this.onTapTimeInvested,
    required this.onTapMastery,
  });

  @override
  Widget build(BuildContext context) {
    final hours = weeklyStudyMinutes ~/ 60;
    final minutes = weeklyStudyMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.schedule,
              label: 'This Week',
              value: '${hours}h ${minutes}m',
              onTap: onTapTimeInvested,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle,
              label: 'Mastered',
              value: '$topicsMastered',
              onTap: onTapMastery,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              label: 'Streak',
              value: '$currentStreak',
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(
              icon,
              color: AppColors.marigold500,
              size: 24,
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeTitleMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
