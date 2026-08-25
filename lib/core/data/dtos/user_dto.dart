/// Data Transfer Objects for User-related entities
/// These represent the database models and are used for data layer operations
library;

class UserDto {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? examId;
  final DateTime? targetDate;
  final int? dailyStudyHours;
  final String? preparationLevel;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime? deletedAt;

  UserDto({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.examId,
    this.targetDate,
    this.dailyStudyHours,
    this.preparationLevel,
    required this.profileComplete,
    required this.createdAt,
    this.lastLogin,
    this.deletedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      examId: json['examId'] as String?,
      targetDate: json['targetDate'] != null 
          ? DateTime.parse(json['targetDate'] as String) 
          : null,
      dailyStudyHours: json['dailyStudyHours'] as int?,
      preparationLevel: json['preparationLevel'] as String?,
      profileComplete: json['profileComplete'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'examId': examId,
      'targetDate': targetDate?.toIso8601String(),
      'dailyStudyHours': dailyStudyHours,
      'preparationLevel': preparationLevel,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  UserDto copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
    bool? profileComplete,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? deletedAt,
  }) {
    return UserDto(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      examId: examId ?? this.examId,
      targetDate: targetDate ?? this.targetDate,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      preparationLevel: preparationLevel ?? this.preparationLevel,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class UserPreferenceDto {
  final String preferenceId;
  final String userId;
  final String themeMode;
  final bool dailyReminderEnabled;
  final bool revisionAlertsEnabled;
  final bool milestoneUpdatesEnabled;

  UserPreferenceDto({
    required this.preferenceId,
    required this.userId,
    required this.themeMode,
    required this.dailyReminderEnabled,
    required this.revisionAlertsEnabled,
    required this.milestoneUpdatesEnabled,
  });

  factory UserPreferenceDto.fromJson(Map<String, dynamic> json) {
    return UserPreferenceDto(
      preferenceId: json['preferenceId'] as String,
      userId: json['userId'] as String,
      themeMode: json['themeMode'] as String? ?? 'system',
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
      revisionAlertsEnabled: json['revisionAlertsEnabled'] as bool? ?? true,
      milestoneUpdatesEnabled: json['milestoneUpdatesEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferenceId': preferenceId,
      'userId': userId,
      'themeMode': themeMode,
      'dailyReminderEnabled': dailyReminderEnabled,
      'revisionAlertsEnabled': revisionAlertsEnabled,
      'milestoneUpdatesEnabled': milestoneUpdatesEnabled,
    };
  }

  UserPreferenceDto copyWith({
    String? preferenceId,
    String? userId,
    String? themeMode,
    bool? dailyReminderEnabled,
    bool? revisionAlertsEnabled,
    bool? milestoneUpdatesEnabled,
  }) {
    return UserPreferenceDto(
      preferenceId: preferenceId ?? this.preferenceId,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      revisionAlertsEnabled: revisionAlertsEnabled ?? this.revisionAlertsEnabled,
      milestoneUpdatesEnabled: milestoneUpdatesEnabled ?? this.milestoneUpdatesEnabled,
    );
  }
}
