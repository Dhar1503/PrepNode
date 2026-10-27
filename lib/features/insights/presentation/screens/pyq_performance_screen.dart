import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/empty_state.dart';
import 'package:prepnode/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/insights/presentation/widgets/subject_pyq_card.dart';
import 'package:prepnode/features/insights/presentation/widgets/accuracy_trend_card.dart';

/// PYQ Performance Analytics Screen
/// Detailed PYQ practice performance analysis
class PyqPerformanceScreen extends ConsumerWidget {
  const PyqPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pyqPerformanceAsync = ref.watch(pyqPerformanceProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PYQ Performance',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: pyqPerformanceAsync.when(
        data: (performance) => _buildContent(context, performance),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PyqPerformance performance) {
    // Nothing answered yet means every section below is empty, which
    // previously rendered three headers over blank space.
    if (performance.subjectStats.isEmpty && performance.topicTrends.isEmpty) {
      return EmptyStates.needsPractice(
        icon: Icons.query_stats_outlined,
        title: 'No PYQ performance yet',
        subtitle:
            'Answer some previous-year questions and this page will show your '
            'accuracy per subject and how it changes over time.',
        onAction: () => context.go('/practice'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),

          // Overall Stats Card
          _buildOverallStats(performance.overallStats),

          const SizedBox(height: AppConstants.spaceLg),

          // Sections hide their headers when they have nothing to list.
          if (performance.subjectStats.isNotEmpty) ...[
            _buildSubjectPerformance(performance.subjectStats),
            const SizedBox(height: AppConstants.spaceLg),
          ],

          if (performance.topicTrends.isNotEmpty) ...[
            _buildAccuracyTrends(performance.topicTrends),
          ],

          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildOverallStats(OverallPyqStats stats) {
    final totalHours = stats.totalTimeSpentMinutes ~/ 60;
    final totalMinutes = stats.totalTimeSpentMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
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
            'Overall Performance',
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
                child: _buildStatCard(
                  'Questions Attempted',
                  '${stats.totalQuestionsAttempted}',
                  Icons.quiz,
                  AppColors.ink500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildStatCard(
                  'Accuracy',
                  '${(stats.overallAccuracy * 100).toInt()}%',
                  Icons.check_circle,
                  AppColors.sage500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Time Invested',
                  '${totalHours}h ${totalMinutes}m',
                  Icons.schedule,
                  AppColors.marigold500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${stats.currentStreak} days',
                  Icons.local_fire_department,
                  AppColors.marigold500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeTitleMedium,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
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

  Widget _buildSubjectPerformance(List<SubjectPyqStats> subjectStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Subject-wise Performance',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...subjectStats.map((stat) => SubjectPyqCard(
          stat: stat,
          onTap: () {
            // Navigate to subject-specific PYQ performance
          },
        )),
      ],
    );
  }

  Widget _buildAccuracyTrends(List<TopicPyqTrend> topicTrends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Accuracy Trends',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...topicTrends.map((trend) => AccuracyTrendCard(
          trend: trend,
        )),
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
            'Unable to load PYQ data',
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
