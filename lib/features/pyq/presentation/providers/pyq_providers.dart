import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/core/network/providers/network_providers.dart';
import 'package:prepgraph/features/pyq/data/repositories/pyq_repository_impl.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_question.dart';
import 'package:prepgraph/features/pyq/domain/entities/pyq_session.dart';
import 'package:prepgraph/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';

/// PYQ Repository Provider
final pyqRepositoryProvider = Provider<PyqRepository>((ref) {
  final remoteDataSource = ref.watch(pyqRemoteDataSourceProvider);
  final localDataSource = ref.watch(pyqLocalDataSourceProvider);
  return PyqRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Topic Summaries State Provider
class TopicSummariesState {
  final bool isLoading;
  final String? errorMessage;
  final List<TopicPyqSummary> summaries;

  const TopicSummariesState({
    this.isLoading = true,
    this.errorMessage,
    this.summaries = const [],
  });

  TopicSummariesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TopicPyqSummary>? summaries,
  }) {
    return TopicSummariesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summaries: summaries ?? this.summaries,
    );
  }
}

/// Topic Summaries State Notifier
class TopicSummariesNotifier extends StateNotifier<TopicSummariesState> {
  final PyqRepository _repository;

  TopicSummariesNotifier(this._repository) : super(const TopicSummariesState());

  Future<void> loadTopicSummaries({
    required String examId,
    required String subjectId,
    String? userId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getTopicSummaries(
      examId: examId,
      subjectId: subjectId,
      userId: userId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (summaries) {
        state = state.copyWith(
          isLoading: false,
          summaries: summaries,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Topic Summaries Provider
final topicSummariesProvider = StateNotifierProvider<TopicSummariesNotifier, TopicSummariesState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return TopicSummariesNotifier(repository);
});

/// Questions State Provider
class QuestionsState {
  final bool isLoading;
  final String? errorMessage;
  final List<PyqQuestion> questions;

  const QuestionsState({
    this.isLoading = true,
    this.errorMessage,
    this.questions = const [],
  });

  QuestionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PyqQuestion>? questions,
  }) {
    return QuestionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      questions: questions ?? this.questions,
    );
  }
}

/// Questions State Notifier
class QuestionsNotifier extends StateNotifier<QuestionsState> {
  final PyqRepository _repository;

  QuestionsNotifier(this._repository) : super(const QuestionsState());

