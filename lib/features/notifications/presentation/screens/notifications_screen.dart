import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/widgets/empty_state.dart';
import 'package:prepgraph/core/widgets/error_state.dart';
import 'package:prepgraph/core/widgets/skeleton_loader.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/presentation/providers/planner_providers.dart';

/// Notifications Screen
/// There is no push-notification infrastructure in this app (no backend,
/// no local-notification package) — this is a real reminder feed built
/// entirely from already-loaded local data (today's Planner tasks, plus a
/// weak-topic nudge from Insights), not fabricated notification content.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  void _loadData() {
    final userId = ref.read(authProvider).userId;
    if (userId != null) {
      ref.read(dailyPlanProvider.notifier).loadDailyPlan(userId: userId, date: DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(dailyPlanProvider);
    final weakAreasAsync = ref.watch(weakAreasProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Reminders',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: planState.isLoading ? _buildLoadingSkeleton() : _buildContent(planState, weakAreasAsync),
    );
  }

  Widget _buildContent(DailyPlanState planState, AsyncValue<WeakArea> weakAreasAsync) {
    if (planState.errorMessage != null) {
      return ErrorStates.generic(message: planState.errorMessage, onRetry: _loadData);
    }

    final pendingTasks =
        planState.dailyPlan?.tasks.where((t) => t.status != TaskStatus.completed).toList() ??
            const <PlannerTask>[];
    final weakTopic = weakAreasAsync.maybeWhen(
      data: (weakArea) => weakArea.weakTopics.isNotEmpty ? weakArea.weakTopics.first : null,
      orElse: () => null,
    );

    if (pendingTasks.isEmpty && weakTopic == null) {
      return ListView(
        children: [
          EmptyStates.noNotifications(padding: const EdgeInsets.all(AppConstants.spaceXl)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: [
        if (pendingTasks.isNotEmpty) ...[
          _sectionHeader("Today's plan (${pendingTasks.length})"),
          ...pendingTasks.map(_buildTaskReminder),
          const SizedBox(height: AppConstants.spaceLg),
        ],
        if (weakTopic != null) ...[
          _sectionHeader('Revision nudge'),
          _buildWeakTopicReminder(weakTopic),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.graphite700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTaskReminder(PlannerTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.marigold500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(_taskIcon(task.type), color: AppColors.marigold500, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                Text(
                  '${task.durationMinutes} min • due today',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => context.push('/planner'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopicReminder(WeakTopic weakTopic) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.rose500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.rose500.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_down, color: AppColors.rose500, size: 20),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weakTopic.topicName} needs revision',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                Text(
                  '${(weakTopic.currentAccuracy * 100).toStringAsFixed(0)}% accuracy over ${weakTopic.attempts} attempts',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => context.push('/learn/topic/${weakTopic.topicId}'),
          ),
        ],
      ),
    );
  }

  IconData _taskIcon(TaskType type) {
    switch (type) {
      case TaskType.learn:
        return Icons.book;
      case TaskType.pyq:
        return Icons.quiz;
      case TaskType.revision:
        return Icons.refresh;
      case TaskType.break_:
        return Icons.coffee;
      case TaskType.mockTest:
        return Icons.assignment;
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return SkeletonCard(
          height: 80,
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
        );
      },
    );
  }
}
