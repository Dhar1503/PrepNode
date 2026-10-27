import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';
import 'package:prepnode/features/roadmap/presentation/providers/roadmap_providers.dart';

/// The roadmap generator wizard.
///
/// Six single-question steps rather than one long form: a new aspirant who
/// has just registered will abandon a page of dropdowns, and one question at
/// a time makes the whole thing answerable in under a minute. Every answer
/// is a tap — nothing here needs the keyboard.
class RoadmapWizardScreen extends ConsumerStatefulWidget {
  const RoadmapWizardScreen({super.key});

  @override
  ConsumerState<RoadmapWizardScreen> createState() => _RoadmapWizardScreenState();
}

class _RoadmapWizardScreenState extends ConsumerState<RoadmapWizardScreen> {
  static const _totalSteps = 6;

  int _step = 0;
  bool _isGenerating = false;

  String _examId = 'tnpsc-group2';
  PreparationLevel _level = PreparationLevel.beginner;
  int _hoursPerDay = 3;
  PreferredStudyTime _preferredTime = PreferredStudyTime.morning;
  late int _targetMonth = DateTime.now().month;
  late int _targetYear = DateTime.now().year + 1;
  StudentType _studentType = StudentType.fullTime;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _generate();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _generate() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null || userId.isEmpty) return;

    setState(() => _isGenerating = true);

    final preferences = RoadmapPreferences(
      userId: userId,
      examId: _examId,
      level: _level,
      hoursPerDay: _hoursPerDay,
      preferredTime: _preferredTime,
      targetMonth: _targetMonth,
      targetYear: _targetYear,
      studentType: _studentType,
    );

    await ref.read(roadmapControllerProvider).generate(preferences);

    if (!mounted) return;
    setState(() => _isGenerating = false);
    context.go('/roadmap');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceLg,
                  vertical: AppConstants.spaceMd,
                ),
                child: _buildStep(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_step + 1} of $_totalSteps',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          // Progress bar animates between steps so the wizard feels like it
          // is going somewhere.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (_step + 1) / _totalSteps),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.lightOutlineVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.ink900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _StepScaffold(
          title: 'Which exam are you preparing for?',
          subtitle: 'Your roadmap is built from that exam\'s syllabus.',
          child: Column(
            children: [
              _ChoiceTile(
                label: 'TNPSC Group 2 / 2A',
                selected: _examId == 'tnpsc-group2',
                onTap: () => setState(() => _examId = 'tnpsc-group2'),
              ),
              _ChoiceTile(
                label: 'TNPSC Group 4',
                selected: _examId == 'tnpsc-group4',
                onTap: () => setState(() => _examId = 'tnpsc-group4'),
              ),
              _ChoiceTile(
                label: 'TNPSC Group 1',
                selected: _examId == 'tnpsc-group1',
                onTap: () => setState(() => _examId = 'tnpsc-group1'),
              ),
            ],
          ),
        ),
      1 => _StepScaffold(
          title: 'How far along are you?',
          subtitle: 'This sets how much new material each day carries.',
          child: Column(
            children: [
              _ChoiceTile(
                label: 'Beginner',
                description: 'Starting the syllabus for the first time',
                selected: _level == PreparationLevel.beginner,
                onTap: () => setState(() => _level = PreparationLevel.beginner),
              ),
              _ChoiceTile(
                label: 'Intermediate',
                description: 'Covered some subjects already',
                selected: _level == PreparationLevel.intermediate,
                onTap: () =>
                    setState(() => _level = PreparationLevel.intermediate),
              ),
              _ChoiceTile(
                label: 'Advanced',
                description: 'Revising and closing gaps',
                selected: _level == PreparationLevel.advanced,
                onTap: () => setState(() => _level = PreparationLevel.advanced),
              ),
            ],
          ),
        ),
      2 => _StepScaffold(
          title: 'How many hours a day can you study?',
          subtitle: 'Be honest — a plan you can finish beats an ambitious one.',
          child: Column(
            children: [
              Text(
                '$_hoursPerDay ${_hoursPerDay == 1 ? 'hour' : 'hours'}',
                style: GoogleFonts.fraunces(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
              Slider(
                value: _hoursPerDay.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.ink900,
                label: '$_hoursPerDay',
                onChanged: (v) => setState(() => _hoursPerDay = v.round()),
              ),
            ],
          ),
        ),
      3 => _StepScaffold(
          title: 'When do you study best?',
          subtitle: 'Used to time your reminders.',
          child: Column(
            children: [
              for (final time in PreferredStudyTime.values)
                _ChoiceTile(
                  label: switch (time) {
                    PreferredStudyTime.morning => 'Morning',
                    PreferredStudyTime.afternoon => 'Afternoon',
                    PreferredStudyTime.night => 'Night',
                  },
                  selected: _preferredTime == time,
                  onTap: () => setState(() => _preferredTime = time),
                ),
            ],
          ),
        ),
      4 => _StepScaffold(
          title: 'When is your exam?',
          subtitle: 'Your roadmap paces itself against this date.',
          child: Column(
            children: [
              _NumberStepper(
                label: 'Month',
                value: _targetMonth,
                min: 1,
                max: 12,
                display: (v) => _monthNames[v - 1],
                onChanged: (v) => setState(() => _targetMonth = v),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              _NumberStepper(
                label: 'Year',
                value: _targetYear,
                min: DateTime.now().year,
                max: DateTime.now().year + 5,
                display: (v) => '$v',
                onChanged: (v) => setState(() => _targetYear = v),
              ),
            ],
          ),
        ),
      _ => _StepScaffold(
          title: 'Are you studying full time?',
          subtitle: 'Working students get a lighter daily load.',
          child: Column(
            children: [
              _ChoiceTile(
                label: 'Full-time student',
                description: 'Preparation is my main commitment',
                selected: _studentType == StudentType.fullTime,
                onTap: () => setState(() => _studentType = StudentType.fullTime),
              ),
              _ChoiceTile(
                label: 'Working student',
                description: 'I study around a job',
                selected: _studentType == StudentType.working,
                onTap: () => setState(() => _studentType = StudentType.working),
              ),
            ],
          ),
        ),
    };
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        AppConstants.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        border: Border(top: BorderSide(color: AppColors.lightOutlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: _step == _totalSteps - 1 ? 'Generate my roadmap' : 'Continue',
            onPressed: _next,
            isLoading: _isGenerating,
          ),
          if (_step > 0) ...[
            const SizedBox(height: AppConstants.spaceXs),
            AppTextButton(label: 'Back', onPressed: _back),
          ],
        ],
      ),
    );
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spaceMd),
        Text(
          title,
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        child,
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.ink900.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            border: Border.all(
              color: selected ? AppColors.ink900 : AppColors.lightOutlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.ink900 : AppColors.lightOutlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String Function(int) display;
  final ValueChanged<int> onChanged;

  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.lightOutlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
                Text(
                  display(value),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeTitleMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.ink900,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.ink900,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
