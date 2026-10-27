import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/conversation.dart';

/// Conversation Tile Widget
/// Displays a conversation in the history list
class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onBookmarkToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.spaceMd),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.sage500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: AppColors.sage500,
          ),
        ),
        title: Text(
          conversation.title,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              '${conversation.messageCount} messages',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              _formatDate(conversation.updatedAt),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onBookmarkToggle != null)
              IconButton(
                icon: Icon(
                  conversation.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: conversation.isBookmarked
                      ? AppColors.sage500
                      : AppColors.graphite700,
                ),
                onPressed: onBookmarkToggle,
                tooltip: conversation.isBookmarked
                    ? 'Remove bookmark'
                    : 'Add bookmark',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.rose500,
                ),
                onPressed: onDelete,
                tooltip: 'Delete conversation',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
