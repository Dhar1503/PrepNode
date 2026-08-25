/// Generic Result wrapper for handling success and failure states
/// Provides a type-safe way to handle operations that can fail
class Result<T> {
  final T? data;
  final Object? failure;
  final bool isSuccess;

  const Result._({
    this.data,
    this.failure,
    required this.isSuccess,
  });

  /// Creates a successful result with data
  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Creates a failure result with a Failure object
  factory Result.failure(Object failure) {
    return Result._(
      failure: failure,
      isSuccess: false,
    );
  }

  /// Executes the appropriate callback based on success or failure
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Object failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(failure!);
    }
  }

  /// Returns the data if successful, or null if failed
  T? getOrNull() => isSuccess ? data : null;

  /// Returns the data if successful, or throws the failure if failed
  T getOrThrow() {
    if (isSuccess) {
      return data as T;
    } else {
      throw failure!;
    }
  }

  /// Maps the data to a new type if successful
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      return Result.success(mapper(data as T));
    } else {
      return Result.failure(failure!);
    }
  }

  /// Chains another operation if successful
  Future<Result<R>> flatMap<R>(Future<Result<R>> Function(T data) mapper) async {
    if (isSuccess) {
      return await mapper(data as T);
    } else {
      return Result.failure(failure!);
    }
  }
}
