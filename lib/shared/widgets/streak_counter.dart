import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Size mode for [StreakCounter].
enum StreakCounterSize {
  /// Compact — used in AppBar / navigation areas (~32 px tall).
  compact,

  /// Large — used in profile screens and leaderboards.
  large,
}

/// Flame icon + streak count widget.
///
/// Pulses when [isActive] (user has maintained their streak today).
/// Supports [compact] (AppBar) and [large] (profile) size modes.
class StreakCounter extends StatelessWidget {
  const StreakCounter({
    super.key,
    required this.count,
    required this.isActive,
    this.size = StreakCounterSize.compact,
  });

  final int count;
  final bool isActive;
  final StreakCounterSize size;

  @override
  Widget build(BuildContext context) {
    final isLarge = size == StreakCounterSize.large;

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Flame — Lottie placeholder (replace with Lottie.asset)
        Text(
          '🔥',
          style: TextStyle(fontSize: isLarge ? 28 : 18),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: isLarge
              ? AppTextStyles.statLarge.copyWith(
                  color: AppColors.streakFire,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                )
              : AppTextStyles.streakCounter.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
        ),
        if (isLarge) ...[
          const SizedBox(width: 6),
          Text(
            'day streak',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (isActive) {
      row = row
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.08,
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return row;
  }
}
