import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_button.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepgraph/features/pyq/presentation/providers/pyq_providers.dart';
import 'package:prepgraph/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepgraph/features/strategy/presentation/providers/strategy_providers.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/ai_hint_widget.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/confidence_rating_widget.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/explanation_panel.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/practice_progress_bar.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/question_card.dart';

/// Practice Session Screen (S5.5)
/// Full-screen practice session with timer, questions, and explanations
class PracticeSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final List<PyqQuestion> questions;
  final String topicName;

  const PracticeSessionScreen({
    super.key,
    required this.sessionId,
    required this.questions,
    required this.topicName,
  });

  @override
  ConsumerState<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isRevealed = false;
  bool _showExplanation = false;
  bool _showHint = false;
  String? _hintText;
  bool _isLoadingHint = false;
  ConfidenceRating? _confidenceRating;
  Timer? _timer;
  int _secondsElapsed = 0;
  int _totalCorrect = 0;
  int _totalAnswered = 0;
  final List<QuestionAttempt> _attempts = [];
  final List<String> _flaggedForRevision = [];
  late final Set<String> _bookmarkedIds;
  final DateTime _sessionStartedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bookmarkedIds = widget.questions.where((q) => q.isBookmarked).map((q) => q.id).toSet();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _handleOptionTap(int index) {
    if (_isRevealed) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _handleSubmit() {
    if (_selectedOptionIndex == null) return;

    final currentQuestion = widget.questions[_currentIndex];
    final isCorrect = _selectedOptionIndex == currentQuestion.correctAnswerIndex;

    setState(() {
      _isRevealed = true;
      _showExplanation = true;
      if (isCorrect) {
        _totalCorrect++;
      }
      _totalAnswered++;

      _attempts.add(QuestionAttempt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: currentQuestion.id,
        selectedOptionIndex: _selectedOptionIndex!,
        correctOptionIndex: currentQuestion.correctAnswerIndex,
        isCorrect: isCorrect,
        timeTakenSeconds: _secondsElapsed,
        confidenceRating: _confidenceRating,
        attemptedAt: DateTime.now(),
      ));

      if (!isCorrect) {
        _flaggedForRevision.add(currentQuestion.topicId);
      }
    });

    _timer?.cancel();

    final userId = ref.read(authProvider).userId ?? '';
    unawaited(ref.read(pyqRepositoryProvider).submitAttempt(
          userId: userId,
          questionId: currentQuestion.id,
          selectedOptionIndex: _selectedOptionIndex!,
          correctOptionIndex: currentQuestion.correctAnswerIndex,
          isCorrect: isCorrect,
          timeTakenSeconds: _secondsElapsed,
          confidenceRating: _confidenceRating,
        ));
  }

  void _handleNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isRevealed = false;
        _showExplanation = false;
        _showHint = false;
        _hintText = null;
        _confidenceRating = null;
        _secondsElapsed = 0;
      });
      _startTimer();
    } else {
      _handleFinish();
    }
  }

  void _handleFinish() {
    final userId = ref.read(authProvider).userId ?? '';
    final firstQuestion = widget.questions.isNotEmpty ? widget.questions.first : null;

    final completedSession = PyqSession(
      id: widget.sessionId,
      userId: userId,
      examId: firstQuestion?.examId ?? '',
      subjectId: firstQuestion?.subjectId ?? '',
      topicId: firstQuestion?.topicId ?? '',
      topicName: widget.topicName,
      mode: SessionMode.batch,
      questions: widget.questions,
      currentIndex: _currentIndex,
      startedAt: _sessionStartedAt,
      completedAt: DateTime.now(),
      totalCorrect: _totalCorrect,
      totalAnswered: _totalAnswered,
      totalDurationSeconds: _attempts.fold(0, (sum, a) => sum + a.timeTakenSeconds),
      isCompleted: true,
      attempts: _attempts,
      flaggedForRevision: _flaggedForRevision,
    );

    // A finished session just wrote real attempt/mastery data — refresh the
    // screens that read the same underlying data instead of leaving them
    // showing stale numbers until the user happens to leave and come back.
    // Same pattern PlannerScreen._handleCompleteTask already uses.
    ref.invalidate(learnerProgressProvider);
    ref.invalidate(masteryAnalyticsProvider);
    ref.invalidate(weakAreasProvider);
    ref.invalidate(pyqPerformanceProvider);
    ref.invalidate(studyCapacityProvider);
    ref.invalidate(nextBestTopicsProvider);
    ref.invalidate(roadmapProvider);
    ref.invalidate(strategySummaryProvider);

    context.push('/practice/summary/${widget.sessionId}', extra: completedSession);
  }

  void _handleExit() {
    if (_totalAnswered > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit Session?'),
          content: const Text('Your progress will be lost. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleGetHint() async {
    final currentQuestion = widget.questions[_currentIndex];
    setState(() {
      _showHint = true;
      _isLoadingHint = true;
    });

    final result = await ref.read(pyqRepositoryProvider).getAiHint(questionId: currentQuestion.id);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _hintText = failure.message;
        _isLoadingHint = false;
      }),
      (hint) => setState(() {
        _hintText = hint;
        _isLoadingHint = false;
      }),
    );
  }

  Future<void> _handleBookmark() async {
    final userId = ref.read(authProvider).userId ?? '';
    final currentQuestion = widget.questions[_currentIndex];

    final result = await ref.read(pyqRepositoryProvider).toggleBookmark(
          userId: userId,
          questionId: currentQuestion.id,
        );

    if (!mounted) return;

    result.fold(
      (failure) {},
      (updated) => setState(() {
        if (updated.isBookmarked) {
          _bookmarkedIds.add(currentQuestion.id);
        } else {
          _bookmarkedIds.remove(currentQuestion.id);
        }
      }),
    );
  }

  void _handleRelatedTopicTap() {
    // Navigate to related topic in Knowledge Graph
    final currentQuestion = widget.questions[_currentIndex];
    if (currentQuestion.relatedTopicId != null) {
      context.push('/learn/topic/${currentQuestion.relatedTopicId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.paper50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Text(
                'No questions available for this session.',
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

    final currentQuestion = widget.questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: Column(
          children: [
            PracticeProgressBar(
              currentIndex: _currentIndex,
              totalQuestions: widget.questions.length,
              correctCount: _totalCorrect,
              onExit: _handleExit,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_showHint)
                      AiHintWidget(
                        hint: _isLoadingHint ? 'Loading hint...' : (_hintText ?? ''),
                        onDismiss: () {
                          setState(() {
                            _showHint = false;
                          });
                        },
                      ),
                    QuestionCard(
                      question: currentQuestion,
                      selectedOptionIndex: _selectedOptionIndex,
                      isRevealed: _isRevealed,
                      onOptionTap: _handleOptionTap,
                      showBookmark: true,
                      isBookmarked: _bookmarkedIds.contains(currentQuestion.id),
                      onBookmarkTap: _handleBookmark,
                    ),
                    if (_showExplanation)
                      ExplanationPanel(
                        explanation: currentQuestion.explanation,
                        relatedTopicId: currentQuestion.relatedTopicId,
                        relatedTopicName: currentQuestion.relatedTopicName,
                        onRelatedTopicTap: _handleRelatedTopicTap,
                        isExpanded: _showExplanation,
                      ),
                    if (_isRevealed && !_showExplanation)
                      _buildConfidenceRating(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceRating() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: ConfidenceRatingWidget(
        selectedRating: _confidenceRating,
        onRatingSelected: (rating) {
          setState(() {
            _confidenceRating = rating;
          });
        },
      ),
    );
  }

  Widget _buildBottomBar() {
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
          if (!_isRevealed) ...[
            Expanded(
              child: AppSecondaryButton(
                label: 'Get Hint',
                onPressed: _handleGetHint,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: AppButton(
                label: 'Submit',
                onPressed: _handleSubmit,
                enabled: _selectedOptionIndex != null,
              ),
            ),
          ] else ...[
            Expanded(
              child: AppButton(
                label: _currentIndex < widget.questions.length - 1 ? 'Next' : 'Finish',
                onPressed: _handleNext,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
