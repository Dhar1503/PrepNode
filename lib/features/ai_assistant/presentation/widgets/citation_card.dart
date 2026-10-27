import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Citation Card Widget
/// Displays source citations for AI responses
class CitationCard extends StatelessWidget {
  final List<String> citations;
  final VoidCallback? onCitationTap;

  const CitationCard({
    super.key,
    required this.citations,
    this.onCitationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: AppConstants.spaceSm),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.azure500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.azure500.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.source,
                size: 16,
                color: AppColors.azure500,
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                'Sources',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.azure500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ...citations.map((citation) {
            return GestureDetector(
              onTap: onCitationTap,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceXs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.link,
                      size: 12,
                      color: AppColors.azure500,
                    ),
                    const SizedBox(width: AppConstants.spaceXs),
                    Expanded(
                      child: Text(
                        citation,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
