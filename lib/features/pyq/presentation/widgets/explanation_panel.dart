import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Explanation Panel Widget
/// Displays explanation after answering a question
class ExplanationPanel extends StatelessWidget {
  final String explanation;
  final String? relatedTopicId;
  final String? relatedTopicName;
  final VoidCallback? onRelatedTopicTap;
  final bool isExpanded;

  const ExplanationPanel({
    super.key,
    required this.explanation,
    this.relatedTopicId,
    this.relatedTopicName,
    this.onRelatedTopicTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isExpanded ? null : 0,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.spaceSm),
              _buildExplanationText(),
              if (relatedTopicName != null && onRelatedTopicTap != null) ...[
                const SizedBox(height: AppConstants.spaceMd),
                _buildRelatedTopicButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          color: AppColors.marigold500,
          size: 20,
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          'Explanation',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationText() {
    return Text(
      explanation,
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyMedium,
        color: AppColors.graphite700,
        height: 1.5,
      ),
    );
  }

  Widget _buildRelatedTopicButton() {
    return GestureDetector(
      onTap: onRelatedTopicTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.sage500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.sage500),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link,
              color: AppColors.sage500,
              size: 16,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Text(
              'Related: $relatedTopicName',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.sage500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
