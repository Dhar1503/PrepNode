import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Widget for filtering by year range
class YearFilter extends StatelessWidget {
  final List<int> availableYears;
  final int selectedYear;
  final ValueChanged<int> onYearSelected;

  const YearFilter({
    super.key,
    required this.availableYears,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableYears.length,
        itemBuilder: (context, index) {
          final year = availableYears[index];
          final isSelected = year == selectedYear;

          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceSm),
            child: ChoiceChip(
              label: Text(year.toString()),
              selected: isSelected,
              onSelected: (_) => onYearSelected(year),
              selectedColor: AppColors.sage500.withValues(alpha: 0.2),
              labelStyle: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.sage500 : AppColors.graphite700,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
            ),
          );
        },
      ),
    );
  }
}
