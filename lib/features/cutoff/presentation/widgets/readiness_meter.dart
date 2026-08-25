import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';

/// Widget displaying readiness level as a visual meter
class ReadinessMeter extends StatelessWidget {
  final double readinessPercentage;
  final String readinessLevel;

  const ReadinessMeter({
    super.key,
    required this.readinessPercentage,
    required this.readinessLevel,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getReadinessColor(readinessLevel);

    return Container(
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
          Text(
            'Readiness Level',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${readinessPercentage.toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeDisplayLarge,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      readinessLevel.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceLg),
              Expanded(
                child: _buildProgressBar(color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: readinessPercentage / 100,
          backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 12,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
            Text(
              '100%',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getReadinessColor(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return AppColors.sage500;
      case 'good':
        return AppColors.marigold500;
      case 'moderate':
        return AppColors.ink500;
      case 'needs_improvement':
        return AppColors.error;
      default:
        return AppColors.graphite700;
    }
  }
}
