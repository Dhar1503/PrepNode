import 'package:prepnode/features/strategy/domain/entities/study_capacity.dart';
import 'package:prepnode/features/strategy/domain/entities/strategy_recommendation.dart';

/// Strategy Summary Entity
///
/// The single-glance payload behind the "My Strategy" dashboard hero card —
/// everything a student needs to see in one place, all real: capacity
/// profile, readiness, next topic, expected score movement, category-aware
/// cutoff gap.
class StrategySummary {
  final CapacityProfile capacityProfile;
  final double readinessPercentage;
  final String readinessLevel;
  final StrategyRecommendation? nextBestTopic;
  final double currentScore;
  final double targetCutoff;
  final double scoreGap; // targetCutoff - currentScore; negative means already above
  final String category;
  final int weeksUntilExam;
  final String todaysFocusHeadline;

  const StrategySummary({
    required this.capacityProfile,
    required this.readinessPercentage,
    required this.readinessLevel,
    required this.nextBestTopic,
    required this.currentScore,
    required this.targetCutoff,
    required this.scoreGap,
    required this.category,
    required this.weeksUntilExam,
    required this.todaysFocusHeadline,
  });
}
