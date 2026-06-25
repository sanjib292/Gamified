/// Application-wide constant values.
///
/// Groups XP rewards, level thresholds, daily goal presets, and UI limits.
abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // XP reward values
  // ---------------------------------------------------------------------------

  /// XP awarded for completing a lesson.
  static const int xpLessonComplete = 20;

  /// XP awarded for passing a quiz (< 100 % score).
  static const int xpQuizPass = 10;

  /// XP awarded for a perfect quiz score (100 %).
  static const int xpQuizPerfect = 15;

  /// XP awarded for completing a challenge activity.
  static const int xpChallenge = 30;

  /// XP awarded for completing a simulation activity.
  static const int xpSimulation = 50;

  /// XP awarded for completing an entire book.
  static const int xpBookCompletion = 100;

  /// Maximum extra XP earned from a daily streak bonus.
  static const int xpMaxDailyStreakBonus = 50;

  /// XP multiplier awarded on a ×2 streak day.
  static const double xpStreakMultiplier2x = 2.0;

  /// XP multiplier awarded on a ×3 streak day.
  static const double xpStreakMultiplier3x = 3.0;

  // ---------------------------------------------------------------------------
  // Level thresholds (cumulative XP required to reach each level)
  // ---------------------------------------------------------------------------

  /// Total XP required to reach level N = (N - 1)^2 * 100
  /// These are pre-computed convenience values for the first 20 levels.
  static const List<int> levelThresholds = <int>[
    0,      // Level 1
    100,    // Level 2
    400,    // Level 3
    900,    // Level 4
    1600,   // Level 5
    2500,   // Level 6
    3600,   // Level 7
    4900,   // Level 8
    6400,   // Level 9
    8100,   // Level 10
    10000,  // Level 11
    12100,  // Level 12
    14400,  // Level 13
    16900,  // Level 14
    19600,  // Level 15
    22500,  // Level 16
    25600,  // Level 17
    28900,  // Level 18
    32400,  // Level 19
    36100,  // Level 20
  ];

  static const int maxTrackedLevel = 20;

  // ---------------------------------------------------------------------------
  // Daily goal options (minutes)
  // ---------------------------------------------------------------------------

  /// The selectable daily learning goal durations in minutes.
  static const List<int> dailyGoalOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  /// Default daily goal in minutes for new users.
  static const int defaultDailyGoalMinutes = 15;

  // ---------------------------------------------------------------------------
  // Streak constants
  // ---------------------------------------------------------------------------

  /// Number of days of streak before a ×2 XP bonus applies.
  static const int streakBonusThreshold2x = 3;

  /// Number of days of streak before a ×3 XP bonus applies.
  static const int streakBonusThreshold3x = 7;

  /// Grace period hours: if a user misses a day but had a long streak,
  /// they have this many hours to complete a lesson before it resets.
  static const int streakGracePeriodHours = 24;

  // ---------------------------------------------------------------------------
  // AI Coach limits
  // ---------------------------------------------------------------------------

  /// Maximum number of messages per AI conversation session.
  static const int aiMaxMessagesPerSession = 50;

  /// Maximum characters per AI user message.
  static const int aiMaxMessageLength = 2000;

  /// Free tier daily AI message quota.
  static const int aiFreeTierDailyMessages = 10;

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  static const int defaultPageSize = 20;
  static const int leaderboardPageSize = 50;

  // ---------------------------------------------------------------------------
  // UI / animation durations (milliseconds)
  // ---------------------------------------------------------------------------

  static const int animDurationFast = 200;
  static const int animDurationMedium = 350;
  static const int animDurationSlow = 600;

  static const int xpPopupDisplayMs = 2500;
  static const int confettiDurationMs = 3000;

  // ---------------------------------------------------------------------------
  // Storage keys
  // ---------------------------------------------------------------------------

  static const String storageKeyTheme = 'mq_theme_mode';
  static const String storageKeyOnboarded = 'mq_onboarded';
  static const String storageKeyDailyGoal = 'mq_daily_goal_min';
  static const String storageKeyLastActiveDate = 'mq_last_active_date';
  static const String storageKeyPushEnabled = 'mq_push_enabled';
}
