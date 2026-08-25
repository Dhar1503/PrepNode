import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/empty_state.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/insights/presentation/widgets/mock_test_attempt_card.dart';

/// Mock Test Trend Analysis Screen
/// Detailed mock test performance trends and analysis
class MockTestTrendsScreen extends ConsumerWidget {
  const MockTestTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockTestAnalyticsAsync = ref.watch(mockTestAnalyticsProvider);

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
          'Mock Test Trends',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: mockTestAnalyticsAsync.when(
        data: (analytics) => _buildContent(context, analytics),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MockTestAnalytics analytics) {
    // With no attempts every section is empty, leaving headers over blank
    // space rather than an explanation.
    if (analytics.attempts.isEmpty) {
      return EmptyStates.needsPractice(
        icon: Icons.timeline_outlined,
        title: 'No mock tests taken yet',
        subtitle:
            'Take a mock test and this page will chart your scores, accuracy '
            'and how your performance trends over time.',
        onAction: () => context.push('/mock-tests'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Subject Stats Summary
          _buildSubjectStatsSummary(analytics.subjectStats),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Attempt History
          _buildAttemptHistory(analytics.attempts),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildSubjectStatsSummary(SubjectMockTestStats stats) {
    final trendIcon = _getTrendIcon(stats.trend);
    final trendColor = _getTrendColor(stats.trend);
    final trendText = _getTrendText(stats.trend);

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
                  'Total Attempts',
                  '${stats.totalAttempts}',
                  Icons.assessment,
                  AppColors.ink500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildStatCard(
                  'Average Score',
                  stats.averageScore.toStringAsFixed(1),
                  Icons.grade,
                  AppColors.marigold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Best Score',
                  stats.bestScore.toStringAsFixed(1),
                  Icons.star,
                  AppColors.sage500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildStatCard(
                  'Trend',
                  trendText,
                  trendIcon,
                  trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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

  Widget _buildAttemptHistory(List<MockTestAttempt> attempts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Attempt History',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...attempts.map((attempt) => MockTestAttemptCard(
          attempt: attempt,
          onTap: () {
            // Navigate to detailed review
          },
        )),
      ],
    );
  }

  IconData _getTrendIcon(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.improving:
        return Icons.trending_up;
      case ScoreTrend.stable:
        return Icons.trending_flat;
      case ScoreTrend.declining:
        return Icons.trending_down;
    }
  }

  Color _getTrendColor(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.improving:
        return AppColors.sage500;
      case ScoreTrend.stable:
        return AppColors.marigold500;
      case ScoreTrend.declining:
        return AppColors.ink500;
    }
  }

  String _getTrendText(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.improving:
        return 'Improving';
      case ScoreTrend.stable:
        return 'Stable';
      case ScoreTrend.declining:
        return 'Declining';
    }
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
            'Unable to load mock test data',
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
