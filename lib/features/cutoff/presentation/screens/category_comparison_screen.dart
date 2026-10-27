import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_scale.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';

/// Category Comparison Screen
/// Compares cutoffs across different categories
class CategoryComparisonScreen extends ConsumerWidget {
  final String examId;

  const CategoryComparisonScreen({
    super.key,
    required this.examId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examCutoffAsync = ref.watch(examCutoffProvider(examId));

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
          'Category Comparison',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: examCutoffAsync.when(
        data: (cutoff) => _buildContent(cutoff),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(ExamCutoff cutoff) {
    // yearlyTrends is sorted ascending by year, so the latest year is the
    // *last* entry — .firstOrNull was silently showing the oldest year.
    final latestYear = cutoff.yearlyTrends.lastOrNull;
    if (latestYear == null) return _buildEmptyState();
    
    final categoryCutoffs = cutoff.categoryCutoffs
        .where((c) => c.year == latestYear.year)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Summary card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink900.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${latestYear.year} Overview',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Vacancies',
                          '${latestYear.totalVacancies}',
                          AppColors.marigold500,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: _buildSummaryItem(
                          'Avg Cutoff',
                          latestYear.averageCutoff.toStringAsFixed(1),
                          AppColors.sage500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Category comparison list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Category-wise Cutoffs',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          ...categoryCutoffs.map<Widget>((cutoff) => _buildCategoryTile(cutoff)),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleMedium,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(CategoryCutoff cutoff) {
    // Exam-specific scale, not a bare literal — see ExamScale's doc comment.
    final maxCutoff = ExamScale.totalMarksFor(examId);
    final progress = cutoff.cutoffMark / maxCutoff;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceXs,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cutoff.category,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                cutoff.cutoffMark.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeTitleMedium,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sage500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          if (cutoff.vacancyCount != null)
            Text(
              '${cutoff.vacancyCount} vacancies',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          const SizedBox(height: AppConstants.spaceMd),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage500),
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
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
            'Unable to load category data',
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
            'No trend data available',
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
