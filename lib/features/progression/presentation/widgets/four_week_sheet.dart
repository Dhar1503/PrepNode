import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/widgets/streak_card.dart';

/// The week strip's tap target: the same activity data over 28 days.
///
/// A sheet rather than a route — it is a detail view of the widget the user
/// just tapped, and dismissing it should put them straight back on the
/// dashboard without touching the navigation stack.
class FourWeekSheet extends StatelessWidget {
  final StreakState streak;

  const FourWeekSheet({super.key, required this.streak});

  static Future<void> show(BuildContext context, StreakState streak) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FourWeekSheet(streak: streak),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 28 days ending today, so the last cell is always today.
    final days = List.generate(28, (i) => today.subtract(Duration(days: 27 - i)));
    final studyDays = days.where(streak.activeDays.contains).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spaceLg,
          AppConstants.spaceMd,
          AppConstants.spaceLg,
          AppConstants.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightOutlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
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
                  // Whole grid lands inside 400ms: the per-cell stagger is
                  // capped so the last square is not still arriving after
                  // the user has started reading.
                  duration: Duration(milliseconds: 220 + (i * 4).clamp(0, 160)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.scale(scale: 0.85 + (0.15 * value), child: child),
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
                _LegendChip(color: ActivityColors.rest, label: 'Rest'),
                _LegendChip(color: ActivityColors.studied, label: 'Studied'),
                _LegendChip(color: ActivityColors.practised, label: 'Practised too'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

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
