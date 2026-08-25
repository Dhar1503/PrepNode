import '../dtos/planning_dto.dart';

// Task types and statuses (matching domain entities)
enum TaskType {
  learn,
  pyq,
  revision,
  break_,
  mockTest,
}

enum TaskStatus {
  pending,
  completed,
  skipped,
  inProgress,
}

/// Mapping extensions for Planner entities

extension StudyPlanDtoMapping on StudyPlanDto {
  /// Convert StudyPlanDto to Domain PlannerTask entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'id': planId,
      'userId': userId,
      'topicId': topicId,
      'date': date,
      'title': title,
      'durationMinutes': durationMinutes,
      'type': type,
      'priority': priority,
      'reason': reason,
      'status': status,
    };
  }
}

