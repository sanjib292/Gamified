import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import '../providers/supabase_provider.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/book_detail/presentation/pages/book_detail_page.dart';
import '../../features/learning_path/presentation/pages/learning_path_page.dart';
import '../../features/lesson/presentation/pages/lesson_page.dart';
import '../../features/ai_coach/presentation/pages/ai_coach_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/achievements_page.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

// Feature pages are imported above — no placeholder classes needed.

class RouterErrorPage extends StatelessWidget {
  const RouterErrorPage({super.key, required this.error});
  final Exception? error;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(error?.toString() ?? 'Unknown routing error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Shell scaffold (bottom navigation)
// ---------------------------------------------------------------------------

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(
              index,
              // Re-tap active tab → go to initial route of that branch.
              initialLocation: index == navigationShell.currentIndex,
            ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_library_outlined),
            selectedIcon: Icon(Icons.local_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Auth change notifier (makes GoRouter reactive to session changes)
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] that notifies GoRouter whenever the auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(authSessionProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

/// The application's [GoRouter] instance.
///
/// Kept alive for the lifetime of the app.
final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final notifier = _AuthChangeNotifier(ref);
    ref.onDispose(notifier.dispose);

    return GoRouter(
      initialLocation: RouteNames.splash,
      debugLogDiagnostics: true,
      refreshListenable: notifier,

      // -----------------------------------------------------------------------
      // Global redirect logic
      // -----------------------------------------------------------------------
      redirect: (context, state) {
        final isAuthenticated = ref.read(isAuthenticatedProvider);
        final location = state.uri.toString();

        // Public routes — never redirect away from these
        const publicRoutes = [
          RouteNames.splash,
          RouteNames.onboarding,
          RouteNames.auth,
        ];
        final isPublic = publicRoutes.any((r) => location.startsWith(r));

        if (!isAuthenticated && !isPublic) {
          return RouteNames.auth;
        }

        return null; // No redirect — proceed to requested route
      },

      // -----------------------------------------------------------------------
      // Error page
      // -----------------------------------------------------------------------
      errorBuilder: (context, state) =>
          RouterErrorPage(error: state.error),

      // -----------------------------------------------------------------------
      // Route tree
      // -----------------------------------------------------------------------
      routes: [
        // ── Splash ────────────────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // ── Onboarding ────────────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // ── Auth ──────────────────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.auth,
          name: 'auth',
          builder: (context, state) => const AuthPage(),
        ),

        // ── Modal: Leaderboard ────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.leaderboard,
          name: 'leaderboard',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const LeaderboardPage(),
          ),
        ),

        // ── Modal: Settings ───────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.settings,
          name: 'settings',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: const SettingsPage(),
          ),
        ),

        // ── Shell (bottom nav) ────────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              _ShellScaffold(navigationShell: navigationShell),
          branches: [
            // Branch 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.home,
                  name: 'home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),

            // Branch 1: Library (with nested routes)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.library,
                  name: 'library',
                  builder: (context, state) => const LibraryPage(),
                  routes: [
                    GoRoute(
                      path: 'book/:bookId',
                      name: 'bookDetail',
                      builder: (context, state) => BookDetailPage(
                        bookId: state.pathParameters['bookId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'path/:pathId',
                          name: 'learningPath',
                          builder: (context, state) => LearningPathPage(
                            bookId: state.pathParameters['bookId']!,
                            pathId: state.pathParameters['pathId']!,
                          ),
                          routes: [
                            GoRoute(
                              path: 'lesson/:lessonId',
                              name: 'lesson',
                              builder: (context, state) => LessonPage(
                                bookId: state.pathParameters['bookId']!,
                                pathId: state.pathParameters['pathId']!,
                                lessonId: state.pathParameters['lessonId']!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Branch 2: AI Coach
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.coach,
                  name: 'coach',
                  builder: (context, state) => const AiCoachPage(),
                ),
              ],
            ),

            // Branch 3: Profile (with nested achievements)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profile,
                  name: 'profile',
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'achievements',
                      name: 'achievements',
                      builder: (context, state) => const AchievementsPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
  name: 'appRouterProvider',
);
