/// Planner Request Models
library;

import 'package:json_annotation/json_annotation.dart';

part 'planner_requests.g.dart';

@JsonSerializable()
class GeneratePlanRequest {
  final String userId;

  GeneratePlanRequest({
    required this.userId,
  });

  factory GeneratePlanRequest.fromJson(Map<String, dynamic> json) =>
      _$GeneratePlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratePlanRequestToJson(this);
}

@JsonSerializable()
class UpdateTaskStatusRequest {
  final String taskId;
  final String status;

  UpdateTaskStatusRequest({
    required this.taskId,
    required this.status,
  });

  factory UpdateTaskStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTaskStatusRequestToJson(this);
}

@JsonSerializable()
class RescheduleTaskRequest {
  final String taskId;
  final String newDate;

  RescheduleTaskRequest({
    required this.taskId,
    required this.newDate,
  });

  factory RescheduleTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$RescheduleTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RescheduleTaskRequestToJson(this);
}
