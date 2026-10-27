/// Authentication Remote Data Source
/// Handles all API calls for authentication
library;

import 'package:prepnode/core/network/api_client.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/models/requests/auth_requests.dart';
import 'package:prepnode/core/network/models/api_response.dart';
import 'package:prepnode/core/network/mappers/dto_mapper.dart';
import 'package:prepnode/core/network/secure_storage_service.dart';
import 'package:prepnode/features/auth/domain/entities/auth_response.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRemoteDataSource({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      ApiConstants.login,
      data: request.toJson(),
    );

    final data = response.data!;
    final authData = data['data'] as Map<String, dynamic>;

    // Save tokens
    await _secureStorage.saveAccessToken(authData['accessToken'] as String);
    await _secureStorage.saveRefreshToken(authData['refreshToken'] as String);
    await _secureStorage.saveUserId(authData['user']['id'] as String);

    // Convert to domain entities
    final userDto = DtoMapper.toUserDto(authData['user'] as Map<String, dynamic>);
    final user = User(
      id: userDto.userId,
      name: userDto.name,
      email: userDto.email,
      avatarUrl: userDto.avatarUrl,
      examId: userDto.examId,
      targetDate: userDto.targetDate,
      dailyStudyHours: userDto.dailyStudyHours,
      preparationLevel: userDto.preparationLevel,
      profileComplete: userDto.profileComplete,
    );

    return AuthResponse(
      accessToken: authData['accessToken'] as String,
      refreshToken: authData['refreshToken'] as String,
      user: user,
    );
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final request = RegisterRequest(name: name, email: email, password: password);
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      ApiConstants.register,
      data: request.toJson(),
    );

    final data = response.data!;
    final authData = data['data'] as Map<String, dynamic>;

    // Save tokens
    await _secureStorage.saveAccessToken(authData['accessToken'] as String);
    await _secureStorage.saveRefreshToken(authData['refreshToken'] as String);
    await _secureStorage.saveUserId(authData['user']['id'] as String);

    // Convert to domain entities
    final userDto = DtoMapper.toUserDto(authData['user'] as Map<String, dynamic>);
    final user = User(
      id: userDto.userId,
      name: userDto.name,
      email: userDto.email,
      avatarUrl: userDto.avatarUrl,
      examId: userDto.examId,
      targetDate: userDto.targetDate,
      dailyStudyHours: userDto.dailyStudyHours,
      preparationLevel: userDto.preparationLevel,
      profileComplete: userDto.profileComplete,
    );

    return AuthResponse(
      accessToken: authData['accessToken'] as String,
      refreshToken: authData['refreshToken'] as String,
      user: user,
    );
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle({
    required String idToken,
  }) async {
    final request = GoogleAuthRequest(idToken: idToken);
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      ApiConstants.googleAuth,
      data: request.toJson(),
    );

    final data = response.data!;
    final authData = data['data'] as Map<String, dynamic>;

    // Save tokens
    await _secureStorage.saveAccessToken(authData['accessToken'] as String);
    await _secureStorage.saveRefreshToken(authData['refreshToken'] as String);
    await _secureStorage.saveUserId(authData['user']['id'] as String);

    // Convert to domain entities
    final userDto = DtoMapper.toUserDto(authData['user'] as Map<String, dynamic>);
    final user = User(
      id: userDto.userId,
      name: userDto.name,
      email: userDto.email,
      avatarUrl: userDto.avatarUrl,
      examId: userDto.examId,
      targetDate: userDto.targetDate,
      dailyStudyHours: userDto.dailyStudyHours,
      preparationLevel: userDto.preparationLevel,
      profileComplete: userDto.profileComplete,
    );

    return AuthResponse(
      accessToken: authData['accessToken'] as String,
      refreshToken: authData['refreshToken'] as String,
      user: user,
    );
  }

  /// Request password reset
  Future<void> forgotPassword({
    required String email,
  }) async {
    final request = ForgotPasswordRequest(email: email);
    await _apiClient.post<ApiResponse<void>>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
    );
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final request = ResetPasswordRequest(
      resetToken: resetToken,
      newPassword: newPassword,
    );
    await _apiClient.post<ApiResponse<void>>(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );
  }

  /// Logout user
  Future<void> logout({
    required String refreshToken,
  }) async {
    final request = LogoutRequest(refreshToken: refreshToken);
    await _apiClient.post<ApiResponse<void>>(
      ApiConstants.logout,
      data: request.toJson(),
    );

    // Clear local tokens
    await _secureStorage.clearAuthData();
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken({
    required String refreshToken,
  }) async {
    final request = RefreshTokenRequest(refreshToken: refreshToken);
    final response = await _apiClient.post<ApiResponse<Map<String, dynamic>>>(
      ApiConstants.refreshToken,
      data: request.toJson(),
    );

    final data = response.data!;
    final authData = data['data'] as Map<String, dynamic>;

    // Save new tokens
    await _secureStorage.saveAccessToken(authData['accessToken'] as String);
    await _secureStorage.saveRefreshToken(authData['refreshToken'] as String);
    await _secureStorage.saveUserId(authData['user']['id'] as String);

    // Convert to domain entities
    final userDto = DtoMapper.toUserDto(authData['user'] as Map<String, dynamic>);
    final user = User(
      id: userDto.userId,
      name: userDto.name,
      email: userDto.email,
      avatarUrl: userDto.avatarUrl,
      examId: userDto.examId,
      targetDate: userDto.targetDate,
      dailyStudyHours: userDto.dailyStudyHours,
      preparationLevel: userDto.preparationLevel,
      profileComplete: userDto.profileComplete,
    );

    return AuthResponse(
      accessToken: authData['accessToken'] as String,
      refreshToken: authData['refreshToken'] as String,
      user: user,
    );
  }
}
