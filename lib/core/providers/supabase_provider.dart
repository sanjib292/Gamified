import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the singleton [SupabaseClient] instance.
///
/// Kept alive for the lifetime of the app — do not auto-dispose.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
  name: 'supabaseClientProvider',
);

/// Provides the [GoTrueClient] (authentication client) from Supabase.
///
/// Derived from [supabaseClientProvider] — always reflects the same
/// underlying instance.
final authClientProvider = Provider<GoTrueClient>(
  (ref) {
    final client = ref.watch(supabaseClientProvider);
    return client.auth;
  },
  name: 'authClientProvider',
);

/// Provides the current Supabase [Session], or `null` if not authenticated.
///
/// This is a [StreamProvider] so widgets can reactively rebuild when the
/// auth state changes (sign-in, sign-out, token refresh).
final authSessionProvider = StreamProvider<AuthState>(
  (ref) {
    final authClient = ref.watch(authClientProvider);
    return authClient.onAuthStateChange;
  },
  name: 'authSessionProvider',
);

/// Convenience provider: true when there is an active, valid session.
final isAuthenticatedProvider = Provider<bool>(
  (ref) {
    final authClient = ref.watch(authClientProvider);
    return authClient.currentSession != null;
  },
  name: 'isAuthenticatedProvider',
);

/// Provides the current user's ID, or `null` if not authenticated.
final currentUserIdProvider = Provider<String?>(
  (ref) {
    final authClient = ref.watch(authClientProvider);
    return authClient.currentUser?.id;
  },
  name: 'currentUserIdProvider',
);
