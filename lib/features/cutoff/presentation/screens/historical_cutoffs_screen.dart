import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/category_selector.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/year_filter.dart';

/// Historical Cutoffs Screen
/// Displays historical cutoff data by year and category
class HistoricalCutoffsScreen extends ConsumerStatefulWidget {
  final String examId;

  const HistoricalCutoffsScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<HistoricalCutoffsScreen> createState() =>
      _HistoricalCutoffsScreenState();
}

class _HistoricalCutoffsScreenState
    extends ConsumerState<HistoricalCutoffsScreen> {
  String? _selectedCategory;
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final examCutoffAsync = ref.watch(examCutoffProvider(widget.examId));

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
          'Historical Cutoffs',
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
    final categories = cutoff.categoryCutoffs.map((c) => c.category).toSet().toList();
    final years = cutoff.yearlyTrends.map((t) => t.year).toList()..sort();
    
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
    if (_selectedYear == null && years.isNotEmpty) {
      _selectedYear = years.last;
    }

    final selectedCat = _selectedCategory;
    final selectedYr = _selectedYear;

    final filteredCutoffs = cutoff.categoryCutoffs.where((c) {
      final yearMatch = selectedYr == null || c.year == selectedYr;
      final categoryMatch = selectedCat == null || c.category == selectedCat;
      return yearMatch && categoryMatch;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),

          // Quick access into the rest of Cutoff Intelligence — trend
          // charts, category comparison, personal readiness and the
          // gap-closing recommendations all exist as real screens already,
          // they just weren't reachable from anywhere in the UI before.
          _buildQuickActions(),

          const SizedBox(height: AppConstants.spaceLg),

          // Year filter
          YearFilter(
            availableYears: years,
            selectedYear: _selectedYear ?? years.last,
            onYearSelected: (year) {
              setState(() {
                _selectedYear = year;
              });
            },
          ),
          
          const SizedBox(height: AppConstants.spaceMd),
          
          // Category selector
          CategorySelector(
            categories: categories,
            selectedCategory: _selectedCategory ?? categories.first,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Cutoff list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Cutoff Data',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          ...filteredCutoffs.map<Widget>((cutoff) => _buildCutoffTile(cutoff)),

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.show_chart, 'Trend', '/cutoff/${widget.examId}/trend'),
      (Icons.compare_arrows, 'Compare', '/cutoff/${widget.examId}/category'),
      (Icons.speed, 'My Readiness', '/cutoff/${widget.examId}/readiness'),
      (Icons.bolt, 'Close Gap', '/cutoff/${widget.examId}/recommendations'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
        itemBuilder: (context, index) {
          final (icon, label, route) = actions[index];
          return ActionChip(
            avatar: Icon(icon, size: 16, color: AppColors.ink900),
            label: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: AppColors.outlineVariant),
            onPressed: () => context.push(route),
          );
        },
      ),
    );
  }

  Widget _buildCutoffTile(CategoryCutoff cutoff) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cutoff.category,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  'Year: ${cutoff.year}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cutoff.cutoffMark.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeTitleLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sage500,
                ),
              ),
              if (cutoff.vacancyCount != null) ...[
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  '${cutoff.vacancyCount} vacancies',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
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
            'Unable to load cutoff data',
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
