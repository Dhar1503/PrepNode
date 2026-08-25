/// Failure Types
/// Represents different types of failures that can occur
abstract class Failure {
  final String message;
  final String? code;
  final Object? originalError;

  const Failure(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.originalError});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.originalError});

  factory NetworkFailure.noConnection({dynamic originalError}) {
    return NetworkFailure(
      'No internet connection',
      code: 'NO_CONNECTION',
      originalError: originalError,
    );
  }

  factory NetworkFailure.timeout({dynamic originalError}) {
    return NetworkFailure(
      'Request timed out',
      code: 'TIMEOUT',
      originalError: originalError,
    );
  }

  factory NetworkFailure.serverError({dynamic originalError}) {
    return NetworkFailure(
      'Server error occurred',
      code: 'SERVER_ERROR',
      originalError: originalError,
    );
  }
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.originalError});

  factory DatabaseFailure.queryFailed({dynamic originalError}) {
    return DatabaseFailure(
      'Database query failed',
      code: 'QUERY_FAILED',
      originalError: originalError,
    );
  }

  factory DatabaseFailure.insertFailed({dynamic originalError}) {
    return DatabaseFailure(
      'Failed to insert data',
      code: 'INSERT_FAILED',
      originalError: originalError,
    );
  }

  factory DatabaseFailure.updateFailed({dynamic originalError}) {
    return DatabaseFailure(
      'Failed to update data',
      code: 'UPDATE_FAILED',
      originalError: originalError,
    );
  }

  factory DatabaseFailure.deleteFailed({dynamic originalError}) {
    return DatabaseFailure(
      'Failed to delete data',
      code: 'DELETE_FAILED',
      originalError: originalError,
    );
  }

  factory DatabaseFailure.notFound({String? entity, dynamic originalError}) {
    return DatabaseFailure(
      entity != null ? '$entity not found' : 'Record not found',
      code: 'NOT_FOUND',
      originalError: originalError,
    );
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.originalError});

  factory ValidationFailure.invalidEmail({dynamic originalError}) {
    return ValidationFailure(
      'Invalid email address',
      code: 'INVALID_EMAIL',
      originalError: originalError,
    );
  }

  factory ValidationFailure.invalidPassword({dynamic originalError}) {
    return ValidationFailure(
      'Password must be at least 8 characters',
      code: 'INVALID_PASSWORD',
      originalError: originalError,
    );
  }

  factory ValidationFailure.requiredField({required String field, dynamic originalError}) {
    return ValidationFailure(
      '$field is required',
      code: 'REQUIRED_FIELD',
      originalError: originalError,
    );
  }

  factory ValidationFailure.invalidFormat({required String field, dynamic originalError}) {
    return ValidationFailure(
      'Invalid format for $field',
      code: 'INVALID_FORMAT',
      originalError: originalError,
    );
  }
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.originalError});

  factory AuthFailure.invalidCredentials({dynamic originalError}) {
    return AuthFailure(
      'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
      originalError: originalError,
    );
  }

  factory AuthFailure.sessionExpired({dynamic originalError}) {
    return AuthFailure(
      'Session expired. Please log in again',
      code: 'SESSION_EXPIRED',
      originalError: originalError,
    );
  }

  factory AuthFailure.notAuthenticated({dynamic originalError}) {
    return AuthFailure(
      'Not authenticated',
      code: 'NOT_AUTHENTICATED',
      originalError: originalError,
    );
  }

  factory AuthFailure.emailAlreadyExists({dynamic originalError}) {
    return AuthFailure(
      'Email already registered',
      code: 'EMAIL_EXISTS',
      originalError: originalError,
    );
  }
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.originalError});
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code, super.originalError});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.originalError});

  factory CacheFailure.notFound({String? key, dynamic originalError}) {
    return CacheFailure(
      key != null ? 'Cache not found: $key' : 'Cache not found',
      code: 'CACHE_NOT_FOUND',
      originalError: originalError,
    );
  }

  factory CacheFailure.writeFailed({dynamic originalError}) {
    return CacheFailure(
      'Failed to write to cache',
      code: 'CACHE_WRITE_FAILED',
      originalError: originalError,
    );
  }
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.originalError});

  factory UnknownFailure.unexpected({dynamic originalError}) {
    return UnknownFailure(
      'An unexpected error occurred',
      code: 'UNEXPECTED_ERROR',
      originalError: originalError,
    );
  }
}
