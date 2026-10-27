import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/skeleton_loader.dart';
import 'package:prepnode/core/widgets/empty_state.dart';
import 'package:prepnode/core/widgets/error_state.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/planner/domain/entities/daily_plan.dart';
import 'package:prepnode/features/planner/domain/entities/planner_task.dart';
import 'package:prepnode/features/planner/presentation/providers/planner_providers.dart';
import 'package:prepnode/features/strategy/domain/entities/roadmap.dart';
import 'package:prepnode/features/strategy/presentation/providers/strategy_providers.dart';
import 'package:prepnode/features/planner/presentation/widgets/reschedule_bottom_sheet.dart';
import 'package:prepnode/features/planner/presentation/widgets/segmented_control.dart';
import 'package:prepnode/features/planner/presentation/widgets/task_card.dart';
import 'package:prepnode/features/planner/presentation/widgets/task_form_bottom_sheet.dart';
import 'package:prepnode/features/planner/presentation/widgets/week_strip.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';

/// AI Planner Screen (S4.1-S4.4)
/// Full daily/weekly personalized schedule with explainable reasoning
class PlannerScreen extends ConsumerStatefulWidget {
  /// Set when arriving from Topic Detail's "Add to Study Plan" button (see
  /// the /planner route in app_router.dart) — opens the add-task sheet
  /// pre-filled with this topic instead of leaving the button's action
  /// silently do nothing.
  final String? addTopicId;
  final String? addTopicName;

