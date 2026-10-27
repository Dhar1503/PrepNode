import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepnode/features/knowledge_graph/presentation/widgets/mastery_ring.dart';

/// Subject List Tile Widget
/// Reusable tile for displaying subjects in the knowledge graph
class SubjectListTile extends StatelessWidget {
  final GraphNode subject;
  final VoidCallback? onTap;

  const SubjectListTile({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppConstants.spaceLg,
          right: AppConstants.spaceLg,
          bottom: AppConstants.spaceMd,
        ),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Row(
          children: [
            MasteryRing(
              masteryPercentage: subject.masteryPercentage,
              masteryState: subject.masteryState,
              size: 32,
              strokeWidth: 2.5,
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${(subject.masteryPercentage * 100).toInt()}% mastered',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodySmall,
                          color: AppColors.graphite700,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      if (subject.estimatedStudyMinutes != null) ...[
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.graphite700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          '${math.max(0, subject.estimatedStudyMinutes! ~/ 60)}h',
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontSizeBodySmall,
                            color: AppColors.graphite700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Icon(
              Icons.chevron_right,
              color: AppColors.graphite700,
            ),
          ],
        ),
      ),
    );
  }
}
