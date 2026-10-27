import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Breadcrumb Navigation Widget
/// Shows navigation path with clickable items
class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(BreadcrumbItem)? onItemTap;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildBreadcrumbs(),
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbs() {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      widgets.add(
        _buildBreadcrumbItem(item, isLast),
      );

      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.graphite700,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, bool isLast) {
    return GestureDetector(
      onTap: isLast ? null : () => onItemTap?.call(item),
      child: Text(
        item.label,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodyMedium,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
          color: isLast ? AppColors.ink900 : AppColors.graphite700,
        ),
      ),
    );
  }
}

class BreadcrumbItem {
  final String id;
  final String label;
  final dynamic data;

  const BreadcrumbItem({
    required this.id,
    required this.label,
    this.data,
  });
}
