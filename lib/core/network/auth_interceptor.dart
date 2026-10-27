/// Auth Interceptor
/// Handles JWT token injection and automatic refresh
library;

import 'package:dio/dio.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;

  AuthInterceptor({
    required this._secureStorage,
    required this._dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token for auth endpoints and public endpoints
    final path = options.path;
    if (_isPublicEndpoint(path)) {
      handler.next(options);
      return;
    }

    // Add access token to headers
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is due to expired token
    if (err.response?.statusCode == 401 && _shouldRefreshToken(err)) {
      try {
        // Attempt to refresh the token
        final newToken = await _refreshToken();
        
        if (newToken != null) {
          // Save new token
          await _secureStorage.saveAccessToken(newToken);
          
          // Update the failed request with new token
          final originalRequest = err.requestOptions;
          originalRequest.headers['Authorization'] = 'Bearer $newToken';
          
          // Retry the original request
          final response = await _dio.fetch(originalRequest);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, clear auth data and let the error propagate
        await _secureStorage.clearAuthData();
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      ApiConstants.authRegister,
      ApiConstants.authLogin,
      ApiConstants.authGoogle,
      ApiConstants.authForgotPassword,
      ApiConstants.authResetPassword,
      ApiConstants.exams,
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  bool _shouldRefreshToken(DioException error) {
    // Check if the error code indicates token expiration
    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          final code = errorObj['code'] as String?;
          return code == 'AUTH_INVALID_TOKEN' || 
                 code == 'AUTH_REFRESH_EXPIRED_OR_REVOKED';
        }
      }
    }
    return false;
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _dio.post(
        ApiConstants.baseUrl + ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['accessToken'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
