import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/cutoff/domain/entities/yearly_trend.dart';

/// Widget displaying cutoff trend as a line chart
class TrendGraph extends StatelessWidget {
  final List<YearlyTrend> trends;
  final String? selectedCategory;

  const TrendGraph({
    super.key,
    required this.trends,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final dataPoints = _getDataPoints();
    final maxY = dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final minY = dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cutoff Trend',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < trends.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppConstants.spaceSm),
                            child: Text(
                              trends[index].year.toString(),
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeBodySmall,
                                color: AppColors.graphite700,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxY - minY) / 5,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppConstants.spaceSm),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeBodySmall,
                              color: AppColors.graphite700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: (trends.length - 1).toDouble(),
                minY: minY - 5,
                maxY: maxY + 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    color: AppColors.sage500,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.sage500,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.sage500.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.ink900,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < trends.length) {
                          final trend = trends[index];
                          return LineTooltipItem(
                            '${trend.year}: ${spot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: AppColors.paper50,
                              fontSize: AppConstants.fontSizeBodySmall,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getDataPoints() {
    final selectedCat = selectedCategory;
    return trends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      
      if (selectedCat != null) {
        final categoryCutoff = trend.categoryBreakdown
            .where((c) => c.category == selectedCat)
            .firstOrNull;
        return FlSpot(
          index.toDouble(),
          categoryCutoff?.cutoffMark ?? trend.averageCutoff,
        );
      }
      
      return FlSpot(index.toDouble(), trend.averageCutoff);
    }).toList();
  }
}
