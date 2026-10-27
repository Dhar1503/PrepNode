import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';

/// One day on the timeline: a status rail on the left, an expandable card on
/// the right. Colour encodes state (green done, ink current, orange weak,
/// grey ahead) so the whole month is readable at a glance without reading a
/// single label.
class RoadmapDayCard extends StatelessWidget {
  final RoadmapDay day;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onCompleteTask;

  const RoadmapDayCard({
    super.key,
    required this.day,
    required this.isExpanded,
    required this.onToggle,
    required this.onCompleteTask,
  });

  Color get _statusColor => switch (day.status) {
        RoadmapDayStatus.completed => const Color(0xFF3F7D58),
        RoadmapDayStatus.current => AppColors.ink900,
        RoadmapDayStatus.weak => const Color(0xFFB4552F),
        RoadmapDayStatus.missed => AppColors.graphite700,
        RoadmapDayStatus.locked => AppColors.lightOutlineVariant,
      };

  String get _statusLabel => switch (day.status) {
        RoadmapDayStatus.completed => 'Completed',
        RoadmapDayStatus.current => 'Today',
        RoadmapDayStatus.weak => 'Partly done',
        RoadmapDayStatus.missed => 'Missed',
        RoadmapDayStatus.locked => 'Upcoming',
      };

  @override
  Widget build(BuildContext context) {
    final isCurrent = day.status == RoadmapDayStatus.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRail(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceSm,
                0,
                AppConstants.spaceLg,
                AppConstants.spaceSm,
              ),
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.ink900.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: Border.all(
                      color: isCurrent ? AppColors.ink900 : AppColors.lightOutlineVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      if (day.tasks.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceSm),
                        _buildProgressBar(),
                      ],
                      // AnimatedSize gives the expand/collapse a real
                      // transition instead of the list jumping.
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: isExpanded
                            ? _buildTaskList()
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The connecting rail. The line runs full height so consecutive cards
  /// join up into one continuous path.
  Widget _buildRail() {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: day.status == RoadmapDayStatus.locked
                      ? Colors.white
                      : _statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _statusColor, width: 2),
                ),
                child: Center(
                  child: day.status == RoadmapDayStatus.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${day.dayNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: day.status == RoadmapDayStatus.locked
                                ? AppColors.graphite700
                                : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Day ${day.dayNumber} · ${_formatDate(day.date)}',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.tasks.length} task${day.tasks.length == 1 ? '' : 's'} · '
                '${day.totalMinutes} min · $_statusLabel',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
        ),
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Icon(Icons.expand_more, color: AppColors.graphite700),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: day.progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, _) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 5,
          backgroundColor: AppColors.lightOutlineVariant,
          valueColor: AlwaysStoppedAnimation(_statusColor),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spaceSm),
        for (final task in day.tasks) _buildTaskRow(task),
      ],
    );
  }

  Widget _buildTaskRow(RoadmapTask task) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox is the tap target, not the whole row — tapping the row
          // toggles the card, and a control that does two things depending
          // on where you hit it is how people complete tasks by accident.
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: task.isCompleted,
              activeColor: const Color(0xFF3F7D58),
              onChanged: task.isCompleted
                  ? null
                  : (_) => onCompleteTask(task.id),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.ink900,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  '${_kindLabel(task.kind)} · ${task.estimatedMinutes} min',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _kindLabel(RoadmapTaskKind kind) => switch (kind) {
        RoadmapTaskKind.study => 'Study',
        RoadmapTaskKind.pyq => 'PYQ practice',
        RoadmapTaskKind.revision => 'Revision',
        RoadmapTaskKind.mock => 'Mock test',
        RoadmapTaskKind.resource => 'Resource',
        RoadmapTaskKind.assessment => 'Assessment',
      };

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
