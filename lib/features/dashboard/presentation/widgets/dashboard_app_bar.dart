import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Dashboard App Bar
/// Custom app bar with greeting, user avatar, and notification icon
class DashboardAppBar extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;

  const DashboardAppBar({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.onNotificationTap,
    this.hasUnreadNotifications = false,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: GoogleFonts.fraunces(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          _buildNotificationButton(),
          const SizedBox(width: AppConstants.spaceSm),
          _buildAvatarButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      onPressed: onNotificationTap,
      icon: Stack(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.ink900,
          ),
          if (hasUnreadNotifications)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.marigold500,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    );
  }

  Widget _buildAvatarButton() {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.sage500,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.lightOutline,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.lightOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
