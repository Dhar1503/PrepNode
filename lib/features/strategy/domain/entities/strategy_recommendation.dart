/// Strategy Recommendation Entity
///
/// One entry in "Your Next Best Topics" — the core output of the Strategy
/// Engine. Every field here is derived from real local data (see
/// StrategyRepositoryImpl._buildNextBestTopics); none of it is templated
/// filler text.
class StrategyRecommendation {
  final String topicId;
  final String topicName;
  final String subjectId;
  final String subjectName;
  final int rank;
  final double masteryPercentage; // 0.0-1.0, real
  final int pyqFrequency; // real count of past-year questions on this topic
  final double pyqFrequencyShare; // this topic's share of total syllabus PYQ volume, 0.0-1.0
  final int estimatedStudyMinutes;
  final double expectedScoreImpact; // marks, on the same scale as cutoff data
  final String difficulty; // 'Quick Win' / 'Medium' / 'Needs Foundation'
  final double confidence; // 0.0-1.0, based on how much attempt data backs the mastery number
  final String reason;

  const StrategyRecommendation({
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    required this.subjectName,
    required this.rank,
    required this.masteryPercentage,
    required this.pyqFrequency,
    required this.pyqFrequencyShare,
    required this.estimatedStudyMinutes,
    required this.expectedScoreImpact,
    required this.difficulty,
    required this.confidence,
    required this.reason,
  });
}
