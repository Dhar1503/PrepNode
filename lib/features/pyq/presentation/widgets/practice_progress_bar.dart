import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Practice Progress Bar Widget
/// Displays progress through a practice session
class PracticeProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int? correctCount;
  final VoidCallback? onExit;

  const PracticeProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    this.correctCount,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / totalQuestions;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Question ${currentIndex + 1} of $totalQuestions',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.graphite700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (correctCount != null) ...[
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  'Correct: $correctCount',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.sage500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: AppConstants.spaceSm),
              GestureDetector(
                onTap: onExit,
                child: Icon(
                  Icons.close,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightOutlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink900),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
