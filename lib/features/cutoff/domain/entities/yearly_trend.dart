import 'package:equatable/equatable.dart';
import 'package:prepgraph/features/cutoff/domain/entities/category_cutoff.dart';

/// Represents trend data for a specific year
class YearlyTrend extends Equatable {
  final int year;
  final double averageCutoff;
  final int totalVacancies;
  final double difficultyIndex; // 0.0 to 1.0, higher = more difficult
  final List<CategoryCutoff> categoryBreakdown;

  const YearlyTrend({
    required this.year,
    required this.averageCutoff,
    required this.totalVacancies,
    required this.difficultyIndex,
    required this.categoryBreakdown,
  });

  @override
  List<Object?> get props => [
        year,
        averageCutoff,
        totalVacancies,
        difficultyIndex,
        categoryBreakdown,
      ];
}
