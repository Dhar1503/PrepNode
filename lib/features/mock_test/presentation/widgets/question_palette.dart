import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';

/// Question Palette Widget
/// Grid of question numbers for navigation
class QuestionPalette extends StatelessWidget {
  final List<MockTestQuestion> questions;
  final int currentIndex;
  final Function(int) onQuestionTap;

  const QuestionPalette({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          top: BorderSide(color: AppColors.lightOutline),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Answered', AppColors.sage500),
              _buildLegend('Not Answered', AppColors.lightOutlineVariant),
              _buildLegend('Marked', AppColors.marigold500),
              _buildLegend('Skipped', AppColors.graphite700),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionNumber(questions[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionNumber(MockTestQuestion question, int index) {
    final isSelected = index == currentIndex;
    final color = _getQuestionColor(question);
    final borderColor = question.isMarkedForReview ? AppColors.marigold500 : null;

    return GestureDetector(
      onTap: () => onQuestionTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: borderColor != null
 ? Border.all(color: borderColor, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.ink900.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: _getTextColor(question),
            ),
          ),
        ),
      ),
    );
  }

  Color _getQuestionColor(MockTestQuestion question) {
    if (question.isMarkedForReview) {
      return AppColors.marigold500.withValues(alpha: 0.3);
    }
    if (question.isAnswered) {
      return AppColors.sage500;
    }
    if (question.isSkipped) {
      return AppColors.graphite700.withValues(alpha: 0.3);
    }
    return AppColors.lightOutlineVariant;
  }

  Color _getTextColor(MockTestQuestion question) {
    if (question.isMarkedForReview) {
      return AppColors.marigold500;
    }
    if (question.isAnswered) {
      return AppColors.lightOnPrimary;
    }
    if (question.isSkipped) {
      return AppColors.graphite700;
    }
    return AppColors.graphite700;
  }
}
