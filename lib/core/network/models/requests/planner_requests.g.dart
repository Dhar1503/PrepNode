// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratePlanRequest _$GeneratePlanRequestFromJson(Map<String, dynamic> json) =>
    GeneratePlanRequest(userId: json['userId'] as String);

Map<String, dynamic> _$GeneratePlanRequestToJson(
  GeneratePlanRequest instance,
) => <String, dynamic>{'userId': instance.userId};

UpdateTaskStatusRequest _$UpdateTaskStatusRequestFromJson(
  Map<String, dynamic> json,
) => UpdateTaskStatusRequest(
  taskId: json['taskId'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$UpdateTaskStatusRequestToJson(
  UpdateTaskStatusRequest instance,
) => <String, dynamic>{'taskId': instance.taskId, 'status': instance.status};

RescheduleTaskRequest _$RescheduleTaskRequestFromJson(
  Map<String, dynamic> json,
) => RescheduleTaskRequest(
  taskId: json['taskId'] as String,
  newDate: json['newDate'] as String,
);

Map<String, dynamic> _$RescheduleTaskRequestToJson(
  RescheduleTaskRequest instance,
) => <String, dynamic>{'taskId': instance.taskId, 'newDate': instance.newDate};
