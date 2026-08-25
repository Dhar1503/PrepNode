import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';
import 'package:prepgraph/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepgraph/features/resources/presentation/widgets/pdf_card.dart';
import 'package:prepgraph/features/resources/presentation/widgets/video_card.dart';
import 'package:prepgraph/features/resources/presentation/widgets/book_card.dart';
import 'package:prepgraph/features/resources/presentation/widgets/website_card.dart';
import 'package:prepgraph/features/resources/presentation/widgets/resource_card.dart';

/// Subject Resources Screen
/// Displays resources filtered by subject with type filtering
class SubjectResourcesScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const SubjectResourcesScreen({
    super.key,
    required this.subjectId,
  });

  @override
  ConsumerState<SubjectResourcesScreen> createState() => _SubjectResourcesScreenState();
}

class _SubjectResourcesScreenState extends ConsumerState<SubjectResourcesScreen> {
  String? _selectedType;
  String? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesBySubjectProvider(widget.subjectId));

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
          'Subject Resources',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: resourcesAsync.when(
        data: (resources) => _buildContent(_applyFilters(resources)),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  List<StudyResource> _applyFilters(List<StudyResource> resources) {
    return resources.where((r) {
      final typeMatch = _selectedType == null || r.type.name == _selectedType;
      final difficultyMatch = _selectedDifficulty == null || r.difficulty == _selectedDifficulty;
      return typeMatch && difficultyMatch;
    }).toList();
  }

  Widget _buildContent(List<StudyResource> resources) {
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),

        const SizedBox(height: AppConstants.spaceMd),

        // Resources grid
        Expanded(
          child: resources.isEmpty
              ? _buildEmptyState()
              // A list, not a 2-column grid: every card this builds
              // (VideoCard, PdfCard, BookCard, WebsiteCard) is a full-width
              // list card with its own 32px side margins and a fixed-height
              // thumbnail. Squeezed into a grid cell they had ~100px of
              // usable width, so titles collapsed to "TNP SC…" and the
              // author line overflowed across neighbouring cards.
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceMd,
                  ),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return _buildResourceCard(resource);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeChip('All', null),
          _buildTypeChip('PDF', 'pdf'),
          _buildTypeChip('Video', 'youtube'),
          _buildTypeChip('Book', 'book'),
          _buildTypeChip('Website', 'website'),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String? type) {
    final isSelected = _selectedType == type || (_selectedType == null && label == 'All');
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spaceSm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedType = isSelected ? null : type;
          });
        },
        selectedColor: AppColors.sage500.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodyMedium,
          color: isSelected ? AppColors.sage500 : AppColors.graphite700,
        ),
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildResourceCard(StudyResource resource) {
    switch (resource.type) {
      case ResourceType.pdf:
        return PdfCard(
          resource: resource,
          onTap: () => context.push('/resources/${resource.id}'),
        );
      case ResourceType.youtube:
        return VideoCard(
          resource: resource,
          onTap: () => context.push('/resources/${resource.id}'),
        );
      case ResourceType.book:
        return BookCard(
          resource: resource,
          onTap: () => context.push('/resources/${resource.id}'),
        );
      case ResourceType.website:
        return WebsiteCard(
          resource: resource,
          onTap: () => context.push('/resources/${resource.id}'),
          isOfficial: resource.isOfficial,
        );
      default:
        return ResourceCard(
          resource: resource,
          onTap: () => context.push('/resources/${resource.id}'),
        );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Difficulty',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Wrap(
              spacing: AppConstants.spaceSm,
              runSpacing: AppConstants.spaceSm,
              children: [
                _buildDifficultyChip('All', null),
                _buildDifficultyChip('Beginner', 'beginner'),
                _buildDifficultyChip('Intermediate', 'intermediate'),
                _buildDifficultyChip('Advanced', 'advanced'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
                child: Text(
                  'Apply',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String? difficulty) {
    final isSelected = _selectedDifficulty == difficulty || 
                              (_selectedDifficulty == null && label == 'All');
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedDifficulty = isSelected ? null : difficulty;
        });
      },
      selectedColor: AppColors.sage500.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyMedium,
        color: isSelected ? AppColors.sage500 : AppColors.graphite700,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
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
            'Unable to load resources',
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
            Icons.inbox,
            size: 48,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No resources found',
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
