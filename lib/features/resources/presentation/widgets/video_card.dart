import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';

/// Video Card Widget
/// Specialized card for video resources (YouTube)
class VideoCard extends StatelessWidget {
  final StudyResource resource;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const VideoCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(resource.durationMinutes);

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
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.graphite700,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.radiusLg),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: AppColors.paper50.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Positioned(
                  top: AppConstants.spaceSm,
                  right: AppConstants.spaceSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink900.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      duration,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        fontWeight: FontWeight.w500,
                        color: AppColors.paper50,
                      ),
                    ),
                  ),
                ),
                if (onBookmark != null)
                  Positioned(
                    top: AppConstants.spaceSm,
                    left: AppConstants.spaceSm,
                    child: GestureDetector(
                      onTap: onBookmark,
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spaceSm),
                        decoration: BoxDecoration(
                          color: AppColors.ink900.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.paper50,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
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
                  
                  // Author and views
                  Row(
                    children: [
                      Text(
                        resource.author,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppColors.graphite700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatViewCount(resource.viewCount),
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
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

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m';
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
