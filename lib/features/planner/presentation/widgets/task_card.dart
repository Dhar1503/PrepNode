import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';

/// Task Card Widget
/// Reusable card for displaying planner tasks with expandable reasoning
class TaskCard extends StatefulWidget {
  final PlannerTask task;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final VoidCallback? onReschedule;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isExpanded;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onSkip,
    this.onReschedule,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isExpanded = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLg,
          vertical: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: _getBorderColor()),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            splashColor: AppColors.ink900.withValues(alpha: 0.05),
            highlightColor: AppColors.ink900.withValues(alpha: 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(),
                AnimatedSize(
                  duration: const Duration(milliseconds: AppConstants.durationMedium2),
                  curve: AppConstants.standardEasing,
                  child: _isExpanded ? _buildExpandedContent() : const SizedBox.shrink(),
                ),
                if (!widget.task.isBreak) _buildActionRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (widget.task.isBreak) {
      return AppColors.sage500.withValues(alpha: 0.1);
    }
    if (widget.task.isCompleted) {
      return AppColors.sage500.withValues(alpha: 0.15);
    }
    if (widget.task.isSkipped) {
      return AppColors.graphite700.withValues(alpha: 0.1);
    }
    return AppColors.paper50;
  }

  Color _getBorderColor() {
    if (widget.task.isCompleted) {
      return AppColors.sage500;
    }
    if (widget.task.isSkipped) {
      return AppColors.graphite700;
    }
    return AppColors.lightOutline;
  }

  Widget _buildTaskHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Row(
        children: [
          _buildTaskIcon(),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: widget.task.isCompleted
                        ? AppColors.graphite700
                        : AppColors.ink900,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTypeChip(),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      '${widget.task.durationMinutes} min',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.task.isCompleted)
            Icon(
              Icons.check_circle,
              color: AppColors.sage500,
              size: 28,
            ),
          if (!widget.task.isCompleted && !widget.task.isSkipped)
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.graphite700,
            ),
          if (widget.onEdit != null || widget.onDelete != null) _buildOverflowMenu(),
        ],
      ),
    );
  }

  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.graphite700, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          widget.onEdit?.call();
        } else if (value == 'delete') {
          widget.onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (widget.onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  Widget _buildTaskIcon() {
    IconData icon;
    Color color;

    switch (widget.task.type) {
      case TaskType.learn:
        icon = Icons.book;
        color = AppColors.ink900;
        break;
      case TaskType.pyq:
        icon = Icons.quiz;
        color = AppColors.marigold500;
        break;
      case TaskType.revision:
        icon = Icons.refresh;
        color = AppColors.sage500;
        break;
      case TaskType.break_:
        icon = Icons.coffee;
        color = AppColors.sage500;
        break;
      case TaskType.mockTest:
        icon = Icons.assignment;
        color = AppColors.ink900;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildTypeChip() {
    String label;
    Color bgColor;

    switch (widget.task.type) {
      case TaskType.learn:
        label = 'Learn';
        bgColor = AppColors.ink900.withValues(alpha: 0.1);
        break;
      case TaskType.pyq:
        label = 'PYQ';
        bgColor = AppColors.marigold500.withValues(alpha: 0.1);
        break;
      case TaskType.revision:
        label = 'Revision';
        bgColor = AppColors.sage500.withValues(alpha: 0.1);
        break;
      case TaskType.break_:
        label = 'Break';
        bgColor = AppColors.sage500.withValues(alpha: 0.1);
        break;
      case TaskType.mockTest:
        label = 'Mock Test';
        bgColor = AppColors.ink900.withValues(alpha: 0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w500,
          color: AppColors.ink900,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: AppColors.lightOutline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 16,
                color: AppColors.marigold500,
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                'Why this?',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            widget.task.reason,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    if (widget.task.isCompleted || widget.task.isSkipped) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Complete',
              icon: Icons.check,
              color: AppColors.sage500,
              onPressed: widget.onComplete,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildActionButton(
              label: 'Skip',
              icon: Icons.skip_next,
              color: AppColors.graphite700,
              onPressed: widget.onSkip,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: _buildActionButton(
              label: 'Reschedule',
              icon: Icons.calendar_today,
              color: AppColors.ink900,
              onPressed: widget.onReschedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spaceSm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(color: color),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
