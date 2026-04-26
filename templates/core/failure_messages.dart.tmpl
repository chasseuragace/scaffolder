import '../errors/failures.dart';

/// Maps a domain [Failure] (or any thrown error) to a user-presentable
/// message. Override or extend per project — for instance, to localize.
String failureToMessage(Object error) {
  final f = error is Failure ? error : failureFromError(error);
  return switch (f) {
    NetworkFailure() => 'Network unavailable. Check your connection and try again.',
    TimeoutFailure() => 'The request took too long. Try again.',
    NotFoundFailure(:final message) => message,
    UnauthorizedFailure() => 'You are not signed in or do not have access.',
    ValidationFailure(:final message, :final fieldErrors) =>
      fieldErrors.isEmpty
          ? message
          : '$message (${fieldErrors.entries.map((e) => "${e.key}: ${e.value}").join(", ")})',
    CacheFailure() => 'Local data could not be read. Try refreshing.',
    UnknownFailure(:final message) => 'Something went wrong. $message',
  };
}
