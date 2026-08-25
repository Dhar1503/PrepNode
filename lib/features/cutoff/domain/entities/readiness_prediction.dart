import 'package:equatable/equatable.dart';

/// Represents user's readiness prediction based on current performance
class ReadinessPrediction extends Equatable {
  final String userId;
  final String examId;
  final double currentScore;
  final double predictedScore;
  final double targetCutoff;
  final double readinessPercentage; // 0.0 to 100.0
  final String readinessLevel; // 'excellent', 'good', 'moderate', 'needs_improvement'
  final List<String> strongAreas;
  final List<String> weakAreas;
  final int weeksUntilExam;
  final String recommendation;

  const ReadinessPrediction({
    required this.userId,
    required this.examId,
    required this.currentScore,
    required this.predictedScore,
    required this.targetCutoff,
    required this.readinessPercentage,
    required this.readinessLevel,
    required this.strongAreas,
    required this.weakAreas,
    required this.weeksUntilExam,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
        userId,
        examId,
        currentScore,
        predictedScore,
        targetCutoff,
        readinessPercentage,
        readinessLevel,
        strongAreas,
        weakAreas,
        weeksUntilExam,
        recommendation,
      ];
}
