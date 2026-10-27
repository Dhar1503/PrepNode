import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/insights/presentation/widgets/mastery_topic_card.dart';

/// Subject Performance Analysis Screen
/// Detailed performance analysis for a specific subject
class SubjectPerformanceScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectPerformanceScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectMasteryAsync = ref.watch(subjectMasteryProvider(subjectId));

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
          'Subject Analysis',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: subjectMasteryAsync.when(
        data: (analytics) => _buildContent(context, analytics),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MasteryAnalytics analytics) {
    if (analytics.topicMasteries.isEmpty) {
      return _buildEmptyState();
    }

    final subjectName = analytics.topicMasteries.first.subjectName;
    
    // Calculate subject-level stats
    final totalTopics = analytics.topicMasteries.length;
    final masteredCount = analytics.topicMasteries
        .where((t) => t.level == MasteryLevel.mastered)
        .length;
    final avgMastery = analytics.topicMasteries
        .map((t) => t.masteryPercentage)
        .reduce((a, b) => a + b) / totalTopics;
    final totalQuestions = analytics.topicMasteries
        .map((t) => t.questionsAttempted)
        .reduce((a, b) => a + b);
    final totalCorrect = analytics.topicMasteries
        .map((t) => t.questionsCorrect)
        .reduce((a, b) => a + b);
    final accuracy = totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Subject Header
          _buildSubjectHeader(subjectName, avgMastery, accuracy),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Stats Row
          _buildStatsRow(totalTopics, masteredCount, totalQuestions),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Topic List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Topics',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...analytics.topicMasteries.map((topic) => MasteryTopicCard(
            topic: topic,
            onTap: () {
              context.push('/learn/topic/${topic.topicId}');
            },
          )),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildSubjectHeader(String subjectName, double avgMastery, double accuracy) {
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
            subjectName,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Average Mastery',
                  '${(avgMastery * 100).toInt()}%',
                  AppColors.sage500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildMetricCard(
                  'Accuracy',
                  '${(accuracy * 100).toInt()}%',
                  AppColors.marigold500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Column(
        children: [
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

  Widget _buildStatsRow(int totalTopics, int masteredCount, int totalQuestions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Topics',
              '$totalTopics',
              Icons.book,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildStatCard(
              'Mastered',
              '$masteredCount',
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildStatCard(
              'Questions',
              '$totalQuestions',
              Icons.quiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.ink500,
            size: 24,
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeTitleMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No data available for this subject',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
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
            'Unable to load subject data',
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








