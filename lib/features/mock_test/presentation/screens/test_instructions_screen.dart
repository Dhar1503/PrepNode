import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepnode/features/mock_test/presentation/providers/mock_test_providers.dart';

/// Test Instructions Screen (S6.2)
/// Displays test rules and instructions before starting
class TestInstructionsScreen extends ConsumerWidget {
  final MockTest test;

  const TestInstructionsScreen({
    super.key,
    required this.test,
  });

  Future<void> _handleStartTest(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    // Builds a real attempt (with real questions) through the same
    // repository/provider chain the rest of the test-taking flow already
    // uses — see MockTestRepositoryImpl.startTest's local fallback.
    await ref.read(testAttemptProvider.notifier).startTest(userId: userId, testId: test.id);

    if (!context.mounted) return;

    final attemptState = ref.read(testAttemptProvider);
    final attempt = attemptState.attempt;
    if (attempt != null) {
      context.push('/mock-tests/test/${attempt.id}', extra: attempt);
    } else if (attemptState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(attemptState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Test Instructions',
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
            _buildTestInfo(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildInstructions(),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSections(),
            const SizedBox(height: AppConstants.spaceXl),
            _buildStartButton(context, ref),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildTestInfo() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            test.title,
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.lightOnPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            test.description ?? '',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            children: [
              Flexible(child: _buildInfoItem(Icons.access_time, '${test.durationMinutes} min')),
              const SizedBox(width: AppConstants.spaceMd),
              Flexible(child: _buildInfoItem(Icons.quiz, '${test.totalQuestions} questions')),
              const SizedBox(width: AppConstants.spaceMd),
              Flexible(child: _buildInfoItem(Icons.star, '${test.totalMarks} marks')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildInstruction('Read each question carefully before answering'),
          _buildInstruction('You can navigate between questions freely'),
          _buildInstruction('Mark questions for review if unsure'),
          _buildInstruction('Timer will auto-submit when time expires'),
          _buildInstruction('No negative marking for unanswered questions'),
          // The app is offline-first — the whole test runs from the local
          // database. Telling candidates they need a connection was both
          // untrue and alarming right before a timed test.
          _buildInstruction('Works fully offline — no connection required'),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSections() {
    if (test.sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Sections',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...test.sections.map((section) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section.name,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.graphite700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '${section.questionCount} Q • ${section.marks} Marks',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(testAttemptProvider).isLoading;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: AppButton(
        label: 'Start Test',
        isLoading: isLoading,
        onPressed: () => _handleStartTest(context, ref),
      ),
    );
  }
}
