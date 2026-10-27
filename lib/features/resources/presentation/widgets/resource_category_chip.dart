import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/resources/domain/entities/resource_category.dart';

/// Resource Category Chip Widget
/// Displays a resource category with icon and count
class ResourceCategoryChip extends StatelessWidget {
  final ResourceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const ResourceCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconData(category.icon),
            size: 18,
            color: isSelected ? AppColors.sage500 : AppColors.graphite700,
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Text(
            category.name,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.sage500 : AppColors.graphite700,
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceXs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sage500.withValues(alpha: 0.2)
                  : AppColors.graphite700.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              category.resourceCount.toString(),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.sage500 : AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.sage500.withValues(alpha: 0.2),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: AppConstants.spaceSm,
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'description':
        return Icons.description;
      case 'play_circle':
        return Icons.play_circle;
      case 'account_balance':
        return Icons.account_balance;
      case 'history':
        return Icons.history;
      case 'menu_book':
        return Icons.menu_book;
      case 'language':
        return Icons.language;
      default:
        return Icons.folder;
    }
  }
}
