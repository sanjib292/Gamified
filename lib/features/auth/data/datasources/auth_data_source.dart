import 'package:supabase_flutter/supabase_flutter.dart';

/// Low-level data source for authentication operations.
///
/// Uses Supabase's built-in OAuth flow (opens system browser, redirects back
/// via deep link). Error mapping happens in [AuthRepositoryImpl].
class AuthDataSource {
  AuthDataSource(this._supabase);

  final SupabaseClient _supabase;

  GoTrueClient get _auth => _supabase.auth;

  /// Launches Supabase Google OAuth flow.
  ///
  /// Opens a browser for the user to authenticate. The session is set
  /// asynchronously when the deep link `com.mindquest.app://login-callback`
  /// is received. Listen to [authStateStream] for the sign-in event.
  Future<void> signInWithGoogle() async {
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.mindquest.app://login-callback',
    );
  }

  /// Signs out of Supabase.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the current [Session] or `null` if not authenticated.
  Session? getSession() => _auth.currentSession;

  /// Emits an [AuthState] event each time the auth state changes.
  Stream<AuthState> authStateStream() => _auth.onAuthStateChange;
}
