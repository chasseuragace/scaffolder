/// Domain-level failure types. Repositories return `Either<Failure, T>` so
/// callers can pattern-match on the failure variant rather than parsing
/// exception strings.

export type Failure =
  | NetworkFailure
  | TimeoutFailure
  | NotFoundFailure
  | ValidationFailure
  | UnauthorizedFailure
  | CacheFailure
  | UnknownFailure;

export class NetworkFailure {
  readonly _tag = 'NetworkFailure';
  message: string;

  constructor(message: string = 'Network error') {
    this.message = message;
  }
}

export class TimeoutFailure {
  readonly _tag = 'TimeoutFailure';
  message: string;

  constructor(message: string = 'Request timed out') {
    this.message = message;
  }
}

export class NotFoundFailure {
  readonly _tag = 'NotFoundFailure';
  message: string;

  constructor(message: string = 'Not found') {
    this.message = message;
  }
}

export class ValidationFailure {
  readonly _tag = 'ValidationFailure';
  message: string;
  fieldErrors: Record<string, string>;

  constructor(message: string, fieldErrors: Record<string, string> = {}) {
    this.message = message;
    this.fieldErrors = fieldErrors;
  }
}

export class UnauthorizedFailure {
  readonly _tag = 'UnauthorizedFailure';
  message: string;

  constructor(message: string = 'Unauthorized') {
    this.message = message;
  }
}

export class CacheFailure {
  readonly _tag = 'CacheFailure';
  message: string;

  constructor(message: string = 'Cache error') {
    this.message = message;
  }
}

export class UnknownFailure {
  readonly _tag = 'UnknownFailure';
  message: string;

  constructor(message: string = 'Unknown error') {
    this.message = message;
  }
}

/// Convenience: maps a thrown error to a domain Failure. Extend per project.
export function failureFromError(error: unknown): Failure {
  if (isFailure(error)) return error;
  const s = String(error).toLowerCase();
  if (s.includes('timeout')) return new TimeoutFailure();
  if (s.includes('socket') || s.includes('network')) return new NetworkFailure();
  return new UnknownFailure(String(error));
}

function isFailure(error: unknown): error is Failure {
  return (
    typeof error === 'object' &&
    error !== null &&
    '_tag' in error &&
    typeof error._tag === 'string'
  );
}