  const PlannerScreen({super.key, this.addTopicId, this.addTopicName});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  int _selectedSegment = 0; // 0 = Today, 1 = Week
  DateTime _selectedDate = DateTime.now();
  bool _hasAutoSeeded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
    if (widget.addTopicId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleAddTaskForTopic(widget.addTopicId!, widget.addTopicName);
      });
    }
  }

  void _loadData() {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;
    ref.read(dailyPlanProvider.notifier).loadDailyPlan(userId: userId, date: DateTime.now()).then((_) {
      if (mounted) _autoSeedFromRoadmapIfEmpty(userId);
    });
  }

  /// Today's Planner used to show empty until a task was added by hand,
  /// even though the Strategy Engine already computes a real ranked
  /// roadmap for today. This connects the two: if there is genuinely
  /// nothing scheduled for today yet, pull today's roadmap items (Day 1
  /// of a fresh roadmap always == today, see StrategyRepositoryImpl.
  /// getRoadmap) and create real planner tasks from them, once per screen
  /// visit. If the roadmap itself is empty (no PYQ/mastery data yet), this
  /// correctly does nothing — Planner stays honestly empty rather than
  /// fabricating tasks.
  Future<void> _autoSeedFromRoadmapIfEmpty(String userId) async {
    if (_hasAutoSeeded) return;
    final existing = ref.read(dailyPlanProvider).dailyPlan?.tasks ?? const [];
    if (existing.isNotEmpty) return;
    _hasAutoSeeded = true;

    List<RoadmapItem> todaysItems;
    try {
      final roadmap = await ref.read(roadmapProvider('tnpsc-group2').future);
      todaysItems = roadmap.days.isEmpty ? const [] : roadmap.days.first.items;
    } catch (_) {
      return; // no roadmap data available yet — leave Planner empty, honestly
    }
    if (todaysItems.isEmpty || !mounted) return;

    final notifier = ref.read(dailyPlanProvider.notifier);
    for (final item in todaysItems) {
      await notifier.createTask(
        userId: userId,
        topicId: item.topicId,
        title: item.activityType == RoadmapActivityType.revision
            ? 'Revise ${item.topicName}'
            : 'Study ${item.topicName}',
        durationMinutes: item.durationMinutes,
        type: item.activityType == RoadmapActivityType.revision ? TaskType.revision : TaskType.learn,
        scheduledDate: DateTime.now(),
        reason: 'Auto-added from your Strategy roadmap',
      );
    }
  }

  void _handleSegmentChange(int index) {
    setState(() {
      _selectedSegment = index;
    });
  }

  void _handleDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadDataForDate(date);
  }

  void _loadDataForDate(DateTime date) {
    final userId = ref.read(authProvider).userId;
    if (userId != null) {
      ref.read(dailyPlanProvider.notifier).loadDailyPlan(userId: userId, date: date);
    }
  }

  Future<void> _handleCompleteTask(PlannerTask task) async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    await ref.read(dailyPlanProvider.notifier).completeTask(userId: userId, task: task);

    // The task's completion just wrote a real study_sessions row and
    // updated its status — refresh the other screens that read the same
    // underlying data instead of leaving them showing stale state.
    ref.read(dashboardProvider.notifier).loadDashboardData(userId: userId);
    ref.invalidate(learnerProgressProvider);
    ref.invalidate(masteryAnalyticsProvider);
    ref.invalidate(studyHabitsProvider);
    ref.invalidate(weakAreasProvider);
  }

  void _handleSkipTask(PlannerTask task) {
    ref.read(dailyPlanProvider.notifier).updateTaskStatus(
          taskId: task.id,
          status: TaskStatus.skipped,
        );
  }

  void _handleRescheduleTask(PlannerTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RescheduleBottomSheet(
        currentScheduledDate: task.scheduledDate,
        onReschedule: (newDate) {
          ref.read(dailyPlanProvider.notifier).rescheduleTask(
                taskId: task.id,
                newDate: newDate,
              );
        },
      ),
    );
  }

  void _handleAddTask() {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormBottomSheet(
        onSubmit: (result) {
          ref.read(dailyPlanProvider.notifier).createTask(
                userId: userId,
                topicId: result.topicId,
                title: result.title,
                durationMinutes: result.durationMinutes,
                type: result.type,
                scheduledDate: _selectedSegment == 1 ? _selectedDate : DateTime.now(),
                reason: result.reason,
              );
        },
      ),
    );
  }

  void _handleAddTaskForTopic(String topicId, String? topicName) {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormBottomSheet(
        initialTopicId: topicId,
        initialTopicName: topicName,
        onSubmit: (result) {
          ref.read(dailyPlanProvider.notifier).createTask(
                userId: userId,
                topicId: result.topicId,
                title: result.title,
                durationMinutes: result.durationMinutes,
                type: result.type,
                scheduledDate: _selectedSegment == 1 ? _selectedDate : DateTime.now(),
                reason: result.reason,
              );
        },
      ),
    );
  }

  void _handleEditTask(PlannerTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormBottomSheet(
        existingTask: task,
        onSubmit: (result) {
          ref.read(dailyPlanProvider.notifier).editTask(
                taskId: task.id,
                topicId: result.topicId,
                title: result.title,
                durationMinutes: result.durationMinutes,
                type: result.type,
                reason: result.reason,
              );
        },
      ),
    );
  }

  void _handleDeleteTask(PlannerTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently remove "${task.title}" from your plan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(dailyPlanProvider.notifier).deleteTask(task.id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.rose500)),
          ),
        ],
      ),
    );
  }

  void _handleTaskTap(PlannerTask task) {
    // Navigate to topic detail or practice session based on task type
    if (task.type == TaskType.learn && task.topicId.isNotEmpty) {
      // Navigate to Knowledge Graph topic detail
      context.push('/learn/topic/${task.topicId}');
    } else if (task.type == TaskType.pyq && task.topicId.isNotEmpty) {
      // Navigate to PYQ practice
      context.go('/practice');
    } else if (task.type == TaskType.mockTest) {
      // Navigate to Mock Tests
      context.push('/mock-tests');
    }
    // M9 Integration: Show related resources for the task
    _showRelatedResources(task);
  }

  // M9 Integration: Show related resources for a task
  void _showRelatedResources(PlannerTask task) {
    if (task.topicId.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RelatedResourcesSheet(topicId: task.topicId),
    );
  }

  void _handleAskAI() {
    // M12 Integration: Navigate to AI Assistant with planner context
    context.push('/ai-assistant/chat?contextModule=planner');
  }

  @override
  Widget build(BuildContext context) {
    final dailyPlanState = ref.watch(dailyPlanProvider);
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        // scaleDown: this bar carries several action icons, so the title
        // must shrink rather than ellipsize at a large font scale.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'AI Planner',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: _handleAskAI,
            tooltip: 'Ask AI About Your Plan',
          ),
        ],
      ),
      body: dailyPlanState.isLoading
          ? _buildLoadingSkeleton()
          : _buildContent(dailyPlanState),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTask,
        backgroundColor: AppColors.ink900,
        tooltip: 'Add Task',
        child: const Icon(Icons.add, color: AppColors.paper50),
      ),
    );
  }

  Widget _buildContent(DailyPlanState state) {
    if (state.errorMessage != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        const SizedBox(height: AppConstants.spaceMd),
        SegmentedControl(
          options: const ['Today', 'This Week'],
          selectedIndex: _selectedSegment,
          onOptionSelected: _handleSegmentChange,
        ),
        const SizedBox(height: AppConstants.spaceLg),
        // Both views are Columns containing an Expanded task list, so they
        // need bounded height. Without these Expanded wrappers the inner
        // Expanded sits in an unbounded Column and throws a layout error —
        // which release builds swallow, rendering the whole planner blank.
        if (_selectedSegment == 0) Expanded(child: _buildTodayView(state.dailyPlan)),
        if (_selectedSegment == 1) Expanded(child: _buildWeekView(state.dailyPlan)),
      ],
    );
  }

  Widget _buildTodayView(DailyPlan? dailyPlan) {
    if (dailyPlan == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // M7 Integration: Readiness indicator from Cutoff Intelligence
        _buildReadinessIndicator(),
        const SizedBox(height: AppConstants.spaceMd),
        if (dailyPlan.supportiveMessage != null) _buildSupportiveMessage(dailyPlan),
        const SizedBox(height: AppConstants.spaceMd),
        Expanded(
          child: _buildTaskList(dailyPlan.tasks),
        ),
      ],
    );
  }

  Widget _buildWeekView(DailyPlan? dailyPlan) {
    return Column(
      children: [
        WeekStrip(
          selectedDate: _selectedDate,
          onDateTap: _handleDateTap,
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Expanded(
          child: _buildTaskList(dailyPlan?.tasks ?? []),
        ),
      ],
    );
  }

  Widget _buildSupportiveMessage(DailyPlan dailyPlan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.marigold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.marigold500),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.marigold500),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              dailyPlan.supportiveMessage!,
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

  Widget _buildTaskList(List<PlannerTask> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceXl),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onComplete: () => _handleCompleteTask(tasks[index]),
          onSkip: () => _handleSkipTask(tasks[index]),
          onReschedule: () => _handleRescheduleTask(tasks[index]),
          onTap: () => _handleTaskTap(tasks[index]),
          onEdit: () => _handleEditTask(tasks[index]),
          onDelete: () => _handleDeleteTask(tasks[index]),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return SkeletonCard(
          height: 140,
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStates.caughtUp(
      onAction: () => context.go('/practice'),
    );
  }

  Widget _buildErrorState() {
    return ErrorStates.network(
      onRetry: _loadData,
      contextMessage: "We couldn't load your plan",
    );
  }

  Widget _buildReadinessIndicator() {
    // M7 Integration: Display readiness prediction from Cutoff Intelligence
    return Consumer(
      builder: (context, ref, _) {
        final examId = 'tnpsc-group2';
        final readinessAsync = ref.watch(readinessPredictionProvider(examId));
        
        return readinessAsync.when(
          data: (prediction) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: _getReadinessColor(prediction.readinessLevel).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(
                  color: _getReadinessColor(prediction.readinessLevel),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getReadinessIcon(prediction.readinessLevel),
                    color: _getReadinessColor(prediction.readinessLevel),
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Readiness: ${_readinessLabel(prediction.readinessLevel)}',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            fontWeight: FontWeight.w600,
                            color: _getReadinessColor(prediction.readinessLevel),
                          ),
                        ),
                        Text(
                          '${prediction.readinessPercentage.toStringAsFixed(0)}% of qualifying mark',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Was a "Details" link into Cutoff Intelligence, which is
                  // now unreachable; sends the user somewhere useful instead.
                  TextButton(
                    onPressed: () => context.go('/insights'),
                    child: Text(
                      'Insights',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: _getReadinessColor(prediction.readinessLevel),
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

  /// 'needs_improvement' -> 'Needs Improvement'. The raw enum value was
  /// being upper-cased straight into the UI, so users saw
  /// "NEEDS_IMPROVEMENT" complete with the underscore.
  String _readinessLabel(String level) {
    return level
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getReadinessColor(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return AppColors.sage500;
      case 'good':
        return AppColors.azure500;
      case 'moderate':
        return AppColors.marigold500;
      case 'needs_improvement':
        return AppColors.rose500;
      default:
        return AppColors.graphite700;
    }
  }

  IconData _getReadinessIcon(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return Icons.check_circle;
      case 'good':
        return Icons.thumb_up;
      case 'moderate':
        return Icons.info;
      case 'needs_improvement':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}

// M9 Integration: Related Resources Sheet for Planner Tasks
class _RelatedResourcesSheet extends ConsumerWidget {
  final String topicId;

  const _RelatedResourcesSheet({required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedResourcesAsync = ref.watch(relatedResourcesProvider(topicId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.graphite700.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Learning Resources',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Resources list
          Expanded(
            child: relatedResourcesAsync.when(
              data: (resources) {
                if (resources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: AppColors.graphite700,
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        Text(
                          'No resources available',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodyMedium,
                            color: AppColors.graphite700,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      child: ListTile(
                        leading: Icon(
                          _getResourceIcon(resource.type.name),
                          color: AppColors.sage500,
                        ),
                        title: Text(
                          resource.title,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodyMedium,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink900,
                          ),
                        ),
                        subtitle: Text(
                          resource.author,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/resources/${resource.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => Center(
                child: Text(
                  'Unable to load resources',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'book':
        return Icons.menu_book;
      case 'youtube':
        return Icons.play_circle;
      case 'website':
        return Icons.language;
      default:
        return Icons.description;
    }
  }
}
