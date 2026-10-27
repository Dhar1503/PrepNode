import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/providers/progression_providers.dart';
import 'package:prepnode/features/progression/presentation/widgets/streak_card.dart';

/// Four headline counts, all read from tables that already exist.
///
/// Each number counts up from zero on entry. A static "0" and an animated
/// one that settles on 0 look identical at rest, so nothing is lost for a
/// new user — but for a returning one the movement is what makes the row
/// feel like their record rather than a template.
class ProfileStatsRow extends ConsumerWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 76),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceMd,
          horizontal: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Row(
          children: [
            _Stat(value: stats.daysStudied, label: 'Days\nstudied'),
            _Stat(value: stats.questionsAttempted, label: 'Questions\nattempted'),
            _Stat(value: stats.topicsExplored, label: 'Topics\nexplored'),
            _Stat(value: stats.mockTests, label: 'Mock\ntests'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.round()}',
              style: GoogleFonts.fraunces(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.3,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The same four-week grid the Home strip opens, inlined for the profile.
///
/// Shares [ActivityColors] and the same activity source as the Home strip,
/// so the two can never show different histories.
class ProfileActivityGrid extends ConsumerWidget {
  const ProfileActivityGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      loading: () => const SizedBox(height: 180),
      error: (_, _) => const SizedBox.shrink(),
      data: (streak) => _Grid(streak: streak),
    );
  }
}

class _Grid extends StatelessWidget {
  final StreakState streak;

  const _Grid({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(28, (i) => today.subtract(Duration(days: 27 - i)));
    final studyDays = days.where(streak.activeDays.contains).length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your last four weeks',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeTitleMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '$studyDays study day${studyDays == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.marigold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, i) {
              final date = days[i];
              final isToday = i == days.length - 1;
              final practised = streak.practisedDays.contains(date);
              final active = streak.activeDays.contains(date);
              final fill = practised
                  ? ActivityColors.practised
                  : active
                      ? ActivityColors.studied
                      : ActivityColors.rest;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 220 + (i * 4).clamp(0, 160)),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.85 + (0.15 * value),
                    child: child,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(5),
                    border: isToday
                        ? Border.all(color: ActivityColors.today, width: 2)
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Wrap(
            spacing: AppConstants.spaceMd,
            runSpacing: AppConstants.spaceXs,
            children: const [
              _Legend(color: ActivityColors.rest, label: 'Rest'),
              _Legend(color: ActivityColors.studied, label: 'Studied'),
              _Legend(color: ActivityColors.practised, label: 'Practised too'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }
}
