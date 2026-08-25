import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/skeleton_loader.dart';
import 'package:prepgraph/core/widgets/error_state.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepgraph/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';
import 'package:prepgraph/features/pyq/presentation/providers/pyq_providers.dart';

/// PYQ Home Screen (S5.1)
/// Practice home with resume card and subject/topic browser
class PyqHomeScreen extends ConsumerStatefulWidget {
  const PyqHomeScreen({super.key});

  @override
  ConsumerState<PyqHomeScreen> createState() => _PyqHomeScreenState();
}

class _PyqHomeScreenState extends ConsumerState<PyqHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  void _loadData() {
    // TODO: Integrate with Cutoff Intelligence - highlight high-frequency cutoff-impact topics
    // TODO: Display cutoff-impact indicator for topics with high historical frequency
    final userId = ref.read(authProvider).userId;
    ref.read(topicSummariesProvider.notifier).loadTopicSummaries(
          examId: 'tnpsc-group2',
          subjectId: 'subject-general-studies',
          userId: userId,
        );
  }

  Future<void> _handleTopicTap(TopicPyqSummary topic) async {
    final userId = ref.read(authProvider).userId ?? '';
    const examId = 'tnpsc-group2';
    const subjectId = 'subject-general-studies';

    // Load this topic's real questions before opening a session — there is
    // no separate "loading" route state, so the practice session screen
    // always needs its full question list up front (passed via `extra`).
    await ref.read(questionsProvider.notifier).loadQuestions(
          examId: examId,
          subjectId: subjectId,
          topicId: topic.topicId,
          userId: userId,
        );
    if (!mounted) return;

    final questions = ref.read(questionsProvider).questions;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions available for this topic yet.')),
      );
      return;
    }

    _openSession(
      userId: userId,
      examId: examId,
      questions: questions,
      mode: SessionMode.batch,
      topicName: topic.topicName,
    );
  }

  void _handleAskAI() {
    // M12 Integration: Navigate to AI Assistant
    context.push('/ai-assistant/chat?contextModule=pyq');
  }

  Future<void> _handleRetryIncorrect() async {
    final userId = ref.read(authProvider).userId ?? '';
    const examId = 'tnpsc-group2';

    await ref.read(incorrectQuestionsProvider.notifier).load(userId: userId, examId: examId);
    if (!mounted) return;

    final questions = ref.read(incorrectQuestionsProvider).questions;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No incorrect questions to retry yet.')),
      );
      return;
    }

    _openSession(userId: userId, examId: examId, questions: questions, mode: SessionMode.incorrectRetry, topicName: 'Retry Incorrect');
  }

  Future<void> _handleBookmarked() async {
    final userId = ref.read(authProvider).userId ?? '';
    const examId = 'tnpsc-group2';

    await ref.read(bookmarkedQuestionsProvider.notifier).load(userId: userId, examId: examId);
    if (!mounted) return;

    final questions = ref.read(bookmarkedQuestionsProvider).questions;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bookmarked questions yet.')),
      );
      return;
    }

    _openSession(userId: userId, examId: examId, questions: questions, mode: SessionMode.bookmarked, topicName: 'Bookmarked');
  }

  void _openSession({
    required String userId,
    required String examId,
    required List<PyqQuestion> questions,
    required SessionMode mode,
    required String topicName,
  }) {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = PyqSession(
      id: sessionId,
      userId: userId,
      examId: examId,
      subjectId: questions.first.subjectId,
      topicId: questions.first.topicId,
      topicName: topicName,
      mode: mode,
      questions: questions,
      currentIndex: 0,
      startedAt: DateTime.now(),
    );
    context.push('/practice/session/$sessionId', extra: session);
  }

  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper50,
      builder: (context) => const _PyqSearchSheet(examId: 'tnpsc-group2'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topicSummariesState = ref.watch(topicSummariesProvider);
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'PYQ Practice',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openSearchSheet,
          ),
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: _handleAskAI,
            tooltip: 'Ask AI',
          ),
        ],
      ),
      body: topicSummariesState.isLoading
          ? _buildLoadingSkeleton()
          : _buildContent(topicSummariesState),
    );
  }

  Widget _buildContent(TopicSummariesState state) {
    if (state.errorMessage != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildQuickActions(),
        const SizedBox(height: AppConstants.spaceLg),
        Expanded(
          child: _buildTopicList(state.summaries),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.refresh,
              label: 'Retry Incorrect',
              color: AppColors.marigold500,
              onTap: _handleRetryIncorrect,
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.bookmark,
              label: 'Bookmarked',
              color: AppColors.sage500,
              onTap: _handleBookmarked,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        splashColor: color.withValues(alpha: 0.15),
        highlightColor: color.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: color),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicList(List<TopicPyqSummary> summaries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        return _buildTopicTile(summaries[index]);
      },
    );
  }

  Widget _buildTopicTile(TopicPyqSummary topic) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTopicTap(topic),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        splashColor: AppColors.ink900.withValues(alpha: 0.05),
        highlightColor: AppColors.ink900.withValues(alpha: 0.02),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.paper50,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: AppColors.lightOutline),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink900.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.topicName,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppConstants.spaceSm,
                      runSpacing: 4,
                      children: [
                        _buildStatBadge('Total', '${topic.totalQuestions}'),
                        _buildStatBadge('Solved', '${topic.solvedQuestions}'),
                        _buildStatBadge('Accuracy', '${(topic.averageAccuracy * 100).toInt()}%'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildFrequencyIndicator(topic.frequencyCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          color: AppColors.graphite700,
        ),
      ),
    );
  }

  Widget _buildFrequencyIndicator(int frequency) {
    return Column(
      children: [
        Text(
          'Appeared',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: List.generate(7, (index) {
            final isActive = index < frequency;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.marigold500 : AppColors.lightOutlineVariant,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      itemCount: 4,
      itemBuilder: (context, index) {
        return SkeletonListTile(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return ErrorStates.network(
      onRetry: _loadData,
      contextMessage: "Couldn't load topics",
    );
  }
}

/// Minimal search/filter sheet reusing [questionsProvider] — supports
/// keyword, difficulty and year, the three filters that don't require a
/// dedicated subject/topic picker (which doesn't otherwise exist yet).
class _PyqSearchSheet extends ConsumerStatefulWidget {
  final String examId;

  const _PyqSearchSheet({required this.examId});

  @override
  ConsumerState<_PyqSearchSheet> createState() => _PyqSearchSheetState();
}

class _PyqSearchSheetState extends ConsumerState<_PyqSearchSheet> {
  final _keywordController = TextEditingController();
  final _yearController = TextEditingController();
  final Set<DifficultyLevel> _selectedDifficulties = {};

  @override
  void dispose() {
    _keywordController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _runSearch() {
    final userId = ref.read(authProvider).userId;
    final year = int.tryParse(_yearController.text.trim());

    ref.read(questionsProvider.notifier).searchQuestions(
          examId: widget.examId,
          query: _keywordController.text.trim(),
          userId: userId,
          filter: PyqFilter(
            years: year != null ? [year] : null,
            difficulties: _selectedDifficulties.isEmpty ? null : _selectedDifficulties.toList(),
          ),
        );
  }

  void _openQuestion(PyqQuestion question) {
    final userId = ref.read(authProvider).userId ?? '';
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = PyqSession(
      id: sessionId,
      userId: userId,
      examId: question.examId,
      subjectId: question.subjectId,
      topicId: question.topicId,
      topicName: 'Search Result',
      mode: SessionMode.single,
      questions: [question],
      currentIndex: 0,
      startedAt: DateTime.now(),
    );
    Navigator.of(context).pop();
    context.push('/practice/session/$sessionId', extra: session);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spaceLg,
        right: AppConstants.spaceLg,
        top: AppConstants.spaceLg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search PYQs',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              hintText: 'Keyword',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Wrap(
            spacing: AppConstants.spaceSm,
            children: DifficultyLevel.values.map((level) {
              final selected = _selectedDifficulties.contains(level);
              return ChoiceChip(
                label: Text(level.name),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedDifficulties.add(level);
                    } else {
                      _selectedDifficulties.remove(level);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Year (optional)'),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _runSearch,
              child: const Text('Search'),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  return ListTile(
                    title: Text(
                      question.questionText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${question.difficulty.name} · ${question.year}'),
                    onTap: () => _openQuestion(question),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
