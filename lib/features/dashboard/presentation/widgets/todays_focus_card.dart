import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/core/widgets/empty_state.dart';
import 'package:prepnode/features/dashboard/domain/entities/daily_plan.dart';
import 'package:prepnode/features/dashboard/domain/entities/daily_task.dart';

/// Today's Focus Card
/// Shows AI study recommendation with continue button
class TodaysFocusCard extends StatelessWidget {
  final DailyPlan dailyPlan;
  final VoidCallback? onContinueStudy;
  final bool isLoading;

  const TodaysFocusCard({
    super.key,
    required this.dailyPlan,
    this.onContinueStudy,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (dailyPlan.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.spaceSm),
          if (dailyPlan.supportiveMessage != null) ...[
            Text(
              dailyPlan.supportiveMessage!,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
          ],
          _buildTaskPreview(),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Continue Study',
            onPressed: onContinueStudy ?? () {},
            backgroundColor: AppColors.marigold500,
            textColor: AppColors.ink900,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          color: AppColors.marigold500,
          size: 24,
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          'Today\'s Focus',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.lightOnPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskPreview() {
    final tasksToShow = dailyPlan.tasks.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < tasksToShow.length; i++) ...[
          _buildTaskItem(tasksToShow[i], i + 1),
          if (i < tasksToShow.length - 1) const SizedBox(height: AppConstants.spaceSm),
        ],
        if (dailyPlan.tasks.length > 3) ...[
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '+${dailyPlan.tasks.length - 3} more tasks',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskItem(DailyTask task, int index) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: task.status == TaskStatus.completed
                ? AppColors.sage500
                : AppColors.lightOnPrimary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: task.status == TaskStatus.completed
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.lightOnPrimary,
                  )
                : Text(
                    index.toString(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightOnPrimary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Text(
            task.topicName,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary,
              decoration: task.status == TaskStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        Text(
          '${task.durationMinutes}m',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.lightOnPrimary.withValues(alpha: 0.6),
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
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lightOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.lightOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.lightOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.sage500,
          width: 1,
        ),
      ),
      child: EmptyStates.caughtUp(
        padding: EdgeInsets.zero,
      ),
    );
  }
}
