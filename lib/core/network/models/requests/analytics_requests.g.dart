// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfidenceCheckinRequest _$ConfidenceCheckinRequestFromJson(
  Map<String, dynamic> json,
) => ConfidenceCheckinRequest(
  topicId: json['topicId'] as String,
  confidenceLevel: (json['confidenceLevel'] as num).toInt(),
);

Map<String, dynamic> _$ConfidenceCheckinRequestToJson(
  ConfidenceCheckinRequest instance,
) => <String, dynamic>{
  'topicId': instance.topicId,
  'confidenceLevel': instance.confidenceLevel,
};
