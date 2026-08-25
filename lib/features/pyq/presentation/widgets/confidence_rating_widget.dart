import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';

/// Confidence Rating Widget
/// Allows user to rate their confidence after answering
class ConfidenceRatingWidget extends StatelessWidget {
  final ConfidenceRating? selectedRating;
  final Function(ConfidenceRating) onRatingSelected;

  const ConfidenceRatingWidget({
    super.key,
    this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How confident are you?',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ConfidenceRating.values.map((rating) {
              return _buildRatingButton(rating);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton(ConfidenceRating rating) {
    final isSelected = selectedRating == rating;
    final label = _getRatingLabel(rating);
    final icon = _getRatingIcon(rating);

    return GestureDetector(
      onTap: () => onRatingSelected(rating),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.ink900 : AppColors.paper50,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.ink900 : AppColors.lightOutline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.lightOnPrimary : AppColors.graphite700,
              size: 24,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.ink900 : AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingLabel(ConfidenceRating rating) {
    switch (rating) {
      case ConfidenceRating.veryLow:
        return 'Very Low';
      case ConfidenceRating.low:
        return 'Low';
      case ConfidenceRating.medium:
        return 'Medium';
      case ConfidenceRating.high:
        return 'High';
      case ConfidenceRating.veryHigh:
        return 'Very High';
    }
  }

  IconData _getRatingIcon(ConfidenceRating rating) {
    switch (rating) {
      case ConfidenceRating.veryLow:
        return Icons.sentiment_very_dissatisfied;
      case ConfidenceRating.low:
        return Icons.sentiment_dissatisfied;
      case ConfidenceRating.medium:
        return Icons.sentiment_neutral;
      case ConfidenceRating.high:
        return Icons.sentiment_satisfied;
      case ConfidenceRating.veryHigh:
        return Icons.sentiment_very_satisfied;
    }
  }
}
