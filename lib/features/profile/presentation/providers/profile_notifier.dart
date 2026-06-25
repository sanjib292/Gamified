import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../book_detail/data/models/book_detail_model.dart' show hexToColor;
import '../../data/models/profile_stats.dart';

// ---------------------------------------------------------------------------
// Profile notifier
// ---------------------------------------------------------------------------

class ProfileNotifier extends AsyncNotifier<ProfileStats> {
  @override
  FutureOr<ProfileStats> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) throw StateError('Not authenticated');

    return _loadProfile(supabase, userId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateDisplayName(String name) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await supabase
        .from('profiles')
        .update({'display_name': name}).eq('id', userId);

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
          profile: current.profile.copyWith(displayName: name)));
    }
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileStats>(
  ProfileNotifier.new,
  name: 'profileProvider',
);

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

final userLevelProvider = Provider<int>((ref) {
  final stats = ref.watch(profileProvider).valueOrNull;
  return stats?.profile.level ?? 1;
});

final xpProgressProvider = Provider<double>((ref) {
  final stats = ref.watch(profileProvider).valueOrNull;
  if (stats == null) return 0.0;
  final xp = stats.profile.xpTotal;
  final level = stats.profile.level;
  final xpForCurrent = XpCalculator.xpForLevel(level);
  final xpForNext = XpCalculator.xpForLevel(level + 1);
  if (xpForNext <= xpForCurrent) return 1.0;
  return ((xp - xpForCurrent) / (xpForNext - xpForCurrent)).clamp(0.0, 1.0);
});

final levelTitleProvider = Provider<String>((ref) {
  final level = ref.watch(userLevelProvider);
  return switch (level) {
    <= 5 => 'Explorer',
    <= 10 => 'Scholar',
    <= 15 => 'Master',
    <= 20 => 'Sage',
    _ => 'Legend',
  };
});

// ---------------------------------------------------------------------------
// Internal loader
// ---------------------------------------------------------------------------

Future<ProfileStats> _loadProfile(
    SupabaseClient supabase, String userId) async {
  // Run independent queries concurrently using typed futures.
  final profileFuture = supabase
      .from('profiles')
      .select('id, display_name, avatar_url, xp_total, level, email')
      .eq('id', userId)
      .single();

  final streakFuture = supabase
      .from('streaks')
      .select('current_days, longest_days, active_dates')
      .eq('user_id', userId)
      .maybeSingle();

  final achievementsFuture = supabase
      .from('user_achievements')
      .select('earned_at, achievements(id, title, description, icon_name, color_hex)')
      .eq('user_id', userId)
      .order('earned_at', ascending: false)
      .limit(10);

  final achievementsCountFuture = supabase
      .from('user_achievements')
      .select()
      .eq('user_id', userId)
      .count(CountOption.exact);

  final completedBooksFuture = supabase
      .from('user_progress')
      .select('book_id, books(id, title, author, cover_url, difficulty)')
      .eq('user_id', userId)
      .eq('status', 'completed');

  final lessonsCountFuture = supabase
      .from('user_progress')
      .select()
      .eq('user_id', userId)
      .eq('status', 'completed')
      .count(CountOption.exact);

  final profileRow = await profileFuture;
  final streakRow = await streakFuture;
  final achievementRows = await achievementsFuture;
  final achievementsCountResp = await achievementsCountFuture;
  final completedBookRows = await completedBooksFuture;
  final lessonsCountResp = await lessonsCountFuture;

  final totalAchievements = achievementsCountResp.count;
  final totalLessons = lessonsCountResp.count;

  final profile = Profile(
    id: profileRow['id'] as String,
    displayName: profileRow['display_name'] as String? ?? 'Learner',
    avatarUrl: profileRow['avatar_url'] as String?,
    xpTotal: (profileRow['xp_total'] as num?)?.toInt() ?? 0,
    level: (profileRow['level'] as num?)?.toInt() ?? 1,
    email: profileRow['email'] as String? ?? '',
  );

  final streak = streakRow != null
      ? Streak(
          currentDays:
              (streakRow['current_days'] as num?)?.toInt() ?? 0,
          longestDays:
              (streakRow['longest_days'] as num?)?.toInt() ?? 0,
          activeDates: List<String>.from(
              streakRow['active_dates'] as List? ?? []),
        )
      : const Streak(currentDays: 0, longestDays: 0);

  final recentAchievements = achievementRows.map<UserAchievement>((row) {
    final achRow =
        row['achievements'] as Map<String, dynamic>;
    final colorHex =
        achRow['color_hex'] as String? ?? '#6C5CE7';
    final color = _hexToColor(colorHex);
    return UserAchievement(
      achievement: Achievement(
        id: achRow['id'] as String,
        title: achRow['title'] as String,
        description: achRow['description'] as String?,
        icon: const IconData(0xe5f9, fontFamily: 'MaterialIcons'),
        color: color,
      ),
      earnedAt: DateTime.tryParse(row['earned_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }).toList();

  final completedBooks = completedBookRows.map<Book>((row) {
    final bookRow = row['books'] as Map<String, dynamic>;
    return _rowToBook(bookRow);
  }).toList();

  return ProfileStats(
    profile: profile,
    streak: streak,
    recentAchievements: recentAchievements,
    totalAchievements: totalAchievements,
    completedBooks: completedBooks,
    totalLessonsCompleted: totalLessons,
  );
}

Color _hexToColor(String hex) => hexToColor(hex);

Book _rowToBook(Map<String, dynamic> row) {
  final difficultyStr =
      (row['difficulty'] as String?)?.toLowerCase() ?? '';
  final difficulty = switch (difficultyStr) {
    'beginner' => BookDifficulty.beginner,
    'advanced' => BookDifficulty.advanced,
    _ => BookDifficulty.intermediate,
  };
  return Book(
    id: row['id'] as String,
    title: row['title'] as String,
    author: row['author'] as String? ?? '',
    coverUrl: row['cover_url'] as String? ?? '',
    difficulty: difficulty,
  );
}
