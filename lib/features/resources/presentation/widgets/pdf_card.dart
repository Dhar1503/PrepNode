import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';

/// PDF Card Widget
/// Specialized card for PDF resources
class PdfCard extends StatelessWidget {
  final StudyResource resource;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDownload;
  final bool isBookmarked;
  final bool isDownloaded;

  const PdfCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onBookmark,
    this.onDownload,
    this.isBookmarked = false,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusLg),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      '${resource.pageCount} pages',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    resource.title,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  
                  // Author
                  Text(
                    resource.author,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  
                  // Actions
                  Row(
                    children: [
                      if (onBookmark != null)
                      _buildActionButton(
                        icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        onTap: onBookmark,
                        color: isBookmarked ? AppColors.sage500 : AppColors.graphite700,
                      ),
                      if (onDownload != null && resource.isDownloadable) ...[
                        const SizedBox(width: AppConstants.spaceSm),
                        _buildActionButton(
                          icon: isDownloaded ? Icons.offline_pin : Icons.download,
                          onTap: onDownload,
                          color: isDownloaded ? AppColors.sage500 : AppColors.graphite700,
                        ),
                      ],
                      const Spacer(),
                      _buildRating(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: AppColors.marigold500,
        ),
        const SizedBox(width: 4),
        Text(
          resource.rating.toStringAsFixed(1),
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            fontWeight: FontWeight.w500,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }
}
