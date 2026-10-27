/// API Client
/// Main HTTP client with Dio, interceptors, and configuration
library;

import 'package:dio/dio.dart';
import 'package:prepnode/core/network/api_constants.dart';
import 'package:prepnode/core/network/api_error_mapper.dart';
import 'package:prepnode/core/network/models/api_response.dart';
import 'package:prepnode/core/network/auth_interceptor.dart';
import 'package:prepnode/core/network/logging_interceptor.dart';
import 'package:prepnode/core/network/retry_interceptor.dart';
import 'package:prepnode/core/network/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient({
    required this._secureStorage,
    RetryInterceptor? retryPolicy,
    bool enableLogging = true,
  }) {
    _dio = Dio(_createBaseOptions());

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage: _secureStorage,
        dio: _dio,
      ),
      retryPolicy ?? RetryInterceptor(),
      LoggingInterceptor(enabled: enableLogging),
    ]);
  }

  Dio get dio => _dio;

  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  /// Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  /// Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  /// Generic PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  /// Generic DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  /// Multipart request for file uploads
  Future<T> upload<T>(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      return _deserialize<T>(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioError(e);
    }
  }

  T _deserialize<T>(dynamic data) {
    if (data is T) {
      return data;
    }

    final typeName = T.toString();
    if (typeName.startsWith('ApiResponse<') && data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, (json) => json) as T;
    }

    if (data == null) {
      return null as T;
    }

    return data as T;
  }
}
