import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Low-level data source for authentication operations.
///
/// Interacts directly with [SupabaseClient] and [GoogleSignIn]. Error mapping
/// to [AppException] happens in [AuthRepositoryImpl], not here.
class AuthDataSource {
  AuthDataSource(this._supabase) : _googleSignIn = GoogleSignIn();

  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  GoTrueClient get _auth => _supabase.auth;

  /// Initiates Google OAuth sign-in and passes the ID token to Supabase.
  ///
  /// Returns the [AuthResponse] from Supabase on success.
  Future<AuthResponse> signInWithGoogle() async {
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      throw Exception('Google sign-in was cancelled by the user.');
    }

    final googleAuth = await googleAccount.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('Google sign-in did not return an ID token.');
    }

    return _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Signs out of both Supabase and Google.
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Returns the current [Session] or `null` if not authenticated.
  Session? getSession() => _auth.currentSession;

  /// Emits an [AuthState] event each time the auth state changes.
  Stream<AuthState> authStateStream() => _auth.onAuthStateChange;
}
