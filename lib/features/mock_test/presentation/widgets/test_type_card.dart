import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';

/// Test Type Card Widget
/// Displays a mock test type option
class TestTypeCard extends StatelessWidget {
  final MockTestType type;
  final String title;
  final String description;
  final int durationMinutes;
  final int questionCount;
  final VoidCallback onTap;
  final bool isSelected;

  const TestTypeCard({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.questionCount,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink900.withValues(alpha: 0.05) : AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.ink900 : AppColors.lightOutline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              title,
              style: GoogleFonts.fraunces(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                _buildStat(
                  icon: Icons.access_time,
                  label: '$durationMinutes min',
                ),
                const SizedBox(width: AppConstants.spaceLg),
                _buildStat(
                  icon: Icons.quiz,
                  label: '$questionCount questions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    switch (type) {
      case MockTestType.topic:
        icon = Icons.topic;
        break;
      case MockTestType.subject:
        icon = Icons.book;
        break;
      case MockTestType.sectional:
        icon = Icons.view_list;
        break;
      case MockTestType.full:
        icon = Icons.assignment;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.ink900 : AppColors.lightOutlineVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
        size: 24,
      ),
    );
  }

  Widget _buildStat({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.graphite700,
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }
}
