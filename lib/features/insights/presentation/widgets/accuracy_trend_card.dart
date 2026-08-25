import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/insights/domain/entities/pyq_performance.dart';

/// Accuracy Trend Card
/// Displays accuracy trend for a specific topic over time
class AccuracyTrendCard extends StatelessWidget {
  final TopicPyqTrend trend;

  const AccuracyTrendCard({
    super.key,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate trend direction
    final recentAccuracy = trend.dailyData.isNotEmpty 
        ? trend.dailyData.last.accuracy 
        : 0.0;
    final earlierAccuracy = trend.dailyData.length > 1
        ? trend.dailyData[trend.dailyData.length - 2].accuracy
        : recentAccuracy;
    final isImproving = recentAccuracy >= earlierAccuracy;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceSm,
      ),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  trend.topicName,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Row(
                children: [
                  Icon(
                    isImproving ? Icons.trending_up : Icons.trending_flat,
                    color: isImproving ? AppColors.sage500 : AppColors.graphite700,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.spaceXs),
                  Text(
                    isImproving ? 'Improving' : 'Stable',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: isImproving ? AppColors.sage500 : AppColors.graphite700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          // Simple trend visualization
          _buildTrendVisualization(),
        ],
      ),
    );
  }

  Widget _buildTrendVisualization() {
    if (trend.dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentData = trend.dailyData.take(7).toList();
    final maxAccuracy = recentData.map((d) => d.accuracy).reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: recentData.asMap().entries.map((entry) {
          final data = entry.value;
          final height = maxAccuracy > 0 ? (data.accuracy / maxAccuracy) * 40 : 0;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height.toDouble(),
                    decoration: BoxDecoration(
                      color: _getAccuracyColor(data.accuracy),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    '${(data.accuracy * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      color: AppColors.graphite700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.sage500;
    if (accuracy >= 0.6) return AppColors.marigold500;
    return AppColors.ink500;
  }
}
