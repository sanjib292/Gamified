// Core application enums for MindQuest

enum ContentType {
  quiz,
  flashcard,
  storyMission,
  simulation,
  challenge,
  video,
  article;

  String toJson() => _contentTypeToJson[this]!;

  static ContentType fromJson(String value) {
    return _contentTypeFromJson[value] ??
        (throw ArgumentError('Unknown ContentType: $value'));
  }
}

const _contentTypeToJson = {
  ContentType.quiz: 'quiz',
  ContentType.flashcard: 'flashcard',
  ContentType.storyMission: 'story_mission',
  ContentType.simulation: 'simulation',
  ContentType.challenge: 'challenge',
  ContentType.video: 'video',
  ContentType.article: 'article',
};

const _contentTypeFromJson = {
  'quiz': ContentType.quiz,
  'flashcard': ContentType.flashcard,
  'story_mission': ContentType.storyMission,
  'simulation': ContentType.simulation,
  'challenge': ContentType.challenge,
  'video': ContentType.video,
  'article': ContentType.article,
};

// ---------------------------------------------------------------------------

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String toJson() => _difficultyToJson[this]!;

  static DifficultyLevel fromJson(String value) {
    return _difficultyFromJson[value] ??
        (throw ArgumentError('Unknown DifficultyLevel: $value'));
  }
}

const _difficultyToJson = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

const _difficultyFromJson = {
  'beginner': DifficultyLevel.beginner,
  'intermediate': DifficultyLevel.intermediate,
  'advanced': DifficultyLevel.advanced,
  'expert': DifficultyLevel.expert,
};

// ---------------------------------------------------------------------------

enum SubscriptionTier {
  free,
  premium,
  premiumPlus;

  String toJson() => _subscriptionTierToJson[this]!;

  static SubscriptionTier fromJson(String value) {
    return _subscriptionTierFromJson[value] ??
        (throw ArgumentError('Unknown SubscriptionTier: $value'));
  }
}

const _subscriptionTierToJson = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.premium: 'premium',
  SubscriptionTier.premiumPlus: 'premium_plus',
};

const _subscriptionTierFromJson = {
  'free': SubscriptionTier.free,
  'premium': SubscriptionTier.premium,
  'premium_plus': SubscriptionTier.premiumPlus,
};

// ---------------------------------------------------------------------------

enum LessonStatus {
  notStarted,
  inProgress,
  completed,
  locked;

  String toJson() => _lessonStatusToJson[this]!;

  static LessonStatus fromJson(String value) {
    return _lessonStatusFromJson[value] ??
        (throw ArgumentError('Unknown LessonStatus: $value'));
  }
}

const _lessonStatusToJson = {
  LessonStatus.notStarted: 'not_started',
  LessonStatus.inProgress: 'in_progress',
  LessonStatus.completed: 'completed',
  LessonStatus.locked: 'locked',
};

const _lessonStatusFromJson = {
  'not_started': LessonStatus.notStarted,
  'in_progress': LessonStatus.inProgress,
  'completed': LessonStatus.completed,
  'locked': LessonStatus.locked,
};

// ---------------------------------------------------------------------------

enum AchievementCategory {
  learning,
  streak,
  social,
  mastery,
  exploration;

  String toJson() => _achievementCategoryToJson[this]!;

  static AchievementCategory fromJson(String value) {
    return _achievementCategoryFromJson[value] ??
        (throw ArgumentError('Unknown AchievementCategory: $value'));
  }
}

const _achievementCategoryToJson = {
  AchievementCategory.learning: 'learning',
  AchievementCategory.streak: 'streak',
  AchievementCategory.social: 'social',
  AchievementCategory.mastery: 'mastery',
  AchievementCategory.exploration: 'exploration',
};

const _achievementCategoryFromJson = {
  'learning': AchievementCategory.learning,
  'streak': AchievementCategory.streak,
  'social': AchievementCategory.social,
  'mastery': AchievementCategory.mastery,
  'exploration': AchievementCategory.exploration,
};

// ---------------------------------------------------------------------------

enum PeriodType {
  daily,
  weekly,
  monthly,
  allTime;

  String toJson() => _periodTypeToJson[this]!;

  static PeriodType fromJson(String value) {
    return _periodTypeFromJson[value] ??
        (throw ArgumentError('Unknown PeriodType: $value'));
  }
}

const _periodTypeToJson = {
  PeriodType.daily: 'daily',
  PeriodType.weekly: 'weekly',
  PeriodType.monthly: 'monthly',
  PeriodType.allTime: 'all_time',
};

const _periodTypeFromJson = {
  'daily': PeriodType.daily,
  'weekly': PeriodType.weekly,
  'monthly': PeriodType.monthly,
  'all_time': PeriodType.allTime,
};
