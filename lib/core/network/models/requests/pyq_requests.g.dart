// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pyq_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitAttemptRequest _$SubmitAttemptRequestFromJson(
  Map<String, dynamic> json,
) => SubmitAttemptRequest(
  attemptId: json['attemptId'] as String,
  questionId: json['questionId'] as String,
  selectedAnswer: json['selectedAnswer'] as String,
  timeTakenSeconds: (json['timeTakenSeconds'] as num).toInt(),
);

Map<String, dynamic> _$SubmitAttemptRequestToJson(
  SubmitAttemptRequest instance,
) => <String, dynamic>{
  'attemptId': instance.attemptId,
  'questionId': instance.questionId,
  'selectedAnswer': instance.selectedAnswer,
  'timeTakenSeconds': instance.timeTakenSeconds,
};
