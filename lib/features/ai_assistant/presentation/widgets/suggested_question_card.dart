import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/suggested_question.dart';

/// Suggested Question Card Widget
/// Displays a suggested question that the user can tap to ask
class SuggestedQuestionCard extends StatelessWidget {
  final SuggestedQuestion question;
  final VoidCallback onTap;

  const SuggestedQuestionCard({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppConstants.spaceSm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(question.category),
              size: 16,
              color: AppColors.sage500,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Flexible(
              child: Text(
                question.question,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.ink900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (question.isPopular) ...[
              const SizedBox(width: AppConstants.spaceSm),
              Icon(
                Icons.local_fire_department,
                size: 16,
                color: AppColors.marigold500,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'concept':
        return Icons.lightbulb_outline;
      case 'practice':
        return Icons.edit_note;
      case 'revision':
        return Icons.refresh;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}
