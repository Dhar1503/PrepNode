/// Mock Test Request Models
library;

import 'package:json_annotation/json_annotation.dart';

part 'mock_test_requests.g.dart';

@JsonSerializable()
class StartTestRequest {
  final String examId;
  final String type;
  final String? subjectId;
  final String? topicId;

  StartTestRequest({
    required this.examId,
    required this.type,
    this.subjectId,
    this.topicId,
  });

  factory StartTestRequest.fromJson(Map<String, dynamic> json) =>
      _$StartTestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StartTestRequestToJson(this);
}

@JsonSerializable()
class SubmitTestRequest {
  final List<TestAnswerRequest> answers;

  SubmitTestRequest({
    required this.answers,
  });

  factory SubmitTestRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitTestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitTestRequestToJson(this);
}

@JsonSerializable()
class TestAnswerRequest {
  final String questionId;
  final String selectedAnswer;

  TestAnswerRequest({
    required this.questionId,
    required this.selectedAnswer,
  });

  factory TestAnswerRequest.fromJson(Map<String, dynamic> json) =>
      _$TestAnswerRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TestAnswerRequestToJson(this);
}
