import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';

/// Book Card Widget
/// Specialized card for book resources
class BookCard extends StatelessWidget {
  final StudyResource resource;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const BookCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
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
        child: Row(
          children: [
            // Book cover placeholder
            Container(
              width: 80,
              height: 120,
              margin: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.marigold500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: AppColors.marigold500.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 40,
                    color: AppColors.marigold500,
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
            Expanded(
              child: Padding(
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
                      'by ${resource.author}',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    
                    // Difficulty
                    if (resource.difficulty.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          resource.difficulty,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            fontWeight: FontWeight.w500,
                            color: _getDifficultyColor(),
                          ),
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Rating and bookmark
                    Row(
                      children: [
                        _buildRating(),
                        const Spacer(),
                        if (onBookmark != null)
                          GestureDetector(
                            onTap: onBookmark,
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? AppColors.sage500 : AppColors.graphite700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
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

  Color _getDifficultyColor() {
    switch (resource.difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.sage500;
      case 'intermediate':
        return AppColors.marigold500;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.graphite700;
    }
  }
}
