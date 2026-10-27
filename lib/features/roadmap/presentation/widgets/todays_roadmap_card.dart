import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/roadmap/domain/entities/roadmap.dart';
import 'package:prepnode/features/roadmap/presentation/providers/roadmap_providers.dart';

/// Today's slice of the roadmap, on the dashboard.
///
/// When no roadmap exists this becomes the prompt to build one — that is the
/// "guide the beginner instead of throwing features at them" requirement: a
/// brand-new user's dashboard leads with one clear next action.
class TodaysRoadmapCard extends ConsumerWidget {
  const TodaysRoadmapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRoadmap = ref.watch(hasRoadmapProvider);

    return hasRoadmap.when(
      loading: () => const SizedBox(height: 80),
      error: (_, _) => const SizedBox.shrink(),
      data: (exists) =>
          exists ? const _TodaysTasks() : const _GenerateRoadmapPrompt(),
    );
  }
}

class _GenerateRoadmapPrompt extends StatelessWidget {
  const _GenerateRoadmapPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ink900, Color(0xFF2C4470)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.marigold500),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                'Start here',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.marigold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'Build your 30-day roadmap',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Six quick questions, then a day-by-day plan built from the real '
            'TNPSC syllabus and adjusted as you go.',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Build my roadmap',
            backgroundColor: AppColors.marigold500,
            textColor: AppColors.ink900,
            onPressed: () => context.push('/roadmap/setup'),
          ),
        ],
      ),
    );
  }
}

class _TodaysTasks extends ConsumerWidget {
  const _TodaysTasks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaysRoadmapProvider);

    return todayAsync.when(
      loading: () => const SizedBox(height: 120),
      error: (_, _) => const SizedBox.shrink(),
      data: (day) {
        if (day == null) return const _RoadmapFinished();
        return _TodayCard(day: day);
      },
    );
  }
}

class _TodayCard extends ConsumerWidget {
  final RoadmapDay day;

  const _TodayCard({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = day.tasks.where((t) => !t.isCompleted).toList();

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Today's roadmap",
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.graphite700,
                      ),
                    ),
                    Text(
                      'Day ${day.dayNumber} · ${day.focusLabel}',
                      style: GoogleFonts.fraunces(
                        fontSize: AppConstants.fontSizeTitleLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/roadmap'),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: day.progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.lightOutlineVariant,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3F7D58)),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            remaining.isEmpty
                ? 'All ${day.tasks.length} tasks done. Well played.'
                : '${day.completedCount}/${day.tasks.length} done · '
                    '${remaining.fold<int>(0, (s, t) => s + t.estimatedMinutes)} min left',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppColors.graphite700,
            ),
          ),
          // Only the next three, so the dashboard stays a summary rather
          // than duplicating the timeline screen.
          for (final task in remaining.take(3)) _buildTaskRow(context, ref, task),
        ],
      ),
    );
  }

  Widget _buildTaskRow(BuildContext context, WidgetRef ref, RoadmapTask task) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: false,
              activeColor: const Color(0xFF3F7D58),
              onChanged: (_) async {
                final xp = await ref
                    .read(roadmapControllerProvider)
                    .completeTask(task.id);
                if (!context.mounted || xp <= 0) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('+$xp XP · ${task.title}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                task.title,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.ink900,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${task.estimatedMinutes}m',
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

/// The 30 days have run out — offer a fresh plan rather than an empty card.
class _RoadmapFinished extends StatelessWidget {
  const _RoadmapFinished();

  @override
  Widget build(BuildContext context) {
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
            'Your 30-day plan has finished',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeTitleLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Generate the next one — it will be built from everything you have '
            'learned since.',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Generate next 30 days',
            onPressed: () => context.push('/roadmap/setup'),
          ),
        ],
      ),
    );
  }
}
