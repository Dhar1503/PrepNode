import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepgraph/core/data/providers/data_providers.dart';
import 'package:prepgraph/core/network/providers/network_providers.dart';
import 'package:prepgraph/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:prepgraph/features/planner/domain/entities/daily_plan.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/domain/entities/study_session.dart';
import 'package:prepgraph/features/planner/domain/entities/weekly_plan.dart';
import 'package:prepgraph/features/planner/domain/repositories/planner_repository.dart';

/// Planner Repository Provider
final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  final remoteDataSource = ref.watch(plannerRemoteDataSourceProvider);
  final localDataSource = ref.watch(plannerLocalDataSourceProvider);
  return PlannerRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Daily Plan State Provider
class DailyPlanState {
  final bool isLoading;
  final String? errorMessage;
  final DailyPlan? dailyPlan;

  const DailyPlanState({
    this.isLoading = true,
    this.errorMessage,
    this.dailyPlan,
  });

  DailyPlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    DailyPlan? dailyPlan,
  }) {
    return DailyPlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dailyPlan: dailyPlan ?? this.dailyPlan,
    );
  }
}

/// Daily Plan State Notifier
class DailyPlanNotifier extends StateNotifier<DailyPlanState> {
  final PlannerRepository _repository;

  DailyPlanNotifier(this._repository) : super(const DailyPlanState());

  Future<void> loadDailyPlan({required String userId, required DateTime date}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getDailyPlan(userId: userId, date: date);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (dailyPlan) {
        state = state.copyWith(
          isLoading: false,
          dailyPlan: dailyPlan,
        );
      },
    );
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final result = await _repository.updateTaskStatus(taskId: taskId, status: status);
    
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedTask) {
        if (state.dailyPlan != null) {
          final updatedTasks = state.dailyPlan!.tasks.map((task) {
            if (task.id == taskId) {
              return updatedTask;
            }
            return task;
          }).toList();
          
          final completedMinutes = updatedTasks
              .where((task) => task.status == TaskStatus.completed)
              .fold(0, (sum, task) => sum + task.durationMinutes);
          
          state = state.copyWith(
            dailyPlan: state.dailyPlan!.copyWith(
              tasks: updatedTasks,
              completedMinutes: completedMinutes,
            ),
          );
        }
      },
    );
  }

  /// Marks a task completed AND persists a real study session for it, so
  /// the activity is immediately visible to Insights/Dashboard the next
  /// time their providers are read. Unlike [updateTaskStatus] (used for
  /// simple status changes like skip), this always writes to study_sessions.
  Future<void> completeTask({
    required String userId,
    required PlannerTask task,
  }) async {
    final statusResult = await _repository.updateTaskStatus(
      taskId: task.id,
      status: TaskStatus.completed,
    );

    statusResult.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return;
      },
      (updatedTask) {
        if (state.dailyPlan != null) {
          final updatedTasks = state.dailyPlan!.tasks.map((t) {
            return t.id == task.id ? updatedTask : t;
          }).toList();
          final completedMinutes = updatedTasks
              .where((t) => t.status == TaskStatus.completed)
              .fold(0, (sum, t) => sum + t.durationMinutes);
          state = state.copyWith(
            dailyPlan: state.dailyPlan!.copyWith(
              tasks: updatedTasks,
              completedMinutes: completedMinutes,
            ),
          );
        }
      },
    );

    final now = DateTime.now();
    await _repository.completeTaskWithSession(
      userId: userId,
      taskId: task.id,
      topicId: task.topicId,
      startTime: now.subtract(Duration(minutes: task.durationMinutes)),
      endTime: now,
      actualDurationMinutes: task.durationMinutes,
      quality: SessionQuality.good,
    );
  }

  Future<void> rescheduleTask({
    required String taskId,
    required DateTime newDate,
  }) async {
    final result = await _repository.rescheduleTask(taskId: taskId, newDate: newDate);
    
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (rescheduledTask) {
        if (state.dailyPlan != null) {
          final updatedTasks = state.dailyPlan!.tasks.map((task) {
            if (task.id == taskId) {
              return rescheduledTask;
            }
            return task;
          }).toList();
          
          state = state.copyWith(
            dailyPlan: state.dailyPlan!.copyWith(tasks: updatedTasks),
          );
        }
      },
    );
  }

  /// Create a new manually-added task and reload the day so it shows up
  /// alongside any adaptive/imported tasks already on the plan.
  Future<void> createTask({
    required String userId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    required DateTime scheduledDate,
    String? reason,
  }) async {
    final result = await _repository.createTask(
      userId: userId,
      topicId: topicId,
      title: title,
      durationMinutes: durationMinutes,
      type: type,
      scheduledDate: scheduledDate,
      reason: reason,
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => loadDailyPlan(userId: userId, date: scheduledDate),
    );
  }

  /// Edit an existing task's details in place, without needing a full
  /// reload of the day (status/date are untouched by an edit).
  Future<void> editTask({
    required String taskId,
    required String topicId,
    required String title,
    required int durationMinutes,
    required TaskType type,
    String? reason,
  }) async {
    final result = await _repository.editTask(
      taskId: taskId,
      topicId: topicId,
      title: title,
      durationMinutes: durationMinutes,
      type: type,
      reason: reason,
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (updatedTask) {
        if (state.dailyPlan != null) {
          final updatedTasks = state.dailyPlan!.tasks.map((task) {
            return task.id == taskId ? updatedTask : task;
          }).toList();
          state = state.copyWith(
            dailyPlan: state.dailyPlan!.copyWith(tasks: updatedTasks),
          );
        }
      },
    );
  }

  /// Permanently remove a task from the plan.
  Future<void> deleteTask(String taskId) async {
    final result = await _repository.deleteTask(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        if (state.dailyPlan != null) {
          final remainingTasks =
              state.dailyPlan!.tasks.where((task) => task.id != taskId).toList();
          final completedMinutes = remainingTasks
              .where((task) => task.status == TaskStatus.completed)
              .fold(0, (sum, task) => sum + task.durationMinutes);
          state = state.copyWith(
            dailyPlan: state.dailyPlan!.copyWith(
              tasks: remainingTasks,
              completedMinutes: completedMinutes,
            ),
          );
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Daily Plan Provider
final dailyPlanProvider = StateNotifierProvider<DailyPlanNotifier, DailyPlanState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return DailyPlanNotifier(repository);
});

/// Weekly Plan State Provider
class WeeklyPlanState {
  final bool isLoading;
  final String? errorMessage;
  final WeeklyPlan? weeklyPlan;

  const WeeklyPlanState({
    this.isLoading = true,
    this.errorMessage,
    this.weeklyPlan,
  });

  WeeklyPlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    WeeklyPlan? weeklyPlan,
  }) {
    return WeeklyPlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
    );
  }
}

