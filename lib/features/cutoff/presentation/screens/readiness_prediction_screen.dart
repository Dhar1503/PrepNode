import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepgraph/features/cutoff/domain/entities/recommendation.dart';
import 'package:prepgraph/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepgraph/features/cutoff/presentation/widgets/prediction_card.dart';
import 'package:prepgraph/features/cutoff/presentation/widgets/readiness_meter.dart';

/// Readiness Prediction Screen
/// Displays user's readiness prediction based on current performance,
/// against their own reservation category's cutoff, plus a ranked list of
/// the topics most worth studying next (see CutoffRepositoryImpl's gap
/// engine — real PYQ frequency crossed with real mastery, not a template).
class ReadinessPredictionScreen extends ConsumerWidget {
  final String examId;

  const ReadinessPredictionScreen({
    super.key,
    required this.examId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(readinessPredictionProvider(examId));
    final selectedCategory = ref.watch(selectedCutoffCategoryProvider);

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
          'Readiness Prediction',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategorySelector(ref, selectedCategory),
          Expanded(
            child: predictionAsync.when(
              data: (prediction) => _buildContent(context, ref, prediction),
              loading: () => _buildLoading(),
              error: (_, _) => _buildError(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(WidgetRef ref, String selectedCategory) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: AppConstants.spaceXs),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tnpscReservationCategories.length,
        itemBuilder: (context, index) {
          final category = tnpscReservationCategories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceSm),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => ref.read(selectedCutoffCategoryProvider.notifier).setCategory(category),
              selectedColor: AppColors.sage500.withValues(alpha: 0.2),
              labelStyle: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.sage500 : AppColors.graphite700,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ReadinessPrediction prediction) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceMd),

          // Readiness meter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: ReadinessMeter(
              readinessPercentage: prediction.readinessPercentage,
              readinessLevel: prediction.readinessLevel,
            ),
          ),

          const SizedBox(height: AppConstants.spaceLg),

          // Prediction card
          PredictionCard(prediction: prediction),

          const SizedBox(height: AppConstants.spaceLg),

          // Plain-English explanation of where these numbers come from — a
          // bare "114 marks" gap is meaningless to a first-time aspirant
          // without knowing the scale and the formula behind it.
          _buildHowItWorks(prediction),

          const SizedBox(height: AppConstants.spaceLg),

          // Close the Gap — real PYQ-frequency × mastery-gap ranked topics
          _buildGapClosingSection(context, ref),

          const SizedBox(height: AppConstants.spaceLg),

          // Strong areas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Strong Areas',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          if (prediction.strongAreas.isEmpty)
            _buildEmptyAreaHint('No topics attempted yet — practice a few PYQs to see your strengths here.')
          else
            ...prediction.strongAreas.map((area) => _buildAreaTile(area, true)),

          const SizedBox(height: AppConstants.spaceLg),

          // Weak areas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Areas to Improve',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          if (prediction.weakAreas.isEmpty)
            _buildEmptyAreaHint('No weak areas found yet — practice a few PYQs to see where to focus.')
          else
            ...prediction.weakAreas.map((area) => _buildAreaTile(area, false)),

          const SizedBox(height: AppConstants.spaceLg),
          
          // Time remaining
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.ink900.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 24,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Until Exam',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                        ),
                        Text(
                          '${prediction.weeksUntilExam} weeks',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeTitleMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildAreaTile(String area, bool isStrong) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceXs,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: isStrong
              ? AppColors.sage500.withValues(alpha: 0.3)
              : AppColors.marigold500.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isStrong ? Icons.check_circle : Icons.trending_up,
            size: 20,
            color: isStrong ? AppColors.sage500 : AppColors.marigold500,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              area,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.ink900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAreaHint(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          color: AppColors.graphite700,
        ),
      ),
    );
  }

  /// Explains the scale and the arithmetic behind the readiness numbers.
  /// Every value shown here is read from the same [prediction] rendered
  /// above, so the explanation can never drift from the actual figures.
  Widget _buildHowItWorks(ReadinessPrediction prediction) {
    final gap = (prediction.targetCutoff - prediction.currentScore).clamp(0, 400);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.azure500.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.azure500.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate_outlined, size: 18, color: AppColors.azure500),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'How this is calculated',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            _calcRow(
              'Exam total',
              '300 marks',
              'TNPSC Group 2 Prelims: 200 questions (100 Language + 75 General Studies + 25 Aptitude) for 300 marks.',
            ),
            _calcRow(
              'Your estimated score',
              '${prediction.currentScore.toStringAsFixed(0)} marks',
              'Derived from your PYQ accuracy, mock-test results and topic mastery so far.',
            ),
            _calcRow(
              'Target cutoff',
              '${prediction.targetCutoff.toStringAsFixed(0)} marks',
              'The most recent published cutoff for your selected category.',
            ),
            _calcRow(
              'Gap to close',
              '${gap.toStringAsFixed(0)} marks',
              'Target cutoff minus your estimated score. Close it using the ranked topics below.',
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value, String note, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.marigold500 : AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGapClosingSection(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(cutoffAnalysisProvider(examId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 20, color: AppColors.marigold500),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'Close the Gap',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Topics ranked by how often they\'ve appeared in past papers vs. how well you know them.',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          analysisAsync.when(
            data: (analysis) {
              final recommendations = analysis.personalizedRecommendations;
              if (recommendations.isEmpty) {
                return _buildEmptyAreaHint(
                  'Not enough PYQ practice data yet to rank topics — attempt a few PYQs first.',
                );
              }
              return Column(
                children: recommendations
                    .map((r) => _buildGapTile(context, r))
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _buildEmptyAreaHint('Could not load gap analysis right now.'),
          ),
        ],
      ),
    );
  }

  Widget _buildGapTile(BuildContext context, Recommendation recommendation) {
    final impactColor = recommendation.estimatedImpact == 'High' ? AppColors.marigold500 : AppColors.sage500;
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                ),
                child: Text(
                  '${recommendation.estimatedImpact} impact',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: impactColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.description,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: AppColors.graphite700),
              const SizedBox(width: 4),
              Text(
                recommendation.timeRequired,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: recommendation.topicId == null
                    ? null
                    : () => context.push('/learn/topic/${recommendation.topicId}'),
                child: Text(
                  'Practice Now',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sage500,
                  ),
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
            'Unable to load readiness prediction',
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
