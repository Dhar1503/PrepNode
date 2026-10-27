import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/learner_progress.dart';

/// Score Hero Card
/// Displays PrepNode Score with breakdown
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
        // A tint of ink rather than flat white. White-on-cream left the card
        // with almost no edge against the paper background — the border and
        // the tint together are what make it read as a raised surface.
        color: AppColors.ink900.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.ink900.withValues(alpha: 0.12)),
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
                'PrepNode Score',
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
              // Counts up from zero on entry. A single 380ms tween — the
              // number is the point of this card, so it is the one thing
              // worth drawing the eye to.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                    height: 1.0,
                  ),
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
    final barColor = _getComponentColor(value);
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
          // 6, not 4: at 4px the fill was a hairline and the tinted track
          // below would have been invisible.
          height: 6,
          decoration: BoxDecoration(
            // Track tinted with the bar's own colour instead of a flat grey,
            // so each row reads as one object and an empty bar still shows
            // where the bar is.
            color: barColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value / 100).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, factor, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        SizedBox(
          // 44, not 32: a three-digit value ("100%") did not fit and wrapped
          // onto a second line as "100" / "%".
          width: 44,
          child: Text(
            '$displayValue%',
            maxLines: 1,
            softWrap: false,
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
