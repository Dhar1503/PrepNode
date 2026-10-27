import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/network/secure_storage_service.dart';
import 'package:prepnode/core/utils/password_hasher.dart';
import 'package:prepnode/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:prepnode/features/auth/data/repositories/auth_repository_impl.dart';

/// In-memory stand-in for the platform keystore. flutter_secure_storage needs
/// a real Android/iOS channel, which unit tests do not have; every method of
/// SecureStorageService is overridden so nothing reaches the channel.
class FakeSecureStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> saveAccessToken(String token) async => _values['access'] = token;

  @override
  Future<void> saveRefreshToken(String token) async => _values['refresh'] = token;

  @override
  Future<void> saveUserId(String userId) async => _values['userId'] = userId;

  @override
  Future<String?> getAccessToken() async => _values['access'];

  @override
  Future<String?> getRefreshToken() async => _values['refresh'];

  @override
  Future<String?> getUserId() async => _values['userId'];

  @override
  Future<void> clearAuthData() async {
    _values.remove('access');
    _values.remove('refresh');
    _values.remove('userId');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = _values['access'];
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAll() async => _values.clear();
}

/// Exposes one shared in-memory database to successive DatabaseService-like
/// wrappers, so a test can build a brand-new datasource over the same stored
/// rows — which is exactly what relaunching the app does.
class TestDatabaseService implements DatabaseService {
  final PrepNodeDatabase _db;

  TestDatabaseService(this._db);

  @override
  PrepNodeDatabase get database => _db;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PrepNodeDatabase db;
  late FakeSecureStorage storage;

  /// Builds the auth stack the way the app wires it up. Called again after
  /// "restarting" to prove nothing depended on in-memory state.
  AuthRepositoryImpl buildRepository() {
    return AuthRepositoryImpl(
      localDataSource: AuthLocalDataSource(
        databaseService: TestDatabaseService(db),
        secureStorage: storage,
      ),
    );
  }

  setUp(() async {
    db = PrepNodeDatabase(NativeDatabase.memory());
    // onCreate does not run until the database is first touched; this also
    // builds the v6 unique-email index the tests below rely on.
    await db.customSelect('SELECT 1').get();
    storage = FakeSecureStorage();
  });

  tearDown(() async {
    await db.close();
  });

  group('PasswordHasher', () {
    test('hashes are salted — the same password never produces the same hash',
        () {
      final a = PasswordHasher.hash('correct horse battery');
      final b = PasswordHasher.hash('correct horse battery');
      expect(a, isNot(equals(b)));
      expect(PasswordHasher.verify('correct horse battery', a), isTrue);
      expect(PasswordHasher.verify('correct horse battery', b), isTrue);
    });

    test('rejects the wrong password and an empty stored hash', () {
      final stored = PasswordHasher.hash('rightpassword');
      expect(PasswordHasher.verify('wrongpassword', stored), isFalse);
      expect(PasswordHasher.verify('anything', ''), isFalse);
    });

    test('still verifies a legacy djb2 hash, and flags it for upgrade', () {
      final legacy = PasswordHasher.legacyHash('oldpassword');
      expect(PasswordHasher.verify('oldpassword', legacy), isTrue);
      expect(PasswordHasher.needsUpgrade(legacy), isTrue);
      expect(PasswordHasher.needsUpgrade(PasswordHasher.hash('x')), isFalse);
    });
  });

  group('account persistence across app restarts', () {
    test('register, restart, then log in with the same credentials', () async {
      final registration = await buildRepository().register(
        name: 'Aspirant',
        email: 'aspirant@example.com',
        password: 'tnpsc2026secure',
      );
      expect(registration.isRight(), isTrue,
          reason: 'registration should succeed');

      // Simulate an app restart: brand-new repository and datasource over
      // the same stored rows, with no carried-over in-memory state.
      final afterRestart = await buildRepository().login(
        email: 'aspirant@example.com',
        password: 'tnpsc2026secure',
      );

      expect(afterRestart.isRight(), isTrue,
          reason: 'the account created before the restart must still log in');
      afterRestart.fold(
        (f) => fail('login failed after restart: ${f.message}'),
        (response) => expect(response.user.email, 'aspirant@example.com'),
      );
    });

    test('the stored password is hashed, never the plaintext', () async {
      await buildRepository().register(
        name: 'Aspirant',
        email: 'hash@example.com',
        password: 'tnpsc2026secure',
      );

      final row = await (db.select(db.users)
            ..where((t) => t.email.equals('hash@example.com')))
          .getSingle();

      expect(row.passwordHash, isNot(contains('tnpsc2026secure')));
      expect(row.passwordHash, startsWith('sha256\$'));
      expect(PasswordHasher.verify('tnpsc2026secure', row.passwordHash), isTrue);
    });

    test('logout clears the session but keeps the account loginable',
        () async {
      final repo = buildRepository();
      final registration = await repo.register(
        name: 'Aspirant',
        email: 'session@example.com',
        password: 'tnpsc2026secure',
      );
      final refreshToken =
          registration.getOrElse(() => throw StateError('no session')).refreshToken;

      await repo.logout(refreshToken: refreshToken);

      expect(await storage.isAuthenticated(), isFalse,
          reason: 'the session must be gone after logout');
      final accountStillThere = await (db.select(db.users)
            ..where((t) => t.email.equals('session@example.com')))
          .getSingleOrNull();
      expect(accountStillThere, isNotNull,
          reason: 'logout must not delete the account');

      final secondLogin = await buildRepository().login(
        email: 'session@example.com',
        password: 'tnpsc2026secure',
      );
      expect(secondLogin.isRight(), isTrue,
          reason: 'logging out then back in must work');
    });
  });

