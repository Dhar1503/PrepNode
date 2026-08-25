import 'pyq_question.dart';

/// PYQ Practice Session Entity
/// Represents a practice session with multiple questions
class PyqSession {
  final String id;
  final String userId;
  final String examId;
  final String subjectId;
  final String topicId;
  final String topicName;
  final SessionMode mode;
  final List<PyqQuestion> questions;
  final int currentIndex;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalCorrect;
  final int totalAnswered;
  final int totalDurationSeconds;
  final bool isCompleted;
  final List<QuestionAttempt> attempts;
  final List<String> flaggedForRevision;

  const PyqSession({
    required this.id,
    required this.userId,
    required this.examId,
    required this.subjectId,
    required this.topicId,
    required this.topicName,
    required this.mode,
    required this.questions,
    required this.currentIndex,
    required this.startedAt,
    this.completedAt,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
    this.totalDurationSeconds = 0,
    this.isCompleted = false,
    this.attempts = const [],
    this.flaggedForRevision = const [],
  });

  PyqSession copyWith({
    String? id,
    String? userId,
    String? examId,
    String? subjectId,
    String? topicId,
    String? topicName,
    SessionMode? mode,
    List<PyqQuestion>? questions,
    int? currentIndex,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalCorrect,
    int? totalAnswered,
    int? totalDurationSeconds,
    bool? isCompleted,
    List<QuestionAttempt>? attempts,
    List<String>? flaggedForRevision,
  }) {
    return PyqSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      examId: examId ?? this.examId,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      attempts: attempts ?? this.attempts,
      flaggedForRevision: flaggedForRevision ?? this.flaggedForRevision,
    );
  }

  double get accuracy {
    if (totalAnswered == 0) return 0.0;
    return totalCorrect / totalAnswered;
  }

  int get remainingQuestions => questions.length - currentIndex - 1;
  PyqQuestion? get currentQuestion {
    if (currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }
  bool get isLastQuestion => currentIndex == questions.length - 1;
}

enum SessionMode {
  single,
  batch,
  incorrectRetry,
  bookmarked,
}

class QuestionAttempt {
  final String id;
  final String questionId;
  final int selectedOptionIndex;
  final int? correctOptionIndex;
  final bool isCorrect;
  final int timeTakenSeconds;
  final ConfidenceRating? confidenceRating;
  final DateTime attemptedAt;
  final String? notes;

  const QuestionAttempt({
    required this.id,
    required this.questionId,
    required this.selectedOptionIndex,
    this.correctOptionIndex,
    required this.isCorrect,
    required this.timeTakenSeconds,
    this.confidenceRating,
    required this.attemptedAt,
    this.notes,
  });

  QuestionAttempt copyWith({
    String? id,
    String? questionId,
    int? selectedOptionIndex,
    int? correctOptionIndex,
    bool? isCorrect,
    int? timeTakenSeconds,
    ConfidenceRating? confidenceRating,
    DateTime? attemptedAt,
    String? notes,
  }) {
    return QuestionAttempt(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      confidenceRating: confidenceRating ?? this.confidenceRating,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      notes: notes ?? this.notes,
    );
  }
}