  Future<void> loadQuestions({
    required String examId,
    required String subjectId,
    required String topicId,
    String? userId,
    PyqFilter? filter,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getQuestions(
      examId: examId,
      subjectId: subjectId,
      topicId: topicId,
      userId: userId,
      filter: filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (questions) {
        state = state.copyWith(
          isLoading: false,
          questions: questions,
        );
      },
    );
  }

  Future<void> searchQuestions({
    required String examId,
    required String query,
    String? subjectId,
    String? topicId,
    String? userId,
    PyqFilter? filter,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.searchQuestions(
      examId: examId,
      query: query,
      subjectId: subjectId,
      topicId: topicId,
      userId: userId,
      filter: filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (questions) {
        state = state.copyWith(
          isLoading: false,
          questions: questions,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Questions Provider
final questionsProvider = StateNotifierProvider<QuestionsNotifier, QuestionsState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return QuestionsNotifier(repository);
});

/// Session State Provider
class SessionState {
  final bool isLoading;
  final String? errorMessage;
  final PyqSession? session;

  const SessionState({
    this.isLoading = false,
    this.errorMessage,
    this.session,
  });

  SessionState copyWith({
    bool? isLoading,
    String? errorMessage,
    PyqSession? session,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      session: session ?? this.session,
    );
  }
}

/// Session State Notifier
class SessionNotifier extends StateNotifier<SessionState> {
  final PyqRepository _repository;

  SessionNotifier(this._repository) : super(const SessionState());

  Future<void> createSession({
    required String userId,
    required String examId,
    required String subjectId,
    required String topicId,
    required String topicName,
    required SessionMode mode,
    required List<PyqQuestion> questions,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.createSession(
      userId: userId,
      examId: examId,
      subjectId: subjectId,
      topicId: topicId,
      topicName: topicName,
      mode: mode,
      questions: questions,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (session) {
        state = state.copyWith(
          isLoading: false,
          session: session,
        );
      },
    );
  }

  Future<void> updateSession({
    required String sessionId,
    int? currentIndex,
    int? totalCorrect,
    int? totalAnswered,
    int? totalDurationSeconds,
    bool? isCompleted,
    List<QuestionAttempt>? attempts,
    List<String>? flaggedForRevision,
  }) async {
    final result = await _repository.updateSession(
      sessionId: sessionId,
      currentIndex: currentIndex,
      totalCorrect: totalCorrect,
      totalAnswered: totalAnswered,
      totalDurationSeconds: totalDurationSeconds,
      isCompleted: isCompleted,
      attempts: attempts,
      flaggedForRevision: flaggedForRevision,
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedSession) {
        state = state.copyWith(session: updatedSession);
      },
    );
  }

  Future<void> getSession({required String sessionId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getSession(sessionId: sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (session) {
        state = state.copyWith(
          isLoading: false,
          session: session,
        );
      },
    );
  }

  Future<void> getActiveSession({required String userId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getActiveSession(userId: userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (session) {
        state = state.copyWith(
          isLoading: false,
          session: session,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Bookmarked/Incorrect Questions State Provider
/// Shared shape for both the "Bookmarked" and "Retry Incorrect" quick
/// actions on the PYQ home screen — both load a flat list of questions
/// derived from stored local data (bookmarks / attempt history).
class QuestionListState {
  final bool isLoading;
  final String? errorMessage;
  final List<PyqQuestion> questions;

  const QuestionListState({
    this.isLoading = false,
    this.errorMessage,
    this.questions = const [],
  });

  QuestionListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PyqQuestion>? questions,
  }) {
    return QuestionListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      questions: questions ?? this.questions,
    );
  }
}

class BookmarkedQuestionsNotifier extends StateNotifier<QuestionListState> {
  final PyqRepository _repository;

  BookmarkedQuestionsNotifier(this._repository) : super(const QuestionListState());

  Future<void> load({required String userId, required String examId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getBookmarkedQuestions(userId: userId, examId: examId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (questions) => state = state.copyWith(isLoading: false, questions: questions),
    );
  }
}

/// Bookmarked Questions Provider
final bookmarkedQuestionsProvider =
    StateNotifierProvider<BookmarkedQuestionsNotifier, QuestionListState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return BookmarkedQuestionsNotifier(repository);
});

class IncorrectQuestionsNotifier extends StateNotifier<QuestionListState> {
  final PyqRepository _repository;

  IncorrectQuestionsNotifier(this._repository) : super(const QuestionListState());

  Future<void> load({required String userId, required String examId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getIncorrectQuestions(userId: userId, examId: examId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (questions) => state = state.copyWith(isLoading: false, questions: questions),
    );
  }
}

/// Incorrect Questions Provider
final incorrectQuestionsProvider =
    StateNotifierProvider<IncorrectQuestionsNotifier, QuestionListState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return IncorrectQuestionsNotifier(repository);
});

/// Session Provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return SessionNotifier(repository);
});

/// Weak Topics State Provider
class WeakTopicsState {
  final bool isLoading;
  final String? errorMessage;
  final List<TopicPyqSummary> weakTopics;

  const WeakTopicsState({
    this.isLoading = true,
    this.errorMessage,
    this.weakTopics = const [],
  });

  WeakTopicsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TopicPyqSummary>? weakTopics,
  }) {
    return WeakTopicsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      weakTopics: weakTopics ?? this.weakTopics,
    );
  }
}

/// Weak Topics State Notifier
class WeakTopicsNotifier extends StateNotifier<WeakTopicsState> {
  final PyqRepository _repository;

  WeakTopicsNotifier(this._repository) : super(const WeakTopicsState());

  Future<void> loadWeakTopics({
    required String userId,
    required String examId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getWeakTopics(
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
      (weakTopics) {
        state = state.copyWith(
          isLoading: false,
          weakTopics: weakTopics,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Weak Topics Provider
final weakTopicsProvider = StateNotifierProvider<WeakTopicsNotifier, WeakTopicsState>((ref) {
  final repository = ref.watch(pyqRepositoryProvider);
  return WeakTopicsNotifier(repository);
});
