import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/error/app_exception.dart';

/// Abstract contract for authentication operations.
///
/// All methods return [Future]s that throw [AppException] subtypes on failure —
/// never raw Supabase or platform exceptions.
abstract interface class AuthRepository {
  /// Signs the user in with Google OAuth.
  ///
  /// Returns the signed-in [User] on success.
  /// Throws [AuthException] on failure.
  Future<User> signInWithGoogle();

  /// Signs the current user out of Supabase and Google.
  ///
  /// Throws [AuthException] on failure.
  Future<void> signOut();

  /// Returns the current [Session] or `null` if not authenticated.
  Session? getSession();

  /// A stream of [AuthState] events emitted when the auth state changes.
  Stream<AuthState> authStateStream();
}
