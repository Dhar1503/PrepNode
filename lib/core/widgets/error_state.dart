import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Error State Component
/// Provides consistent error state UI with calm messaging per Design System §28
class ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  const ErrorState({
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
            color: AppColors.lightError,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.graphite700,
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

/// Pre-built error states for common scenarios
class ErrorStates {
  /// Network error - couldn't load data
  static Widget network({
    VoidCallback? onRetry,
    String? contextMessage,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: "We couldn't load this",
      subtitle: contextMessage ?? "Check your connection and try again",
      actionLabel: "Try again",
      onAction: onRetry,
      padding: padding,
    );
  }

  /// Server error
  static Widget server({
    VoidCallback? onRetry,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.cloud_off,
      title: "Something went wrong",
      subtitle: "Our servers had a hiccup. Please try again",
      actionLabel: "Try again",
      onAction: onRetry,
      padding: padding,
    );
  }

  /// Generic error
  static Widget generic({
    String? message,
    VoidCallback? onRetry,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.error_outline,
      title: "Something didn't work",
      subtitle: message ?? "This didn't load. Let's try again",
      actionLabel: "Try again",
      onAction: onRetry,
      padding: padding,
    );
  }

  /// Not found error
  static Widget notFound({
    String? itemType,
    VoidCallback? onAction,
    String? actionLabel,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.search_off,
      title: "Not found",
      subtitle: itemType != null 
          ? "We couldn't find that $itemType" 
          : "This item doesn't exist or was removed",
      actionLabel: actionLabel ?? "Go back",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Permission denied error
  static Widget permission({
    String? permissionType,
    VoidCallback? onAction,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.lock_outline,
      title: "Permission needed",
      subtitle: permissionType != null
          ? "You need $permissionType permission to continue"
          : "You don't have permission to access this",
      actionLabel: "Settings",
      onAction: onAction,
      padding: padding,
    );
  }

  /// Timeout error
  static Widget timeout({
    VoidCallback? onRetry,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.hourglass_empty,
      title: "Taking too long",
      subtitle: "This request timed out. Please try again",
      actionLabel: "Try again",
      onAction: onRetry,
      padding: padding,
    );
  }

  /// Offline error
  static Widget offline({
    VoidCallback? onRetry,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.cloud_off,
      title: "You're offline",
      subtitle: "Connect to the internet to continue",
      actionLabel: "Retry",
      onAction: onRetry,
      padding: padding,
    );
  }

  /// Data sync error
  static Widget sync({
    VoidCallback? onRetry,
    EdgeInsets? padding,
  }) {
    return ErrorState(
      icon: Icons.sync_problem,
      title: "Sync failed",
      subtitle: "Your data couldn't be synchronized",
      actionLabel: "Try again",
      onAction: onRetry,
      padding: padding,
    );
  }
}
