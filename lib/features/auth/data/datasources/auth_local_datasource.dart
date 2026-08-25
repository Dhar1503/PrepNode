/// Authentication Local Data Source
/// Handles local storage and caching for authentication
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:prepgraph/core/data/database/database_service.dart';
import 'package:prepgraph/core/data/database/database.dart' hide User;
import 'package:prepgraph/core/network/secure_storage_service.dart';
import 'package:prepgraph/features/auth/domain/entities/user.dart';

class AuthLocalDataSource {
  final DatabaseService _databaseService;
  final SecureStorageService _secureStorage;

  AuthLocalDataSource({
    required DatabaseService databaseService,
    required SecureStorageService secureStorage,
  })  : _databaseService = databaseService,
        _secureStorage = secureStorage;

  /// Save user to local database. When [plainPassword] is supplied (a real
  /// backend just authenticated it), it's hashed and cached locally too, so
  /// this same account can use the offline login fallback later if the
  /// backend becomes unreachable. Without it, an existing local password
  /// hash is left untouched on update, and defaults to empty on first
  /// insert (matches accounts that have only ever been seen via a remote
  /// login/register — the backend, not this device, owns their password).
  Future<void> saveUser(User user, {String? plainPassword}) async {
    final db = _databaseService.database;
    final existingUser = await (db.select(db.users)
          ..where((tbl) => tbl.userId.equals(user.id)))
        .getSingleOrNull();

    if (existingUser != null) {
      await (db.update(db.users)..where((tbl) => tbl.userId.equals(user.id)))
          .write(UsersCompanion(
        name: Value(user.name),
        email: Value(user.email),
        avatarUrl: Value(user.avatarUrl),
        examId: Value(user.examId),
        targetDate: Value(user.targetDate),
        dailyStudyHours: Value(user.dailyStudyHours),
        preparationLevel: Value(user.preparationLevel),
        profileComplete: Value(user.profileComplete),
        lastLogin: Value(DateTime.now()),
        passwordHash:
            plainPassword != null ? Value(_hashSecret(plainPassword)) : const Value.absent(),
      ));
    } else {
      await db.into(db.users).insert(UsersCompanion.insert(
        userId: user.id,
        name: user.name,
        email: user.email,
        passwordHash: plainPassword != null ? _hashSecret(plainPassword) : '',
        avatarUrl: Value(user.avatarUrl),
        examId: Value(user.examId),
        targetDate: Value(user.targetDate),
        dailyStudyHours: Value(user.dailyStudyHours),
        preparationLevel: Value(user.preparationLevel),
        profileComplete: Value(user.profileComplete),
      ));
    }
  }

  /// Get user from local database
  Future<User?> getUser(String userId) async {
    final db = _databaseService.database;
    final user = await (db.select(db.users)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();

    if (user == null) return null;

    return User(
      id: user.userId,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      examId: user.examId,
      targetDate: user.targetDate,
      dailyStudyHours: user.dailyStudyHours,
      preparationLevel: user.preparationLevel,
      profileComplete: user.profileComplete,
    );
  }

  /// Look up a locally-known user by email (used by the offline register
  /// fallback's duplicate-account check, and the offline login fallback).
  Future<User?> getUserByEmail(String email) async {
    final db = _databaseService.database;
    final row = await (db.select(db.users)
          ..where((tbl) => tbl.email.equals(email.trim())))
        .getSingleOrNull();
    if (row == null) return null;

    return User(
      id: row.userId,
      name: row.name,
      email: row.email,
      avatarUrl: row.avatarUrl,
      examId: row.examId,
      targetDate: row.targetDate,
      dailyStudyHours: row.dailyStudyHours,
      preparationLevel: row.preparationLevel,
      profileComplete: row.profileComplete,
    );
  }

  /// Verify a plaintext password against the locally-cached hash for an
  /// email, for the offline login fallback. Returns the matching user, or
  /// null if the email is unknown locally or the password doesn't match —
  /// callers must not distinguish between these two cases in the resulting
  /// error message (avoids leaking which emails are registered).
  Future<User?> verifyLocalCredentials({
    required String email,
    required String password,
  }) async {
    final db = _databaseService.database;
    final row = await (db.select(db.users)
          ..where((tbl) => tbl.email.equals(email.trim())))
        .getSingleOrNull();
    if (row == null) return null;
    if (row.passwordHash.isEmpty || row.passwordHash != _hashSecret(password)) {
      return null;
    }

    return User(
      id: row.userId,
      name: row.name,
      email: row.email,
      avatarUrl: row.avatarUrl,
      examId: row.examId,
      targetDate: row.targetDate,
      dailyStudyHours: row.dailyStudyHours,
      preparationLevel: row.preparationLevel,
      profileComplete: row.profileComplete,
    );
  }

  /// Create a brand-new local-only account for the offline register
  /// fallback. Callers must first check [getUserByEmail] themselves to
  /// enforce duplicate-account validation — this method does not re-check.
  Future<User> createLocalUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = _databaseService.database;
    final userId = const Uuid().v4();
    final trimmedEmail = email.trim();

    await db.into(db.users).insert(UsersCompanion.insert(
      userId: userId,
      name: name,
      email: trimmedEmail,
      passwordHash: _hashSecret(password),
      profileComplete: const Value(false),
    ));

    return User(
      id: userId,
      name: name,
      email: trimmedEmail,
      profileComplete: false,
    );
  }

