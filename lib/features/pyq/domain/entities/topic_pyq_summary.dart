/// Topic PYQ Summary Entity
/// Summary of PYQs for a topic with metadata
class TopicPyqSummary {
  final String topicId;
  final String topicName;
  final int totalQuestions;
  final int solvedQuestions;
  final int bookmarkedQuestions;
  final int incorrectQuestions;
  final double averageAccuracy;
  final int? lastYear;
  final int? firstYear;
  final int frequencyCount;
  final List<int> yearsAppeared;

  const TopicPyqSummary({
    required this.topicId,
    required this.topicName,
    required this.totalQuestions,
    required this.solvedQuestions,
    required this.bookmarkedQuestions,
    required this.incorrectQuestions,
    required this.averageAccuracy,
    this.lastYear,
    this.firstYear,
    required this.frequencyCount,
    required this.yearsAppeared,
  });

  TopicPyqSummary copyWith({
    String? topicId,
    String? topicName,
    int? totalQuestions,
    int? solvedQuestions,
    int? bookmarkedQuestions,
    int? incorrectQuestions,
    double? averageAccuracy,
    int? lastYear,
    int? firstYear,
    int? frequencyCount,
    List<int>? yearsAppeared,
  }) {
    return TopicPyqSummary(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      solvedQuestions: solvedQuestions ?? this.solvedQuestions,
      bookmarkedQuestions: bookmarkedQuestions ?? this.bookmarkedQuestions,
      incorrectQuestions: incorrectQuestions ?? this.incorrectQuestions,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      lastYear: lastYear ?? this.lastYear,
      firstYear: firstYear ?? this.firstYear,
      frequencyCount: frequencyCount ?? this.frequencyCount,
      yearsAppeared: yearsAppeared ?? this.yearsAppeared,
    );
  }

  double get completionPercentage {
    if (totalQuestions == 0) return 0.0;
    return solvedQuestions / totalQuestions;
  }

  bool get isWeakTopic => averageAccuracy < 0.5 && solvedQuestions >= 3;
}
