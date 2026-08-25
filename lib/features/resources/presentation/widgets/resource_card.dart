import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';

/// Resource Card Widget
/// Displays a study resource with thumbnail, title, type, and metadata
class ResourceCard extends StatelessWidget {
  final StudyResource resource;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDownload;
  final bool isBookmarked;
  final bool isDownloaded;

  const ResourceCard({
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
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            // Thumbnail
            _buildThumbnail(),
            const SizedBox(width: AppConstants.spaceMd),
            
            // Content
            Expanded(
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
                  
                  // Type and metadata
                  Row(
                    children: [
                      Flexible(child: _buildTypeChip()),
                      if (resource.difficulty.isNotEmpty) ...[
                        const SizedBox(width: AppConstants.spaceXs),
                        Flexible(child: _buildDifficultyChip()),
                      ],
                      const Spacer(),
                      _buildRating(),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  
                  // Author and views
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.graphite700,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          resource.author,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppColors.graphite700,
                      ),
                      const SizedBox(width: 4),
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
            
            // Action buttons
            Column(
              children: [
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
                if (onDownload != null && resource.isDownloadable)
                  IconButton(
                    icon: Icon(
                      isDownloaded ? Icons.offline_pin : Icons.download,
                      color: isDownloaded ? AppColors.sage500 : AppColors.graphite700,
                    ),
                    onPressed: onDownload,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    IconData icon;
    Color color;

    switch (resource.type) {
      case ResourceType.pdf:
        icon = Icons.picture_as_pdf;
        color = AppColors.error;
        break;
      case ResourceType.book:
        icon = Icons.menu_book;
        color = AppColors.marigold500;
        break;
      case ResourceType.youtube:
        icon = Icons.play_circle;
        color = AppColors.error;
        break;
      case ResourceType.website:
        icon = Icons.language;
        color = AppColors.sage500;
        break;
      case ResourceType.governmentMaterial:
        icon = Icons.account_balance;
        color = AppColors.ink900;
        break;
      case ResourceType.previousPapers:
        icon = Icons.history;
        color = AppColors.marigold500;
        break;
      case ResourceType.notes:
        icon = Icons.description;
        color = AppColors.sage500;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }

  Widget _buildTypeChip() {
    String label;
    switch (resource.type) {
      case ResourceType.pdf:
        label = 'PDF';
        break;
      case ResourceType.book:
        label = 'Book';
        break;
      case ResourceType.youtube:
        label = 'Video';
        break;
      case ResourceType.website:
        label = 'Website';
        break;
      case ResourceType.governmentMaterial:
        label = 'Official';
        break;
      case ResourceType.previousPapers:
        label = 'Papers';
        break;
      case ResourceType.notes:
        label = 'Notes';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w500,
          color: AppColors.sage500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDifficultyChip() {
    String label;
    Color color;
    
    switch (resource.difficulty.toLowerCase()) {
      case 'beginner':
        label = 'Beginner';
        color = AppColors.sage500;
        break;
      case 'intermediate':
        label = 'Intermediate';
        color = AppColors.marigold500;
        break;
      case 'advanced':
        label = 'Advanced';
        color = AppColors.error;
        break;
      default:
        label = resource.difficulty;
        color = AppColors.graphite700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 14,
          color: AppColors.marigold500,
        ),
        const SizedBox(width: 2),
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

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
