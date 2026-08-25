import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:prepgraph/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prepgraph/features/auth/domain/entities/auth_response.dart';
import 'package:prepgraph/features/auth/domain/entities/user.dart';
import 'package:prepgraph/features/auth/domain/repositories/auth_repository.dart';

/// Local sessions (offline login/register fallback) are kept alive for this
/// long before SplashScreen's expiration check forces a re-login — mirrors
/// a typical refresh-token lifetime.
const _localSessionLifetime = Duration(days: 30);

/// Production Auth Repository Implementation
/// Uses remote API and local database with offline-first strategy. Every
/// action that talks to the backend falls back to the local Drift database
/// when the backend is unreachable (a [NetworkFailure] from the API layer)
/// — a real rejection from a reachable backend (wrong password, duplicate
/// email, validation errors) is never masked by the fallback.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

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

    try {
      // Call remote API
      final authResponse = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save user to local database, caching a local password hash too so
      // this account can use the offline fallback later if needed.
      await _localDataSource.saveUser(authResponse.user, plainPassword: password);
      await _localDataSource.recordSession(
        userId: authResponse.user.id,
        refreshToken: authResponse.refreshToken,
        expiresAt: DateTime.now().add(_localSessionLifetime),
      );

      return Right(authResponse);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      // Backend unreachable — fall back to a locally-known account.
      return _loginLocally(email: email, password: password);
    }
  }

  Future<Either<Failure, AuthResponse>> _loginLocally({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _localDataSource.verifyLocalCredentials(
        email: email,
        password: password,
      );
      if (user == null) {
        return Left(AuthFailure.invalidCredentials());
      }

      return Right(await _startLocalSession(user));
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

    try {
      // Call remote API
      final authResponse = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Save user to local database, caching a local password hash too so
      // this account can use the offline fallback later if needed.
      await _localDataSource.saveUser(authResponse.user, plainPassword: password);
      await _localDataSource.recordSession(
        userId: authResponse.user.id,
        refreshToken: authResponse.refreshToken,
        expiresAt: DateTime.now().add(_localSessionLifetime),
      );

      return Right(authResponse);
    } catch (e) {
      final failure = _mapErrorToFailure(e);
      if (failure is! NetworkFailure) {
        return Left(failure);
      }
      // Backend unreachable — fall back to creating a local-only account.
      return _registerLocally(name: name, email: email, password: password);
    }
  }

  Future<Either<Failure, AuthResponse>> _registerLocally({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final existing = await _localDataSource.getUserByEmail(email);
      if (existing != null) {
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
    try {
      // Call remote API
      final authResponse = await _remoteDataSource.loginWithGoogle(
        idToken: idToken,
      );

      // Save user to local database
      await _localDataSource.saveUser(authResponse.user);

      return Right(authResponse);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      await _remoteDataSource.forgotPassword(email: email);
      return const Right(null);
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

      await _remoteDataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout({
    required String refreshToken,
  }) async {
    try {
      await _remoteDataSource.logout(refreshToken: refreshToken);
    } catch (e) {
      // Even if the remote call fails (no backend, expired session, etc.),
      // logout must still succeed locally — a network hiccup can never
      // trap a user who wants to log out.
    }

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
    try {
      final authResponse = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      // Update user in local database
      await _localDataSource.saveUser(authResponse.user);

      return Right(authResponse);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  Failure _mapErrorToFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
