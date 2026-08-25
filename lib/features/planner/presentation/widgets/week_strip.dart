import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Week Strip Widget
/// 7-column calendar strip for week navigation
class WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateTap;
  final DateTime? weekStart;

  const WeekStrip({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
    this.weekStart,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = weekStart ?? _getStartOfWeek(selectedDate);
    final days = <DateTime>[];

    for (int i = 0; i < 7; i++) {
      days.add(startOfWeek.add(Duration(days: i)));
    }

    // minHeight, not a fixed height: the two labels are ~56px tall once the
    // reader's system font scale is applied (1.3 on a phone with larger text
    // is enough), which overflowed the 48px left inside a hard 80px box.
    // A minimum keeps the strip its designed size at normal scale and lets
    // it grow instead of clipping at larger ones.
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: days.map((date) {
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          final isPast = date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

          return Expanded(
            child: GestureDetector(
              onTap: isPast ? null : () => onDateTap(date),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.ink900
                      : isToday
                          ? AppColors.marigold500.withValues(alpha: 0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Size to the labels rather than to the incoming
                  // constraints, so the Row above can grow with them.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayName(date),
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.lightOnPrimary
                            : isToday
                                ? AppColors.marigold500
                                : isPast
                                    ? AppColors.graphite700.withValues(alpha: 0.5)
                                    : AppColors.graphite700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyLarge,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.lightOnPrimary
                            : isToday
                                ? AppColors.marigold500
                                : isPast
                                    ? AppColors.graphite700.withValues(alpha: 0.5)
                                    : AppColors.ink900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    final day = date.weekday;
    final start = date.subtract(Duration(days: day - 1));
    return DateTime(start.year, start.month, start.day);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
