import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Prompt Chips Widget
/// Displays quick prompt options for the user
class PromptChips extends StatelessWidget {
  final List<String> prompts;
  final Function(String) onPromptSelected;

  const PromptChips({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spaceSm,
      runSpacing: AppConstants.spaceSm,
      children: prompts.map((prompt) {
        return GestureDetector(
          onTap: () => onPromptSelected(prompt),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on,
                  size: 16,
                  color: AppColors.marigold500,
                ),
                const SizedBox(width: AppConstants.spaceXs),
                Text(
                  prompt,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
