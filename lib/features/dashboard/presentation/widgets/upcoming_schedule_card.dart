import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/utils/formatters.dart';
import 'package:prepgraph/core/widgets/skeleton_loader.dart';
import 'package:prepgraph/features/dashboard/domain/entities/upcoming_schedule.dart';

/// Upcoming Schedule Card
/// Shows upcoming scheduled items
class UpcomingScheduleCard extends StatelessWidget {
  final List<UpcomingSchedule> schedule;
  final bool isLoading;

  const UpcomingScheduleCard({
    super.key,
    required this.schedule,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (schedule.isEmpty) {
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
          ...schedule.map((item) => _buildScheduleItem(item)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Upcoming Schedule',
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
    );
  }

  Widget _buildScheduleItem(UpcomingSchedule item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Row(
        children: [
          _buildScheduleIcon(item.type),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          _buildDateBadge(item.scheduledAt),
        ],
      ),
    );
  }

  Widget _buildScheduleIcon(ScheduleType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ScheduleType.mockTest:
        icon = Icons.assignment;
        color = AppColors.marigold500;
        break;
      case ScheduleType.revision:
        icon = Icons.refresh;
        color = AppColors.sage500;
        break;
      case ScheduleType.milestone:
        icon = Icons.flag;
        color = AppColors.ink900;
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

  Widget _buildDateBadge(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    String dateText;
    if (difference.inDays == 0) {
      dateText = 'Today';
    } else if (difference.inDays == 1) {
      dateText = 'Tomorrow';
    } else if (difference.inDays < 7) {
      dateText = '${difference.inDays}d';
    } else {
      dateText = Formatters.formatDateShort(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink900.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        dateText,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w500,
          color: AppColors.ink900,
        ),
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
            width: 180,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          for (int i = 0; i < 2; i++) ...[
            SkeletonListTile(
              padding: EdgeInsets.zero,
            ),
            if (i < 1) const SizedBox(height: AppConstants.spaceMd),
          ],
        ],
      ),
    );
  }
}
