/// Data Transfer Objects for Engagement-related entities
/// Achievements, Bookmarks
library;

class AchievementDto {
  final String achievementId;
  final String userId;
  final String achievementType;
  final String title;
  final String description;
  final String? relatedTopicId;
  final DateTime unlockedAt;
  final bool seen;

  AchievementDto({
    required this.achievementId,
    required this.userId,
    required this.achievementType,
    required this.title,
    required this.description,
    this.relatedTopicId,
    required this.unlockedAt,
    required this.seen,
  });

  factory AchievementDto.fromJson(Map<String, dynamic> json) {
    return AchievementDto(
      achievementId: json['achievementId'] as String,
      userId: json['userId'] as String,
      achievementType: json['achievementType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      relatedTopicId: json['relatedTopicId'] as String?,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      seen: json['seen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'userId': userId,
      'achievementType': achievementType,
      'title': title,
      'description': description,
      'relatedTopicId': relatedTopicId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'seen': seen,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': achievementId,
      'userId': userId,
      'achievementType': achievementType,
      'title': title,
      'description': description,
      'relatedTopicId': relatedTopicId,
      'unlockedAt': unlockedAt,
      'seen': seen,
    };
  }
}

class BookmarkDto {
  final String bookmarkId;
  final String userId;
  final String entityType;
  final String entityId;
  final DateTime createdAt;

  BookmarkDto({
    required this.bookmarkId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });

  factory BookmarkDto.fromJson(Map<String, dynamic> json) {
    return BookmarkDto(
      bookmarkId: json['bookmarkId'] as String,
      userId: json['userId'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmarkId': bookmarkId,
      'userId': userId,
      'entityType': entityType,
      'entityId': entityId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'id': bookmarkId,
      'userId': userId,
      'entityType': entityType,
      'entityId': entityId,
      'createdAt': createdAt,
    };
  }
}
