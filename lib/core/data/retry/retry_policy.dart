import 'dart:async';
import '../result.dart';

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<Type> retryableFailureTypes;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.retryableFailureTypes = const [
      Exception,
    ],
  });

  /// Default retry config for network operations
  static const network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 2.0,
  );

  /// Default retry config for database operations
  static const database = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 2.0,
  );

  /// No retry (single attempt)
  static const none = RetryConfig(
    maxAttempts: 1,
  );
}

/// Retry policy for handling failed operations
class RetryPolicy {
  final RetryConfig config;

  RetryPolicy({this.config = RetryConfig.network});

  /// Execute an operation with retry logic
  Future<Result<T>> execute<T>(
    Future<Result<T>> Function() operation, {
    void Function(int attempt, Object failure)? onRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = config.initialDelay;

    while (attempt < config.maxAttempts) {
      attempt++;

      try {
        final result = await operation();

        if (result.isSuccess) {
          return result;
        }

        // Check if failure is retryable
        if (!isRetryable(result.failure!)) {
          return result;
        }

        // If this was the last attempt, return the failure
        if (attempt >= config.maxAttempts) {
          return result;
        }

        // Call retry callback if provided
        if (onRetry != null) {
          onRetry(attempt, result.failure!);
        }

        // Wait before retrying
        await Future.delayed(currentDelay);

        // Calculate next delay with exponential backoff
        currentDelay = _calculateNextDelay(currentDelay);

      } catch (e) {
        // If this was the last attempt, return the failure
        if (attempt >= config.maxAttempts) {
          return Result.failure(e);
        }

        // Call retry callback if provided
        if (onRetry != null) {
          onRetry(attempt, e);
        }

        // Wait before retrying
        await Future.delayed(currentDelay);

        // Calculate next delay with exponential backoff
        currentDelay = _calculateNextDelay(currentDelay);
      }
    }

    // This should never be reached, but return a generic failure
    return Result.failure(Exception('Unknown error'));
  }

  /// Check if a failure is retryable based on configuration
  bool isRetryable(Object failure) {
    return config.retryableFailureTypes.any((type) => failure.runtimeType == type);
  }

  /// Calculate next delay with exponential backoff
  Duration _calculateNextDelay(Duration currentDelay) {
    final nextDelayMs = currentDelay.inMilliseconds * config.backoffMultiplier;
    final clampedDelayMs = nextDelayMs.clamp(
      config.initialDelay.inMilliseconds.toDouble(),
      config.maxDelay.inMilliseconds.toDouble(),
    );
    return Duration(milliseconds: clampedDelayMs.toInt());
  }
}

/// Execute operation with retry using default policy
Future<Result<T>> retry<T>(
  Future<Result<T>> Function() operation, {
  RetryConfig? config,
  void Function(int attempt, Object failure)? onRetry,
}) async {
  final policy = RetryPolicy(config: config ?? RetryConfig.network);
  return policy.execute(operation, onRetry: onRetry);
}
