/// Logging Interceptor
/// Logs API requests and responses for debugging
library;

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  final bool enabled;

  LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) {
      handler.next(options);
      return;
    }

    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) {
      handler.next(response);
      return;
    }

    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      handler.next(err);
      return;
    }

    _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    print('🔵 API Request');
    print('  Method: ${options.method}');
    print('  URL: ${options.uri}');
    print('  Headers: ${options.headers}');
    if (options.data != null) {
      print('  Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('  Query: ${options.queryParameters}');
    }
  }

  void _logResponse(Response response) {
    print('🟢 API Response');
    print('  Status: ${response.statusCode}');
    print('  URL: ${response.requestOptions.uri}');
    print('  Data: ${response.data}');
  }

  void _logError(DioException error) {
    print('🔴 API Error');
    print('  Type: ${error.type}');
    print('  Message: ${error.message}');
    print('  URL: ${error.requestOptions.uri}');
    if (error.response != null) {
      print('  Status: ${error.response?.statusCode}');
      print('  Data: ${error.response?.data}');
    }
  }
}
