import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/chat_message.dart';

/// Chat Bubble Widget
/// Displays a single chat message with appropriate styling based on role
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onCopy;

  const ChatBubble({
    super.key,
    required this.message,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.sage500,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.sage500
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          color: isUser ? Colors.white : AppColors.ink900,
                          height: 1.5,
                        ),
                      ),
                      if (message.citations != null &&
                          message.citations!.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceSm),
                        ...message.citations!.map((citation) => Padding(
                              padding: const EdgeInsets.only(
                                  top: AppConstants.spaceXs),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 12,
                                    color: isUser
                                        ? Colors.white70
                                        : AppColors.graphite700,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      citation,
                                      style: GoogleFonts.inter(
                                        fontSize: AppConstants.fontSizeBodySmall,
                                        color: isUser
                                            ? Colors.white70
                                            : AppColors.graphite700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppConstants.spaceSm),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.graphite700,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
              if (!isUser && onCopy != null) ...[
                const SizedBox(width: AppConstants.spaceSm),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
