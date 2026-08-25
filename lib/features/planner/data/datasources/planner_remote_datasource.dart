/// Planner Remote Data Source
/// Handles all API calls for planner data
library;

import 'package:prepgraph/core/network/api_client.dart';
import 'package:prepgraph/core/network/api_constants.dart';
import 'package:prepgraph/core/network/models/requests/planner_requests.dart';
import 'package:prepgraph/core/network/models/api_response.dart';
import 'package:prepgraph/features/planner/domain/entities/daily_plan.dart';
import 'package:prepgraph/features/planner/domain/entities/planner_task.dart';
import 'package:prepgraph/features/planner/domain/entities/weekly_plan.dart';

class PlannerRemoteDataSource {
  final ApiClient _apiClient;

  PlannerRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Get daily plan for a specific date
  Future<DailyPlan> getDailyPlan({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/daily?userId=$userId&date=${date.toIso8601String()}',
    );

    final planData = response.data!;
    final data = planData['data'] as Map<String, dynamic>;

    final tasksData = data['tasks'] as List<dynamic>;
    final tasks = tasksData.map((taskData) {
      return PlannerTask(
        id: taskData['taskId'] as String,
        topicId: taskData['topicId'] as String,
        title: taskData['title'] as String,
        durationMinutes: taskData['durationMinutes'] as int,
        reason: taskData['reason'] as String? ?? '',
        type: _mapTaskType(taskData['type'] as String),
        status: _mapTaskStatus(taskData['status'] as String),
        scheduledDate: DateTime.parse(taskData['scheduledDate'] as String),
        order: taskData['order'] as int? ?? 0,
      );
    }).toList();

    return DailyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      tasks: tasks,
      totalStudyMinutes: data['totalStudyMinutes'] as int? ?? 0,
      completedMinutes: data['completedMinutes'] as int? ?? 0,
    );
  }

  /// Get weekly plan
  Future<WeeklyPlan> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/weekly?userId=$userId&weekStart=${weekStart.toIso8601String()}',
    );

    final planData = response.data!;
    final data = planData['data'] as Map<String, dynamic>;

    final dailyPlansData = data['dailyPlans'] as List<dynamic>;
    final dailyPlansMap = <DateTime, DailyPlan>{};
    var totalTasksCount = 0;
    var completedTasksCount = 0;
    
    for (final dayData in dailyPlansData) {
      final date = DateTime.parse(dayData['date'] as String);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final tasksData = dayData['tasks'] as List<dynamic>;
      final tasks = tasksData.map((taskData) {
        return PlannerTask(
          id: taskData['taskId'] as String,
          topicId: taskData['topicId'] as String,
          title: taskData['title'] as String,
          durationMinutes: taskData['durationMinutes'] as int,
          reason: taskData['reason'] as String? ?? '',
          type: _mapTaskType(taskData['type'] as String),
          status: _mapTaskStatus(taskData['status'] as String),
          scheduledDate: date,
          order: taskData['order'] as int? ?? 0,
        );
      }).toList();
      
      totalTasksCount += tasks.length;
      completedTasksCount += tasks.where((t) => t.status == TaskStatus.completed).length;

      dailyPlansMap[normalizedDate] = DailyPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        tasks: tasks,
        totalStudyMinutes: dayData['totalStudyMinutes'] as int? ?? 0,
        completedMinutes: dayData['completedMinutes'] as int? ?? 0,
      );
    }

    final weekEnd = weekStart.add(const Duration(days: 6));
    return WeeklyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailyPlans: dailyPlansMap,
      totalStudyMinutes: data['totalStudyMinutes'] as int? ?? 0,
      completedMinutes: data['completedMinutes'] as int? ?? 0,
      totalTasks: totalTasksCount,
      completedTasks: completedTasksCount,
    );
  }

  /// Update task status
  Future<PlannerTask> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final request = UpdateTaskStatusRequest(taskId: taskId, status: status.name);
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/tasks/$taskId/status',
      data: request.toJson(),
    );

    final taskData = response.data!;
    final data = taskData['data'] as Map<String, dynamic>;

    return PlannerTask(
      id: data['taskId'] as String,
      topicId: data['topicId'] as String,
      title: data['title'] as String,
      durationMinutes: data['durationMinutes'] as int,
      reason: data['reason'] as String? ?? '',
      type: _mapTaskType(data['type'] as String),
      status: _mapTaskStatus(data['status'] as String),
      scheduledDate: DateTime.parse(data['scheduledDate'] as String),
      order: data['order'] as int? ?? 0,
    );
  }

  /// Reschedule task to new date
  Future<PlannerTask> rescheduleTask({
    required String taskId,
    required DateTime newDate,
  }) async {
    final request = RescheduleTaskRequest(taskId: taskId, newDate: newDate.toIso8601String());
    final response = await _apiClient.patch<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/tasks/$taskId/reschedule',
      data: request.toJson(),
    );

    final taskData = response.data!;
    final data = taskData['data'] as Map<String, dynamic>;

    return PlannerTask(
      id: data['taskId'] as String,
      topicId: data['topicId'] as String,
      title: data['title'] as String,
      durationMinutes: data['durationMinutes'] as int,
      reason: data['reason'] as String? ?? '',
      type: _mapTaskType(data['type'] as String),
      status: _mapTaskStatus(data['status'] as String),
      scheduledDate: DateTime.parse(data['scheduledDate'] as String),
      order: data['order'] as int? ?? 0,
    );
  }

  /// Generate adaptive plan
  Future<DailyPlan> generateAdaptivePlan({
    required String userId,
    required DateTime date,
  }) async {
    final request = GeneratePlanRequest(userId: userId);
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/generate',
      data: request.toJson(),
    );

    final planData = response.data!;
    final data = planData['data'] as Map<String, dynamic>;

    final tasksData = data['tasks'] as List<dynamic>;
    final tasks = tasksData.map((taskData) {
      return PlannerTask(
        id: taskData['taskId'] as String,
        topicId: taskData['topicId'] as String,
        title: taskData['title'] as String,
        durationMinutes: taskData['durationMinutes'] as int,
        reason: taskData['reason'] as String? ?? '',
        type: _mapTaskType(taskData['type'] as String),
        status: _mapTaskStatus(taskData['status'] as String),
        scheduledDate: DateTime.parse(taskData['scheduledDate'] as String),
        order: taskData['order'] as int? ?? 0,
      );
    }).toList();

    return DailyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      tasks: tasks,
      totalStudyMinutes: data['totalStudyMinutes'] as int? ?? 0,
      completedMinutes: data['completedMinutes'] as int? ?? 0,
    );
  }

  /// Get break suggestion
  Future<String> getBreakSuggestion({
    required String userId,
    required int consecutiveStudyMinutes,
  }) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.planner}/break-suggestion?userId=$userId&consecutiveMinutes=$consecutiveStudyMinutes',
    );

    final data = response.data!;
    return data['data']['suggestion'] as String;
  }

  // Helper methods for mapping

  TaskType _mapTaskType(String type) {
    switch (type.toLowerCase()) {
      case 'learn':
        return TaskType.learn;
      case 'pyq':
        return TaskType.pyq;
      case 'revision':
        return TaskType.revision;
      case 'break':
        return TaskType.break_;
      case 'mock_test':
        return TaskType.mockTest;
      default:
        return TaskType.learn;
    }
  }

  TaskStatus _mapTaskStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'skipped':
        return TaskStatus.skipped;
      default:
        return TaskStatus.pending;
    }
  }
}
