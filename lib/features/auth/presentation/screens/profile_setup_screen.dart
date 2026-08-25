import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_button.dart';
import 'package:prepgraph/features/auth/domain/entities/exam.dart';
import 'package:prepgraph/features/auth/domain/entities/learner_profile.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';

/// Profile Setup Wizard (S1.1-S1.5)
/// 5-step wizard to capture exam, timeline, availability, and preparation level
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  LearnerProfile _profile = const LearnerProfile();
  List<Exam> _exams = [];
  bool _isLoadingExams = false;
  bool _isGeneratingPlan = false;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoadingExams = true;
    });

    final result = await ref.read(profileRepositoryProvider).getExams();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingExams = false;
        });
      },
      (exams) {
        setState(() {
          _isLoadingExams = false;
          _exams = exams;
        });
      },
    );
  }

  void _handleNextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handlePreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleCompleteSetup() async {
    setState(() {
      _isGeneratingPlan = true;
    });

    final userId = ref.read(authProvider).userId;
    if (userId != null) {
      await ref.read(profileRepositoryProvider).updateProfile(
            userId: userId,
            examId: _profile.examId,
            targetDate: _profile.targetDate,
            dailyStudyHours: _profile.dailyStudyHours,
            preparationLevel: _profile.preparationLevel?.name,
          );
    }

    if (!mounted) return;

    setState(() {
      _isGeneratingPlan = false;
    });
    context.go('/home');
  }

  void _selectExam(Exam exam) {
    setState(() {
      _profile = _profile.copyWith(examId: exam.id);
    });
    _handleNextStep();
  }

  void _selectTargetDate(DateTime date) {
    setState(() {
      _profile = _profile.copyWith(targetDate: date);
    });
    _handleNextStep();
  }

  // Unlike exam/date/level (one-shot taps, fine to auto-advance), the
  // slider fires this continuously while dragging — auto-advancing here
  // made it jump to the next step on the first touch, before the user
  // could actually pick a value. The step's own "Continue" button is the
  // only thing that should advance now.
  void _selectStudyHours(int hours) {
    setState(() {
      _profile = _profile.copyWith(dailyStudyHours: hours);
    });
  }

  void _selectPreparationLevel(PreparationLevel level) {
    setState(() {
      _profile = _profile.copyWith(preparationLevel: level);
    });
    _handleNextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildExamSelectionStep(),
                  _buildTargetDateStep(),
                  _buildStudyHoursStep(),
                  _buildPreparationLevelStep(),
                  _buildCompletionStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 4 ? AppConstants.spaceXs : 0,
              ),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.ink900 : AppColors.lightOutlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExamSelectionStep() {
    return _isLoadingExams
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceLg),
                _buildStepTitle('Select your exam'),
                const SizedBox(height: AppConstants.spaceSm),
                _buildStepDescription(
                  'Choose the exam you\'re preparing for',
                ),
                const SizedBox(height: AppConstants.spaceXl),
                Expanded(
                  child: ListView.builder(
                    itemCount: _exams.length,
                    itemBuilder: (context, index) {
                      final exam = _exams[index];
                      return _buildExamCard(exam);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildExamCard(Exam exam) {
    final isSelected = _profile.examId == exam.id;
    
    return GestureDetector(
      onTap: exam.comingSoon ? null : () => _selectExam(exam),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ink900
              : AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.ink900
                : exam.comingSoon
                    ? AppColors.lightOutlineVariant
                    : AppColors.lightOutline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : exam.comingSoon
                      ? Icons.lock_outline
                      : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.lightOnPrimary
                  : exam.comingSoon
                      ? AppColors.graphite700
                      : AppColors.ink900,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.name,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.lightOnPrimary
                          : exam.comingSoon
                              ? AppColors.graphite700
                              : AppColors.ink900,
                    ),
                  ),
                  if (exam.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      exam.description!,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: isSelected
                            ? AppColors.lightOnPrimary.withValues(alpha: 0.8)
                            : AppColors.graphite700,
                      ),
                    ),
                  ],
                  if (exam.comingSoon) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Coming soon',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.lightOnPrimary
                            : AppColors.marigold500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetDateStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          _buildStepTitle('Set your target date'),
          const SizedBox(height: AppConstants.spaceSm),
          _buildStepDescription(
            'When do you plan to take the exam?',
          ),
          const SizedBox(height: AppConstants.spaceXl),
          Expanded(
            child: Center(
              child: _buildDatePickerCard(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Continue',
            onPressed: _handleNextStep,
            enabled: _profile.targetDate != null,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppTextButton(
            label: 'Back',
            onPressed: _handlePreviousStep,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: AppColors.ink900,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            _profile.targetDate != null
                ? '${_profile.targetDate!.day}/${_profile.targetDate!.month}/${_profile.targetDate!.year}'
                : 'Select a date',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: _profile.targetDate != null ? 'Change Date' : 'Pick Date',
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 90)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) {
                _selectTargetDate(picked);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudyHoursStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          _buildStepTitle('Daily study hours'),
          const SizedBox(height: AppConstants.spaceSm),
          _buildStepDescription(
            'How many hours can you study daily?',
          ),
          const SizedBox(height: AppConstants.spaceXl),
          Expanded(
            child: Center(
              child: _buildStudyHoursSlider(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Continue',
            onPressed: _handleNextStep,
            enabled: _profile.dailyStudyHours != null,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppTextButton(
            label: 'Back',
            onPressed: _handlePreviousStep,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyHoursSlider() {
    final hours = _profile.dailyStudyHours ?? 4;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$hours hours',
            style: GoogleFonts.fraunces(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'per day',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Slider(
            value: hours.toDouble(),
            min: 1,
            max: 8,
            divisions: 7,
            label: '$hours hours',
            activeColor: AppColors.ink900,
            onChanged: (value) {
              _selectStudyHours(value.round());
            },
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 hr',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
              Text(
                '8+ hrs',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationLevelStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          _buildStepTitle('Your preparation level'),
          const SizedBox(height: AppConstants.spaceSm),
          _buildStepDescription(
            'This helps us personalize your plan',
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Expanded(
            child: ListView(
              children: PreparationLevel.values.map((level) {
                return _buildLevelCard(level);
              }).toList(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Continue',
            onPressed: _handleNextStep,
            enabled: _profile.preparationLevel != null,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppTextButton(
            label: 'Back',
            onPressed: _handlePreviousStep,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(PreparationLevel level) {
    final isSelected = _profile.preparationLevel == level;
    
    return GestureDetector(
      onTap: () => _selectPreparationLevel(level),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ink900
              : AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.ink900 : AppColors.lightOutline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayName,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: isSelected
                          ? AppColors.lightOnPrimary.withValues(alpha: 0.8)
                          : AppColors.graphite700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          if (_isGeneratingPlan) ...[
            _buildAiThinkingIndicator(),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Personalizing your first plan...',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyLarge,
                color: AppColors.graphite700,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.sage500,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Setup complete!',
              style: GoogleFonts.fraunces(
                fontSize: AppConstants.fontSizeHeadlineMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Your personalized study plan is ready',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceXl),
            AppButton(
              label: 'Get Started',
              onPressed: _handleCompleteSetup,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            AppTextButton(
              label: 'Back',
              onPressed: _handlePreviousStep,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiThinkingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        const SizedBox(width: 8),
        _buildDot(1),
        const SizedBox(width: 8),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.marigold500,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStepTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
    );
  }

  Widget _buildStepDescription(String description) {
    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyMedium,
        color: AppColors.graphite700,
      ),
    );
  }
}
