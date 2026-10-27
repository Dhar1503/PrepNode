import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/providers/progression_providers.dart';

/// Daily challenge, weekly mission and a study tip.
///
/// The greeting and challenge text are built from the user's own numbers
/// (streak length, XP today, objective progress) rather than generic
/// encouragement — a line that could have been shown to anybody reads as
/// filler, and aspirants notice.
class MotivationCard extends ConsumerWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(dailyChallengeProvider);
    final mission = ref.watch(weeklyMissionProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY CHALLENGE',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          challenge.when(
            loading: () => const SizedBox(height: 40),
            error: (_, _) => const SizedBox.shrink(),
            data: (obj) => obj == null
                ? const SizedBox.shrink()
                : _ObjectiveRow(objective: obj),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'WEEKLY MISSION',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          mission.when(
            loading: () => const SizedBox(height: 40),
            error: (_, _) => const SizedBox.shrink(),
            data: (obj) => obj == null
                ? const SizedBox.shrink()
                : _ObjectiveRow(objective: obj),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          const Divider(height: 1, color: AppColors.lightOutlineVariant),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline,
                  size: 18, color: AppColors.marigold500),
              const SizedBox(width: AppConstants.spaceXs),
              Expanded(
                child: Text(
                  _tipOfTheDay(),
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Rotates by day-of-year: stable within a day, different tomorrow, and
  /// no randomness to make the UI untestable.
  static String _tipOfTheDay() {
    final now = DateTime.now();
    final index = now.difference(DateTime(now.year)).inDays % _tips.length;
    return _tips[index];
  }

  static const _tips = [
    'Answer PYQs on a topic the same day you study it — recall while it is '
        'fresh is what moves it into long-term memory.',
    'TNPSC repeats. A topic that appeared three times in past papers is worth '
        'more of your evening than one that appeared once.',
    'Revise yesterday\'s topic for ten minutes before starting today\'s. '
        'Spacing beats re-reading.',
    'Take mocks at the same time of day as your real exam. Pacing is a habit, '
        'not knowledge.',
    'A wrong answer you understood is worth more than a right answer you '
        'guessed. Review both.',
    'Tamil and English sections are the cheapest marks on the paper — do not '
        'leave them to the last week.',
    'If a subject keeps scoring under 50%, the problem is usually coverage, '
        'not practice. Go back to the source material.',
  ];
}

class _ObjectiveRow extends StatelessWidget {
  final Objective objective;

  const _ObjectiveRow({required this.objective});

  @override
  Widget build(BuildContext context) {
    final done = objective.isComplete;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                objective.title,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                  decoration:
                      done ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: objective.ratio),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: AppColors.lightOutlineVariant,
                    valueColor: AlwaysStoppedAnimation(
                      done ? const Color(0xFF3F7D58) : AppColors.marigold500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          '${objective.progress}/${objective.target}',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            fontWeight: FontWeight.w700,
            color: done ? const Color(0xFF3F7D58) : AppColors.graphite700,
          ),
        ),
      ],
    );
  }
}

/// Builds the dashboard greeting from real state. Exposed as a function so
/// the dashboard app bar can use it without pulling in the whole card.
String buildMotivationalGreeting({
  required StreakState streak,
  required XpState xp,
  int? remainingTasks,
}) {
  if (streak.current >= 3) {
    return 'Day ${streak.current}. You are building real consistency.';
  }
  if (remainingTasks != null && remainingTasks > 0) {
    return 'Only $remainingTasks task${remainingTasks == 1 ? '' : 's'} left today.';
  }
  if (xp.todayXp > 0) {
    return 'You have earned ${xp.todayXp} XP today. Keep going.';
  }
  if (streak.atRisk) {
    return 'Your ${streak.current}-day streak is still alive — one task keeps it.';
  }
  return 'A single task today is enough to start a streak.';
}
