import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../../../shared/widgets/xp_progress_bar.dart';
import '../../data/models/profile_stats.dart';
import '../providers/profile_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: state.when(
        loading: () => const MqFullPageLoading(),
        error: (err, _) => MqSimpleError(
          message: err.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (stats) => _ProfileContent(stats: stats),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile content
// ---------------------------------------------------------------------------

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelTitle = ref.watch(levelTitleProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(profileProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar + name + level
            _AvatarSection(
              stats: stats,
              levelTitle: levelTitle,
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSpacing.md),

            // XP progress bar
            XpProgressBar(
              currentXp: stats.profile.xpTotal,
              level: stats.profile.level,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),

            const SizedBox(height: AppSpacing.lg),

            // Stats grid
            _StatsGrid(stats: stats)
                .animate()
                .fadeIn(duration: 300.ms, delay: 120.ms),

            const SizedBox(height: AppSpacing.lg),

            // Streak calendar
            _StreakCalendar(streak: stats.streak)
                .animate()
                .fadeIn(duration: 300.ms, delay: 160.ms),

            const SizedBox(height: AppSpacing.lg),

            // Recent achievements
            _RecentAchievements(
              stats: stats,
              onViewAll: () => context.push(RouteNames.achievements),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar section
// ---------------------------------------------------------------------------

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.stats, required this.levelTitle});

  final ProfileStats stats;
  final String levelTitle;

  @override
  Widget build(BuildContext context) {
    final profile = stats.profile;
    final initials = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : 'M';

    return Row(
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: profile.avatarUrl != null &&
                        profile.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _InitialsAvatar(initials: initials),
                      )
                    : _InitialsAvatar(initials: initials),
              ),
            ),
            // Level badge
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(
                      color: AppColors.background, width: 2),
                ),
                child: Text(
                  'Lv. ${profile.level}',
                  style: AppTextStyles.levelBadge,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.displayName,
                  style: AppTextStyles.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(levelTitle,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.streakFire, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.streak.currentDays} day streak',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.streakFire),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.streakFire,
          value: '${stats.streak.currentDays}',
          label: 'Day Streak'),
      _StatItem(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          value: '${stats.totalLessonsCompleted}',
          label: 'Lessons'),
      _StatItem(
          icon: Icons.menu_book_rounded,
          color: AppColors.info,
          value: '${stats.completedBooks.length}',
          label: 'Books'),
      _StatItem(
          icon: Icons.star_rounded,
          color: AppColors.xpGold,
          value: _formatXp(stats.profile.xpTotal),
          label: 'Total XP'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.value, style: AppTextStyles.headlineSmall),
          Text(item.label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak calendar
// ---------------------------------------------------------------------------

class _StreakCalendar extends StatelessWidget {
  const _StreakCalendar({required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final activeDateStrings = streak.activeDates.toSet();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity', style: AppTextStyles.titleSmall),
              Text(
                'Best: ${streak.longestDays} days',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final date = today.subtract(Duration(days: 6 - i));
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final isActive = activeDateStrings.contains(dateStr);
              final isToday = i == 6;

              return Column(
                children: [
                  Text(
                    _dayLabel(date.weekday),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: isActive
                        ? const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : Center(
                            child: Text(
                              '${date.day}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.textHint),
                            ),
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String _dayLabel(int weekday) => const [
        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
      ][weekday - 1];
}

// ---------------------------------------------------------------------------
// Recent achievements
// ---------------------------------------------------------------------------

class _RecentAchievements extends StatelessWidget {
  const _RecentAchievements({
    required this.stats,
    required this.onViewAll,
  });

  final ProfileStats stats;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements', style: AppTextStyles.titleMedium),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View all ${stats.totalAchievements}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        stats.recentAchievements.isEmpty
            ? Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'Complete lessons to unlock achievements!',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.sm,
                children: stats.recentAchievements
                    .map((ua) => AchievementBadgeTile(
                          achievement: ua.achievement,
                          isEarned: true,
                        ))
                    .toList(),
              ),
      ],
    );
  }
}
