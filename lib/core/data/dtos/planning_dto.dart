/// Data Transfer Objects for Planning & Progress-related entities
/// StudyPlans, UserTopicProgress, ConfidenceCheckins
library;

class StudyPlanDto {
  final String planId;
  final String userId;
  final String topicId;
  final DateTime date;
  final String title;
  final int durationMinutes;
  final String type;
  final String priority;
  final String? reason;
  final String status;

  StudyPlanDto({
    required this.planId,
    required this.userId,
    required this.topicId,
    required this.date,
    required this.title,
    required this.durationMinutes,
    required this.type,
    required this.priority,
    this.reason,
    required this.status,
  });

  factory StudyPlanDto.fromJson(Map<String, dynamic> json) {
    return StudyPlanDto(
      planId: json['planId'] as String,
      userId: json['userId'] as String,
      topicId: json['topicId'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as int,
      type: json['type'] as String,
      priority: json['priority'] as String? ?? 'medium',
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'userId': userId,
      'topicId': topicId,
      'date': date.toIso8601String(),
      'title': title,
      'durationMinutes': durationMinutes,
      'type': type,
      'priority': priority,
      'reason': reason,
      'status': status,
    };
  }
}

class UserTopicProgressDto {
  final String progressId;
  final String userId;
  final String topicId;
  final double masteryPercentage;
  final double? accuracy;
  final DateTime? lastRevisionDate;

  UserTopicProgressDto({
    required this.progressId,
    required this.userId,
    required this.topicId,
    required this.masteryPercentage,
    this.accuracy,
    this.lastRevisionDate,
  });

  factory UserTopicProgressDto.fromJson(Map<String, dynamic> json) {
    return UserTopicProgressDto(
      progressId: json['progressId'] as String,
      userId: json['userId'] as String,
      topicId: json['topicId'] as String,
      masteryPercentage: (json['masteryPercentage'] as num).toDouble(),
      accuracy: json['accuracy'] != null 
          ? (json['accuracy'] as num).toDouble() 
          : null,
      lastRevisionDate: json['lastRevisionDate'] != null 
          ? DateTime.parse(json['lastRevisionDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId,
      'userId': userId,
      'topicId': topicId,
      'masteryPercentage': masteryPercentage,
      'accuracy': accuracy,
      'lastRevisionDate': lastRevisionDate?.toIso8601String(),
    };
  }
}

class ConfidenceCheckinDto {
  final String checkinId;
  final String userId;
  final String topicId;
  final int confidenceLevel;
  final DateTime weekOf;

  ConfidenceCheckinDto({
    required this.checkinId,
    required this.userId,
    required this.topicId,
    required this.confidenceLevel,
    required this.weekOf,
  });

  factory ConfidenceCheckinDto.fromJson(Map<String, dynamic> json) {
    return ConfidenceCheckinDto(
      checkinId: json['checkinId'] as String,
      userId: json['userId'] as String,
      topicId: json['topicId'] as String,
      confidenceLevel: json['confidenceLevel'] as int,
      weekOf: DateTime.parse(json['weekOf'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkinId': checkinId,
      'userId': userId,
      'topicId': topicId,
      'confidenceLevel': confidenceLevel,
      'weekOf': weekOf.toIso8601String(),
    };
  }
}
