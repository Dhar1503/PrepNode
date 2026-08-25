import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/presentation/widgets/mastery_ring.dart';

/// Topic List Tile Widget
/// Reusable tile for displaying topics in the knowledge graph
class TopicListTile extends StatelessWidget {
  final GraphNode topic;
  final VoidCallback? onTap;
  final int? depth;

  const TopicListTile({
    super.key,
    required this.topic,
    this.onTap,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final indentation = (depth ?? 0) * AppConstants.spaceLg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: AppConstants.spaceLg + indentation,
          right: AppConstants.spaceLg,
          bottom: AppConstants.spaceSm,
        ),
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Row(
          children: [
            MasteryRing(
              masteryPercentage: topic.masteryPercentage,
              masteryState: topic.masteryState,
              size: 24,
              strokeWidth: 2,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          topic.name,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodyMedium,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // importanceScore is real PYQ-frequency weighting (see
                      // KnowledgeGraphLocalDataSource.getTopics) — this
                      // badge means "actually appears often in past papers,"
                      // not a generic difficulty label.
                      if ((topic.importanceScore ?? 0) >= 0.6) ...[
                        const SizedBox(width: AppConstants.spaceXs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.marigold500.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.whatshot, size: 12, color: AppColors.marigold500),
                              const SizedBox(width: 2),
                              Text(
                                'Frequent',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.marigold500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (topic.estimatedStudyMinutes != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${topic.estimatedStudyMinutes ?? 0} min',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodySmall,
                        color: AppColors.graphite700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (topic.type == NodeType.topic)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.graphite700,
              ),
          ],
        ),
      ),
    );
  }
}
