/// Retry Interceptor with Connectivity Detection
/// Retries failed requests based on configurable policy
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final Connectivity _connectivity;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
  }) : _connectivity = Connectivity();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    if (retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    // Check connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.every((r) => r == ConnectivityResult.none)) {
      handler.next(err);
      return;
    }

    // Calculate delay
    final delay = _calculateDelay(retryCount);

    // Wait before retry
    await Future.delayed(delay);

    // Update retry count
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    // Retry the request
    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          connectTimeout: err.requestOptions.connectTimeout,
          receiveTimeout: err.requestOptions.receiveTimeout,
          sendTimeout: err.requestOptions.sendTimeout,
          headers: err.requestOptions.headers,
        ),
      ).fetch(err.requestOptions);

      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException error) {
    // Don't retry if request was cancelled
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    // Don't retry on 4xx errors (except 429 rate limit)
    if (error.response?.statusCode != null) {
      final status = error.response!.statusCode!;
      if (status >= 400 && status < 500 && status != 429) {
        return false;
      }
    }

    // Don't retry on specific error types
    if (error.type == DioExceptionType.badCertificate) {
      return false;
    }

    return true;
  }

  Duration _calculateDelay(int retryCount) {
    final nextDelayMs = initialDelay.inMilliseconds * (backoffMultiplier * retryCount);
    final clampedDelayMs = nextDelayMs.clamp(
      initialDelay.inMilliseconds.toDouble(),
      maxDelay.inMilliseconds.toDouble(),
    );
    return Duration(milliseconds: clampedDelayMs.toInt());
  }
}
