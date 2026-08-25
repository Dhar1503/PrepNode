// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  name: json['name'] as String?,
  examId: json['examId'] as String?,
  targetDate: json['targetDate'] as String?,
  dailyStudyHours: (json['dailyStudyHours'] as num?)?.toInt(),
  preparationLevel: json['preparationLevel'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'examId': instance.examId,
  'targetDate': instance.targetDate,
  'dailyStudyHours': instance.dailyStudyHours,
  'preparationLevel': instance.preparationLevel,
};

UpdatePreferencesRequest _$UpdatePreferencesRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePreferencesRequest(
  themeMode: json['themeMode'] as String?,
  dailyReminderEnabled: json['dailyReminderEnabled'] as bool?,
  revisionAlertsEnabled: json['revisionAlertsEnabled'] as bool?,
  milestoneUpdatesEnabled: json['milestoneUpdatesEnabled'] as bool?,
  plannerRemindersEnabled: json['plannerRemindersEnabled'] as bool?,
  mockTestRemindersEnabled: json['mockTestRemindersEnabled'] as bool?,
  studyStreakRemindersEnabled: json['studyStreakRemindersEnabled'] as bool?,
  resourceRecommendationsEnabled:
      json['resourceRecommendationsEnabled'] as bool?,
  aiRecommendationsEnabled: json['aiRecommendationsEnabled'] as bool?,
  cutoffAlertsEnabled: json['cutoffAlertsEnabled'] as bool?,
);

Map<String, dynamic> _$UpdatePreferencesRequestToJson(
  UpdatePreferencesRequest instance,
) => <String, dynamic>{
  'themeMode': instance.themeMode,
  'dailyReminderEnabled': instance.dailyReminderEnabled,
  'revisionAlertsEnabled': instance.revisionAlertsEnabled,
  'milestoneUpdatesEnabled': instance.milestoneUpdatesEnabled,
  'plannerRemindersEnabled': instance.plannerRemindersEnabled,
  'mockTestRemindersEnabled': instance.mockTestRemindersEnabled,
  'studyStreakRemindersEnabled': instance.studyStreakRemindersEnabled,
  'resourceRecommendationsEnabled': instance.resourceRecommendationsEnabled,
  'aiRecommendationsEnabled': instance.aiRecommendationsEnabled,
  'cutoffAlertsEnabled': instance.cutoffAlertsEnabled,
};

DeleteAccountRequest _$DeleteAccountRequestFromJson(
  Map<String, dynamic> json,
) => DeleteAccountRequest(
  confirmationPassword: json['confirmationPassword'] as String,
);

Map<String, dynamic> _$DeleteAccountRequestToJson(
  DeleteAccountRequest instance,
) => <String, dynamic>{'confirmationPassword': instance.confirmationPassword};
