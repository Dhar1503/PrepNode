// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_test_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartTestRequest _$StartTestRequestFromJson(Map<String, dynamic> json) =>
    StartTestRequest(
      examId: json['examId'] as String,
      type: json['type'] as String,
      subjectId: json['subjectId'] as String?,
      topicId: json['topicId'] as String?,
    );

Map<String, dynamic> _$StartTestRequestToJson(StartTestRequest instance) =>
    <String, dynamic>{
      'examId': instance.examId,
      'type': instance.type,
      'subjectId': instance.subjectId,
      'topicId': instance.topicId,
    };

SubmitTestRequest _$SubmitTestRequestFromJson(Map<String, dynamic> json) =>
    SubmitTestRequest(
      answers: (json['answers'] as List<dynamic>)
          .map((e) => TestAnswerRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmitTestRequestToJson(SubmitTestRequest instance) =>
    <String, dynamic>{'answers': instance.answers};

TestAnswerRequest _$TestAnswerRequestFromJson(Map<String, dynamic> json) =>
    TestAnswerRequest(
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
    );

Map<String, dynamic> _$TestAnswerRequestToJson(TestAnswerRequest instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedAnswer': instance.selectedAnswer,
    };
