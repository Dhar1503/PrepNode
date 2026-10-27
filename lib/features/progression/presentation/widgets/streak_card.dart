import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/providers/progression_providers.dart';
import 'package:prepnode/features/progression/presentation/widgets/four_week_sheet.dart';

/// Shared palette for every activity square in the app, so the week strip
/// and the four-week grid can never drift apart.
class ActivityColors {
  ActivityColors._();

  /// A day with no recorded activity. Deliberately a warm neutral, not a
  /// red or a grey-out: a missed day is rest, not failure.
  static const rest = Color(0xFFEAE7DD);

  /// Studied — planner, roadmap, resources, revision.
  static const studied = Color(0xFFE5A73B);

  /// Studied and practised questions (PYQ or mock).
  static const practised = Color(0xFF5C8A72);

  /// Outline on today's cell.
  static const today = Color(0xFF1B2A4A);
}

/// Home week strip.
///
/// Leads with a sentence rather than a number. "12 day streak" makes the
/// reader do the work — twelve days of what, ending when? "You studied 4 of
/// the last 7 days" is the same data already interpreted, and it cannot
/// read as a failure the way a streak that resets to zero does.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      loading: () => const _StripSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (streak) => _WeekStrip(streak: streak),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final StreakState streak;

  const _WeekStrip({required this.streak});

  @override
  Widget build(BuildContext context) {
    final studied = streak.studyDaysInLast(7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          onTap: () => FourWeekSheet.show(context, streak),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.lightOutlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You studied $studied of the last 7 days',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _runSentence(streak.current),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.graphite700,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                _DayBars(streak: streak),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Describes the run in words. Never mentions a broken streak, and never
  /// says "0" — with nothing running the line is an invitation, not a
  /// report of failure.
  static String _runSentence(int current) {
    if (current <= 0) return 'Ready when you are';
    return '${_spell(current)} ${current == 1 ? 'day' : 'days'} in a row right now';
  }

  static String _spell(int n) {
    const words = [
      'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
      'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve',
    ];
    // Past twelve, digits read faster than words.
    return n < words.length ? words[n] : '$n';
  }
}

/// Seven bars, oldest on the left, today on the right.
class _DayBars extends StatelessWidget {
  final StreakState streak;

  const _DayBars({required this.streak});

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      children: List.generate(7, (i) {
        final date = today.subtract(Duration(days: 6 - i));
        final isToday = i == 6;
        final practised = streak.practisedDays.contains(date);
        final active = streak.activeDays.contains(date);
        final fill = practised
            ? ActivityColors.practised
            : active
                ? ActivityColors.studied
                : ActivityColors.rest;

        // date.weekday is 1..7 from Monday, matching the letter row.
        final letter = _letters[date.weekday - 1];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bars grow from the baseline on entry — one 320ms tween,
                // staggered slightly so the week reads left to right.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 260 + (i * 18)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 34 * value,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: ActivityColors.today, width: 2)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  letter,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.graphite700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      height: 116,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
    );
  }
}
