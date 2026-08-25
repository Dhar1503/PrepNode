import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/resources/domain/entities/download_status.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';
import 'package:prepgraph/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepgraph/features/resources/presentation/widgets/bookmark_button.dart';
import 'package:prepgraph/features/resources/presentation/widgets/download_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resource Detail Screen (S9.2)
/// Displays full resource details with actions
class ResourceDetailScreen extends ConsumerStatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({
    super.key,
    required this.resourceId,
  });

  @override
  ConsumerState<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  bool _hasMarkedViewed = false;

  @override
  Widget build(BuildContext context) {
    final resourceAsync = ref.watch(resourceByIdProvider(widget.resourceId));
    final downloadStatusAsync = ref.watch(downloadStatusProvider(widget.resourceId));
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarksAsync.maybeWhen(
      data: (bookmarks) => bookmarks.any((b) => b.resourceId == widget.resourceId),
      orElse: () => false,
    );

    if (!_hasMarkedViewed && resourceAsync.hasValue) {
      _hasMarkedViewed = true;
      final userId = ref.read(authProvider).userId;
      if (userId != null && userId.isNotEmpty) {
        ref.read(resourceRepositoryProvider).markAsViewed(userId, widget.resourceId);
      }
    }

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
          'Resource Details',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResource,
          ),
        ],
      ),
      body: resourceAsync.when(
        data: (resource) => _buildContent(resource, downloadStatusAsync, isBookmarked),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(
    StudyResource resource,
    AsyncValue<DownloadStatus?> downloadStatusAsync,
    bool isBookmarked,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail/Preview area
          _buildPreviewArea(resource),
          
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and metadata
                _buildHeader(resource),
                
                const SizedBox(height: AppConstants.spaceLg),
                
                // Description
                _buildDescription(resource),
                
                const SizedBox(height: AppConstants.spaceLg),
                
                // Tags
                _buildTags(resource),
                
                const SizedBox(height: AppConstants.spaceLg),
                
                // Stats
                _buildStats(resource),
                
                const SizedBox(height: AppConstants.spaceXl),
                
                // Actions
                downloadStatusAsync.when(
                  data: (status) => _buildActions(resource, status, isBookmarked),
                  loading: () => _buildActionsLoading(),
                  error: (_, _) => _buildActions(resource, null, isBookmarked),
                ),
                
                const SizedBox(height: AppConstants.spaceXl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea(StudyResource resource) {
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
      height: 200,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHeader(StudyResource resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two independent badges on purpose: `isOfficial` is a claim about
        // the resource's origin (govt/official body), `verificationStatus`
        // is whether PrepGraph actually checked the link. A resource can be
        // claimed-official but link-unverified — showing one green checkmark
        // for both would let an unverified/placeholder link masquerade as
        // confirmed official content (Phase 1C data-integrity fix).
        Wrap(
          spacing: AppConstants.spaceSm,
          runSpacing: AppConstants.spaceXs,
          children: [
            if (resource.isOfficial)
              _buildBadge(
                icon: Icons.account_balance,
                label: 'Claimed Official Source',
                color: AppColors.ink500,
              ),
            _buildVerificationBadge(resource),
          ],
        ),

        const SizedBox(height: AppConstants.spaceMd),
        
        // Title
        Text(
          resource.title,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeHeadlineMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        
        const SizedBox(height: AppConstants.spaceSm),
        
        // Author and type
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: AppColors.graphite700,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                resource.author,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Icon(
              Icons.category,
              size: 18,
              color: AppColors.graphite700,
            ),
            const SizedBox(width: 4),
            Text(
              _getTypeLabel(resource.type),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spaceSm),
        
        // Rating
        Row(
          children: [
            Icon(
              Icons.star,
              size: 18,
              color: AppColors.marigold500,
            ),
            const SizedBox(width: 4),
            Text(
              resource.rating.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Flexible(
              child: Text(
                '${resource.viewCount} views',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // A resource can be genuinely verified, honestly unverified (real-looking
  // link PrepGraph hasn't confirmed yet), or a placeholder (example.com —
  // not a real destination at all). These need visibly different treatment
  // so a placeholder link can never read as "probably fine, just unchecked".
  Widget _buildVerificationBadge(StudyResource resource) {
    if (resource.verificationStatus == VerificationStatus.verified) {
      return _buildBadge(
        icon: Icons.verified,
        label: 'Verified',
        color: AppColors.sage500,
      );
    }
    final isPlaceholder = resource.url.contains('example.com') ||
        (resource.sourceUrl?.contains('example.com') ?? false);
    if (isPlaceholder) {
      return _buildBadge(
        icon: Icons.report_problem_outlined,
        // Kept short on purpose: the badge sits in a Wrap that gives it
        // unbounded width, so a long label overflows the row instead of
        // ellipsising. The warning icon and red colour carry the rest.
        label: 'Placeholder — not real',
        color: AppColors.error,
      );
    }
    return _buildBadge(
      icon: Icons.help_outline,
      label: 'Unverified source',
      color: AppColors.marigold500,
    );
  }

  Widget _buildDescription(StudyResource resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Text(
          resource.description,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTags(StudyResource resource) {
    if (resource.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Wrap(
          spacing: AppConstants.spaceSm,
          runSpacing: AppConstants.spaceSm,
          children: resource.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceSm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.sage500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Text(
                tag,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.sage500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStats(StudyResource resource) {
    return Row(
      children: [
        if (resource.pageCount > 0)
          _buildStatItem(Icons.description, '${resource.pageCount} pages'),
        if (resource.durationMinutes > 0)
          _buildStatItem(Icons.access_time, _formatDuration(resource.durationMinutes)),
        if (resource.difficulty.isNotEmpty)
          _buildStatItem(Icons.bar_chart, resource.difficulty),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.sage500,
              size: 24,
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(StudyResource resource, DownloadStatus? status, bool isBookmarked) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openResource(resource),
            icon: const Icon(Icons.open_in_new),
            label: Text(
              resource.type == ResourceType.youtube ? 'Watch Video' : 'Open Resource',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sage500,
              foregroundColor: AppColors.paper50,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.spaceMd),
        
        // Secondary actions
        Row(
          children: [
            Expanded(
              child: BookmarkButton(
                isBookmarked: isBookmarked,
                onTap: () => _toggleBookmark(isBookmarked),
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: DownloadButton(
                status: status,
                onTap: () => _handleDownload(resource.id),
                isDownloadable: resource.isDownloadable,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spaceMd),
        
        // M12 Integration: Ask AI about this resource
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleAskAI(resource),
            icon: const Icon(Icons.psychology),
            label: Text(
              'Ask AI About This Resource',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink900,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  String _getTypeLabel(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.book:
        return 'Book';
      case ResourceType.youtube:
        return 'Video';
      case ResourceType.website:
        return 'Website';
      case ResourceType.governmentMaterial:
        return 'Official';
      case ResourceType.previousPapers:
        return 'Previous Papers';
      case ResourceType.notes:
        return 'Notes';
    }
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m';
  }

  /// Opens the resource in the browser / YouTube app.
  ///
  /// Placeholder rows (the example.com seed entries) are refused up front:
  /// launching them would just dump the user on a dead domain, which is
  /// worse than saying plainly that the link isn't real yet.
  Future<void> _openResource(StudyResource resource) async {
    final messenger = ScaffoldMessenger.of(context);
    final url = resource.url;

    if (url.isEmpty || url.contains('example.com')) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This entry is a placeholder — it has no real link yet.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This resource has an invalid link.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Couldn\'t open $url')),
      );
    }
  }

  Future<void> _toggleBookmark(bool isCurrentlyBookmarked) async {
    final userId = ref.read(authProvider).userId;
    if (userId == null || userId.isEmpty) return;

    final repository = ref.read(resourceRepositoryProvider);
    if (isCurrentlyBookmarked) {
      final bookmarksResult = await repository.getBookmarks(userId);
      final bookmarks = bookmarksResult.getOrElse(() => const []);
      final matching = bookmarks.where((b) => b.resourceId == widget.resourceId);
      for (final bookmark in matching) {
        await repository.removeBookmark(bookmark.id);
      }
    } else {
      await repository.addBookmark(userId, widget.resourceId);
    }
    ref.invalidate(bookmarksProvider);
  }

  Future<void> _handleDownload(String resourceId) async {
    final userId = ref.read(authProvider).userId;
    if (userId == null || userId.isEmpty) return;

    final repository = ref.read(resourceRepositoryProvider);
    await repository.updateDownloadStatus(
      userId,
      resourceId,
      DownloadState.completed,
      1.0,
    );
    ref.invalidate(downloadStatusProvider(resourceId));
    ref.invalidate(downloadedResourcesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource downloaded for offline access')),
      );
    }
  }

  void _handleAskAI(StudyResource resource) {
    // M12 Integration: Navigate to AI Assistant with resource context
    final question = 'Can you explain the key concepts covered in "${resource.title}"? How should I approach studying this resource for TNPSC preparation?';
    context.push(
      '/ai-assistant/explain?resourceId=${resource.id}&initialQuestion=${Uri.encodeComponent(question)}',
    );
  }

  void _shareResource() {
    // TODO: Implement share functionality when share_plus is added as dependency
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
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
            'Unable to load resource',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}
