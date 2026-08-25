import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/insights/presentation/widgets/score_hero_card.dart';
import 'package:prepgraph/features/insights/presentation/widgets/strength_map_preview.dart';
import 'package:prepgraph/features/insights/presentation/widgets/headline_stats_row.dart';
import 'package:prepgraph/features/insights/presentation/widgets/subject_performance_card.dart';
import 'package:prepgraph/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepgraph/features/cutoff/presentation/widgets/readiness_meter.dart';
import 'package:prepgraph/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepgraph/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepgraph/features/resources/presentation/widgets/resource_card.dart';

/// Insights Home Screen (S8.1)
/// Personal-only reflection on progress — never comparative
class InsightsHomeScreen extends ConsumerStatefulWidget {
  const InsightsHomeScreen({super.key});

  @override
  ConsumerState<InsightsHomeScreen> createState() => _InsightsHomeScreenState();
}

class _InsightsHomeScreenState extends ConsumerState<InsightsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final learnerProgressAsync = ref.watch(learnerProgressProvider);
    final masteryAnalyticsAsync = ref.watch(masteryAnalyticsProvider);
    final studyHabitsAsync = ref.watch(studyHabitsProvider);
    final readinessPredictionAsync = ref.watch(readinessPredictionProvider('tnpsc-group2'));

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Insights',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () => _handleAskAI(),
            tooltip: 'Ask AI About Your Progress',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            
            // PrepGraph Score Hero
            learnerProgressAsync.when(
              data: (progress) => _buildScoreHero(progress),
              loading: () => _buildScoreSkeleton(),
              error: (_, _) => _buildScoreError(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Strength Map Preview
            masteryAnalyticsAsync.when(
              data: (analytics) => _buildStrengthMapPreview(analytics),
              loading: () => _buildStrengthMapSkeleton(),
              error: (_, _) => _buildStrengthMapError(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Headline Stats Row
            studyHabitsAsync.when(
              data: (habits) => _buildHeadlineStats(habits),
              loading: () => _buildHeadlineStatsSkeleton(),
              error: (_, _) => _buildHeadlineStatsError(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Readiness Meter from Cutoff Intelligence
            readinessPredictionAsync.when(
              data: (prediction) => _buildReadinessMeter(prediction),
              loading: () => _buildReadinessMeterSkeleton(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // Subject Performance Cards
            masteryAnalyticsAsync.when(
              data: (analytics) => _buildSubjectPerformance(analytics),
              loading: () => _buildSubjectPerformanceSkeleton(),
              error: (_, _) => _buildSubjectPerformanceError(),
            ),
            
            const SizedBox(height: AppConstants.spaceLg),
            
            // M9 Integration: Most Used Resources & Learning Material Effectiveness
            _buildResourceInsights(),
            
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHero(LearnerProgress progress) {
    return ScoreHeroCard(
      score: progress.prepGraphScore,
      scoreComponents: progress.scoreComponents,
      onTap: () {
        // Navigate to Score Detail screen
        context.push('/insights/score-detail');
      },
    );
  }

  Widget _buildScoreSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
    );
  }

  Widget _buildScoreError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          'Score data unavailable',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthMapPreview(MasteryAnalytics analytics) {
    return StrengthMapPreview(
      topicMasteries: analytics.topicMasteries,
      onTap: () {
        context.push('/insights/strength-map');
      },
      onTopicTap: (topicId) {
        context.push('/learn/topic/$topicId');
      },
    );
  }

  Widget _buildStrengthMapSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
    );
  }

  Widget _buildStrengthMapError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          'Strength map unavailable',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildHeadlineStats(StudyHabits habits) {
    return HeadlineStatsRow(
      weeklyStudyMinutes: habits.weeklyStats.totalStudyMinutes,
      topicsMastered: _countMasteredTopics(ref.read(masteryAnalyticsProvider)),
      currentStreak: habits.weeklyStats.currentStreak,
      onTapTimeInvested: () {
        context.push('/insights/time-invested');
      },
      onTapMastery: () {
        context.push('/insights/strength-map');
      },
    );
  }

  Widget _buildHeadlineStatsSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
    );
  }

  Widget _buildHeadlineStatsError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          'Stats unavailable',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectPerformance(MasteryAnalytics analytics) {
    // Group by subject
    final subjectGroups = <String, List<TopicMastery>>{};
    for (var topic in analytics.topicMasteries) {
      subjectGroups.putIfAbsent(topic.subjectId, () => []);
      subjectGroups[topic.subjectId]!.add(topic);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Subject Performance',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...subjectGroups.entries.map((entry) {
          final subjectTopics = entry.value;
          final avgMastery = subjectTopics
              .map((t) => t.masteryPercentage)
              .reduce((a, b) => a + b) / subjectTopics.length;
          
          return SubjectPerformanceCard(
            subjectId: entry.key,
            subjectName: subjectTopics.first.subjectName,
            masteryPercentage: avgMastery,
            topicsCount: subjectTopics.length,
            onTap: () {
              context.push('/insights/subject/${entry.key}');
            },
          );
        }),
      ],
    );
  }

  Widget _buildSubjectPerformanceSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSubjectPerformanceError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          'Subject performance unavailable',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.onErrorContainer,
          ),
        ),
      ),
    );
  }

  int _countMasteredTopics(AsyncValue<MasteryAnalytics> analyticsAsync) {
    return analyticsAsync.when(
      data: (analytics) => analytics.topicMasteries
          .where((topic) => topic.level == MasteryLevel.mastered)
          .length,
      loading: () => 0,
      error: (_, _) => 0,
    );
  }

  Widget _buildReadinessMeter(ReadinessPrediction prediction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: ReadinessMeter(
        readinessPercentage: prediction.readinessPercentage,
        readinessLevel: prediction.readinessLevel,
      ),
    );
  }

  Widget _buildReadinessMeterSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
    );
  }

  // M9 Integration: Most Used Resources & Learning Material Effectiveness
  Widget _buildResourceInsights() {
    final recentlyViewedAsync = ref.watch(recentlyViewedProvider);
    final recommendedAsync = ref.watch(recommendedResourcesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Icon(
                Icons.insights,
                color: AppColors.sage500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'Learning Resources',
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
                onPressed: () => context.push('/resources'),
                child: Text(
                  'View All',
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
        // Most Used Resources
        recentlyViewedAsync.when(
          data: (resources) {
            if (resources.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Text(
                    'Recently Viewed',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.graphite700,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                ...resources.take(2).map((resource) {
                  return ResourceCard(
                    resource: resource,
                    onTap: () => context.push('/resources/${resource.id}'),
                  );
                }),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        // Recommended Resources
        recommendedAsync.when(
          data: (recommendations) {
            if (recommendations.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Text(
                    'Recommended for You',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.graphite700,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                ...recommendations.take(2).map((rec) {
                  return ResourceCard(
                    resource: rec.resource,
                    onTap: () => context.push('/resources/${rec.resource.id}'),
                  );
                }),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _handleAskAI() {
    // M12 Integration: Navigate to AI Assistant with insights context
    context.push('/ai-assistant/chat?contextModule=insights');
  }
}
