import '../datasources/user_local_datasource.dart';
import '../dtos/user_dto.dart';
import '../result.dart';
import 'base_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository for User-related operations
/// Implements Repository pattern with local data source
class UserRepository extends BaseRepositoryImpl {
  final UserLocalDataSource _localDataSource;

  UserRepository(this._localDataSource);

  /// Get user by ID
  Future<Result<UserDto>> getUserById(String userId) async {
    try {
      return await _localDataSource.getUserById(userId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get user by email
  Future<Result<UserDto>> getUserByEmail(String email) async {
    try {
      return await _localDataSource.getUserByEmail(email);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create user
  Future<Result<UserDto>> createUser({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = const Uuid().v4();
      final dto = UserDto(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        profileComplete: false,
        createdAt: DateTime.now(),
      );

      final result = await _localDataSource.upsertUser(dto);
      return result;
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update user profile
  Future<Result<UserDto>> updateUserProfile({
    required String userId,
    String? name,
    String? avatarUrl,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
  }) async {
    try {
      return await _localDataSource.updateUserProfile(
        userId,
        name: name,
        avatarUrl: avatarUrl,
        examId: examId,
        targetDate: targetDate,
        dailyStudyHours: dailyStudyHours,
        preparationLevel: preparationLevel,
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update last login timestamp
  Future<Result<void>> updateLastLogin(String userId) async {
    try {
      return await _localDataSource.updateLastLogin(userId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get user preferences
  Future<Result<UserPreferenceDto>> getUserPreferences(String userId) async {
    try {
      return await _localDataSource.getUserPreferences(userId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update user preferences
  Future<Result<void>> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      // Get existing preferences first
      final existingResult = await _localDataSource.getUserPreferences(userId);
      
      return existingResult.fold(
        onSuccess: (existing) {
          final updated = UserPreferenceDto(
            preferenceId: existing.preferenceId,
            userId: userId,
            themeMode: preferences['themeMode'] as String? ?? existing.themeMode,
            dailyReminderEnabled: preferences['dailyReminderEnabled'] as bool? ?? existing.dailyReminderEnabled,
            revisionAlertsEnabled: preferences['revisionAlertsEnabled'] as bool? ?? existing.revisionAlertsEnabled,
            milestoneUpdatesEnabled: preferences['milestoneUpdatesEnabled'] as bool? ?? existing.milestoneUpdatesEnabled,
          );
          return _localDataSource.updateUserPreferences(updated);
        },
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _localDataSource.clearAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }
}
