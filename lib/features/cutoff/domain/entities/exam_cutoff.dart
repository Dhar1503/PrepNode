import 'package:equatable/equatable.dart';
import 'package:prepgraph/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/entities/yearly_trend.dart';

/// Represents historical cutoff data for a specific exam
class ExamCutoff extends Equatable {
  final String examId;
  final String examName;
  final String conductingBody;
  final List<CategoryCutoff> categoryCutoffs;
  final List<YearlyTrend> yearlyTrends;

  const ExamCutoff({
    required this.examId,
    required this.examName,
    required this.conductingBody,
    required this.categoryCutoffs,
    required this.yearlyTrends,
  });

  @override
  List<Object?> get props => [
        examId,
        examName,
        conductingBody,
        categoryCutoffs,
        yearlyTrends,
      ];
}
