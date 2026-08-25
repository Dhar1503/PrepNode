import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_summary.dart';
import 'package:prepgraph/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepgraph/features/strategy/presentation/providers/strategy_providers.dart';

const String _defaultExamId = 'tnpsc-group2';

/// My Strategy hero card — the Dashboard's headline widget. One glance at
/// capacity profile, readiness, cutoff gap, and the single most important
/// next topic, all computed live from real local data via
/// StrategyRepository (see strategy_providers.dart). This is the "mentor,
/// not a database" moment the rest of the app builds toward.
class StrategyHeroCard extends ConsumerWidget {
  const StrategyHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(strategySummaryProvider(_defaultExamId));

    return GestureDetector(
      onTap: () => context.push('/strategy'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink900, AppColors.ink900.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(color: AppColors.ink900.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: summaryAsync.when(
          data: (summary) => _buildContent(context, summary),
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: Colors.white))),
          error: (_, _) => _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StrategySummary summary) {
    final gap = summary.scoreGap;
    final isAhead = gap <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.marigold500, size: 18),
            const SizedBox(width: AppConstants.spaceXs),
            Text(
              'My Strategy',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.marigold500,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            // Reservation category deliberately NOT shown here. It is only
            // meaningful inside Cutoff Intelligence, where it is a factual
            // filter over published category-wise cutoff marks. Study
            // strategy is identical for every learner, so surfacing caste
            // alongside it would imply a link that does not exist.
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Text(
          summary.capacityProfile.label,
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.lightOnPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          summary.todaysFocusHeadline,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.lightOnPrimary.withValues(alpha: 0.85),
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildStat(
                'Readiness',
                '${summary.readinessPercentage.toInt()}%',
                AppColors.sage500,
              ),
            ),
            Expanded(
              child: _buildStat(
                // Measured against the exam's official qualifying mark, not
                // the old invented cutoff figures — see ExamScale.
                isAhead ? 'Above Qualifying' : 'Marks To Gain',
                '${gap.abs().toStringAsFixed(0)}',
                isAhead ? AppColors.sage500 : AppColors.marigold500,
              ),
            ),
            Expanded(
              child: _buildStat(
                'Weeks Left',
                summary.weeksUntilExam > 0 ? '${summary.weeksUntilExam}' : '—',
                AppColors.azure500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Row(
          children: [
            Icon(Icons.touch_app, size: 14, color: AppColors.lightOnPrimary.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(
              'Tap for your full strategy',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.lightOnPrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: color),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightOnPrimary.withValues(alpha: 0.65)),
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: AppColors.marigold500, size: 20),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Text(
            'Complete a few PYQs or a mock test to unlock your personalized strategy.',
            style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, color: AppColors.lightOnPrimary.withValues(alpha: 0.85)),
          ),
        ),
      ],
    );
  }
}
