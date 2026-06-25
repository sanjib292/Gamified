/// Supabase table names, storage buckets, and Edge Function identifiers.
///
/// Centralising these constants prevents typo-driven bugs and makes
/// schema migrations easier to track in a single file.
abstract final class SupabaseConfig {
  // ---------------------------------------------------------------------------
  // Table names
  // ---------------------------------------------------------------------------

  static const String profiles = 'profiles';
  static const String subscriptions = 'subscriptions';
  static const String books = 'books';
  static const String lessons = 'lessons';
  static const String learningPaths = 'learning_paths';
  static const String lessonContent = 'lesson_content';
  static const String userProgress = 'user_progress';
  static const String xpLogs = 'xp_logs';
  static const String achievements = 'achievements';
  static const String userAchievements = 'user_achievements';
  static const String streaks = 'streaks';
  static const String aiConversations = 'ai_conversations';
  static const String aiMessages = 'ai_messages';
  static const String embeddings = 'embeddings';
  static const String notifications = 'notifications';
  static const String analyticsEvents = 'analytics_events';
  static const String bookmarks = 'bookmarks';
  static const String lessonAttempts = 'lesson_attempts';
  static const String userAiProfile = 'user_ai_profile';
  static const String recommendations = 'recommendations';
  static const String leaderboards = 'leaderboards';
  static const String userLearningStats = 'user_learning_stats';

  // ---------------------------------------------------------------------------
  // Storage bucket names
  // ---------------------------------------------------------------------------

  static const String avatarsBucket = 'avatars';
  static const String bookCoversBucket = 'book-covers';
  static const String audioLessonsBucket = 'audio-lessons';
  static const String animationsBucket = 'animations';
  static const String iconsBucket = 'icons';

  // ---------------------------------------------------------------------------
  // Edge Function names
  // ---------------------------------------------------------------------------

  static const String fnGenerateLesson = 'generate-lesson';
  static const String fnAiCoachMessage = 'ai-coach-message';
  static const String fnEmbedContent = 'embed-content';
  static const String fnGenerateQuiz = 'generate-quiz';
  static const String fnPersonalizeRecommendations = 'personalize-recommendations';
  static const String fnProcessXp = 'process-xp';
  static const String fnUpdateStreak = 'update-streak';
  static const String fnSendNotification = 'send-notification';
  static const String fnAnalyticsIngest = 'analytics-ingest';
  static const String fnSyncLeaderboard = 'sync-leaderboard';

  // ---------------------------------------------------------------------------
  // Realtime channel names
  // ---------------------------------------------------------------------------

  static const String channelLeaderboard = 'leaderboard';
  static const String channelAiMessages = 'ai-messages';
  static const String channelNotifications = 'notifications';

  // ---------------------------------------------------------------------------
  // Column names used across multiple tables
  // ---------------------------------------------------------------------------

  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
}
