/// Authentication Local Data Source
/// Owns the on-device account store. PrepNode has no backend, so this is the
/// only place accounts are ever created, verified or persisted.
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/data/database/database.dart' hide User;
import 'package:prepnode/core/data/database/database.dart' as dbm show User;
import 'package:prepnode/core/network/secure_storage_service.dart';
import 'package:prepnode/core/utils/password_hasher.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';

/// Why a local credential check failed, so the UI can say something useful
/// instead of one blanket "invalid credentials".
///
/// Distinguishing these normally leaks which emails are registered. That
/// threat does not apply here: the account store is a SQLite file inside
/// this app's private data directory, so anyone who can probe it can
/// already read the row list directly. The usability win is real, the
/// enumeration risk is not.
enum LocalCredentialOutcome { success, unknownEmail, wrongPassword }

class LocalCredentialResult {
  final LocalCredentialOutcome outcome;
  final User? user;

  const LocalCredentialResult(this.outcome, [this.user]);
}

class AuthLocalDataSource {
  final DatabaseService _databaseService;
  final SecureStorageService _secureStorage;

  AuthLocalDataSource({
    required DatabaseService databaseService,
    required SecureStorageService secureStorage,
  })  : _databaseService = databaseService,
        _secureStorage = secureStorage;

  /// Emails are stored and compared in one canonical form. Without this,
  /// registering as "Aspirant@Gmail.com" and later logging in as
  /// "aspirant@gmail.com" looked to the app like two different accounts —
  /// the account existed, the password was right, and login still failed.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  /// Save user to local database. When [plainPassword] is supplied it is
  /// hashed and stored; otherwise an existing hash is left untouched on
  /// update and defaults to empty on first insert (an account with no
  /// password can never be logged into locally, by design).
  Future<void> saveUser(User user, {String? plainPassword}) async {
    final db = _databaseService.database;
    final email = normalizeEmail(user.email);
    final existingUser = await (db.select(db.users)
          ..where((tbl) => tbl.userId.equals(user.id)))
        .getSingleOrNull();

    if (existingUser != null) {
      await (db.update(db.users)..where((tbl) => tbl.userId.equals(user.id)))
          .write(UsersCompanion(
        name: Value(user.name),
        email: Value(email),
        avatarUrl: Value(user.avatarUrl),
        examId: Value(user.examId),
        targetDate: Value(user.targetDate),
        dailyStudyHours: Value(user.dailyStudyHours),
        preparationLevel: Value(user.preparationLevel),
        profileComplete: Value(user.profileComplete),
        lastLogin: Value(DateTime.now()),
        passwordHash: plainPassword != null
            ? Value(PasswordHasher.hash(plainPassword))
            : const Value.absent(),
      ));
    } else {
      await db.into(db.users).insert(UsersCompanion.insert(
        userId: user.id,
        name: user.name,
        email: email,
        passwordHash:
            plainPassword != null ? PasswordHasher.hash(plainPassword) : '',
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

    return user == null ? null : _toUser(user);
  }

  /// Look up a locally-known user by email.
  Future<User?> getUserByEmail(String email) async {
    final row = await _findRowByEmail(email);
    return row == null ? null : _toUser(row);
  }

  /// Whether an account already exists for [email] (duplicate-registration
  /// check). Uses the same normalization as registration itself, so
  /// "A@b.com" and "a@b.com" cannot both be registered.
  Future<bool> emailExists(String email) async {
    return await _findRowByEmail(email) != null;
  }

  /// Verify a plaintext password against the stored hash for an email.
  ///
  /// On success, an account still holding a legacy (unsalted djb2) hash is
  /// transparently re-hashed with the current scheme — this is the only
  /// moment the plaintext is available, so it is the only place the upgrade
  /// can happen without forcing a password reset.
  Future<LocalCredentialResult> verifyLocalCredentials({
    required String email,
    required String password,
  }) async {
    final db = _databaseService.database;
    final row = await _findRowByEmail(email);
    if (row == null) {
      return const LocalCredentialResult(LocalCredentialOutcome.unknownEmail);
    }
    if (!PasswordHasher.verify(password, row.passwordHash)) {
      return const LocalCredentialResult(LocalCredentialOutcome.wrongPassword);
    }

    if (PasswordHasher.needsUpgrade(row.passwordHash)) {
      await (db.update(db.users)..where((tbl) => tbl.userId.equals(row.userId)))
          .write(UsersCompanion(
        passwordHash: Value(PasswordHasher.hash(password)),
      ));
    }

    return LocalCredentialResult(LocalCredentialOutcome.success, _toUser(row));
  }

  /// Create a brand-new local-only account. Callers must first check
  /// [emailExists] — this method does not re-check.
  Future<User> createLocalUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = _databaseService.database;
    final userId = const Uuid().v4();
    final normalizedEmail = normalizeEmail(email);
    final trimmedName = name.trim();

    await db.into(db.users).insert(UsersCompanion.insert(
      userId: userId,
      name: trimmedName,
      email: normalizedEmail,
      passwordHash: PasswordHasher.hash(password),
      profileComplete: const Value(false),
    ));

    return User(
      id: userId,
      name: trimmedName,
      email: normalizedEmail,
      profileComplete: false,
    );
  }

  /// Persist a session's tokens to secure storage.
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
  /// checked at app restart without a network round trip.
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
            tokenHash: PasswordHasher.hashToken(refreshToken),
            expiresAt: expiresAt,
            deviceLabel: const Value('this-device'),
          ),
        );
  }

  /// Whether a given refresh token's locally-tracked session has expired or
  /// been revoked. A token with no matching local row is treated as valid.
  Future<bool> isSessionExpired(String refreshToken) async {
    final row = await _findSessionRow(refreshToken);
    if (row == null) return false;
    if (row.revokedAt != null) return true;
    return row.expiresAt.isBefore(DateTime.now());
  }

  /// Convenience wrapper for [isSessionExpired] against whatever refresh
  /// token is currently persisted in secure storage.
  Future<bool> isCurrentSessionExpired() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    return isSessionExpired(refreshToken);
  }

  /// Revoke the locally-tracked session for a refresh token (logout).
  /// Only the session row is touched — the account itself is untouched, so
  /// the same credentials work on the next login.
  Future<void> revokeSession(String refreshToken) async {
    final db = _databaseService.database;
    final row = await _findSessionRow(refreshToken);
    if (row == null) return;
    await (db.update(db.refreshTokens)
          ..where((tbl) => tbl.tokenId.equals(row.tokenId)))
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

  /// Clear the session only. Deliberately does NOT delete the account row,
  /// so logging out never destroys the credentials needed to log back in.
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

  /// Email lookup used by every credential path.
  ///
  /// Reads with `get()` rather than `getSingleOrNull()` on purpose: the
  /// users table had no unique constraint on email until schema v6, so a
  /// database written by an older build can legitimately hold duplicate
  /// rows. `getSingleOrNull()` throws on those, which surfaced as an
  /// "unknown error" on login and locked the account out entirely. Taking
  /// the earliest-created row keeps such a device usable.
  Future<dbm.User?> _findRowByEmail(String email) async {
    final db = _databaseService.database;
    final normalized = normalizeEmail(email);
    final rows = await (db.select(db.users)
          ..where((tbl) => tbl.email.lower().equals(normalized))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Session lookup that accepts both the current SHA-256 token hash and
  /// the legacy djb2 one, so sessions created by an older build are still
  /// recognised (and can still be revoked) after the upgrade.
  Future<RefreshToken?> _findSessionRow(String refreshToken) async {
    final db = _databaseService.database;
    final current = PasswordHasher.hashToken(refreshToken);
    final legacy = PasswordHasher.legacyHash(refreshToken);
    final rows = await (db.select(db.refreshTokens)
          ..where((tbl) => tbl.tokenHash.isIn([current, legacy])))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  User _toUser(dbm.User row) {
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
}
