import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/option_tile.dart';

/// Question Card Widget
/// Displays a PYQ question with options
class QuestionCard extends StatelessWidget {
  final PyqQuestion question;
  final int? selectedOptionIndex;
  final bool isRevealed;
  final Function(int) onOptionTap;
  final bool showBookmark;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedOptionIndex,
    this.isRevealed = false,
    required this.onOptionTap,
    this.showBookmark = true,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.spaceMd),
          _buildQuestionText(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildOptions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildDifficultyBadge(),
        const SizedBox(width: AppConstants.spaceSm),
        _buildYearBadge(),
        const SizedBox(width: AppConstants.spaceSm),
        Flexible(child: _buildVerificationBadge()),
        const Spacer(),
        if (showBookmark)
          GestureDetector(
            onTap: onBookmarkTap,
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.marigold500 : AppColors.graphite700,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    String label;
    Color color;

    switch (question.difficulty) {
      case DifficultyLevel.easy:
        label = 'Easy';
        color = AppColors.sage500;
        break;
      case DifficultyLevel.medium:
        label = 'Medium';
        color = AppColors.marigold500;
        break;
      case DifficultyLevel.hard:
        label = 'Hard';
        color = AppColors.ink900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildYearBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        '${question.year}',
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.graphite700,
        ),
      ),
    );
  }

  // Nothing in this screen previously told a user whether a question was an
  // actual confirmed past paper question — Phase 1C data-integrity fix, so
  // seed/illustrative questions can't be mistaken for confirmed real PYQs.
  Widget _buildVerificationBadge() {
    final isVerified = question.verificationStatus == 'verified';
    final color = isVerified ? AppColors.sage500 : AppColors.marigold500;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.help_outline,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isVerified ? 'Verified PYQ' : 'Unverified',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText() {
    return Text(
      question.questionText,
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyLarge,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
        height: 1.5,
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        final isSelected = selectedOptionIndex == index;
        final isCorrect = isRevealed && index == question.correctAnswerIndex;
        final isIncorrect = isRevealed && isSelected && !isCorrect;

        return OptionTile(
          optionText: option,
          optionIndex: index,
          isSelected: isSelected,
          isCorrect: isCorrect,
          isIncorrect: isIncorrect,
          isRevealed: isRevealed,
          onTap: () => onOptionTap(index),
        );
      }).toList(),
    );
  }
}
