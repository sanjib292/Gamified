import 'package:supabase_flutter/supabase_flutter.dart';

/// A single row in the leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.xpAmount,
    this.isCurrentUser = false,
  });

  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int xpAmount;
  final bool isCurrentUser;
}

/// Leaderboard time period.
enum LeaderboardPeriod { weekly, monthly, allTime }

/// Data source for leaderboard data.
class LeaderboardDataSource {
  const LeaderboardDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<LeaderboardEntry>> fetchLeaderboard(
    LeaderboardPeriod period,
    String? currentUserId,
  ) async {
    // Choose the correct view/table per period.
    final tableName = switch (period) {
      LeaderboardPeriod.weekly => 'leaderboard_weekly',
      LeaderboardPeriod.monthly => 'leaderboard_monthly',
      LeaderboardPeriod.allTime => 'leaderboard_all_time',
    };

    final rows = await _supabase
        .from(tableName)
        .select('rank, user_id, display_name, avatar_url, xp_amount')
        .order('rank')
        .limit(100);

    return rows.asMap().entries.map<LeaderboardEntry>((entry) {
      final row = entry.value;
      final userId = row['user_id'] as String;
      return LeaderboardEntry(
        rank: (row['rank'] as num?)?.toInt() ?? (entry.key + 1),
        userId: userId,
        displayName: row['display_name'] as String? ?? 'Learner',
        avatarUrl: row['avatar_url'] as String?,
        xpAmount: (row['xp_amount'] as num?)?.toInt() ?? 0,
        isCurrentUser: userId == currentUserId,
      );
    }).toList();
  }
}
