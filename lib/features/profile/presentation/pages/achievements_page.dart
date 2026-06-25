import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../data/models/profile_stats.dart';
import '../providers/profile_notifier.dart';

// ---------------------------------------------------------------------------
// Achievements page
// ---------------------------------------------------------------------------

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Achievements', style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: profileState.when(
        loading: () => const MqFullPageLoading(),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (stats) => _AllAchievementsList(
          earnedIds: stats.recentAchievements
              .map((ua) => ua.achievement.id)
              .toSet(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loads ALL achievements from DB, marks earned vs unearned
// ---------------------------------------------------------------------------

final _allAchievementsProvider =
    FutureProvider<List<Achievement>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase
      .from('achievements')
      .select('id, title, description, icon_name, color_hex, category')
      .order('category')
      .order('title');

  return rows.map<Achievement>((row) {
    final colorHex = row['color_hex'] as String? ?? '#6C5CE7';
    final color = _hexToColor(colorHex);
    return Achievement(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      icon: _iconForName(row['icon_name'] as String? ?? 'star'),
      color: color,
    );
  }).toList();
});

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

IconData _iconForName(String name) => switch (name) {
      'book' => Icons.menu_book_rounded,
      'fire' => Icons.local_fire_department_rounded,
      'star' => Icons.star_rounded,
      'trophy' => Icons.emoji_events_rounded,
      'brain' => Icons.psychology_rounded,
      'lightning' => Icons.bolt_rounded,
      _ => Icons.star_rounded,
    };

class _AllAchievementsList extends ConsumerWidget {
  const _AllAchievementsList({required this.earnedIds});

  final Set<String> earnedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allState = ref.watch(_allAchievementsProvider);

    return allState.when(
      loading: () => const MqFullPageLoading(),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (achievements) {
        // Group by category.
        final grouped = <String, List<Achievement>>{};
        for (final a in achievements) {
          grouped.putIfAbsent(a.id.split('_').first, () => []).add(a);
        }

        // Flat list: earned first, then unearned.
        final earned = achievements.where((a) => earnedIds.contains(a.id)).toList();
        final unearned =
            achievements.where((a) => !earnedIds.contains(a.id)).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Earned section
            if (earned.isNotEmpty)
              _AchievementSection(
                title: 'Earned (${earned.length})',
                achievements: earned,
                isEarned: true,
              ),

            // Unearned section
            if (unearned.isNotEmpty)
              _AchievementSection(
                title: 'Still to Unlock (${unearned.length})',
                achievements: unearned,
                isEarned: false,
              ),

            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
          ],
        );
      },
    );
  }
}

class _AchievementSection extends StatelessWidget {
  const _AchievementSection({
    required this.title,
    required this.achievements,
    required this.isEarned,
  });

  final String title;
  final List<Achievement> achievements;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
            child: Text(title, style: AppTextStyles.titleSmall),
          ),
          Padding(
            padding: AppSpacing.hPaddingMd,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.sm,
              children: achievements
                  .asMap()
                  .entries
                  .map((e) => AchievementBadgeTile(
                        achievement: e.value,
                        isEarned: isEarned,
                      ).animate().fadeIn(
                          duration: 200.ms,
                          delay: Duration(
                              milliseconds: e.key * 40)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
