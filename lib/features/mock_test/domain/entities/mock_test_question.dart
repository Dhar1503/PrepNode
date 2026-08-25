/// Mock Test Question Entity
/// Represents a question in a mock test
class MockTestQuestion {
  final String id;
  final String testId;
  final String sectionId;
  final String? subjectId;
  final String? topicId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int marks;
  final int order;
  final QuestionStatus status;
  final int? selectedOptionIndex;
  final bool isSkipped;
  final bool isMarkedForReview;
  final int? timeTakenSeconds;
  // Per-question, mirroring how `marks` is already carried per-question
  // rather than centrally on MockTest — see MockTest.negativeMarking for
  // the test-level configured value this is populated from. Defaults to 0
  // (no penalty) for any construction site that doesn't have a real rate
  // to supply, rather than assuming a rate that was never configured.
  final double negativeMarking;

  const MockTestQuestion({
    required this.id,
    required this.testId,
    required this.sectionId,
    this.subjectId,
    this.topicId,
    required this.questionText,
    required this.options,
    this.correctAnswerIndex = 0,
    this.explanation = '',
    this.marks = 0,
    this.order = 0,
    this.status = QuestionStatus.notAnswered,
    this.selectedOptionIndex,
    this.isSkipped = false,
    this.isMarkedForReview = false,
    this.timeTakenSeconds,
    this.negativeMarking = 0.0,
  });

  MockTestQuestion copyWith({
    String? id,
    String? testId,
    String? sectionId,
    String? subjectId,
    String? topicId,
    String? questionText,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    int? marks,
    int? order,
    QuestionStatus? status,
    int? selectedOptionIndex,
    bool? isSkipped,
    bool? isMarkedForReview,
    int? timeTakenSeconds,
    double? negativeMarking,
  }) {
    return MockTestQuestion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      marks: marks ?? this.marks,
      order: order ?? this.order,
      status: status ?? this.status,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isSkipped: isSkipped ?? this.isSkipped,
      isMarkedForReview: isMarkedForReview ?? this.isMarkedForReview,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      negativeMarking: negativeMarking ?? this.negativeMarking,
    );
  }

  bool get isAnswered => status == QuestionStatus.answered;
  bool get isCorrect => selectedOptionIndex == correctAnswerIndex;

  /// Correct -> +marks. Incorrect (answered but wrong) -> -negativeMarking.
  /// Unanswered or skipped -> 0, matching the app's advertised rule ("No
  /// negative marking for unanswered questions" — test_instructions_screen.dart;
  /// "Unanswered questions: 0 marks" — mock_test_home_screen.dart). Skipped
  /// questions are treated the same as unanswered ones: neither rule text
  /// distinguishes an explicit skip from simply never answering.
  double get obtainedMarks {
    if (!isAnswered) return 0.0;
    return isCorrect ? marks.toDouble() : -negativeMarking;
  }
}

enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  skipped,
}
