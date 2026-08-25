/// Secure Storage Service
/// Handles secure storage of authentication tokens and sensitive data
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prepgraph/core/network/api_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: ApiConstants.accessTokenKey, value: token);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: ApiConstants.refreshTokenKey, value: token);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: ApiConstants.userIdKey, value: userId);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConstants.accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: ApiConstants.refreshTokenKey);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: ApiConstants.userIdKey);
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
    await _storage.delete(key: ApiConstants.userIdKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all data (for logout/account deletion)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