  group('email handling', () {
    test('login is case-insensitive about the email that was registered',
        () async {
      await buildRepository().register(
        name: 'Aspirant',
        email: 'Aspirant@Example.COM',
        password: 'tnpsc2026secure',
      );

      final result = await buildRepository().login(
        email: 'aspirant@example.com',
        password: 'tnpsc2026secure',
      );

      expect(result.isRight(), isTrue,
          reason: 'a capitalised registration must not create an account the '
              'user can never log back into');
    });

    test('duplicate registration is rejected, including a different case',
        () async {
      await buildRepository().register(
        name: 'First',
        email: 'dup@example.com',
        password: 'tnpsc2026secure',
      );

      final sameCase = await buildRepository().register(
        name: 'Second',
        email: 'dup@example.com',
        password: 'anotherpassword',
      );
      final differentCase = await buildRepository().register(
        name: 'Third',
        email: 'DUP@Example.com',
        password: 'anotherpassword',
      );

      expect(sameCase.isLeft(), isTrue);
      expect(differentCase.isLeft(), isTrue,
          reason: 'email uniqueness must be case-insensitive');

      final rows = await db.select(db.users).get();
      expect(rows.length, 1, reason: 'only one account should exist');
    });

    test('the database itself enforces one account per email', () async {
      await buildRepository().register(
        name: 'First',
        email: 'unique@example.com',
        password: 'tnpsc2026secure',
      );

      // Bypass the repository entirely — the unique index added in schema
      // v6 is what makes this impossible rather than merely discouraged.
      expect(
        () => db.into(db.users).insert(UsersCompanion.insert(
              userId: 'manually-inserted',
              name: 'Duplicate',
              email: 'unique@example.com',
              passwordHash: 'whatever',
            )),
        throwsA(anything),
      );
    });
  });

  group('login error messages', () {
    test('an unknown email says so, rather than blaming the password',
        () async {
      final result = await buildRepository().login(
        email: 'nobody@example.com',
        password: 'tnpsc2026secure',
      );

      result.fold(
        (failure) => expect(failure.code, 'UNKNOWN_EMAIL'),
        (_) => fail('login should not succeed for an unknown account'),
      );
    });

    test('a wrong password is reported as a wrong password', () async {
      await buildRepository().register(
        name: 'Aspirant',
        email: 'wrongpass@example.com',
        password: 'tnpsc2026secure',
      );

      final result = await buildRepository().login(
        email: 'wrongpass@example.com',
        password: 'notthepassword',
      );

      result.fold(
        (failure) => expect(failure.code, 'INVALID_CREDENTIALS'),
        (_) => fail('login should not succeed with the wrong password'),
      );
    });
  });

  group('legacy accounts', () {
    test('an account stored with the old djb2 hash can still log in, and is '
        'upgraded to SHA-256 in the process', () async {
      // Exactly what a build before this sprint would have written.
      await db.into(db.users).insert(UsersCompanion.insert(
            userId: 'legacy-user',
            name: 'Legacy',
            email: 'legacy@example.com',
            passwordHash: PasswordHasher.legacyHash('tnpsc2026secure'),
          ));

      final result = await buildRepository().login(
        email: 'legacy@example.com',
        password: 'tnpsc2026secure',
      );
      expect(result.isRight(), isTrue,
          reason: 'the hashing upgrade must not lock existing users out');

      final row = await (db.select(db.users)
            ..where((t) => t.userId.equals('legacy-user')))
          .getSingle();
      expect(row.passwordHash, startsWith('sha256\$'),
          reason: 'the hash should be upgraded once the plaintext is known');
    });
  });
}
