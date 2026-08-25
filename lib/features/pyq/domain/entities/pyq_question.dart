/// PYQ Question Entity
/// Represents a previous year question with all metadata
class PyqQuestion {
  final String id;
  final String examId;
  final String subjectId;
  final String topicId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? relatedTopicId;
  final String? relatedTopicName;
  final int year;
  final DifficultyLevel difficulty;
  final bool isSolved;
  final bool isBookmarked;
  final String? userNotes;
  final ConfidenceRating? confidenceRating;
  final DateTime? lastAttemptedAt;
  final bool? wasCorrect;
  final int? timesAppeared;
  final int? timesCorrectOverall;
  // Added Phase 1A (real PYQ data foundation) — see database.dart's
  // Questions table for why these exist.
  final String language; // 'english' | 'tamil' | 'both'
  final String? source; // e.g. "TNPSC Group 2 2023 Prelims — official paper"
  final String verificationStatus; // 'verified' | 'unverified'

  const PyqQuestion({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.topicId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.relatedTopicId,
    this.relatedTopicName,
    required this.year,
    required this.difficulty,
    required this.isSolved,
    required this.isBookmarked,
    this.userNotes,
    this.confidenceRating,
    this.lastAttemptedAt,
    this.wasCorrect,
    this.timesAppeared,
    this.timesCorrectOverall,
    this.language = 'english',
    this.source,
    this.verificationStatus = 'unverified',
  });

  PyqQuestion copyWith({
    String? id,
    String? examId,
    String? subjectId,
    String? topicId,
    String? questionText,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? relatedTopicId,
    String? relatedTopicName,
    int? year,
    DifficultyLevel? difficulty,
    bool? isSolved,
    bool? isBookmarked,
    String? userNotes,
    ConfidenceRating? confidenceRating,
    DateTime? lastAttemptedAt,
    bool? wasCorrect,
    int? timesAppeared,
    int? timesCorrectOverall,
    String? language,
    String? source,
    String? verificationStatus,
  }) {
    return PyqQuestion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      relatedTopicId: relatedTopicId ?? this.relatedTopicId,
      relatedTopicName: relatedTopicName ?? this.relatedTopicName,
      year: year ?? this.year,
      difficulty: difficulty ?? this.difficulty,
      isSolved: isSolved ?? this.isSolved,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      userNotes: userNotes ?? this.userNotes,
      confidenceRating: confidenceRating ?? this.confidenceRating,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      timesAppeared: timesAppeared ?? this.timesAppeared,
      timesCorrectOverall: timesCorrectOverall ?? this.timesCorrectOverall,
      language: language ?? this.language,
      source: source ?? this.source,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  double get overallAccuracy {
    if (timesAppeared == null || timesAppeared == 0) return 0.0;
    return (timesCorrectOverall ?? 0) / timesAppeared!;
  }

  bool needsRevision() {
    return wasCorrect == false || 
           (confidenceRating != null && confidenceRating!.index < 2);
  }
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum ConfidenceRating {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}
