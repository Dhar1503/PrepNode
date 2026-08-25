import 'mock_test.dart';
import 'mock_test_question.dart';

/// Mock Test Attempt Entity
/// Represents a user's attempt at a mock test
class MockTestAttempt {
  final String id;
  final String userId;
  final String testId;
  final MockTestType testType;
  final AttemptStatus status;
  final DateTime startedAt;
  final int currentSectionIndex;
  final int currentQuestionIndex;
  final int timeRemainingSeconds;
  final DateTime? completedAt;
  final int durationSeconds;
  final int totalQuestions;
  final int answeredQuestions;
  final int markedForReview;
  final int skippedQuestions;
  final double obtainedMarks;
  final double totalMarks;
  final double accuracy;
  final List<MockTestQuestion> questions;
  final bool isCompleted;
  final bool isPaused;
  final DateTime? lastPausedAt;

  const MockTestAttempt({
    required this.id,
    required this.userId,
    required this.testId,
    required this.startedAt,
    this.testType = MockTestType.full,
    this.status = AttemptStatus.inProgress,
    this.currentSectionIndex = 0,
    this.currentQuestionIndex = 0,
    this.timeRemainingSeconds = 0,
    this.completedAt,
    this.durationSeconds = 0,
    this.totalQuestions = 0,
    this.answeredQuestions = 0,
    this.markedForReview = 0,
    this.skippedQuestions = 0,
    this.obtainedMarks = 0,
    this.totalMarks = 0,
    this.accuracy = 0,
    this.questions = const [],
    this.isCompleted = false,
    this.isPaused = false,
    this.lastPausedAt,
  });

  MockTestAttempt copyWith({
    String? id,
    String? userId,
    String? testId,
    MockTestType? testType,
    AttemptStatus? status,
    DateTime? startedAt,
    int? currentSectionIndex,
    int? currentQuestionIndex,
    int? timeRemainingSeconds,
    DateTime? completedAt,
    int? durationSeconds,
    int? totalQuestions,
    int? answeredQuestions,
    int? markedForReview,
    int? skippedQuestions,
    double? obtainedMarks,
    double? totalMarks,
    double? accuracy,
    List<MockTestQuestion>? questions,
    bool? isCompleted,
    bool? isPaused,
    DateTime? lastPausedAt,
  }) {
    return MockTestAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      testType: testType ?? this.testType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      markedForReview: markedForReview ?? this.markedForReview,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      accuracy: accuracy ?? this.accuracy,
      questions: questions ?? this.questions,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      lastPausedAt: lastPausedAt ?? this.lastPausedAt,
    );
  }

  double get percentage => (obtainedMarks / totalMarks) * 100;
  int get remainingQuestions => totalQuestions - answeredQuestions - skippedQuestions;
  int get unansweredQuestions => totalQuestions - answeredQuestions;
}

enum AttemptStatus {
  inProgress,
  paused,
  submitted,
  completed,
}
