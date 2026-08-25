import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Option Tile Widget
/// Displays an answer option with different states
class OptionTile extends StatelessWidget {
  final String optionText;
  final int optionIndex;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isRevealed;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.optionText,
    required this.optionIndex,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isRevealed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + optionIndex); // A, B, C, D

    return GestureDetector(
      onTap: isRevealed ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: _getBorderColor(),
            width: _getBorderWidth(),
          ),
        ),
        child: Row(
          children: [
            _buildOptionLetter(letter),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
            if (isRevealed && isCorrect)
              Icon(
                Icons.check_circle,
                color: AppColors.sage500,
                size: 24,
              ),
            if (isRevealed && isIncorrect)
              Icon(
                Icons.cancel,
                color: AppColors.graphite700,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionLetter(String letter) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _getLetterBackgroundColor(),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            fontWeight: FontWeight.w600,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isRevealed) {
      if (isCorrect) {
        return AppColors.sage500.withValues(alpha: 0.15);
      }
      if (isIncorrect) {
        return AppColors.graphite700.withValues(alpha: 0.1);
      }
    }
    if (isSelected) {
      return AppColors.ink900.withValues(alpha: 0.05);
    }
    return AppColors.paper50;
  }

  Color _getLetterBackgroundColor() {
    if (isRevealed) {
      if (isCorrect) {
        return AppColors.sage500;
      }
      if (isIncorrect) {
        return AppColors.graphite700;
      }
    }
    if (isSelected) {
      return AppColors.ink900;
    }
    return AppColors.lightOutlineVariant;
  }

  Color _getBorderColor() {
    if (isRevealed) {
      if (isCorrect) {
        return AppColors.sage500;
      }
      if (isIncorrect) {
        return AppColors.graphite700;
      }
    }
    if (isSelected) {
      return AppColors.ink900;
    }
    return AppColors.lightOutline;
  }

  double _getBorderWidth() {
    if (isSelected || isRevealed) {
      return 2.0;
    }
    return 1.0;
  }

  Color _getTextColor() {
    if (isRevealed) {
      if (isCorrect) {
        return AppColors.sage500;
      }
      if (isIncorrect) {
        return AppColors.graphite700;
      }
    }
    if (isSelected) {
      return AppColors.ink900;
    }
    return AppColors.ink900;
  }
}
