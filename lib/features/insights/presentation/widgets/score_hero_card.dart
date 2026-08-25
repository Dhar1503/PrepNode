import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';

/// Score Hero Card
/// Displays PrepGraph Score with breakdown
class ScoreHeroCard extends StatelessWidget {
  final double score;
  final ScoreComponents scoreComponents;
  final VoidCallback onTap;

  const ScoreHeroCard({
    super.key,
    required this.score,
    required this.scoreComponents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PrepGraph Score',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  'See breakdown',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.ink500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '/ 100',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    color: AppColors.graphite700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildScoreComponents(),
        ],
      ),
    );
  }

  Widget _buildScoreComponents() {
    return Column(
      children: [
        _buildComponentRow('Topic Completion', scoreComponents.topicCompletion),
        const SizedBox(height: AppConstants.spaceSm),
        _buildComponentRow('PYQ Performance', scoreComponents.pyqPerformance),
        const SizedBox(height: AppConstants.spaceSm),
        _buildComponentRow('Mock Test Accuracy', scoreComponents.mockAccuracy),
        const SizedBox(height: AppConstants.spaceSm),
        _buildComponentRow('Consistency', scoreComponents.consistency),
        const SizedBox(height: AppConstants.spaceSm),
        _buildComponentRow('Revision Discipline', scoreComponents.revisionDiscipline),
      ],
    );
  }

  Widget _buildComponentRow(String label, double value) {
    final displayValue = value.toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getComponentColor(value),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        SizedBox(
          width: 32,
          child: Text(
            '$displayValue%',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getComponentColor(double value) {
    if (value >= 80) return AppColors.sage500;
    if (value >= 60) return AppColors.marigold500;
    return AppColors.ink500;
  }
}
