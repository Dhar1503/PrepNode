import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/auth/domain/entities/auth_response.dart';

/// Auth Repository Interface
/// Abstract contract for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Login with Google
  Future<Either<Failure, AuthResponse>> loginWithGoogle({
    required String idToken,
  });

  /// Request password reset
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Logout user
  Future<Either<Failure, void>> logout({
    required String refreshToken,
  });

  /// Refresh access token
  Future<Either<Failure, AuthResponse>> refreshToken({
    required String refreshToken,
  });
}
