import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Onboarding Skip Button
/// Positioned top-right, allows skipping the carousel
class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingSkipButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceSm),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.graphite700.withValues(alpha: 0.7),
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
