import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

final _authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(ref.watch(supabaseClientProvider)),
  name: '_authDataSourceProvider',
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDataSourceProvider)),
  name: 'authRepositoryProvider',
);

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

/// Watches the Supabase auth state stream and exposes sign-in/sign-out
/// actions to the UI.
///
/// Kept alive for the app lifetime — the auth stream must always be active.
class AuthNotifier extends AsyncNotifier<User?> {
  late StreamSubscription<AuthState> _authSub;

  @override
  FutureOr<User?> build() {
    final repo = ref.watch(authRepositoryProvider);

    // Seed initial value from current session.
    final initialUser = repo.getSession()?.user;

    // Subscribe to auth state changes and update this notifier.
    _authSub = repo.authStateStream().listen((authState) {
      state = AsyncData(authState.session?.user);
    });

    ref.onDispose(_authSub.cancel);

    return initialUser;
  }

  /// Launches Google OAuth. The auth stream in [build] updates state on completion.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Browser opened — state will be set by the auth stream when sign-in
      // completes. Reset to null if user closes browser without signing in.
      if (state.isLoading) {
        state = const AsyncData(null);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await AsyncValue.guard(repo.signOut);
    // Auth stream will set state to null automatically.
  }
}

/// The main auth provider. keepAlive so the stream is never cancelled.
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
  name: 'authProvider',
);
