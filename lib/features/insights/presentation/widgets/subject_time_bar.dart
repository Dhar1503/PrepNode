import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Subject Time Bar
/// Displays time spent per subject as a progress bar
class SubjectTimeBar extends StatelessWidget {
  final String subjectName;
  final int totalMinutes;
  final double percentage;

  const SubjectTimeBar({
    super.key,
    required this.subjectName,
    required this.totalMinutes,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Container(
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
                  subjectName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${hours}h ${minutes}m',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.ink500,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            '${percentage.toStringAsFixed(1)}% of total time',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}
