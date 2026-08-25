/// Learner Profile Entity
/// Represents the user's exam preparation profile
class LearnerProfile {
  final String? examId;
  final DateTime? targetDate;
  final int? dailyStudyHours;
  final PreparationLevel? preparationLevel;
  final String? preferredLanguage;
  final List<String>? strongSubjects;
  final List<String>? weakSubjects;
  final bool notificationsEnabled;

  const LearnerProfile({
    this.examId,
    this.targetDate,
    this.dailyStudyHours,
    this.preparationLevel,
    this.preferredLanguage,
    this.strongSubjects,
    this.weakSubjects,
    this.notificationsEnabled = true,
  });

  LearnerProfile copyWith({
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    PreparationLevel? preparationLevel,
    String? preferredLanguage,
    List<String>? strongSubjects,
    List<String>? weakSubjects,
    bool? notificationsEnabled,
  }) {
    return LearnerProfile(
      examId: examId ?? this.examId,
      targetDate: targetDate ?? this.targetDate,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      preparationLevel: preparationLevel ?? this.preparationLevel,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      strongSubjects: strongSubjects ?? this.strongSubjects,
      weakSubjects: weakSubjects ?? this.weakSubjects,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  bool get isComplete =>
      examId != null &&
      targetDate != null &&
      dailyStudyHours != null &&
      preparationLevel != null;
}

enum PreparationLevel {
  beginner,
  intermediate,
  advanced,
}

extension PreparationLevelExtension on PreparationLevel {
  String get displayName {
    switch (this) {
      case PreparationLevel.beginner:
        return 'Beginner';
      case PreparationLevel.intermediate:
        return 'Intermediate';
      case PreparationLevel.advanced:
        return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case PreparationLevel.beginner:
        return 'Just starting out';
      case PreparationLevel.intermediate:
        return 'Some preparation done';
      case PreparationLevel.advanced:
        return 'Well-prepared';
    }
  }
}
