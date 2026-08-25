import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/dashboard/domain/entities/daily_plan.dart';
import 'package:prepgraph/features/dashboard/domain/entities/progress_summary.dart';
import 'package:prepgraph/features/dashboard/domain/entities/recent_activity.dart';
import 'package:prepgraph/features/dashboard/domain/entities/upcoming_schedule.dart';
import 'package:prepgraph/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/todays_focus_card.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/daily_progress_section.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:prepgraph/features/dashboard/presentation/widgets/upcoming_schedule_card.dart';
import 'package:prepgraph/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepgraph/features/resources/presentation/widgets/resource_card.dart';
import 'package:prepgraph/features/strategy/presentation/widgets/strategy_hero_card.dart';

/// Dashboard Screen (S2.1)
/// Main home screen with daily focus, progress, and quick actions
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDashboardData);
  }

  void _loadDashboardData() {
    final userId = ref.read(authProvider).userId;
    if (userId != null) {
      ref.read(dashboardProvider.notifier).loadDashboardData(userId: userId);
    }
  }

  void _handleContinueStudy() {
    context.push('/planner');
  }

  void _handleAvatarTap() {
    // '/profile' is a bottom-nav tab, not a detail screen — go() switches
    // branches within the shell (keeping the nav bar), push() would stack
    // a whole separate screen on top of it.
    context.go('/profile');
  }

  void _handleNotificationTap() {
    context.push('/notifications');
  }

  // M9 Integration: Continue Reading Section
  Widget _buildContinueReadingSection() {
    final recentlyViewedAsync = ref.watch(recentlyViewedProvider);
    
    return recentlyViewedAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Continue Reading',
                      style: TextStyle(
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
                      'See All',
                      style: TextStyle(
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
            ResourceCard(
              resource: resources.first,
              onTap: () => context.push('/resources/${resources.first.id}'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  // M9 Integration: Recommended Resources Preview
  Widget _buildRecommendedResourcesPreview() {
    final recommendedAsync = ref.watch(recommendedResourcesProvider);
    
    return recommendedAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recommended for You',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeHeadlineSmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/resources/recommended'),
                    child: Text(
                      'See All',
                      style: TextStyle(
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
            ResourceCard(
              resource: recommendations.first.resource,
              onTap: () => context.push('/resources/${recommendations.first.resource.id}'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final userName = ref.watch(authProvider).userName;
    final dailyPlan = dashboardState.dailyPlan as DailyPlan?;
    final progressSummary = dashboardState.progressSummary as ProgressSummary?;
    final recentActivities = dashboardState.recentActivities as List<RecentActivity>?;
    final upcomingSchedule = dashboardState.upcomingSchedule as List<UpcomingSchedule>?;

    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  DashboardAppBar(
                    userName: userName ?? 'there',
                    onAvatarTap: _handleAvatarTap,
                    onNotificationTap: _handleNotificationTap,
                    // Real indicator: today's plan has at least one
                    // pending task (was previously hardcoded to true).
                    hasUnreadNotifications:
                        dailyPlan != null && dailyPlan.totalTasks - dailyPlan.completedTasks > 0,
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  const StrategyHeroCard(),
                  const SizedBox(height: AppConstants.spaceLg),
                  if (dailyPlan != null)
                    TodaysFocusCard(
                      dailyPlan: dailyPlan,
                      isLoading: dashboardState.isLoadingPlan,
                      onContinueStudy: _handleContinueStudy,
                    ),
                  const SizedBox(height: AppConstants.spaceLg),
                  if (progressSummary != null)
                    DailyProgressSection(
                      progress: progressSummary,
                      isLoading: dashboardState.isLoadingProgress,
                    ),
                  const SizedBox(height: AppConstants.spaceLg),
                  const QuickActionsGrid(),
                  const SizedBox(height: AppConstants.spaceLg),
                  // Continue Reading Section - M9 Integration
                  _buildContinueReadingSection(),
                  const SizedBox(height: AppConstants.spaceLg),
                  // Recommended Resources Preview - M9 Integration
                  _buildRecommendedResourcesPreview(),
                  const SizedBox(height: AppConstants.spaceLg),
                  if (recentActivities != null)
                    RecentActivityCard(
                      activities: recentActivities,
                      isLoading: dashboardState.isLoadingActivities,
                    ),
                  const SizedBox(height: AppConstants.spaceLg),
                  if (upcomingSchedule != null)
                    UpcomingScheduleCard(
                      schedule: upcomingSchedule,
                      isLoading: dashboardState.isLoadingSchedule,
                    ),
                  const SizedBox(height: AppConstants.spaceXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
