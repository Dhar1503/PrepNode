import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_button.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/presentation/providers/planner_providers.dart';

/// Detailed Analysis Screen (S6.6)
/// Comprehensive performance analysis with time and subject breakdown
class DetailedAnalysisScreen extends ConsumerWidget {
  final MockTestResult result;

  const DetailedAnalysisScreen({
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
          'Detailed Analysis',
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
            _buildPerformanceOverview(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildTimeAnalysis(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSubjectPerformance(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildWeakTopicsDetail(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildRecommendations(context, ref),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  label: 'Total Score',
                  value: '${result.obtainedMarks.toStringAsFixed(1)}/${result.totalMarks}',
                  percentage: result.percentage,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: _buildOverviewCard(
                  label: 'Accuracy',
                  value: '${(result.accuracy * 100).toInt()}%',
                  percentage: result.accuracy * 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String label,
    required String value,
    required double percentage,
  }) {
    final color = percentage >= 70
        ? AppColors.sage500
        : percentage >= 50
            ? AppColors.marigold500
            : AppColors.graphite700;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis() {
    final avgTime = result.timeTakenSeconds / result.totalQuestions;
    final timePerQuestion = result.timeTakenSeconds / result.correctAnswers;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Analysis',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildTimeRow('Total Time', '${(result.timeTakenSeconds / 60).toStringAsFixed(1)} min'),
          _buildTimeRow('Average per Question', '${avgTime.toStringAsFixed(1)} sec'),
          _buildTimeRow('Time per Correct Answer', '${timePerQuestion.toStringAsFixed(1)} sec'),
          const SizedBox(height: AppConstants.spaceMd),
          _buildTimeEfficiency(),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEfficiency() {
    final avgTime = result.timeTakenSeconds / result.totalQuestions;
    final efficiency = avgTime < 60 ? 'Excellent' : avgTime < 90 ? 'Good' : 'Needs Improvement';
    final color = avgTime < 60 ? AppColors.sage500 : avgTime < 90 ? AppColors.marigold500 : AppColors.graphite700;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.speed,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Text(
            'Time Efficiency: $efficiency',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance() {
    if (result.sectionResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject-wise Performance',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...result.sectionResults.map((section) => _buildSubjectCard(section)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SectionResult section) {
    final color = section.percentage >= 70
        ? AppColors.sage500
        : section.percentage >= 50
            ? AppColors.marigold500
            : AppColors.graphite700;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: color),
      ),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${section.percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              _buildSubjectStat('Correct', section.correctAnswers, AppColors.sage500),
              const SizedBox(width: AppConstants.spaceLg),
              _buildSubjectStat('Incorrect', section.incorrectAnswers, AppColors.graphite700),
              const SizedBox(width: AppConstants.spaceLg),
              _buildSubjectStat('Skipped', section.skippedQuestions, AppColors.marigold500),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: section.percentage / 100,
              backgroundColor: AppColors.lightOutlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildWeakTopicsDetail() {
    if (result.weakTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.marigold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
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
                'Weak Topics Analysis',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...result.weakTopics.map((topic) => _buildWeakTopicCard(topic)),
        ],
      ),
    );
  }

  Widget _buildWeakTopicCard(WeakTopic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  topic.topicName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${(topic.accuracy * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              _buildWeakStat('Questions', '${topic.totalQuestions}'),
              const SizedBox(width: AppConstants.spaceLg),
              _buildWeakStat('Correct', '${topic.correctAnswers}'),
              const SizedBox(width: AppConstants.spaceLg),
              _buildWeakStat('Avg Time', '${topic.timePerQuestion.toStringAsFixed(0)}s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeakStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.graphite700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.sage500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.sage500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Recommendations',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildRecommendation('Focus on weak topics identified above'),
          _buildRecommendation('Practice PYQs for low-scoring subjects'),
          _buildRecommendation('Review time management for slow sections'),
          _buildRecommendation('Schedule revision for marked topics'),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Add to Revision Plan',
            onPressed: () => _addWeakTopicsToRevisionPlan(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _addWeakTopicsToRevisionPlan(BuildContext context, WidgetRef ref) async {
    if (result.weakTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No weak topics to add — nice work on this test.')),
      );
      return;
    }

    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final repository = ref.read(plannerRepositoryProvider);
    final scheduledDate = DateTime.now().add(const Duration(days: 1));
    var added = 0;

    for (final topic in result.weakTopics.take(5)) {
      final createResult = await repository.createTask(
        userId: userId,
        topicId: topic.topicId,
        title: 'Revise ${topic.topicName}',
        durationMinutes: 30,
        type: TaskType.revision,
        scheduledDate: scheduledDate,
        reason: 'Scored ${(topic.accuracy * 100).toStringAsFixed(0)}% on this topic in a mock test',
      );
      createResult.fold((_) {}, (_) => added++);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added > 0
              ? 'Added $added revision task${added == 1 ? '' : 's'} to your Planner for tomorrow'
              : 'Could not add tasks to your Planner — please try again',
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
