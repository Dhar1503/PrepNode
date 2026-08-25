import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';

/// Empty State Component
/// Provides consistent empty state UI with invitation framing per Design System §26
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceXl,
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.sage500,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppConstants.spaceLg),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink900,
                foregroundColor: AppColors.lightOnPrimary,
                elevation: AppConstants.elevation1,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.buttonHorizontalPadding,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeLabelLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pre-built empty states for common scenarios
class EmptyStates {
  /// Empty state for first-time users with no progress
  static Widget firstTime({
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.explore_outlined,
      title: "Your progress map will build up as you go",
      subtitle: "Ready to start exploring your first topic?",
      actionLabel: "Explore your first topic",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Empty state for caught up / all tasks done
  static Widget caughtUp({
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.check_circle_outline,
      title: "You're all caught up!",
      subtitle: "Great consistency. Take a well-deserved break.",
      actionLabel: "Practice something extra",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Empty state for no search results
  static Widget noResults({
    String? searchQuery,
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: "No results found",
      subtitle: searchQuery != null
          ? "We couldn't find anything matching \"$searchQuery\""
          : "Try adjusting your search terms",
      actionLabel: "Clear search",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Empty state for no notifications
  static Widget noNotifications({
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.notifications_none_outlined,
      title: "No notifications yet",
      subtitle: "We'll let you know when there's something important",
      padding: padding,
    );
  }

  /// Empty state for no bookmarks
  static Widget noBookmarks({
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.bookmark_border,
      title: "No bookmarks yet",
      subtitle: "Bookmark questions and resources to find them easily",
      actionLabel: "Browse topics",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Empty state for no resources
  static Widget noResources({
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.folder_open,
      title: "No resources available",
      subtitle: "Learning materials for this topic will appear here",
      actionLabel: "Browse all resources",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Empty state for no achievements
  static Widget noAchievements({
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.emoji_events_outlined,
      title: "Your first milestone will appear here",
      subtitle: "Keep learning to unlock personal achievements",
      padding: padding,
    );
  }

  /// Empty state for no activity
  static Widget noActivity({
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.history,
      title: "No recent activity",
      subtitle: "Your learning journey will be tracked here",
      padding: padding,
    );
  }

  /// Empty state for offline mode
  static Widget offline({
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: Icons.cloud_off,
      title: "You're offline",
      subtitle: "Some features require an internet connection",
      actionLabel: "Retry connection",
      onAction: onAction,
      padding: padding,
    );
  }

  /// For analytics screens that have nothing to show until the student has
  /// actually practised. These screens previously rendered section headers
  /// above blank space, which reads as a broken page rather than "no data
  /// yet" — so each one says what it will show and offers a way to start.
  static Widget needsPractice({
    required String title,
    required String subtitle,
    IconData icon = Icons.insights_outlined,
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionLabel: onAction == null ? null : 'Start practising',
      onAction: onAction,
      padding: padding,
    );
  }
}
