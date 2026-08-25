import '../database/database.dart';
import '../dtos/user_dto.dart';
import '../failures.dart';
import '../result.dart';
import 'local_datasource.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Local data source for User-related operations
class UserLocalDataSource extends BaseLocalDataSource {
  UserLocalDataSource(super.database);

  /// Get user by ID
  Future<Result<UserDto>> getUserById(String userId) async {
    try {
      final query = database.select(database.users)
        ..where((tbl) => tbl.userId.equals(userId))
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'User'));
      }

      final dto = UserDto(
        userId: result.userId,
        name: result.name,
        email: result.email,
        phone: result.phone,
        avatarUrl: result.avatarUrl,
        examId: result.examId,
        targetDate: result.targetDate,
        dailyStudyHours: result.dailyStudyHours,
        preparationLevel: result.preparationLevel,
        profileComplete: result.profileComplete,
        createdAt: result.createdAt,
        lastLogin: result.lastLogin,
        deletedAt: result.deletedAt,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get user by email
  Future<Result<UserDto>> getUserByEmail(String email) async {
    try {
      final query = database.select(database.users)
        ..where((tbl) => tbl.email.equals(email))
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'User'));
      }

      final dto = UserDto(
        userId: result.userId,
        name: result.name,
        email: result.email,
        phone: result.phone,
        avatarUrl: result.avatarUrl,
        examId: result.examId,
        targetDate: result.targetDate,
        dailyStudyHours: result.dailyStudyHours,
        preparationLevel: result.preparationLevel,
        profileComplete: result.profileComplete,
        createdAt: result.createdAt,
        lastLogin: result.lastLogin,
        deletedAt: result.deletedAt,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create or update user
  Future<Result<UserDto>> upsertUser(UserDto user) async {
    try {
      final existingUser = await (database.select(database.users)
            ..where((tbl) => tbl.userId.equals(user.userId)))
          .getSingleOrNull();

      if (existingUser != null) {
        // Update existing user
        await database.update(database.users).replace(
          UsersCompanion(
            userId: Value(user.userId),
            name: Value(user.name),
            email: Value(user.email),
            phone: Value(user.phone),
            avatarUrl: Value(user.avatarUrl),
            examId: Value(user.examId),
            targetDate: Value(user.targetDate),
            dailyStudyHours: Value(user.dailyStudyHours),
            preparationLevel: Value(user.preparationLevel),
            profileComplete: Value(user.profileComplete),
            lastLogin: Value(user.lastLogin),
          ),
        );
      } else {
        // Insert new user
        await database.into(database.users).insert(
          UsersCompanion(
            userId: Value(user.userId),
            name: Value(user.name),
            email: Value(user.email),
            profileComplete: Value(user.profileComplete),
            createdAt: Value(user.createdAt),
          ),
        );
      }

      return Result.success(user);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update user profile fields
  Future<Result<UserDto>> updateUserProfile(String userId, {
    String? name,
    String? avatarUrl,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
  }) async {
    try {
      final updateData = UsersCompanion(
        userId: Value(userId),
        name: name != null ? Value(name) : const Value.absent(),
        avatarUrl: avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
        examId: examId != null ? Value(examId) : const Value.absent(),
        targetDate: targetDate != null ? Value(targetDate) : const Value.absent(),
        dailyStudyHours: dailyStudyHours != null ? Value(dailyStudyHours) : const Value.absent(),
        preparationLevel: preparationLevel != null ? Value(preparationLevel) : const Value.absent(),
      );

      await database.update(database.users).replace(updateData);

      // Fetch updated user
      return await getUserById(userId);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update last login timestamp
  Future<Result<void>> updateLastLogin(String userId) async {
    try {
      await database.update(database.users).replace(
        UsersCompanion(
          userId: Value(userId),
          lastLogin: Value(DateTime.now()),
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get user preferences
  Future<Result<UserPreferenceDto>> getUserPreferences(String userId) async {
    try {
      final query = database.select(database.userPreferences)
        ..where((tbl) => tbl.userId.equals(userId))
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        // Create default preferences
        final defaultPrefs = UserPreferenceDto(
          preferenceId: const Uuid().v4(),
          userId: userId,
          themeMode: 'system',
          dailyReminderEnabled: true,
          revisionAlertsEnabled: true,
          milestoneUpdatesEnabled: true,
        );

        await database.into(database.userPreferences).insert(
          UserPreferencesCompanion(
            preferenceId: Value(defaultPrefs.preferenceId),
            userId: Value(defaultPrefs.userId),
            themeMode: Value(defaultPrefs.themeMode),
            dailyReminderEnabled: Value(defaultPrefs.dailyReminderEnabled),
            revisionAlertsEnabled: Value(defaultPrefs.revisionAlertsEnabled),
            milestoneUpdatesEnabled: Value(defaultPrefs.milestoneUpdatesEnabled),
          ),
        );

        return Result.success(defaultPrefs);
      }

      final dto = UserPreferenceDto(
        preferenceId: result.preferenceId,
        userId: result.userId,
        themeMode: result.themeMode,
        dailyReminderEnabled: result.dailyReminderEnabled,
        revisionAlertsEnabled: result.revisionAlertsEnabled,
        milestoneUpdatesEnabled: result.milestoneUpdatesEnabled,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update user preferences
  Future<Result<UserPreferenceDto>> updateUserPreferences(UserPreferenceDto prefs) async {
    try {
      final existing = await (database.select(database.userPreferences)
            ..where((tbl) => tbl.preferenceId.equals(prefs.preferenceId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.userPreferences).replace(
          UserPreferencesCompanion(
            preferenceId: Value(prefs.preferenceId),
            userId: Value(prefs.userId),
            themeMode: Value(prefs.themeMode),
            dailyReminderEnabled: Value(prefs.dailyReminderEnabled),
            revisionAlertsEnabled: Value(prefs.revisionAlertsEnabled),
            milestoneUpdatesEnabled: Value(prefs.milestoneUpdatesEnabled),
          ),
        );
      } else {
        await database.into(database.userPreferences).insert(
          UserPreferencesCompanion(
            preferenceId: Value(prefs.preferenceId),
            userId: Value(prefs.userId),
            themeMode: Value(prefs.themeMode),
            dailyReminderEnabled: Value(prefs.dailyReminderEnabled),
            revisionAlertsEnabled: Value(prefs.revisionAlertsEnabled),
            milestoneUpdatesEnabled: Value(prefs.milestoneUpdatesEnabled),
          ),
        );
      }

      return Result.success(prefs);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await database.delete(database.users).go();
      await database.delete(database.userPreferences).go();
      await database.delete(database.refreshTokens).go();
    } catch (e) {
      throw handleDatabaseError(e);
    }
  }
}
