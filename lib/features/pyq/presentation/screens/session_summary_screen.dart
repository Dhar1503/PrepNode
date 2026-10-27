import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepnode/features/resources/presentation/widgets/resource_card.dart';

/// Session Summary Screen (S5.6)
/// Displays summary after completing a practice session
class SessionSummaryScreen extends ConsumerWidget {
  final PyqSession session;

  const SessionSummaryScreen({
    super.key,
    required this.session,
  });

  void _handleReviewIncorrect(BuildContext context) {
    final incorrectQuestionIds = session.attempts
        .where((a) => !a.isCorrect)
        .map((a) => a.questionId)
        .toSet();
    final incorrectQuestions =
        session.questions.where((q) => incorrectQuestionIds.contains(q.id)).toList();

    if (incorrectQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No incorrect answers to review.')),
      );
      return;
    }

    final reviewSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final reviewSession = session.copyWith(
      id: reviewSessionId,
      mode: SessionMode.incorrectRetry,
      questions: incorrectQuestions,
      currentIndex: 0,
      isCompleted: false,
      totalCorrect: 0,
      totalAnswered: 0,
      attempts: const [],
    );

    context.push('/practice/session/$reviewSessionId', extra: reviewSession);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracy = session.accuracy;
    final duration = session.totalDurationSeconds / 60;

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
          'Session Summary',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            _buildScoreCard(accuracy),
            const SizedBox(height: AppConstants.spaceLg),
            _buildStatsGrid(duration),
            const SizedBox(height: AppConstants.spaceLg),
            _buildWeakTopics(context),
            const SizedBox(height: AppConstants.spaceLg),
            // M9 Integration: Suggested resources for weak areas
            _buildSuggestedResources(context),
            const SizedBox(height: AppConstants.spaceLg),
            _buildActions(context),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(double accuracy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '${(accuracy * 100).toInt()}%',
            style: GoogleFonts.fraunces(
              fontSize: 64,
              fontWeight: FontWeight.w500,
              color: AppColors.lightOnPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '${session.totalCorrect} of ${session.totalAnswered} correct',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(double duration) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              label: 'Time',
              value: '${duration.toStringAsFixed(1)} min',
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _buildStatCard(
              icon: Icons.quiz,
              label: 'Questions',
              value: '${session.totalAnswered}',
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: _buildStatCard(
              icon: Icons.speed,
              label: 'Avg/Question',
              value: '${(duration / session.totalAnswered).toStringAsFixed(1)} min',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      // spaceSm, not spaceMd: three cards across a phone leave ~120px each,
      // and 48px of inset forced "Questions" and "Avg/Question" to wrap
      // mid-word ("Quest / ions").
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.ink900, size: 24),
          const SizedBox(height: AppConstants.spaceSm),
          // Both lines scale down rather than wrapping: these are short
          // stat labels where a broken word reads as a rendering fault.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyLarge,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopics(BuildContext context) {
    if (session.flaggedForRevision.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.marigold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.marigold500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppColors.marigold500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Flagged for Revision',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '${session.flaggedForRevision.length} topics need review based on your performance.',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'Review in Study Planner',
            onPressed: () {
              // Opens the planner so the user can add revision tasks for
              // the flagged topics — doesn't auto-create them itself, since
              // flaggedForRevision only carries topic ids, not the topic
              // names/subjects the add-task form needs.
              context.push('/planner');
            },
          ),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'Ask AI About Weak Areas',
            onPressed: () {
              // M12 Integration: Navigate to AI Assistant with weak topics context
              final weakTopicsText = session.flaggedForRevision.join(', ');
              final question = 'I scored ${(session.accuracy * 100).toInt()}% in my practice session. My weak areas are: $weakTopicsText. Can you explain these topics and suggest how to improve?';
              context.push(
                '/ai-assistant/explain?moduleId=pyq&initialQuestion=${Uri.encodeComponent(question)}',
              );
            },
            icon: const Icon(Icons.psychology, size: 20),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          AppSecondaryButton(
            label: 'View Detailed Analytics',
            onPressed: () {
              // M8 Integration: Navigate to Insights for detailed analysis
              context.go('/insights');
            },
            icon: const Icon(Icons.analytics, size: 20),
          ),
        ],
      ),
    );
  }

  // M9 Integration: Suggested resources for weak areas
  Widget _buildSuggestedResources(BuildContext context) {
    if (session.flaggedForRevision.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.sage500,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  'Suggested Resources',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/resources/recommended'),
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.sage500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Based on your weak performance, we recommend these resources:',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        // Show recommended resources
        Consumer(
          builder: (context, ref, _) {
            final recommendedAsync = ref.watch(recommendedResourcesProvider);
            
            return recommendedAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  children: recommendations.take(2).map((rec) {
                    return ResourceCard(
                      resource: rec.resource,
                      onTap: () => context.push('/resources/${rec.resource.id}'),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        children: [
          AppButton(
            label: 'Review Incorrect Answers',
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => _handleReviewIncorrect(context),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppSecondaryButton(
            label: 'Back to Practice Home',
            onPressed: () {
              context.go('/practice');
            },
          ),
        ],
      ),
    );
  }
}
