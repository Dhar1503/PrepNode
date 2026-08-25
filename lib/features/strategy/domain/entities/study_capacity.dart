/// Study Capacity Entity
///
/// Classifies HOW a student studies, not how smart they are — consistency,
/// speed of improvement, coverage vs. depth, revision discipline. Computed
/// entirely from real local signals (see StrategyRepositoryImpl), never
/// hardcoded to one label: the profile is picked by a decision tree over
/// several independently-computed factors, each exposed in [factors] so the
/// UI can show its own reasoning rather than asserting a verdict.
class StudyCapacity {
  final String userId;
  final CapacityProfile profile;
  final double capacityScore; // 0-100 composite
  final Map<String, double> factors; // factor name -> 0.0-1.0
  final String summary;
  final int dataPoints; // how much real activity this was computed from

  const StudyCapacity({
    required this.userId,
    required this.profile,
    required this.capacityScore,
    required this.factors,
    required this.summary,
    required this.dataPoints,
  });
}

enum CapacityProfile {
  buildingMomentum, // not enough activity yet for a confident read
  fastLearner,
  slowConsistent,
  examReady,
  needsRevision,
  highPotential,
  weakFoundation,
  needsConceptBuilding,
  lowConsistency,
  highAccuracyLowCoverage,
}

extension CapacityProfileLabel on CapacityProfile {
  String get label {
    switch (this) {
      case CapacityProfile.buildingMomentum:
        return 'Building Momentum';
      case CapacityProfile.fastLearner:
        return 'Fast Learner';
      case CapacityProfile.slowConsistent:
        return 'Slow & Consistent';
      case CapacityProfile.examReady:
        return 'Exam Ready';
      case CapacityProfile.needsRevision:
        return 'Needs Revision';
      case CapacityProfile.highPotential:
        return 'High Potential';
      case CapacityProfile.weakFoundation:
        return 'Weak Foundation';
      case CapacityProfile.needsConceptBuilding:
        return 'Needs Concept Building';
      case CapacityProfile.lowConsistency:
        return 'Low Consistency';
      case CapacityProfile.highAccuracyLowCoverage:
        return 'High Accuracy, Low Coverage';
    }
  }
}
