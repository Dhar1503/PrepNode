import 'package:equatable/equatable.dart';

/// Learner Progress Entity
/// Represents overall learner progress across the syllabus
class LearnerProgress extends Equatable {
  final String userId;
  final double prepGraphScore;
  final ScoreComponents scoreComponents;
  final DateTime lastUpdated;

  const LearnerProgress({
    required this.userId,
    required this.prepGraphScore,
    required this.scoreComponents,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, prepGraphScore, scoreComponents, lastUpdated];
}

/// Score Components
/// Breakdown of the five weighted components of PrepGraph Score
class ScoreComponents extends Equatable {
  final double topicCompletion; // Weight: 30%
  final double pyqPerformance; // Weight: 25%
  final double mockAccuracy; // Weight: 20%
  final double consistency; // Weight: 15%
  final double revisionDiscipline; // Weight: 10%

  const ScoreComponents({
    required this.topicCompletion,
    required this.pyqPerformance,
    required this.mockAccuracy,
    required this.consistency,
    required this.revisionDiscipline,
  });

  @override
  List<Object?> get props => [
        topicCompletion,
        pyqPerformance,
        mockAccuracy,
        consistency,
        revisionDiscipline,
      ];
}
