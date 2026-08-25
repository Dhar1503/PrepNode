import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/empty_state.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/insights/presentation/widgets/study_calendar_heatmap.dart';
import 'package:prepgraph/features/insights/presentation/widgets/subject_time_bar.dart';

/// Study Time Analytics Screen (S8.3)
/// Study time breakdown by subject/day/week
class StudyTimeScreen extends ConsumerWidget {
  const StudyTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyHabitsAsync = ref.watch(studyHabitsProvider);

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
          'Time Invested',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: studyHabitsAsync.when(
        data: (habits) => _buildContent(context, habits),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StudyHabits habits) {
    // No recorded study days means every chart below is empty.
    if (habits.dailyData.isEmpty) {
      return EmptyStates.needsPractice(
        icon: Icons.schedule_outlined,
        title: 'No study time recorded yet',
        subtitle:
            'As you work through topics and practice sessions, this page will '
            'show how your study time is spread across days and subjects.',
        onAction: () => context.go('/practice'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Weekly Summary Card
          _buildWeeklySummary(habits.weeklyStats),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Study Calendar Heatmap
          _buildCalendarSection(habits.dailyData),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Subject Time Distribution
          _buildSubjectDistribution(habits.subjectDistribution),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(WeeklyStudyStats stats) {
    final totalHours = stats.totalStudyMinutes ~/ 60;
    final totalMinutes = stats.totalStudyMinutes % 60;
    final avgHours = stats.averageDailyMinutes ~/ 60;
    final avgMinutes = stats.averageDailyMinutes % 60;

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
            'This Week',
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
                child: _buildSummaryStat(
                  'Total Time',
                  '${totalHours}h ${totalMinutes}m',
                  Icons.schedule,
                  AppColors.marigold500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildSummaryStat(
                  'Daily Average',
                  '${avgHours}h ${avgMinutes}m',
                  Icons.trending_up,
                  AppColors.sage500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Active Days',
                  '${stats.activeStudyDays}/7',
                  Icons.calendar_today,
                  AppColors.ink500,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: _buildSummaryStat(
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

  Widget _buildSummaryStat(String label, String value, IconData icon, Color color) {
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

  Widget _buildCalendarSection(List<DailyStudyData> dailyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Study Calendar',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        StudyCalendarHeatmap(dailyData: dailyData),
      ],
    );
  }

  Widget _buildSubjectDistribution(SubjectTimeDistribution distribution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Subject Distribution',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...distribution.entries.map((entry) => SubjectTimeBar(
          subjectName: entry.subjectName,
          totalMinutes: entry.totalMinutes,
          percentage: entry.percentageOfTotal,
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
            'Unable to load study data',
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
