import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/core/network/providers/network_providers.dart';
import 'package:prepgraph/features/mock_test/data/repositories/mock_test_repository_impl.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_attempt.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_question.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test_result.dart';
import 'package:prepgraph/features/mock_test/domain/repositories/mock_test_repository.dart';

/// Mock Test Repository Provider
final mockTestRepositoryProvider = Provider<MockTestRepository>((ref) {
  final remoteDataSource = ref.watch(mockTestRemoteDataSourceProvider);
  final localDataSource = ref.watch(mockTestLocalDataSourceProvider);
  return MockTestRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Mock Tests State Provider
class MockTestsState {
  final bool isLoading;
  final String? errorMessage;
  final List<MockTest> tests;

  const MockTestsState({
    this.isLoading = true,
    this.errorMessage,
    this.tests = const [],
  });

  MockTestsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MockTest>? tests,
  }) {
    return MockTestsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      tests: tests ?? this.tests,
    );
  }
}

/// Mock Tests State Notifier
class MockTestsNotifier extends StateNotifier<MockTestsState> {
  final MockTestRepository _repository;

  MockTestsNotifier(this._repository) : super(const MockTestsState());

  Future<void> loadMockTests({
    required String examId,
    MockTestType? type,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getMockTests(
      examId: examId,
      type: type,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (tests) {
        state = state.copyWith(
          isLoading: false,
          tests: tests,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Mock Tests Provider
final mockTestsProvider = StateNotifierProvider<MockTestsNotifier, MockTestsState>((ref) {
  final repository = ref.watch(mockTestRepositoryProvider);
  return MockTestsNotifier(repository);
});

/// Test Attempt State Provider
class TestAttemptState {
  final bool isLoading;
  final String? errorMessage;
  final MockTestAttempt? attempt;
  final bool isSubmitting;

  const TestAttemptState({
    this.isLoading = false,
    this.errorMessage,
    this.attempt,
    this.isSubmitting = false,
  });

  TestAttemptState copyWith({
    bool? isLoading,
    String? errorMessage,
    MockTestAttempt? attempt,
    bool? isSubmitting,
  }) {
    return TestAttemptState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      attempt: attempt ?? this.attempt,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Test Attempt State Notifier
class TestAttemptNotifier extends StateNotifier<TestAttemptState> {
  final MockTestRepository _repository;

  TestAttemptNotifier(this._repository) : super(const TestAttemptState());

  Future<void> startTest({
    required String userId,
    required String testId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.startTest(
      userId: userId,
      testId: testId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (attempt) {
        state = state.copyWith(
          isLoading: false,
          attempt: attempt,
        );
      },
    );
  }

  Future<void> resumeTest({
    required String attemptId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.resumeTest(attemptId: attemptId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (attempt) {
        state = state.copyWith(
          isLoading: false,
          attempt: attempt,
        );
      },
    );
  }

  /// Seeds the notifier with an attempt built elsewhere (e.g. by the route
  /// that starts the test) so the rest of the test-taking flow — answer
  /// selection, navigation, timer, submission — reads and writes through
  /// this provider instead of separate widget state.
  void loadAttempt(MockTestAttempt attempt) {
    state = TestAttemptState(attempt: attempt);
  }

  /// Advances the attempt's remaining time by one second. Called from the
  /// screen's ticking timer so the countdown lives in provider state rather
  /// than a widget-local counter.
  void tick() {
    final attempt = state.attempt;
    if (attempt == null || attempt.timeRemainingSeconds <= 0) return;
    state = state.copyWith(
      attempt: attempt.copyWith(
        timeRemainingSeconds: attempt.timeRemainingSeconds - 1,
      ),
    );
  }

  /// Records the selected option for a question. This is local state only
  /// (no network round-trip): correctness is derived from the question's
  /// own [MockTestQuestion.correctAnswerIndex] already held in state, and
  /// answers are persisted in bulk when the test is submitted.
  void updateQuestionAnswer({
    required String questionId,
    required int selectedOptionIndex,
    int? timeTakenSeconds,
  }) {
    final attempt = state.attempt;
    if (attempt == null) return;

    final updatedQuestions = attempt.questions.map((q) {
      if (q.id != questionId) return q;
      return q.copyWith(
        selectedOptionIndex: selectedOptionIndex,
        status: QuestionStatus.answered,
        isSkipped: false,
        timeTakenSeconds: timeTakenSeconds ?? q.timeTakenSeconds,
      );
    }).toList();

    state = state.copyWith(attempt: attempt.copyWith(questions: updatedQuestions));
  }

  void markForReview({
    required String questionId,
    required bool isMarked,
  }) {
    final attempt = state.attempt;
    if (attempt == null) return;

    final updatedQuestions = attempt.questions.map((q) {
      if (q.id != questionId) return q;
      return q.copyWith(isMarkedForReview: isMarked);
    }).toList();

    state = state.copyWith(attempt: attempt.copyWith(questions: updatedQuestions));
  }

  void skipQuestion({
    required String questionId,
  }) {
    final attempt = state.attempt;
    if (attempt == null) return;

    final updatedQuestions = attempt.questions.map((q) {
      if (q.id != questionId) return q;
      return q.copyWith(isSkipped: true, status: QuestionStatus.skipped);
    }).toList();

    state = state.copyWith(attempt: attempt.copyWith(questions: updatedQuestions));
  }

  Future<void> pauseTest({
    required String attemptId,
  }) async {
    final result = await _repository.pauseTest(attemptId: attemptId);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (attempt) {
        state = state.copyWith(attempt: attempt);
      },
    );
  }

  /// Submits the current attempt, calculating the score from its actual
  /// answered questions and persisting the result. Returns the computed
  /// result so the caller can carry it to the result/analysis screens.
  Future<MockTestResult?> submitTest() async {
    final attempt = state.attempt;
    if (attempt == null) return null;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await _repository.submitTest(attempt: attempt);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (testResult) {
        state = state.copyWith(
          isSubmitting: false,
          attempt: attempt.copyWith(isCompleted: true),
        );
        return testResult;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Test Attempt Provider
final testAttemptProvider = StateNotifierProvider<TestAttemptNotifier, TestAttemptState>((ref) {
  final repository = ref.watch(mockTestRepositoryProvider);
  return TestAttemptNotifier(repository);
});

/// Test Result State Provider
class TestResultState {
  final bool isLoading;
  final String? errorMessage;
  final MockTestResult? result;

  const TestResultState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  TestResultState copyWith({
    bool? isLoading,
    String? errorMessage,
    MockTestResult? result,
  }) {
    return TestResultState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      result: result ?? this.result,
    );
  }
}

/// Test Result State Notifier
class TestResultNotifier extends StateNotifier<TestResultState> {
  final MockTestRepository _repository;

  TestResultNotifier(this._repository) : super(const TestResultState());

  Future<void> getTestResult({
    required String attemptId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getTestResult(attemptId: attemptId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (testResult) {
        state = state.copyWith(
          isLoading: false,
          result: testResult,
        );
      },
    );
  }

  Future<void> getTestHistory({
    required String userId,
    String? examId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getTestHistory(
      userId: userId,
      examId: examId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (history) {
        // Store history in result for now
        if (history.isNotEmpty) {
          state = state.copyWith(
            isLoading: false,
            result: history.first,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Test Result Provider
final testResultProvider = StateNotifierProvider<TestResultNotifier, TestResultState>((ref) {
  final repository = ref.watch(mockTestRepositoryProvider);
  return TestResultNotifier(repository);
});
