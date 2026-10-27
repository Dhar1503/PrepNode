import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';
import 'package:prepnode/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:prepnode/features/roadmap/presentation/widgets/roadmap_day_card.dart';

/// The 30-day roadmap as a vertical timeline.
///
/// Days are grouped by week with a sticky-ish week header, and connected by
/// a rail so the plan reads as one path rather than a list of cards.
class RoadmapTimelineScreen extends ConsumerStatefulWidget {
  const RoadmapTimelineScreen({super.key});

  @override
  ConsumerState<RoadmapTimelineScreen> createState() =>
      _RoadmapTimelineScreenState();
}

class _RoadmapTimelineScreenState extends ConsumerState<RoadmapTimelineScreen> {
  String? _expandedDayId;
  bool _isAdapting = false;

  @override
  Widget build(BuildContext context) {
    final roadmapAsync = ref.watch(roadmapProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Your Roadmap',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Re-optimize',
            icon: _isAdapting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            onPressed: _isAdapting ? null : _adapt,
          ),
        ],
      ),
      body: roadmapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load roadmap.\n$e')),
        data: (roadmap) {
          if (roadmap.isEmpty) return _buildEmpty();
          return _buildTimeline(roadmap);
        },
      ),
    );
  }

  Future<void> _adapt() async {
    setState(() => _isAdapting = true);
    final result = await ref.read(roadmapControllerProvider).adapt();
    if (!mounted) return;
    setState(() => _isAdapting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.didAdapt ? result.changes.first : 'Your roadmap is already on track.',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Text(
          'No roadmap yet. Generate one from the dashboard.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.graphite700),
        ),
      ),
    );
  }

  Widget _buildTimeline(Roadmap roadmap) {
    // One flat list with week headers injected, rather than nested
    // ListViews — nested scrollables inside a scrollable is the usual way
    // this kind of screen ends up unscrollable.
    final items = <Widget>[];
    var lastWeek = 0;

    items.add(_buildSummary(roadmap));

    for (final day in roadmap.days) {
      if (day.weekNumber != lastWeek) {
        lastWeek = day.weekNumber;
        items.add(_buildWeekHeader(day));
      }
      items.add(RoadmapDayCard(
        day: day,
        isExpanded: _expandedDayId == day.id,
        onToggle: () => setState(() {
          _expandedDayId = _expandedDayId == day.id ? null : day.id;
        }),
        onCompleteTask: (taskId) async {
          final xp = await ref.read(roadmapControllerProvider).completeTask(taskId);
          if (!mounted || xp <= 0) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('+$xp XP'), duration: const Duration(seconds: 2)),
          );
        },
      ));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceXl),
      children: items,
    );
  }

  Widget _buildSummary(Roadmap roadmap) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.ink900,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${roadmap.completedDays} of ${roadmap.days.length} days complete',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeTitleLarge,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: roadmap.overallProgress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppColors.marigold500),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            '${(roadmap.overallProgress * 100).round()}% of all tasks done',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(RoadmapDay day) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          Text(
            'WEEK ${day.weekNumber}',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              day.focusLabel,
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
}