  /// Persist a session's tokens to secure storage. Used for the offline
  /// fallback session created locally when no backend is reachable (a real
  /// backend session's tokens are already saved by AuthRemoteDataSource).
  Future<void> saveSessionTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _secureStorage.saveUserId(userId);
  }

  /// Record a session's refresh token locally so its expiration can be
  /// checked at app restart without a network round trip — used for both
  /// a real backend session (recording its own refresh token) and the
  /// offline fallback session (which mints its own local token).
  Future<void> recordSession({
    required String userId,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    final db = _databaseService.database;
    await db.into(db.refreshTokens).insert(
          RefreshTokensCompanion.insert(
            tokenId: const Uuid().v4(),
            userId: userId,
            tokenHash: _hashSecret(refreshToken),
            expiresAt: expiresAt,
            deviceLabel: const Value('this-device'),
          ),
        );
  }

  /// Whether a given refresh token's locally-tracked session has expired or
  /// been revoked. A token with no matching local row (e.g. a backend
  /// session established before this tracking existed) is treated as
  /// valid — the network layer's AuthInterceptor already handles expiration
  /// for real backend sessions via 401 + refresh.
  Future<bool> isSessionExpired(String refreshToken) async {
    final db = _databaseService.database;
    final row = await (db.select(db.refreshTokens)
          ..where((tbl) => tbl.tokenHash.equals(_hashSecret(refreshToken))))
        .getSingleOrNull();
    if (row == null) return false;
    if (row.revokedAt != null) return true;
    return row.expiresAt.isBefore(DateTime.now());
  }

  /// Convenience wrapper for [isSessionExpired] against whatever refresh
  /// token is currently persisted in secure storage — used by SplashScreen
  /// during session restoration.
  Future<bool> isCurrentSessionExpired() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    return isSessionExpired(refreshToken);
  }

  /// Revoke the locally-tracked session for a refresh token (logout
  /// cleanup). A no-op if the token has no local row.
  Future<void> revokeSession(String refreshToken) async {
    final db = _databaseService.database;
    await (db.update(db.refreshTokens)
          ..where((tbl) => tbl.tokenHash.equals(_hashSecret(refreshToken))))
        .write(RefreshTokensCompanion(revokedAt: Value(DateTime.now())));
  }

  /// Get current user ID from secure storage
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.getUserId();
  }

  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  /// Get refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isAuthenticated();
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await _secureStorage.clearAuthData();
  }

  /// Delete user from local database
  Future<void> deleteUser(String userId) async {
    final db = _databaseService.database;
    await (db.delete(db.users)..where((tbl) => tbl.userId.equals(userId))).go();
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    final db = _databaseService.database;
    await (db.update(db.users)..where((tbl) => tbl.userId.equals(userId)))
        .write(UsersCompanion(lastLogin: Value(DateTime.now())));
  }

  /// Deterministic local-only credential hash for the offline fallback
  /// login/register path and local session-token tracking. This is NOT
  /// used when a real backend is reachable — the backend owns real
  /// password hashing there. No crypto package exists in this project (by
  /// design, to avoid adding unnecessary dependencies), so this djb2-style
  /// mix is a local-device gate only, not a cryptographically secure hash.
  String _hashSecret(String value) {
    final bytes = utf8.encode('prepgraph-local-salt::$value');
    int hash = 5381;
    for (final byte in bytes) {
      hash = ((hash << 5) + hash + byte) & 0x7FFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
