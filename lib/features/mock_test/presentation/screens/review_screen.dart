import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_button.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepgraph/features/pyq/presentation/providers/pyq_providers.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/option_tile.dart';
import 'package:prepgraph/features/pyq/presentation/widgets/explanation_panel.dart';

/// Review Screen (S6.4)
/// Question-by-question review with explanations
class ReviewScreen extends ConsumerStatefulWidget {
  final MockTestResult result;
  final List<MockTestQuestion> questions;

  const ReviewScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentIndex];
    final isCorrect = currentQuestion.isCorrect;

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review Answers',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          Text(
            '${_currentIndex + 1}/${widget.questions.length}',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildQuestionCard(currentQuestion, isCorrect),
                  const SizedBox(height: AppConstants.spaceMd),
                  ExplanationPanel(
                    explanation: currentQuestion.explanation,
                    relatedTopicId: currentQuestion.topicId,
                    relatedTopicName: 'Related Topic',
                    onRelatedTopicTap: () {
                      if (currentQuestion.topicId != null) {
                        context.push('/learn/topic/${currentQuestion.topicId}');
                      }
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildRelatedPyQButton(currentQuestion),
                  const SizedBox(height: AppConstants.spaceLg),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MockTestQuestion question, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.sage500.withValues(alpha: 0.1)
            : AppColors.graphite700.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isCorrect ? AppColors.sage500 : AppColors.graphite700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.sage500 : AppColors.graphite700,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                isCorrect ? 'Correct' : 'Incorrect',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? AppColors.sage500 : AppColors.graphite700,
                ),
              ),
              const Spacer(),
              Text(
                '+${question.marks} marks',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
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
            final isSelected = question.selectedOptionIndex == index;
            final isCorrectOption = index == question.correctAnswerIndex;

            return OptionTile(
              optionText: option,
              optionIndex: index,
              isSelected: isSelected,
              isCorrect: isCorrectOption,
              isIncorrect: isSelected && !isCorrect,
              isRevealed: true,
              onTap: () {},
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedPyQButton(MockTestQuestion question) {
    if (question.topicId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: AppSecondaryButton(
        label: 'Practice Related PYQs',
        icon: const Icon(Icons.quiz, size: 20),
        onPressed: () => _handlePracticeRelatedPyqs(question),
      ),
    );
  }

  /// Loads real PYQ questions for this question's topic and navigates with
  /// a real session via `extra` — this previously navigated straight to
  /// `/practice/session/<topicId>` with no `extra`, which the practice
  /// session route only ever renders as an empty (no-questions) session.
  Future<void> _handlePracticeRelatedPyqs(MockTestQuestion question) async {
    final topicId = question.topicId;
    if (topicId == null) return;

    final userId = ref.read(authProvider).userId ?? '';
    const examId = 'tnpsc-group2';
    final subjectId = question.subjectId ?? 'subject-general-studies';

    final result = await ref.read(pyqRepositoryProvider).getQuestions(
          examId: examId,
          subjectId: subjectId,
          topicId: topicId,
          userId: userId,
        );

    if (!mounted) return;

    final questions = result.fold((_) => const <PyqQuestion>[], (qs) => qs);
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PYQ questions available for this topic yet.')),
      );
      return;
    }

    final session = PyqSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      examId: examId,
      subjectId: subjectId,
      topicId: topicId,
      topicName: 'Related Practice',
      mode: SessionMode.batch,
      questions: questions,
      currentIndex: 0,
      startedAt: DateTime.now(),
    );

    context.push('/practice/session/${session.id}', extra: session);
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
          Expanded(
            child: AppSecondaryButton(
              label: 'Previous',
              onPressed: _currentIndex > 0
                  ? () {
                      setState(() {
                        _currentIndex--;
                      });
                    }
                  : () {},
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _currentIndex < widget.questions.length - 1
                ? AppButton(
                    label: 'Next',
                    onPressed: () {
                      setState(() {
                        _currentIndex++;
                      });
                    },
                  )
                : AppButton(
                    label: 'Finish Review',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
