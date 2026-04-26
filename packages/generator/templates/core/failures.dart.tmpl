/// Domain-level failure types. Repositories return `Either<Failure, T>` so
/// callers can pattern-match on the failure variant rather than parsing
/// exception strings.
library;

sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
  final Map<String, String> fieldErrors;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}

/// Convenience: maps a thrown error to a domain Failure. Extend per project.
Failure failureFromError(Object error) {
  if (error is Failure) return error;
  final s = error.toString().toLowerCase();
  if (s.contains('timeout')) return const TimeoutFailure();
  if (s.contains('socket') || s.contains('network')) return const NetworkFailure();
  return UnknownFailure(error.toString());
}
