import 'package:flutter/material.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/knowledge_graph/domain/entities/graph_node.dart';

/// Mastery Ring Widget
/// Circular progress indicator showing mastery state
class MasteryRing extends StatelessWidget {
  final double masteryPercentage;
  final MasteryState masteryState;
  final double size;
  final double strokeWidth;

  const MasteryRing({
    super.key,
    required this.masteryPercentage,
    required this.masteryState,
    this.size = 24,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForState();
    final progress = masteryPercentage.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.lightOutlineVariant,
                width: strokeWidth,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Center icon
          if (masteryState == MasteryState.mastered)
            Icon(
              Icons.check,
              size: size * 0.5,
              color: color,
            ),
        ],
      ),
    );
  }

  Color _getColorForState() {
    switch (masteryState) {
      case MasteryState.mastered:
        return AppColors.sage500;
      case MasteryState.inProgress:
        return AppColors.marigold500;
      case MasteryState.notStarted:
        return AppColors.graphite700;
      case MasteryState.needsRevision:
        return AppColors.marigold500;
    }
  }
}
