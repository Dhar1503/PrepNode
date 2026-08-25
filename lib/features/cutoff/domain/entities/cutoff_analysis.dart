import 'package:equatable/equatable.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/entities/readiness_prediction.dart';
import 'package:prepgraph/features/cutoff/domain/entities/recommendation.dart';

/// Represents comprehensive cutoff analysis for a user
class CutoffAnalysis extends Equatable {
  final String userId;
  final String examId;
  final ExamCutoff examCutoff;
  final ReadinessPrediction readinessPrediction;
  final List<Recommendation> personalizedRecommendations;

  const CutoffAnalysis({
    required this.userId,
    required this.examId,
    required this.examCutoff,
    required this.readinessPrediction,
    required this.personalizedRecommendations,
  });

  @override
  List<Object?> get props => [
        userId,
        examId,
        examCutoff,
        readinessPrediction,
        personalizedRecommendations,
      ];
}
