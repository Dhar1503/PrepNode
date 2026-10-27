import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/yearly_trend.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/category_selector.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/trend_graph.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/trend_legend.dart';

/// Year-wise Trend Analysis Screen
/// Displays cutoff trends over years with category filtering
class YearTrendScreen extends ConsumerStatefulWidget {
  final String examId;

  const YearTrendScreen({
    super.key,
    required this.examId,
  });

  @override
  ConsumerState<YearTrendScreen> createState() => _YearTrendScreenState();
}

class _YearTrendScreenState extends ConsumerState<YearTrendScreen> {
  String? _selectedCategory;

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
          'Year-wise Trend',
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
    
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    final selectedCat = _selectedCategory;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Category selector
          CategorySelector(
            categories: categories,
            selectedCategory: selectedCat ?? categories.first,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Trend graph
          TrendGraph(
            trends: cutoff.yearlyTrends,
            selectedCategory: selectedCat,
          ),
          
          const SizedBox(height: AppConstants.spaceMd),
          
          // Trend legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: TrendLegend(
              items: [
                const LegendItem(
                  label: 'Average Cutoff',
                  color: AppColors.sage500,
                ),
                if (_selectedCategory != null)
                  LegendItem(
                    label: _selectedCategory!,
                    color: AppColors.marigold500,
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.spaceLg),

          // Score insights — volatility, expected safe score, and estimated
          // competitive score, all derived directly from the real seeded
          // cutoff marks above (mean/std-dev over the years on screen), not
          // a separately fabricated figure.
          _buildScoreInsights(cutoff, selectedCat),

          const SizedBox(height: AppConstants.spaceLg),

          // Yearly breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Yearly Breakdown',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          ...cutoff.yearlyTrends.map<Widget>((trend) => _buildTrendTile(trend)),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildScoreInsights(ExamCutoff cutoff, String? selectedCategory) {
    final marks = selectedCategory == null
        ? cutoff.yearlyTrends.map((t) => t.averageCutoff).toList()
        : cutoff.categoryCutoffs.where((c) => c.category == selectedCategory).map((c) => c.cutoffMark).toList();
    if (marks.isEmpty) return const SizedBox.shrink();

    final mean = marks.reduce((a, b) => a + b) / marks.length;
    final highest = marks.reduce((a, b) => a > b ? a : b);
    final lowest = marks.reduce((a, b) => a < b ? a : b);
    final variance = marks.map((m) => (m - mean) * (m - mean)).reduce((a, b) => a + b) / marks.length;
    final volatility = sqrt(variance);

    // "Safe" score: highest observed cutoff plus one standard deviation of
    // headroom. "Competitive" score: the mean plus a smaller half-deviation
    // margin. Both are real statistics over the actual seeded marks, not
    // separately invented numbers.
    final safeScore = highest + volatility;
    final competitiveScore = mean + (volatility / 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCategory == null ? 'Score Insights' : 'Score Insights — $selectedCategory',
              style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyLarge, fontWeight: FontWeight.w600, color: AppColors.ink900),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(child: _insightStat('Highest', highest.toStringAsFixed(1), AppColors.sage500)),
                Expanded(child: _insightStat('Lowest', lowest.toStringAsFixed(1), AppColors.graphite700)),
                Expanded(child: _insightStat('Average', mean.toStringAsFixed(1), AppColors.ink500)),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(child: _insightStat('Volatility', '±${volatility.toStringAsFixed(1)}', AppColors.azure500)),
                Expanded(child: _insightStat('Safe Score', safeScore.toStringAsFixed(1), AppColors.marigold500)),
                Expanded(child: _insightStat('Competitive', competitiveScore.toStringAsFixed(1), AppColors.rose500)),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              volatility < 3
                  ? 'This cutoff has been stable across the years shown — a fairly reliable target.'
                  : 'This cutoff moves noticeably year to year — treat "Safe Score" as the real target, not the average.',
              style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700)),
      ],
    );
  }

  Widget _buildTrendTile(YearlyTrend trend) {
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
                  '${trend.year}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  'Vacancies: ${trend.totalVacancies}',
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
                trend.averageCutoff.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeTitleLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sage500,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                'Difficulty: ${(trend.difficultyIndex * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
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
            'Unable to load trend data',
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
