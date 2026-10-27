import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/planner/domain/entities/planner_task.dart';

/// Result of submitting the task form, shared by create and edit flows.
class TaskFormResult {
  final String topicId;
  final String title;
  final int durationMinutes;
  final TaskType type;
  final String? reason;

  const TaskFormResult({
    required this.topicId,
    required this.title,
    required this.durationMinutes,
    required this.type,
    this.reason,
  });
}

/// Bottom sheet for creating a new study task or editing an existing one.
/// Reuses the existing Knowledge Graph subject/topic providers for topic
/// selection instead of introducing a new topic-lookup mechanism.
class TaskFormBottomSheet extends ConsumerStatefulWidget {
  final PlannerTask? existingTask;
  final void Function(TaskFormResult result) onSubmit;

  /// Pre-fills the topic when opened from a topic-scoped entry point (e.g.
  /// Topic Detail's "Add to Study Plan") instead of the generic FAB — skips
  /// the subject/topic pickers since the topic is already known.
  final String? initialTopicId;
  final String? initialTopicName;

  const TaskFormBottomSheet({
    super.key,
    this.existingTask,
    required this.onSubmit,
    this.initialTopicId,
    this.initialTopicName,
  });

  @override
  ConsumerState<TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends ConsumerState<TaskFormBottomSheet> {
  static const _examId = 'tnpsc-group2';

  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _reasonController;
  TaskType _selectedType = TaskType.learn;
  String? _selectedSubjectId;
  String? _selectedTopicId;
  String? _validationError;

  bool get _isEditing => widget.existingTask != null;
  bool get _hasPrefilledTopic => !_isEditing && widget.initialTopicId != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(
      text: task?.title ?? (widget.initialTopicName != null ? 'Study ${widget.initialTopicName}' : ''),
    );
    _durationController = TextEditingController(text: (task?.durationMinutes ?? 30).toString());
    _reasonController = TextEditingController(text: task?.reason ?? '');
    _selectedType = task?.type ?? TaskType.learn;
    _selectedTopicId = widget.initialTopicId;

    if (!_isEditing && !_hasPrefilledTopic) {
      Future.microtask(() {
        ref.read(subjectsProvider.notifier).loadSubjects(examId: _examId);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubjectChanged(String? subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedTopicId = null;
    });
    if (subjectId != null) {
      ref.read(topicsProvider.notifier).loadTopics(subjectId: subjectId);
    }
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final topicId = _isEditing ? widget.existingTask!.topicId : _selectedTopicId;

    if (title.isEmpty || duration <= 0 || topicId == null || topicId.isEmpty) {
      setState(() {
        _validationError = 'Please fill in title, topic and a valid duration';
      });
      return;
    }

    widget.onSubmit(TaskFormResult(
      topicId: topicId,
      title: title,
      durationMinutes: duration,
      type: _selectedType,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.graphite700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Edit Task' : 'Add Task',
              style: GoogleFonts.fraunces(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            if (_hasPrefilledTopic) ...[
              _buildPrefilledTopicRow(),
              const SizedBox(height: AppConstants.spaceMd),
            ] else if (!_isEditing) ...[
              _buildSubjectTopicPickers(),
              const SizedBox(height: AppConstants.spaceMd),
            ],
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            DropdownButtonFormField<TaskType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: TaskType.learn, child: Text('Learn')),
                DropdownMenuItem(value: TaskType.pyq, child: Text('PYQ Practice')),
                DropdownMenuItem(value: TaskType.revision, child: Text('Revision')),
                DropdownMenuItem(value: TaskType.mockTest, child: Text('Mock Test')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: AppConstants.spaceMd),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                _validationError!,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.rose500,
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXl),
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: AppButton(
                    label: _isEditing ? 'Save' : 'Add',
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefilledTopicRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Icon(Icons.topic_outlined, size: 18, color: AppColors.graphite700),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              widget.initialTopicName ?? 'Selected topic',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTopicPickers() {
    final subjectsState = ref.watch(subjectsProvider);
    final topicsState = ref.watch(topicsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedSubjectId,
          decoration: const InputDecoration(labelText: 'Subject'),
          items: subjectsState.subjects
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              .toList(),
          onChanged: _handleSubjectChanged,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        DropdownButtonFormField<String>(
          initialValue: _selectedTopicId,
          decoration: const InputDecoration(labelText: 'Topic'),
          items: topicsState.topics
              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
              .toList(),
          onChanged: (value) => setState(() => _selectedTopicId = value),
        ),
      ],
    );
  }
}
