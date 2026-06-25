import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.xpTotal = 0,
    this.level = 1,
    this.email = '',
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final int xpTotal;
  final int level;
  final String email;

  Profile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    int? xpTotal,
    int? level,
    String? email,
  }) =>
      Profile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        xpTotal: xpTotal ?? this.xpTotal,
        level: level ?? this.level,
        email: email ?? this.email,
      );
}

// ---------------------------------------------------------------------------
// Streak
// ---------------------------------------------------------------------------

class Streak {
  const Streak({
    required this.currentDays,
    required this.longestDays,
    this.activeDates = const [],
  });

  final int currentDays;
  final int longestDays;

  /// ISO date strings (yyyy-MM-dd) for the last 7 days of activity.
  final List<String> activeDates;
}

// ---------------------------------------------------------------------------
// UserAchievement — earned achievement + date
// ---------------------------------------------------------------------------

class UserAchievement {
  const UserAchievement({
    required this.achievement,
    required this.earnedAt,
  });

  final Achievement achievement;
  final DateTime earnedAt;
}

// ---------------------------------------------------------------------------
// ProfileStats — aggregate
// ---------------------------------------------------------------------------

class ProfileStats {
  const ProfileStats({
    required this.profile,
    required this.streak,
    required this.recentAchievements,
    this.totalAchievements = 0,
    this.completedBooks = const [],
    this.totalLessonsCompleted = 0,
  });

  final Profile profile;
  final Streak streak;
  final List<UserAchievement> recentAchievements;
  final int totalAchievements;
  final List<Book> completedBooks;
  final int totalLessonsCompleted;

  ProfileStats copyWith({
    Profile? profile,
    Streak? streak,
    List<UserAchievement>? recentAchievements,
    int? totalAchievements,
    List<Book>? completedBooks,
    int? totalLessonsCompleted,
  }) =>
      ProfileStats(
        profile: profile ?? this.profile,
        streak: streak ?? this.streak,
        recentAchievements:
            recentAchievements ?? this.recentAchievements,
        totalAchievements:
            totalAchievements ?? this.totalAchievements,
        completedBooks: completedBooks ?? this.completedBooks,
        totalLessonsCompleted:
            totalLessonsCompleted ?? this.totalLessonsCompleted,
      );
}
