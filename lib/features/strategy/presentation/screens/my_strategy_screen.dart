import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/strategy/domain/entities/roadmap.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_recommendation.dart';
import 'package:prepgraph/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepgraph/features/strategy/presentation/providers/strategy_providers.dart';

const String _defaultExamId = 'tnpsc-group2';

/// My Strategy Screen
///
/// The Strategy Engine's home: study capacity classification, the ranked
/// "Next Best Topics" list, and a roadmap — all computed live from real
/// local data via StrategyRepository. Nothing here is templated copy.
class MyStrategyScreen extends ConsumerWidget {
  const MyStrategyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Strategy',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            _buildCapacitySection(ref),
            const SizedBox(height: AppConstants.spaceLg),
            _buildNextBestTopicsSection(context, ref),
            const SizedBox(height: AppConstants.spaceLg),
            _buildRoadmapSection(context, ref),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection(WidgetRef ref) {
    final capacityAsync = ref.watch(studyCapacityProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: capacityAsync.when(
        data: (capacity) => _buildCapacityCard(capacity),
        loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
        error: (_, _) => _buildSectionError('Could not compute your study capacity right now.'),
      ),
    );
  }

  Widget _buildCapacityCard(StudyCapacity capacity) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(color: AppColors.ink900.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title on its own line: at phone width the label and the score
          // competed for space, ellipsizing "Building Momentum" into
          // "Building Mom..." with a bare, unexplained number beside it.
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.marigold500, size: 22),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  capacity.profile.label,
                  style: GoogleFonts.fraunces(
                    fontSize: AppConstants.fontSizeHeadlineSmall,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              Text(
                '${capacity.capacityScore.toInt()}',
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.marigold500,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '/ 100 preparation score',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.lightOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            capacity.summary,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.lightOnPrimary.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          if (capacity.profile != CapacityProfile.buildingMomentum) ...[
            const SizedBox(height: AppConstants.spaceMd),
            ...capacity.factors.entries.take(4).map((e) => _buildFactorBar(e.key, e.value)),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.lightOnPrimary.withValues(alpha: 0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.lightOnPrimary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.marigold500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBestTopicsSection(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(nextBestTopicsProvider(_defaultExamId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 20, color: AppColors.marigold500),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Your Next Best Topics',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeHeadlineSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Not "study everything" — exactly what to study next, ranked by real PYQ frequency vs. your mastery.',
            style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          topicsAsync.when(
            data: (topics) {
              if (topics.isEmpty) {
                return _buildSectionError('Not enough PYQ/mastery data yet to rank topics — practice a few PYQs first.');
              }
              return Column(children: topics.map((t) => _buildTopicCard(context, t)).toList());
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _buildSectionError('Could not load recommendations right now.'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, StrategyRecommendation rec) {
    final impactColor = rec.difficulty == 'Quick Win'
        ? AppColors.sage500
        : rec.difficulty == 'Medium'
            ? AppColors.marigold500
            : AppColors.rose500;

    final durationText = (rec.estimatedStudyMinutes / 60) >= 1
        ? '${(rec.estimatedStudyMinutes / 60).toStringAsFixed(1)} hr'
        : '${rec.estimatedStudyMinutes} min';
    final freqPct = (rec.pyqFrequencyShare * 100).toStringAsFixed(0);
    final masteryPct = (rec.masteryPercentage * 100).toStringAsFixed(0);
    final impactText = rec.expectedScoreImpact >= 0.5
        ? '~${rec.expectedScoreImpact.toStringAsFixed(1)} marks'
        : '<1 mark';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.ink900, shape: BoxShape.circle),
                child: Text(
                  '${rec.rank}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.lightOnPrimary),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  rec.topicName,
                  style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, fontWeight: FontWeight.w600, color: AppColors.ink900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: impactColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppConstants.radiusXs)),
                child: Text(
                  rec.difficulty,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: impactColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              'Study for $durationText — here\'s why:',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reasonBullet(Icons.bar_chart, 'Appears in ~$freqPct% of this subject\'s PYQ volume'),
                _reasonBullet(Icons.gps_fixed, 'You\'re currently only $masteryPct% mastered here'),
                _reasonBullet(Icons.trending_up, 'Closing this gap raises your expected score by $impactText',
                    color: AppColors.sage500),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/learn/topic/${rec.topicId}'),
                child: Text(
                  'Practice Now',
                  style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, fontWeight: FontWeight.w600, color: AppColors.sage500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reasonBullet(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: color ?? AppColors.graphite700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection(BuildContext context, WidgetRef ref) {
    final roadmapLength = ref.watch(roadmapLengthProvider);
    final roadmapAsync = ref.watch(roadmapProvider(_defaultExamId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 20, color: AppColors.azure500),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Roadmap',
                style: GoogleFonts.inter(fontSize: AppConstants.fontSizeHeadlineSmall, fontWeight: FontWeight.w600, color: AppColors.ink900),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            children: [7, 30, 90].map((days) {
              final isSelected = roadmapLength == days;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spaceSm),
                child: ChoiceChip(
                  label: Text(days == 7 ? '7-Day Crash' : days == 30 ? '30-Day' : '90-Day'),
                  selected: isSelected,
                  onSelected: (_) => ref.read(roadmapLengthProvider.notifier).state = days,
                  selectedColor: AppColors.azure500.withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.azure500 : AppColors.graphite700,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: isSelected ? AppColors.azure500 : AppColors.outlineVariant),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: roadmapAsync.when(
            data: (roadmap) {
              if (roadmap.days.isEmpty) {
                return _buildSectionError('Not enough data yet to build a roadmap.');
              }
              final upcoming = roadmap.days.take(7).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roadmap.weeksUntilExam > 0
                        ? '${roadmap.weeksUntilExam} weeks until your target date — showing the first week below.'
                        : 'Set a target date in Profile Setup for an exam-countdown-aware roadmap.',
                    style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  ...upcoming.map(_buildRoadmapDayTile),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _buildSectionError('Could not build a roadmap right now.'),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapDayTile(RoadmapDay day) {
    if (day.items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Day ${day.dayNumber}',
                style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, fontWeight: FontWeight.w600, color: AppColors.ink900),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${day.totalMinutes} min',
                style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...day.items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(
                      item.activityType == RoadmapActivityType.revision ? Icons.refresh : Icons.menu_book,
                      size: 14,
                      color: AppColors.graphite700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.topicName} (${item.durationMinutes} min)',
                        style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionError(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.graphite700),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: AppColors.graphite700),
            ),
          ),
        ],
      ),
    );
  }
}
