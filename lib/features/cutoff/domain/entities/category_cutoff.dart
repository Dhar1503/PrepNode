import 'package:equatable/equatable.dart';

/// Represents cutoff data for a specific category in a year
class CategoryCutoff extends Equatable {
  final String category;
  final double cutoffMark;
  final int? vacancyCount;
  final int year;

  const CategoryCutoff({
    required this.category,
    required this.cutoffMark,
    this.vacancyCount,
    required this.year,
  });

  @override
  List<Object?> get props => [category, cutoffMark, vacancyCount, year];
}
