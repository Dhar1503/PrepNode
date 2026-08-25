import 'package:flutter/material.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/resources/domain/entities/download_status.dart';

/// Download Button Widget
/// Shows download status and allows download action
class DownloadButton extends StatelessWidget {
  final DownloadStatus? status;
  final VoidCallback onTap;
  final bool isDownloadable;

  const DownloadButton({
    super.key,
    required this.status,
    required this.onTap,
    required this.isDownloadable,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDownloadable) {
      return const SizedBox.shrink();
    }

    switch (status?.state) {
      case DownloadState.downloading:
        return _buildDownloading();
      case DownloadState.completed:
        return _buildCompleted();
      case DownloadState.failed:
        return _buildFailed();
      case DownloadState.paused:
        return _buildPaused();
      case DownloadState.notDownloaded:
      default:
        return _buildNotDownloaded();
    }
  }

  Widget _buildNotDownloaded() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.sage500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              size: 18,
              color: AppColors.sage500,
            ),
            const SizedBox(width: AppConstants.spaceXs),
            Text(
              'Download',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.sage500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloading() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.marigold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.marigold500),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Text(
            '${((status?.progress ?? 0) * 100).toInt()}%',
            style: TextStyle(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w500,
              color: AppColors.marigold500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.sage500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.offline_pin,
              size: 18,
              color: AppColors.sage500,
            ),
            const SizedBox(width: AppConstants.spaceXs),
            Text(
              'Offline',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.sage500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailed() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 18,
              color: AppColors.error,
            ),
            const SizedBox(width: AppConstants.spaceXs),
            Text(
              'Retry',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaused() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.marigold500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              size: 18,
              color: AppColors.marigold500,
            ),
            const SizedBox(width: AppConstants.spaceXs),
            Text(
              'Resume',
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.marigold500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
