import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../data/datasources/leaderboard_data_source.dart';
import '../widgets/podium_widget.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _leaderboardDataSourceProvider = Provider<LeaderboardDataSource>(
  (ref) => LeaderboardDataSource(ref.watch(supabaseClientProvider)),
);

final _leaderboardPeriodProvider =
    StateProvider<LeaderboardPeriod>((ref) => LeaderboardPeriod.weekly);

final _leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>,
    LeaderboardPeriod>((ref, period) async {
  final ds = ref.watch(_leaderboardDataSourceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ds.fetchLeaderboard(period, userId);
});

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(_leaderboardPeriodProvider);
    final leaderboardState = ref.watch(_leaderboardProvider(period));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Leaderboard', style: AppTextStyles.titleMedium),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _PeriodTabBar(
            selected: period,
            onChanged: (p) =>
                ref.read(_leaderboardPeriodProvider.notifier).state = p,
          ),
        ),
      ),
      body: leaderboardState.when(
        loading: () => const MqFullPageLoading(),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (entries) => _LeaderboardBody(
          entries: entries,
          currentUserId: currentUserId,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period tab bar
// ---------------------------------------------------------------------------

class _PeriodTabBar extends StatelessWidget {
  const _PeriodTabBar({
    required this.selected,
    required this.onChanged,
  });

  final LeaderboardPeriod selected;
  final void Function(LeaderboardPeriod) onChanged;

  static const _tabs = [
    (LeaderboardPeriod.weekly, 'Weekly'),
    (LeaderboardPeriod.monthly, 'Monthly'),
    (LeaderboardPeriod.allTime, 'All Time'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = selected == tab.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab.$2,
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaderboard body
// ---------------------------------------------------------------------------

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({
    required this.entries,
    required this.currentUserId,
  });

  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data yet — start learning!'),
      );
    }

    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    // Find current user's position (may be outside top 10).
    final currentUserEntry = entries
        .where((e) => e.userId == currentUserId)
        .firstOrNull;
    final userInTop10 = (currentUserEntry?.rank ?? 999) <= 10;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Podium
            SliverToBoxAdapter(
              child: PodiumWidget(
                first: top3[0],
                second: top3.length > 1 ? top3[1] : null,
                third: top3.length > 2 ? top3[2] : null,
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Rank list (4+)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md,
                  // Extra bottom padding when sticky bar is shown.
                  userInTop10 ? AppSpacing.md : 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final entry = rest[i];
                    return _RankRow(entry: entry)
                        .animate()
                        .fadeIn(duration: 200.ms,
                            delay: Duration(milliseconds: i * 40));
                  },
                  childCount: rest.length,
                ),
              ),
            ),
          ],
        ),

        // Sticky current-user row at bottom if not in top 10.
        if (!userInTop10 && currentUserEntry != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.sm),
                  _RankRow(entry: currentUserEntry),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rank row
// ---------------------------------------------------------------------------

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary.withOpacity(0.4))
            : Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: ClipOval(
              child: entry.avatarUrl != null
                  ? Image.network(entry.avatarUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Initials(entry.displayName))
                  : _Initials(entry.displayName),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Name
          Expanded(
            child: Text(
              entry.displayName +
                  (entry.isCurrentUser ? ' (You)' : ''),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: entry.isCurrentUser
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // XP
          Text(
            _formatXp(entry.xpAmount),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.xpGold,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}

class _Initials extends StatelessWidget {
  const _Initials(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.15),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}
