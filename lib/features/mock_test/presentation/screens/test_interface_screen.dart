import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepnode/features/mock_test/presentation/providers/mock_test_providers.dart';
import 'package:prepnode/features/mock_test/presentation/widgets/neutral_timer.dart';
import 'package:prepnode/features/mock_test/presentation/widgets/question_palette.dart';
import 'package:prepnode/features/pyq/presentation/widgets/option_tile.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/strategy/presentation/providers/strategy_providers.dart';

/// Test Interface Screen (S6.3)
/// Full-screen test interface with timer, questions, and navigation.
/// All test-taking state (answers, navigation, timer, submission) is
/// managed by [testAttemptProvider] rather than local widget state.
class TestInterfaceScreen extends ConsumerStatefulWidget {
  final MockTestAttempt attempt;

  const TestInterfaceScreen({
    super.key,
    required this.attempt,
  });

  @override
  ConsumerState<TestInterfaceScreen> createState() => _TestInterfaceScreenState();
}

class _TestInterfaceScreenState extends ConsumerState<TestInterfaceScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  Timer? _timer;
  int _questionTimeSeconds = 0;
  bool _showPalette = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Deferred: Riverpod forbids modifying a provider synchronously during
    // a widget's initState (still mid-build), so this has to run after the
    // current frame instead of inline here.
    Future.microtask(() => ref.read(testAttemptProvider.notifier).loadAttempt(widget.attempt));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      ref.read(testAttemptProvider.notifier).tick();
      setState(() {
        _questionTimeSeconds++;
      });
    });
  }

  void _handleOptionTap(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _saveCurrentAnswer(List<MockTestQuestion> questions) {
    if (_selectedOptionIndex != null && _currentIndex < questions.length) {
      ref.read(testAttemptProvider.notifier).updateQuestionAnswer(
            questionId: questions[_currentIndex].id,
            selectedOptionIndex: _selectedOptionIndex!,
            timeTakenSeconds: _questionTimeSeconds,
          );
    }
  }

  void _handleNext(List<MockTestQuestion> questions) {
    _saveCurrentAnswer(questions);
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = questions[_currentIndex].selectedOptionIndex;
        _questionTimeSeconds = questions[_currentIndex].timeTakenSeconds ?? 0;
      });
    }
  }

  void _handlePrevious(List<MockTestQuestion> questions) {
    _saveCurrentAnswer(questions);
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedOptionIndex = questions[_currentIndex].selectedOptionIndex;
        _questionTimeSeconds = questions[_currentIndex].timeTakenSeconds ?? 0;
      });
    }
  }

  void _handleMarkForReview(List<MockTestQuestion> questions) {
    final question = questions[_currentIndex];
    ref.read(testAttemptProvider.notifier).markForReview(
          questionId: question.id,
          isMarked: !question.isMarkedForReview,
        );
  }

  void _handleSkip(List<MockTestQuestion> questions) {
    ref.read(testAttemptProvider.notifier).skipQuestion(
          questionId: questions[_currentIndex].id,
        );
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = questions[_currentIndex].selectedOptionIndex;
        _questionTimeSeconds = questions[_currentIndex].timeTakenSeconds ?? 0;
      });
    }
  }

  void _handleQuestionTap(int index, List<MockTestQuestion> questions) {
    _saveCurrentAnswer(questions);
    setState(() {
      _currentIndex = index;
      _selectedOptionIndex = questions[index].selectedOptionIndex;
      _questionTimeSeconds = questions[index].timeTakenSeconds ?? 0;
      _showPalette = false;
    });
  }

  void _handleSubmit(List<MockTestQuestion> questions) {
    _saveCurrentAnswer(questions);
    _showSubmitConfirmation(questions);
  }

  void _showSubmitConfirmation(List<MockTestQuestion> questions) {
    final answeredCount = questions.where((q) => q.isAnswered).length;
    final skippedCount = questions.where((q) => q.isSkipped).length;
    final unansweredCount = questions.length - answeredCount - skippedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: $answeredCount'),
            Text('Skipped: $skippedCount'),
            Text('Unanswered: $unansweredCount'),
            const SizedBox(height: AppConstants.spaceSm),
            const Text('Are you sure you want to submit?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    setState(() => _isSubmitting = true);

    final result = await ref.read(testAttemptProvider.notifier).submitTest();

    if (!mounted) return;

    if (result == null) {
      setState(() => _isSubmitting = false);
      final error = ref.read(testAttemptProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not submit the test. Please try again.')),
      );
      return;
    }

    // Same reasoning as PYQ practice completion: a submitted test just
    // wrote a real score, and everything that reads from that same data
    // (Dashboard, Insights, Strategy) should reflect it immediately, not
    // whenever the user next happens to revisit those screens.
    ref.invalidate(learnerProgressProvider);
    ref.invalidate(masteryAnalyticsProvider);
    ref.invalidate(mockTestAnalyticsProvider);
    ref.invalidate(weakAreasProvider);
    ref.invalidate(studyCapacityProvider);
    ref.invalidate(nextBestTopicsProvider);
    ref.invalidate(roadmapProvider);
    ref.invalidate(strategySummaryProvider);

    // Replace rather than push: this attempt is finished, so the test
    // interface must not stay underneath the result screen. Leaving it there
    // let the user navigate back into a submitted test whose _isSubmitting
    // flag was still true, which made the Submit button a permanent no-op
    // (see the guard on its onPressed) and trapped them on a dead screen.
    context.pushReplacement('/mock-tests/result/${result.attemptId}', extra: result);
  }

  void _handleTimeUp() {
    if (_isSubmitting) return;
    _submitTest();
  }

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(testAttemptProvider).attempt;
    final questions = attempt?.questions ?? const <MockTestQuestion>[];

    if (attempt == null || questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.paper50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Text(
                'No questions available for this test.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyLarge,
                  color: AppColors.graphite700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentIndex = _currentIndex < questions.length ? _currentIndex : questions.length - 1;
    final currentQuestion = questions[currentIndex];
    final remainingTime = attempt.timeRemainingSeconds;

    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(remainingTime, questions.length),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildQuestionCard(currentQuestion),
                    if (_showPalette) _buildQuestionPalette(questions),
                  ],
                ),
              ),
            ),
            _buildBottomBar(questions),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int remainingTime, int questionCount) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          bottom: BorderSide(color: AppColors.lightOutline),
        ),
      ),
      child: Row(
        children: [
          NeutralTimer(
            totalSeconds: remainingTime,
            onTimeUp: _handleTimeUp,
          ),
          const Spacer(),
          Text(
            'Question ${_currentIndex + 1} of $questionCount',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          IconButton(
            icon: Icon(_showPalette ? Icons.grid_on : Icons.grid_off),
            onPressed: () {
              setState(() {
                _showPalette = !_showPalette;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MockTestQuestion question) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (question.isMarkedForReview)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.marigold500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 14,
                        color: AppColors.marigold500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Marked for Review',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.marigold500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                '+${question.marks} marks',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.sage500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            question.questionText,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOptionIndex == index;

            return OptionTile(
              optionText: option,
              optionIndex: index,
              isSelected: isSelected,
              isCorrect: false,
              isIncorrect: false,
              isRevealed: false,
              onTap: () => _handleOptionTap(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionPalette(List<MockTestQuestion> questions) {
    return QuestionPalette(
      questions: questions,
      currentIndex: _currentIndex,
      onQuestionTap: (index) => _handleQuestionTap(index, questions),
    );
  }

  Widget _buildBottomBar(List<MockTestQuestion> questions) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          top: BorderSide(color: AppColors.lightOutline),
        ),
      ),
      child: Row(
        children: [
          // Icons dropped from these two: at 4-across on a phone each slot is
          // ~70px, and icon + gap + label overflowed by 19px on a real device.
          Expanded(
            child: AppSecondaryButton(
              label: 'Prev',
              onPressed: () => _handlePrevious(questions),
              enabled: _currentIndex > 0,
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            child: AppSecondaryButton(
              label: questions[_currentIndex].isMarkedForReview ? 'Marked' : 'Mark',
              onPressed: () => _handleMarkForReview(questions),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            child: AppSecondaryButton(
              label: 'Skip',
              onPressed: () => _handleSkip(questions),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            flex: 2,
            child: _currentIndex < questions.length - 1
                ? AppButton(
                    label: 'Next',
                    onPressed: () => _handleNext(questions),
                  )
                : AppButton(
                    label: _isSubmitting ? 'Submitting...' : 'Submit',
                    onPressed: _isSubmitting ? () {} : () => _handleSubmit(questions),
                  ),
          ),
        ],
      ),
    );
  }
}
