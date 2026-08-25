import '../dtos/user_dto.dart';

/// Mapping extensions for User entities
/// Note: Domain entity mapping will be added when domain entities are available
extension UserDtoMapping on UserDto {
  /// Convert UserDto to Domain User entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'profileComplete': profileComplete,
    };
  }
}

