import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';

/// Downloads / Offline Resources Screen
/// Displays downloaded resources for offline access
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadedResourcesProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Offline Resources',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(context, ref),
          ),
        ],
      ),
      body: downloadsAsync.when(
        data: (downloads) => _buildContent(context, ref, downloads),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, downloads) {
    if (downloads.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Storage info
        _buildStorageInfo(downloads),

        const SizedBox(height: AppConstants.spaceMd),

        // Downloads list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return _buildDownloadTile(context, ref, download);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(List downloads) {
    final totalSize = downloads.fold<num>(
      0,
      (sum, download) => sum + (download.fileSizeBytes ?? 0),
    );

    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: AppColors.sage500,
            size: 32,
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Used',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  _formatFileSize(totalSize.toInt()),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${downloads.length} files',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context, WidgetRef ref, download) {
    return FutureBuilder(
      future: ref.read(resourceByIdProvider(download.resourceId).future),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final resource = snapshot.data;
          if (resource == null) return const SizedBox.shrink();
          
          return Container(
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
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.sage500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    _getResourceIcon(resource.type.name),
                    color: AppColors.sage500,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spaceXs),
                      Text(
                        _formatFileSize(download.fileSizeBytes),
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                      if (download.downloadedAt != null)
                        Text(
                          'Downloaded ${_formatDate(download.downloadedAt!)}',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Actions
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteDownload(context, ref, download.resourceId),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'book':
        return Icons.menu_book;
      case 'youtube':
        return Icons.play_circle;
      case 'website':
        return Icons.language;
      default:
        return Icons.description;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes bytes';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _deleteDownload(BuildContext context, WidgetRef ref, String resourceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Download',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this offline resource?',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final userId = ref.read(authProvider).userId;
              if (userId != null && userId.isNotEmpty) {
                await ref.read(resourceRepositoryProvider).deleteDownload(userId, resourceId);
                ref.invalidate(downloadedResourcesProvider);
                ref.invalidate(downloadStatusProvider(resourceId));
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted')),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Downloads',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all offline resources?',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final userId = ref.read(authProvider).userId;
              if (userId != null && userId.isNotEmpty) {
                await ref.read(resourceRepositoryProvider).clearDownloads(userId);
                ref.invalidate(downloadedResourcesProvider);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All downloads cleared')),
                );
              }
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Unable to load downloads',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.offline_pin_outlined,
            size: 48,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No offline resources',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'Download resources to access them offline',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}
