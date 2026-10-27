import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:prepnode/features/auth/domain/entities/auth_response.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';
import 'package:prepnode/features/auth/domain/repositories/auth_repository.dart';

/// Local sessions (offline login/register fallback) are kept alive for this
/// long before SplashScreen's expiration check forces a re-login — mirrors
/// a typical refresh-token lifetime.
const _localSessionLifetime = Duration(days: 30);

/// Production Auth Repository Implementation
///
/// PrepNode ships with no backend: accounts are created, verified and stored
/// entirely in the local Drift database on the device. Credentials are never
/// transmitted off the device.
///
/// This class previously called a remote API first and fell back to local
/// storage when the backend was unreachable. That path was removed — it sent
/// the user's name, email and plaintext password to an unregistered domain on
/// every login and registration, so any party who registered that domain would
/// have received them.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Email and password are required'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return _loginLocally(email: email, password: password);
  }

  Future<Either<Failure, AuthResponse>> _loginLocally({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _localDataSource.verifyLocalCredentials(
        email: email,
        password: password,
      );

      switch (result.outcome) {
        case LocalCredentialOutcome.unknownEmail:
          // Accounts live only on this device, so "no account here" is a
          // genuinely different situation from a typo'd password — the user
          // may be on a reinstalled app or a different phone, and telling
          // them to register is the actionable answer.
          return const Left(AuthFailure(
            'No PrepNode account found on this device for that email. '
            'Accounts are stored locally, so you may need to register first.',
            code: 'UNKNOWN_EMAIL',
          ));
        case LocalCredentialOutcome.wrongPassword:
          return const Left(AuthFailure(
            'Incorrect password. Please try again.',
            code: 'INVALID_CREDENTIALS',
          ));
        case LocalCredentialOutcome.success:
          final user = result.user!;
          await _localDataSource.updateLastLogin(user.id);
          return Right(await _startLocalSession(user));
      }
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validate input
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('All fields are required'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    if (password.length < 8) {
      return const Left(ValidationFailure('Password must be at least 8 characters'));
    }

    return _registerLocally(name: name, email: email, password: password);
  }

  Future<Either<Failure, AuthResponse>> _registerLocally({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (await _localDataSource.emailExists(email)) {
        return Left(AuthFailure.emailAlreadyExists());
      }

      final user = await _localDataSource.createLocalUser(
        name: name,
        email: email,
        password: password,
      );
      return Right(await _startLocalSession(user));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  /// Mints a local-only session (tokens + expiry tracking) for a user
  /// resolved entirely from the local database, with no backend involved.
  Future<AuthResponse> _startLocalSession(User user) async {
    final accessToken = 'local-${const Uuid().v4()}';
    final refreshToken = 'local-${const Uuid().v4()}';

    await _localDataSource.saveSessionTokens(
      userId: user.id,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _localDataSource.recordSession(
      userId: user.id,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(_localSessionLifetime),
    );

    return AuthResponse(accessToken: accessToken, refreshToken: refreshToken, user: user);
  }

  @override
  Future<Either<Failure, AuthResponse>> loginWithGoogle({
    required String idToken,
  }) async {
    // Google sign-in needs a backend to verify the ID token, and PrepNode has
    // none. The "Continue with Google" button was already removed from the
    // login screen, so this is unreachable from the UI.
    return const Left(
      AuthFailure('Google sign-in is not available in this release'),
    );
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      // No backend exists to send a reset email. Report this honestly rather
      // than returning success for a message that will never arrive.
      return const Left(
        AuthFailure(
          'Password reset by email is not available. Accounts are stored only '
          'on this device, so there is no server to send a reset link.',
        ),
      );
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 8) {
        return const Left(ValidationFailure('Password must be at least 8 characters'));
      }

      // Counterpart to forgotPassword: no backend issues or validates reset
      // tokens, so there is nothing to redeem here.
      return const Left(
        AuthFailure('Password reset is not available in this release'),
      );
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout({
    required String refreshToken,
  }) async {
    // Sessions live only in the local database, so logging out is purely a
    // local revoke-and-clear.
    if (refreshToken.isNotEmpty) {
      await _localDataSource.revokeSession(refreshToken);
    }
    await _localDataSource.clearAuthData();
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken({
    required String refreshToken,
  }) async {
    // Local sessions carry their own expiry (see [_localSessionLifetime]) and
    // there is no token service to refresh against. Nothing in the app calls
    // this; an expired session sends the user back to the login screen.
    return Left(AuthFailure.sessionExpired());
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
