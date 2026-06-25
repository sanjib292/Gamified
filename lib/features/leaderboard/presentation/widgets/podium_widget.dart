import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/leaderboard_data_source.dart';

/// Top-3 podium widget.
///
/// Rank 1 is center and elevated; ranks 2 & 3 flank on sides.
/// Uses [CustomPaint] for the stepped platform shapes.
class PodiumWidget extends StatelessWidget {
  const PodiumWidget({
    super.key,
    required this.first,
    required this.second,
    required this.third,
  });

  final LeaderboardEntry first;
  final LeaderboardEntry? second;
  final LeaderboardEntry? third;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank 2 — left
          if (second != null)
            _PodiumSlot(entry: second!, height: 100, rankColor: const Color(0xFFC0C0C0))
          else
            const SizedBox(width: 90),

          const SizedBox(width: AppSpacing.sm),

          // Rank 1 — center, taller
          _PodiumSlot(entry: first, height: 130, rankColor: AppColors.xpGold),

          const SizedBox(width: AppSpacing.sm),

          // Rank 3 — right
          if (third != null)
            _PodiumSlot(
                entry: third!, height: 80, rankColor: const Color(0xFFCD7F32))
          else
            const SizedBox(width: 90),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.height,
    required this.rankColor,
  });

  final LeaderboardEntry entry;
  final double height;
  final Color rankColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          _RankAvatar(entry: entry, rankColor: rankColor),
          const SizedBox(height: AppSpacing.xs),
          // Name
          Text(
            entry.displayName,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // XP
          Text(
            _formatXp(entry.xpAmount),
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.xpGold, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Platform
          _Platform(height: height, rankColor: rankColor, rank: entry.rank),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({required this.entry, required this.rankColor});

  final LeaderboardEntry entry;
  final Color rankColor;

  @override
  Widget build(BuildContext context) {
    final initials = entry.displayName.isNotEmpty
        ? entry.displayName[0].toUpperCase()
        : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 2.5),
            color: AppColors.surfaceVariant,
          ),
          child: ClipOval(
            child: entry.avatarUrl != null
                ? Image.network(entry.avatarUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _InitialsPlaceholder(initials: initials))
                : _InitialsPlaceholder(initials: initials),
          ),
        ),
        Positioned(
          bottom: -6,
          right: -6,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsPlaceholder extends StatelessWidget {
  const _InitialsPlaceholder({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.15),
      alignment: Alignment.center,
      child: Text(initials,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform({
    required this.height,
    required this.rankColor,
    required this.rank,
  });

  final double height;
  final Color rankColor;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            rankColor.withOpacity(0.7),
            rankColor.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: AppTextStyles.headlineSmall
              .copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }
}
