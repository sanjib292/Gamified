import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'app_exception.dart';

/// Maps low-level exceptions from Supabase, the Dart HTTP stack, and other
/// libraries into [AppException] subclasses.
///
/// Usage:
/// ```dart
/// try {
///   await supabase.from('books').select();
/// } catch (e, st) {
///   throw ErrorHandler.handle(e, st);
/// }
/// ```
abstract final class ErrorHandler {
  /// Converts [error] into an [AppException].
  ///
  /// Also accepts an optional [stack] for logging purposes —
  /// the mapping itself does not swallow the stack trace.
  static AppException handle(Object error, [StackTrace? stack]) {
    // -------------------------------------------------------------------------
    // Supabase / GoTrue auth exception
    // -------------------------------------------------------------------------
    if (error is supa.AuthException) {
      return AuthException(message: error.message);
    }

    // -------------------------------------------------------------------------
    // PostgreSQL / Supabase database (PostgREST) exception
    // -------------------------------------------------------------------------
    if (error is supa.PostgrestException) {
      // HTTP 401 / 403 from RLS policies
      if (error.code == '42501' || error.message.contains('permission denied')) {
        return NotAuthorizedException(message: error.message);
      }

      // Row-level not found (PostgREST returns 406 with message "0 rows")
      if (error.message.contains('0 rows') ||
          error.code == 'PGRST116' ||
          error.code == 'PGRST204') {
        return NotFoundException(resource: _inferResource(error.message));
      }

      return DatabaseException(
        message: error.message,
        code: error.code,
      );
    }

    // -------------------------------------------------------------------------
    // Supabase storage exception
    // -------------------------------------------------------------------------
    if (error is supa.StorageException) {
      return NetworkException(
        message: error.message,
        statusCode: int.tryParse(error.statusCode ?? ''),
      );
    }

    // -------------------------------------------------------------------------
    // Dart native socket / HTTP errors
    // -------------------------------------------------------------------------
    if (error is SocketException) {
      return const NetworkException(message: 'No internet connection.');
    }

    if (error is HttpException) {
      return NetworkException(message: error.message);
    }

    if (error is TlsException) {
      return const NetworkException(message: 'Secure connection failed.');
    }

    // -------------------------------------------------------------------------
    // Standard Dart exceptions
    // -------------------------------------------------------------------------
    if (error is FormatException) {
      return ValidationException(
        message: 'Invalid data format: ${error.message}',
      );
    }

    if (error is ArgumentError) {
      return ValidationException(
        message: error.message?.toString() ?? 'Invalid argument.',
        field: error.name,
      );
    }

    // -------------------------------------------------------------------------
    // Already-mapped AppExceptions — pass through unchanged
    // -------------------------------------------------------------------------
    if (error is AppException) {
      return error;
    }

    // -------------------------------------------------------------------------
    // Catch-all
    // -------------------------------------------------------------------------
    return UnknownException(
      message: error.toString(),
      error: error,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _inferResource(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('lesson')) return 'lesson';
    if (lower.contains('book')) return 'book';
    if (lower.contains('user') || lower.contains('profile')) return 'profile';
    if (lower.contains('achievement')) return 'achievement';
    return 'resource';
  }
}
