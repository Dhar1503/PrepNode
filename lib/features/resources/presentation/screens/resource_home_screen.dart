import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepgraph/features/resources/presentation/widgets/recommendation_banner.dart';
import 'package:prepgraph/features/resources/presentation/widgets/resource_category_chip.dart';
import 'package:prepgraph/features/resources/presentation/widgets/resource_card.dart';
import 'package:prepgraph/features/resources/presentation/widgets/search_bar.dart';

/// Resource Home Screen (S9.1)
/// Entry point for Resources module with search, categories, and recommendations
class ResourceHomeScreen extends ConsumerStatefulWidget {
  const ResourceHomeScreen({super.key});

  @override
  ConsumerState<ResourceHomeScreen> createState() => _ResourceHomeScreenState();
}

class _ResourceHomeScreenState extends ConsumerState<ResourceHomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(resourceCategoriesProvider);
    final recommendedAsync = ref.watch(recommendedResourcesProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Resources',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/resources/bookmarks'),
          ),
          // Downloads entry point removed: nothing in the app actually
          // downloads a file — the "download" state is local bookkeeping
          // only, so the screen could never list a real offline resource.
          // The route and screen stay in the repo for when real downloading
          // exists.
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceMd),
            
            // Search bar
            ResourceSearchBar(
              query: _searchQuery,
              onQueryChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Recommendation banner
            RecommendationBanner(
              title: 'Recommended for You',
              subtitle: 'Based on your learning progress',
              onTap: () => context.push('/resources/recommended'),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Resource categories
            categoriesAsync.when(
              data: (categories) => _buildCategories(categories),
              loading: () => _buildLoading(),
              error: (_, _) => _buildError(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Recommended resources preview
            recommendedAsync.when(
              data: (recommendations) => _buildRecommendedPreview(recommendations),
              loading: () => _buildLoading(),
              error: (_, _) => _buildError(),
            ),
            
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(List categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Browse by Category',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spaceSm),
                child: ResourceCategoryChip(
                  category: category,
                  isSelected: _selectedCategory == category.id,
                  onTap: () {
                    setState(() {
                      _selectedCategory = _selectedCategory == category.id ? null : category.id;
                    });
                    if (_selectedCategory != null) {
                      context.push('/resources/subject/${category.id}');
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedPreview(List recommendedResources) {
    if (recommendedResources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Top Recommendations',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/resources/recommended'),
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.sage500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...recommendedResources.take(3).map((rec) {
          return ResourceCard(
            resource: rec.resource,
            onTap: () => context.push('/resources/${rec.resource.id}'),
          );
        }),
      ],
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
}
