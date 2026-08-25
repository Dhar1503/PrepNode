/// Mock Test Result Entity
/// Represents the detailed result of a completed mock test
class MockTestResult {
  final String? id;
  final String attemptId;
  final String testId;
  final String userId;
  final double obtainedMarks;
  final double totalMarks;
  final double percentage;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final int totalQuestions;
  final double accuracy;
  final int timeTakenSeconds;
  final double? totalScore;
  final int? maxScore;
  final int? rank;
  final int? correct;
  final int? incorrect;
  final int? skipped;
  final List<SectionResult> sectionResults;
  final List<WeakTopic> weakTopics;
  final List<String> flaggedForRevision;
  final String aiSummary;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  const MockTestResult({
    this.id,
    required this.attemptId,
    required this.testId,
    required this.userId,
    this.obtainedMarks = 0,
    this.totalMarks = 0,
    this.percentage = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedQuestions = 0,
    this.totalQuestions = 0,
    this.accuracy = 0,
    this.timeTakenSeconds = 0,
    this.totalScore,
    this.maxScore,
    this.rank,
    this.correct,
    this.incorrect,
    this.skipped,
    this.sectionResults = const [],
    this.weakTopics = const [],
    this.flaggedForRevision = const [],
    this.aiSummary = '',
    this.submittedAt,
    this.completedAt,
  });

  MockTestResult copyWith({
    String? id,
    String? attemptId,
    String? testId,
    String? userId,
    double? obtainedMarks,
    double? totalMarks,
    double? percentage,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedQuestions,
    int? totalQuestions,
    double? accuracy,
    int? timeTakenSeconds,
    double? totalScore,
    int? maxScore,
    int? rank,
    int? correct,
    int? incorrect,
    int? skipped,
    List<SectionResult>? sectionResults,
    List<WeakTopic>? weakTopics,
    List<String>? flaggedForRevision,
    String? aiSummary,
    DateTime? submittedAt,
    DateTime? completedAt,
  }) {
    return MockTestResult(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      testId: testId ?? this.testId,
      userId: userId ?? this.userId,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      percentage: percentage ?? this.percentage,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      accuracy: accuracy ?? this.accuracy,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      rank: rank ?? this.rank,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      skipped: skipped ?? this.skipped,
      sectionResults: sectionResults ?? this.sectionResults,
      weakTopics: weakTopics ?? this.weakTopics,
      flaggedForRevision: flaggedForRevision ?? this.flaggedForRevision,
      aiSummary: aiSummary ?? this.aiSummary,
      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class SectionResult {
  final String sectionId;
  final String sectionName;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final double obtainedMarks;
  final double totalMarks;
  final double percentage;
  final double accuracy;
  final int timeTakenSeconds;
  final int? correct;
  final int? incorrect;
  final int? skipped;
  final int? marks;

  const SectionResult({
    required this.sectionId,
    required this.sectionName,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedQuestions = 0,
    this.obtainedMarks = 0,
    this.totalMarks = 0,
    this.percentage = 0,
    this.accuracy = 0,
    this.timeTakenSeconds = 0,
    this.correct,
    this.incorrect,
    this.skipped,
    this.marks,
  });

  SectionResult copyWith({
    String? sectionId,
    String? sectionName,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedQuestions,
    double? obtainedMarks,
    double? totalMarks,
    double? percentage,
    double? accuracy,
    int? timeTakenSeconds,
    int? correct,
    int? incorrect,
    int? skipped,
    int? marks,
  }) {
    return SectionResult(
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      percentage: percentage ?? this.percentage,
      accuracy: accuracy ?? this.accuracy,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      correct: correct ?? this.correct,
      incorrect: incorrect ?? this.incorrect,
      skipped: skipped ?? this.skipped,
      marks: marks ?? this.marks,
    );
  }
}

class WeakTopic {
  final String topicId;
  final String topicName;
  final String subjectId;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final double timePerQuestion;

  const WeakTopic({
    required this.topicId,
    required this.topicName,
    required this.subjectId,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.accuracy = 0,
    this.timePerQuestion = 0,
  });

  WeakTopic copyWith({
    String? topicId,
    String? topicName,
    String? subjectId,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
    double? timePerQuestion,
  }) {
    return WeakTopic(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      subjectId: subjectId ?? this.subjectId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
    );
  }

  bool get isWeak => accuracy < 0.5 && totalQuestions >= 2;
}
