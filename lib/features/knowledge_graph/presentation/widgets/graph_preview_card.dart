import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';

/// Dashboard preview of the knowledge graph: subject coverage bars plus a
/// count of what needs attention. Tapping opens the full graph.
///
/// A miniature of the real graph would be unreadable at this size and would
/// pay the full layout cost on every dashboard build, so this summarises the
/// same data instead — the numbers are the honest part of the graph anyway.
class GraphPreviewCard extends ConsumerWidget {
  const GraphPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphAsync = ref.watch(syllabusGraphProvider);

    return graphAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, _) => const SizedBox.shrink(),
      data: (graph) {
        if (graph.nodes.isEmpty) return const SizedBox.shrink();

        final subjects =
            graph.nodes.where((n) => n.type == NodeType.subject).toList();
        final weak = graph.nodes
            .where((n) =>
                n.masteryState == MasteryState.needsRevision &&
                (n.type == NodeType.topic || n.type == NodeType.subtopic))
            .length;

        return InkWell(
          onTap: () => context.go('/learn'),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
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
                    const Icon(Icons.account_tree,
                        size: 18, color: AppColors.ink900),
                    const SizedBox(width: AppConstants.spaceXs),
                    Expanded(
                      child: Text(
                        'Knowledge Graph',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeTitleMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.graphite700),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  weak > 0
                      ? '$weak topic${weak == 1 ? '' : 's'} need revision · '
                          '${graph.nodes.length} nodes'
                      : '${graph.nodes.length} nodes across ${subjects.length} subjects',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.graphite700,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                for (final subject in subjects) _SubjectBar(subject: subject),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final GraphNode subject;

  const _SubjectBar({required this.subject});

  @override
  Widget build(BuildContext context) {
    final ratio = (subject.masteryPercentage / 100).clamp(0.0, 1.0);
    final color = switch (subject.masteryState) {
      MasteryState.mastered => const Color(0xFF3F7D58),
      MasteryState.needsRevision => const Color(0xFFB4552F),
      MasteryState.inProgress => AppColors.ink900,
      MasteryState.notStarted => AppColors.lightOutlineVariant,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceXs),
      child: Row(
        children: [
          // Proportional rather than a fixed 110dp box: at this device's
          // 1.3x font scale "General English" and "General Studies" both
          // overran it and came out as "General Engl…". scaleDown keeps the
          // whole name whatever the scale.
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subject.name,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    color: AppColors.ink900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          Expanded(
            flex: 4,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.lightOutlineVariant,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceXs),
          SizedBox(
            width: 34,
            child: Text(
              '${subject.masteryPercentage.round()}%',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
