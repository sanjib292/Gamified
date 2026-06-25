/// Sealed hierarchy of domain-specific exceptions for MindQuest.
///
/// All service and repository methods should map low-level errors into one of
/// these types so the UI can render a consistent, user-friendly message.
sealed class AppException implements Exception {
  const AppException();

  /// A message suitable for display in the UI (no stack traces, no codes).
  String get userMessage;

  @override
  String toString() => '$runtimeType: $userMessage';
}

// ---------------------------------------------------------------------------
// Network
// ---------------------------------------------------------------------------

/// Thrown when an HTTP request fails or the device is offline.
final class NetworkException extends AppException {
  const NetworkException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String get userMessage {
    if (statusCode != null) {
      return switch (statusCode!) {
        401 => 'Your session has expired. Please sign in again.',
        403 => 'You don\'t have permission to do that.',
        404 => 'The requested resource was not found.',
        429 => 'Too many requests. Please slow down.',
        >= 500 => 'Server error. Please try again in a moment.',
        _ => 'Network error ($statusCode). Please check your connection.',
      };
    }
    return 'No internet connection. Please check your network settings.';
  }
}

// ---------------------------------------------------------------------------
// Authentication
// ---------------------------------------------------------------------------

/// Thrown for authentication failures (bad credentials, expired token, etc.).
final class AuthException extends AppException {
  const AuthException({required this.message});

  final String message;

  @override
  String get userMessage {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') || lower.contains('wrong password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with that email address.';
    }
    if (lower.contains('weak password')) {
      return 'Password must be at least 8 characters and contain a mix of characters.';
    }
    if (lower.contains('already registered')) {
      return 'An account with that email already exists.';
    }
    return 'Authentication failed. Please try again.';
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

/// Thrown when a Supabase / PostgreSQL database operation fails.
final class DatabaseException extends AppException {
  const DatabaseException({
    required this.message,
    this.code,
  });

  final String message;

  /// PostgreSQL error code (e.g. `'23505'` for unique violation).
  final String? code;

  @override
  String get userMessage {
    if (code != null) {
      return switch (code!) {
        '23505' => 'That entry already exists.',
        '23503' => 'Cannot complete the operation due to a related record.',
        '42501' => 'You don\'t have permission to perform this action.',
        _ => 'A database error occurred. Please try again.',
      };
    }
    return 'A database error occurred. Please try again.';
  }
}

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

/// Thrown when user-provided data fails validation before reaching the server.
final class ValidationException extends AppException {
  const ValidationException({
    required this.message,
    this.field,
  });

  final String message;

  /// The form field name that caused the error, if applicable.
  final String? field;

  @override
  String get userMessage => message;
}

// ---------------------------------------------------------------------------
// Authorisation
// ---------------------------------------------------------------------------

/// Thrown when the authenticated user lacks permission for an operation.
final class NotAuthorizedException extends AppException {
  const NotAuthorizedException({required this.message});

  final String message;

  @override
  String get userMessage =>
      'You don\'t have permission to do that. Please upgrade your plan or contact support.';
}

// ---------------------------------------------------------------------------
// Not found
// ---------------------------------------------------------------------------

/// Thrown when a requested resource does not exist.
final class NotFoundException extends AppException {
  const NotFoundException({required this.resource});

  /// Human-readable name of the resource (e.g. `'lesson'`, `'book'`).
  final String resource;

  @override
  String get userMessage =>
      'The ${resource.toLowerCase()} you\'re looking for could not be found.';
}

// ---------------------------------------------------------------------------
// Unknown / catch-all
// ---------------------------------------------------------------------------

/// Thrown for unexpected errors that don't map to a known category.
final class UnknownException extends AppException {
  const UnknownException({
    required this.message,
    this.error,
  });

  final String message;

  /// The original error object for logging purposes.
  final Object? error;

  @override
  String get userMessage =>
      'Something went wrong. Please try again or contact support if the problem persists.';
}