/// Weekly Plan State Notifier
class WeeklyPlanNotifier extends StateNotifier<WeeklyPlanState> {
  final PlannerRepository _repository;

  WeeklyPlanNotifier(this._repository) : super(const WeeklyPlanState());

  Future<void> loadWeeklyPlan({required String userId, required DateTime weekStart}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getWeeklyPlan(userId: userId, weekStart: weekStart);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (weeklyPlan) {
        state = state.copyWith(
          isLoading: false,
          weeklyPlan: weeklyPlan,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Weekly Plan Provider
final weeklyPlanProvider = StateNotifierProvider<WeeklyPlanNotifier, WeeklyPlanState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return WeeklyPlanNotifier(repository);
});

/// Study Sessions State Provider
class StudySessionsState {
  final bool isLoading;
  final String? errorMessage;
  final List<StudySession> sessions;

  const StudySessionsState({
    this.isLoading = true,
    this.errorMessage,
    this.sessions = const [],
  });

  StudySessionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<StudySession>? sessions,
  }) {
    return StudySessionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sessions: sessions ?? this.sessions,
    );
  }
}

/// Study Sessions State Notifier
class StudySessionsNotifier extends StateNotifier<StudySessionsState> {
  final PlannerRepository _repository;

  StudySessionsNotifier(this._repository) : super(const StudySessionsState());

  Future<void> loadStudySessions({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getStudySessions(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (sessions) {
        state = state.copyWith(
          isLoading: false,
          sessions: sessions,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Study Sessions Provider
final studySessionsProvider = StateNotifierProvider<StudySessionsNotifier, StudySessionsState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return StudySessionsNotifier(repository);
});

/// Adaptive Plan State Provider
class AdaptivePlanState {
  final bool isLoading;
  final String? errorMessage;
  final DailyPlan? adaptivePlan;

  const AdaptivePlanState({
    this.isLoading = false,
    this.errorMessage,
    this.adaptivePlan,
  });

  AdaptivePlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    DailyPlan? adaptivePlan,
  }) {
    return AdaptivePlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      adaptivePlan: adaptivePlan ?? this.adaptivePlan,
    );
  }
}

/// Adaptive Plan State Notifier
class AdaptivePlanNotifier extends StateNotifier<AdaptivePlanState> {
  final PlannerRepository _repository;

  AdaptivePlanNotifier(this._repository) : super(const AdaptivePlanState());

  Future<void> generateAdaptivePlan({required String userId, required DateTime date}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.generateAdaptivePlan(userId: userId, date: date);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (adaptivePlan) {
        state = state.copyWith(
          isLoading: false,
          adaptivePlan: adaptivePlan,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Adaptive Plan Provider
final adaptivePlanProvider = StateNotifierProvider<AdaptivePlanNotifier, AdaptivePlanState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return AdaptivePlanNotifier(repository);
});

/// Break Suggestion State Provider
class BreakSuggestionState {
  final bool isLoading;
  final String? errorMessage;
  final String? suggestion;

  const BreakSuggestionState({
    this.isLoading = false,
    this.errorMessage,
    this.suggestion,
  });

  BreakSuggestionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? suggestion,
  }) {
    return BreakSuggestionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      suggestion: suggestion ?? this.suggestion,
    );
  }
}

/// Break Suggestion State Notifier
class BreakSuggestionNotifier extends StateNotifier<BreakSuggestionState> {
  final PlannerRepository _repository;

  BreakSuggestionNotifier(this._repository) : super(const BreakSuggestionState());

  Future<void> getBreakSuggestion({
    required String userId,
    required int consecutiveStudyMinutes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _repository.getBreakSuggestion(
      userId: userId,
      consecutiveStudyMinutes: consecutiveStudyMinutes,
    );
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (suggestion) {
        state = state.copyWith(
          isLoading: false,
          suggestion: suggestion,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Break Suggestion Provider
final breakSuggestionProvider = StateNotifierProvider<BreakSuggestionNotifier, BreakSuggestionState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return BreakSuggestionNotifier(repository);
});
