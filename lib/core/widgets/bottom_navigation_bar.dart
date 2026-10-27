import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Bottom Navigation Bar
/// Main navigation for the app with 5 tabs
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          top: BorderSide(
            color: AppColors.lightOutline,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceSm,
            vertical: AppConstants.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.menu_book,
                  label: 'Learn',
                  index: 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.quiz,
                  label: 'Practice',
                  index: 2,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.insights,
                  label: 'Insights',
                  index: 3,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Horizontal padding is 2, not spaceSm: five Expanded slots across a
        // phone leave ~75px each, and 32px of inset truncated every label to
        // "Ho…" / "Pra…" / "Insi…" / "Pro…". The slot itself (plus
        // HitTestBehavior.opaque) already provides the tap target, so the
        // inset bought nothing.
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: AppConstants.spaceXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.ink900 : AppColors.graphite700,
              size: 24,
            ),
            const SizedBox(height: 4),
            // scaleDown so a long label shrinks slightly rather than losing
            // characters to an ellipsis.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.ink900 : AppColors.graphite700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
