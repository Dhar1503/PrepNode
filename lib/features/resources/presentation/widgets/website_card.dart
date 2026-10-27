import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';

/// Website Card Widget
/// Specialized card for website resources
class WebsiteCard extends StatelessWidget {
  final StudyResource resource;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked, 
      isOfficial;

  const WebsiteCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.isOfficial = false,
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
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            // Website icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sage500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.sage500,
                size: 32,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with official badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resource.title,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodyMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOfficial)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sage500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          ),
                          child: Text(
                            'Official',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeBodySmall,
                              fontWeight: FontWeight.w500,
                              color: AppColors.sage500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  
                  // URL
                  Text(
                    _extractDomain(resource.url),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                    maxLines: 1,
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
                    ],
                  ),
                ],
              ),
            ),
            
            // Bookmark button
            if (onBookmark != null)
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.sage500 : AppColors.graphite700,
                ),
                onPressed: onBookmark,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
