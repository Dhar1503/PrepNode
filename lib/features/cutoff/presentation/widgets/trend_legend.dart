import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Widget displaying legend for trend graph
class TrendLegend extends StatelessWidget {
  final List<LegendItem> items;

  const TrendLegend({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Wrap(
        spacing: AppConstants.spaceMd,
        runSpacing: AppConstants.spaceSm,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class LegendItem {
  final String label;
  final Color color;

  const LegendItem({
    required this.label,
    required this.color,
  });
}
