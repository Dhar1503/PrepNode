/// Analytics Request Models
library;

import 'package:json_annotation/json_annotation.dart';

part 'analytics_requests.g.dart';

@JsonSerializable()
class ConfidenceCheckinRequest {
  final String topicId;
  final int confidenceLevel;

  ConfidenceCheckinRequest({
    required this.topicId,
    required this.confidenceLevel,
  });

  factory ConfidenceCheckinRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfidenceCheckinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfidenceCheckinRequestToJson(this);
}
