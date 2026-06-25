/// Named route path constants for GoRouter.
///
/// Nested routes use the full path from root so they can be used with
/// [GoRouter.go] directly without needing to know the parent path.
abstract final class RouteNames {
  // ---------------------------------------------------------------------------
  // Top-level / modal routes
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  // ---------------------------------------------------------------------------
  // Shell branch: Home
  // ---------------------------------------------------------------------------

  static const String home = '/home';

  // ---------------------------------------------------------------------------
  // Shell branch: Library
  // ---------------------------------------------------------------------------

  static const String library = '/library';

  /// Path parameter: `:bookId`
  static const String bookDetail = '/library/book/:bookId';

  /// Path parameters: `:bookId`, `:pathId`
  static const String learningPath = '/library/book/:bookId/path/:pathId';

  /// Path parameters: `:bookId`, `:pathId`, `:lessonId`
  static const String lesson =
      '/library/book/:bookId/path/:pathId/lesson/:lessonId';

  // ---------------------------------------------------------------------------
  // Shell branch: AI Coach
  // ---------------------------------------------------------------------------

  static const String coach = '/coach';

  // ---------------------------------------------------------------------------
  // Shell branch: Profile (nested)
  // ---------------------------------------------------------------------------

  static const String profile = '/profile';
  static const String achievements = '/profile/achievements';

  // ---------------------------------------------------------------------------
  // Modal / full-screen overlay routes
  // ---------------------------------------------------------------------------

  static const String leaderboard = '/leaderboard';
  static const String settings = '/settings';

  // ---------------------------------------------------------------------------
  // Helper: build concrete paths from templates
  // ---------------------------------------------------------------------------

  /// Resolves [bookDetail] for a given [bookId].
  static String bookDetailPath(String bookId) =>
      '/library/book/$bookId';

  /// Resolves [learningPath] for given [bookId] and [pathId].
  static String learningPathPath(String bookId, String pathId) =>
      '/library/book/$bookId/path/$pathId';

  /// Resolves [lesson] for given [bookId], [pathId], and [lessonId].
  static String lessonPath(
    String bookId,
    String pathId,
    String lessonId,
  ) =>
      '/library/book/$bookId/path/$pathId/lesson/$lessonId';
}
