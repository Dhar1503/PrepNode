/// DTO Mapper Utilities
/// Converts API responses to DTOs
library;

import 'package:prepnode/core/data/dtos/content_dto.dart';
import 'package:prepnode/core/data/dtos/engagement_dto.dart';
import 'package:prepnode/core/data/dtos/planning_dto.dart';
import 'package:prepnode/core/data/dtos/user_dto.dart';

class DtoMapper {
  // User DTO Mappers
  static UserDto toUserDto(Map<String, dynamic> userData) {
    return UserDto(
      userId: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      avatarUrl: userData['avatarUrl'] as String?,
      examId: userData['examId'] as String?,
      targetDate: userData['targetDate'] != null 
          ? DateTime.parse(userData['targetDate'] as String) 
          : null,
      dailyStudyHours: userData['dailyStudyHours'] as int?,
      preparationLevel: userData['preparationLevel'] as String?,
      profileComplete: userData['profileComplete'] as bool? ?? false,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // User Topic Progress DTO Mapper
  static UserTopicProgressDto toUserTopicProgressDto(
      Map<String, dynamic> progressData) {
    return UserTopicProgressDto(
      progressId: progressData['progressId'] as String,
      userId: progressData['userId'] as String,
      topicId: progressData['topicId'] as String,
      masteryPercentage: (progressData['masteryPercentage'] as num).toDouble(),
      accuracy: progressData['accuracy'] != null
          ? (progressData['accuracy'] as num).toDouble()
          : null,
      lastRevisionDate: progressData['lastRevisionDate'] != null
          ? DateTime.parse(progressData['lastRevisionDate'] as String)
          : null,
    );
  }

  // Study Plan DTO Mapper
  static StudyPlanDto toStudyPlanDto(Map<String, dynamic> planData) {
    return StudyPlanDto(
      planId: planData['planId'] as String,
      userId: planData['userId'] as String,
      topicId: planData['topicId'] as String,
      date: DateTime.parse(planData['date'] as String),
      title: planData['title'] as String,
      durationMinutes: planData['durationMinutes'] as int,
      type: planData['type'] as String,
      priority: planData['priority'] as String? ?? 'medium',
      reason: planData['reason'] as String?,
      status: planData['status'] as String? ?? 'pending',
    );
  }

  // Achievement DTO Mapper
  static AchievementDto toAchievementDto(Map<String, dynamic> achievementData) {
    return AchievementDto(
      achievementId: achievementData['achievementId'] as String,
      userId: achievementData['userId'] as String,
      achievementType: achievementData['achievementType'] as String,
      title: achievementData['title'] as String,
      description: achievementData['description'] as String,
      relatedTopicId: achievementData['relatedTopicId'] as String?,
      unlockedAt: DateTime.parse(achievementData['unlockedAt'] as String),
      seen: achievementData['seen'] as bool? ?? false,
    );
  }

  // Bookmark DTO Mapper
  static BookmarkDto toBookmarkDto(Map<String, dynamic> bookmarkData) {
    return BookmarkDto(
      bookmarkId: bookmarkData['bookmarkId'] as String,
      userId: bookmarkData['userId'] as String,
      entityType: bookmarkData['entityType'] as String,
      entityId: bookmarkData['entityId'] as String,
      createdAt: DateTime.parse(bookmarkData['createdAt'] as String),
    );
  }

  // Exam DTO Mapper
  static ExamDto toExamDto(Map<String, dynamic> examData) {
    return ExamDto(
      examId: examData['id'] as String,
      examName: examData['name'] as String,
      description: examData['description'] as String?,
      conductingBody: examData['conductingBody'] as String?,
      comingSoon: examData['comingSoon'] as bool? ?? false,
      createdAt: examData['createdAt'] != null
          ? DateTime.parse(examData['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Subject DTO Mapper
  static SubjectDto toSubjectDto(Map<String, dynamic> subjectData) {
    return SubjectDto(
      subjectId: subjectData['id'] as String,
      examId: subjectData['examId'] as String,
      subjectName: subjectData['subjectName'] as String,
      importanceWeight: (subjectData['importanceWeight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Topic DTO Mapper
  static TopicDto toTopicDto(Map<String, dynamic> topicData) {
    return TopicDto(
      topicId: topicData['id'] as String,
      subjectId: topicData['subjectId'] as String,
      parentTopicId: topicData['parentTopicId'] as String?,
      topicName: topicData['topicName'] as String,
      difficulty: topicData['difficulty'] as String? ?? 'medium',
      importanceScore: (topicData['importanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
