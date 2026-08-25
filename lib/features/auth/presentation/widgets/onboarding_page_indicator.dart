import 'package:flutter/material.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Onboarding Page Indicator
/// Shows 4 dots with active state as a pill
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.ink900 : AppColors.lightOutlineVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
    );
  }
}
