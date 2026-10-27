import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/skeleton_loader.dart';
import 'package:prepnode/features/dashboard/domain/entities/recent_activity.dart';

/// Recent Activity Card
/// Shows recently completed activities
class RecentActivityCard extends StatelessWidget {
  final List<RecentActivity> activities;
  final bool isLoading;

  const RecentActivityCard({
    super.key,
    required this.activities,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (activities.isEmpty) {
      return const SizedBox.shrink();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.spaceMd),
          ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Recent Activity',
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Row(
        children: [
          _buildActivityIcon(activity.type),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
                if (activity.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (activity.durationMinutes != null) ...[
            const SizedBox(width: AppConstants.spaceSm),
            Text(
              '${activity.durationMinutes}m',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityIcon(ActivityType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ActivityType.topicCompleted:
        icon = Icons.check_circle;
        color = AppColors.sage500;
        break;
      case ActivityType.pyqPractice:
        icon = Icons.quiz;
        color = AppColors.marigold500;
        break;
      case ActivityType.mockTest:
        icon = Icons.assignment;
        color = AppColors.ink900;
        break;
      case ActivityType.revision:
        icon = Icons.refresh;
        color = AppColors.sage500;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          for (int i = 0; i < 3; i++) ...[
            SkeletonListTile(
              padding: EdgeInsets.zero,
            ),
            if (i < 2) const SizedBox(height: AppConstants.spaceMd),
          ],
        ],
      ),
    );
  }
}
