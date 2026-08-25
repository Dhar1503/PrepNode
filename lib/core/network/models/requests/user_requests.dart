/// User Request Models
library;

import 'package:json_annotation/json_annotation.dart';

part 'user_requests.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  final String? name;
  final String? examId;
  final String? targetDate;
  final int? dailyStudyHours;
  final String? preparationLevel;

  UpdateProfileRequest({
    this.name,
    this.examId,
    this.targetDate,
    this.dailyStudyHours,
    this.preparationLevel,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class UpdatePreferencesRequest {
  final String? themeMode;
  final bool? dailyReminderEnabled;
  final bool? revisionAlertsEnabled;
  final bool? milestoneUpdatesEnabled;
  final bool? plannerRemindersEnabled;
  final bool? mockTestRemindersEnabled;
  final bool? studyStreakRemindersEnabled;
  final bool? resourceRecommendationsEnabled;
  final bool? aiRecommendationsEnabled;
  final bool? cutoffAlertsEnabled;

  UpdatePreferencesRequest({
    this.themeMode,
    this.dailyReminderEnabled,
    this.revisionAlertsEnabled,
    this.milestoneUpdatesEnabled,
    this.plannerRemindersEnabled,
    this.mockTestRemindersEnabled,
    this.studyStreakRemindersEnabled,
    this.resourceRecommendationsEnabled,
    this.aiRecommendationsEnabled,
    this.cutoffAlertsEnabled,
  });

  factory UpdatePreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePreferencesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePreferencesRequestToJson(this);
}

@JsonSerializable()
class DeleteAccountRequest {
  final String confirmationPassword;

  DeleteAccountRequest({
    required this.confirmationPassword,
  });

  factory DeleteAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountRequestToJson(this);
}
