/// API Error Mapper
/// Maps HTTP status codes and API error codes to domain failures
library;

import 'package:dio/dio.dart';
import 'package:prepnode/core/data/failures.dart';

class ApiErrorMapper {
  static Failure mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
          code: 'CONNECTION_TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
          code: 'NO_INTERNET',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          'Invalid SSL certificate',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        if (error.error is FormatException) {
          return const NetworkFailure(
            'Invalid response format',
            code: 'INVALID_FORMAT',
          );
        }
        return UnknownFailure(
          error.message ?? 'An unknown error occurred',
          originalError: error.error,
        );
    }
  }

  static Failure _mapStatusCode(int? statusCode, dynamic responseData) {
    if (statusCode == null) {
      return const UnknownFailure(
        'Unknown error occurred',
        code: 'UNKNOWN_STATUS',
      );
    }

    // Extract error code and message from response if available
    String? errorCode;
    String? errorMessage;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          errorCode = error['code'] as String?;
          errorMessage = error['message'] as String?;
        }
      }
    }

    // Use provided error message or default
    final message = errorMessage ?? _getDefaultMessageForStatus(statusCode);
    final code = errorCode ?? _getDefaultCodeForStatus(statusCode);

    switch (statusCode) {
      case 400:
        return ValidationFailure(message, code: code);

      case 401:
        if (code == 'AUTH_INVALID_TOKEN' || code == 'AUTH_REFRESH_EXPIRED_OR_REVOKED') {
          return AuthFailure(message, code: code);
        }
        if (code == 'AUTH_INVALID_CREDENTIALS') {
          return AuthFailure(message, code: code);
        }
        return AuthFailure(message, code: code);

      case 403:
        return AuthFailure(message, code: code);

      case 404:
        return const NetworkFailure(
          'Resource not found',
          code: 'RESOURCE_NOT_FOUND',
        );

      case 409:
        return ValidationFailure(message, code: code);

      case 429:
        return const NetworkFailure(
          'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return const NetworkFailure(
          'Server error. Please try again later.',
          code: 'SERVER_ERROR',
        );

      default:
        return UnknownFailure(message, code: code);
    }
  }

  static String _getDefaultMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Authentication failed';
      case 403:
        return 'Access denied';
      case 404:
        return 'Resource not found';
      case 409:
        return 'Resource already exists';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      default:
        return 'An error occurred';
    }
  }

  static String _getDefaultCodeForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'VALIDATION_ERROR';
      case 401:
        return 'AUTH_ERROR';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 429:
        return 'RATE_LIMITED';
      case 500:
        return 'INTERNAL_ERROR';
      default:
        return 'UNKNOWN_ERROR';
    }
  }
}
