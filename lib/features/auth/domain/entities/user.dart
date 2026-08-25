/// User Entity
/// Represents a user in the system
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? examId;
  final DateTime? targetDate;
  final int? dailyStudyHours;
  final String? preparationLevel;
  final bool profileComplete;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.examId,
    this.targetDate,
    this.dailyStudyHours,
    this.preparationLevel,
    required this.profileComplete,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
    bool? profileComplete,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      examId: examId ?? this.examId,
      targetDate: targetDate ?? this.targetDate,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      preparationLevel: preparationLevel ?? this.preparationLevel,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }
}
