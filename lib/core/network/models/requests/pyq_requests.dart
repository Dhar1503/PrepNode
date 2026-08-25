/// PYQ Request Models
library;

import 'package:json_annotation/json_annotation.dart';

part 'pyq_requests.g.dart';

@JsonSerializable()
class SubmitAttemptRequest {
  final String attemptId;
  final String questionId;
  final String selectedAnswer;
  final int timeTakenSeconds;

  SubmitAttemptRequest({
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswer,
    required this.timeTakenSeconds,
  });

  factory SubmitAttemptRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitAttemptRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitAttemptRequestToJson(this);
}
