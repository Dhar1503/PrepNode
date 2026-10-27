import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_scale.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepnode/features/mock_test/presentation/providers/mock_test_providers.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepnode/features/resources/presentation/widgets/resource_card.dart';

/// Result Screen (S6.5)
/// Displays test results with score and section breakdown
class ResultScreen extends ConsumerWidget {
  final MockTestResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Test Result',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            _buildScoreCard(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildCutoffComparison(context),
            const SizedBox(height: AppConstants.spaceLg),
            _buildStatsGrid(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSectionBreakdown(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildWeakTopics(context),
            const SizedBox(height: AppConstants.spaceLg),
            // M9 Integration: Suggested resources based on incorrect answers
            _buildSuggestedResources(context),
            const SizedBox(height: AppConstants.spaceLg),
            _buildAiSummary(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildActions(context, ref),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '${result.obtainedMarks.toStringAsFixed(1)}/${result.totalMarks}',
            style: GoogleFonts.fraunces(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: AppColors.lightOnPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '${result.percentage.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreStat('Correct', result.correctAnswers, AppColors.sage500),
              _buildScoreStat('Incorrect', result.incorrectAnswers, AppColors.graphite700),
              _buildScoreStat('Skipped', result.skippedQuestions, AppColors.marigold500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCutoffComparison(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Mock exam ID - in production, this would come from the test configuration
        final examId = 'tnpsc-group2';
        final readinessAsync = ref.watch(readinessPredictionProvider(examId));
        
        return readinessAsync.when(
          data: (prediction) {
            // `targetCutoff` is in MARKS on the exam's own scale (e.g. 185 of
            // 300 for TNPSC Group 2), while `result.percentage` is a percent
            // of this mock test's marks. Comparing them directly rendered the
            // cutoff as "185.0%" and produced nonsense gaps like "168.3%
            // below". Convert the cutoff to a percentage of the exam total
            // first so both sides of the comparison are the same unit.
            final examTotalMarks = ExamScale.totalMarksFor(examId);
            final targetCutoffPercent =
                examTotalMarks > 0 ? (prediction.targetCutoff / examTotalMarks) * 100 : 0.0;
            final scoreGap = targetCutoffPercent - result.percentage;
            final isAboveCutoff = result.percentage >= targetCutoffPercent;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: isAboveCutoff 
                    ? AppColors.sage500.withValues(alpha: 0.1)
                    : AppColors.marigold500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(
                  color: isAboveCutoff 
                      ? AppColors.sage500 
                      : AppColors.marigold500,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isAboveCutoff ? Icons.check_circle : Icons.info_outline,
                        color: isAboveCutoff 
                            ? AppColors.sage500 
                            : AppColors.marigold500,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Text(
                        'Cutoff Comparison',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeHeadlineSmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Score',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeBodySmall,
                                color: AppColors.graphite700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${result.percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.fraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Qualifying Mark',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeBodySmall,
                                color: AppColors.graphite700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${targetCutoffPercent.toStringAsFixed(1)}%',
                              style: GoogleFonts.fraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isAboveCutoff ? 'Above by' : 'Below by',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeBodySmall,
                                color: AppColors.graphite700,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${scoreGap.abs().toStringAsFixed(1)}%',
                              style: GoogleFonts.fraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: isAboveCutoff
                                    ? AppColors.sage500
                                    : AppColors.marigold500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    isAboveCutoff
                        ? 'You\'re above the official qualifying mark. Selection cutoffs run higher, so keep building.'
                        : 'You\'re ${scoreGap.abs().toStringAsFixed(1)}% below the official qualifying mark. Focus on weak areas to improve.',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.graphite700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  // "View Historical Trends" removed with the rest of Cutoff
                  // Intelligence — the trends it opened were invented data.
                  TextButton(
                    onPressed: () => context.go('/practice'),
                    child: Text(
                      'Practise weak areas',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: isAboveCutoff
                            ? AppColors.sage500
                            : AppColors.marigold500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildScoreStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.fraunces(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final timeMinutes = result.timeTakenSeconds / 60;
    final avgTime = result.timeTakenSeconds / result.totalQuestions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              label: 'Time Taken',
              value: '${timeMinutes.toStringAsFixed(1)} min',
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _buildStatCard(
              icon: Icons.speed,
              label: 'Avg/Question',
              value: '${avgTime.toStringAsFixed(1)} sec',
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _buildStatCard(
              icon: Icons.psychology,
              label: 'Accuracy',
              value: '${(result.accuracy * 100).toInt()}%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.ink900, size: 24),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w700,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBreakdown() {
    if (result.sectionResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section Breakdown',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...result.sectionResults.map((section) => _buildSectionBar(section)),
        ],
      ),
    );
  }

  Widget _buildSectionBar(SectionResult section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.sectionName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${section.percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: section.percentage / 100,
              backgroundColor: AppColors.lightOutlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                section.percentage >= 70
                    ? AppColors.sage500
                    : section.percentage >= 50
                        ? AppColors.marigold500
                        : AppColors.graphite700,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopics(BuildContext context) {
    if (result.weakTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.marigold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.marigold500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: AppColors.marigold500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Weak Areas',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ...result.weakTopics.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    topic.topicName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.graphite700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '${(topic.accuracy * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.marigold500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'Add to Revision Plan',
            onPressed: () {
              // Navigate to planner to add revision tasks
              context.push('/planner');
            },
          ),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'Ask AI About Weak Areas',
            onPressed: () {
              // Navigate to AI Assistant with mock test context
              final weakTopicsText = result.weakTopics
                  .map((t) => t.topicName)
                  .join(', ');
              final question = 'I scored ${result.percentage.toStringAsFixed(1)}% in my mock test. My weak areas are: $weakTopicsText. Can you explain these topics and suggest how to improve?';
              context.push(
                '/ai-assistant/explain?moduleId=mock_test&initialQuestion=${Uri.encodeComponent(question)}',
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'View Detailed Analytics',
            onPressed: () {
              // M8 Integration: Navigate to Insights for detailed analysis
              context.go('/insights');
            },
            icon: const Icon(Icons.analytics, size: 20),
          ),
        ],
      ),
    );
  }

  // M9 Integration: Suggested resources based on incorrect answers
  Widget _buildSuggestedResources(BuildContext context) {
    if (result.weakTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.sage500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'Suggested Resources',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 2,
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
        const SizedBox(height: AppConstants.spaceSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Based on your incorrect answers, we recommend these resources:',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        // Show recommended resources
        Consumer(
          builder: (context, ref, _) {
            final recommendedAsync = ref.watch(recommendedResourcesProvider);
            
            return recommendedAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  children: recommendations.take(2).map((rec) {
                    return ResourceCard(
                      resource: rec.resource,
                      onTap: () => context.push('/resources/${rec.resource.id}'),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAiSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.sage500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.sage500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'AI Analysis',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            result.aiSummary,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        children: [
          AppButton(
            label: 'Review Answers',
            icon: const Icon(Icons.reviews, size: 20),
            onPressed: () {
              // The real answered questions are still held in
              // testAttemptProvider right after submission (submitTest()
              // marks the attempt completed but doesn't clear it).
              final attempt = ref.read(testAttemptProvider).attempt;
              final questions =
                  attempt != null && attempt.id == result.attemptId ? attempt.questions : const [];
              context.push(
                '/mock-tests/review/${result.attemptId}',
                extra: {'result': result, 'questions': questions},
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'Detailed Analysis',
            onPressed: () {
              context.push('/mock-tests/analysis/${result.attemptId}', extra: result);
            },
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'Back to Mock Tests',
            onPressed: () {
              context.push('/mock-tests');
            },
          ),
        ],
      ),
    );
  }
}
