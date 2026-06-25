import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Size variants for [AchievementBadge].
enum BadgeSize {
  /// 40 px — compact use in lists or achievement rows.
  small,

  /// 80 px — prominent use in profile and celebration overlays.
  large,
}

/// Minimal Achievement model surface used by [AchievementBadge].
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.description,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String? description;
}

/// Hexagonal badge with icon, colour tint, and earned/unearned opacity.
///
/// Uses a custom [CustomClipper] to render a flat-top hexagon on the large
/// variant. The small variant uses a circle for legibility at 40 px.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isEarned,
    this.size = BadgeSize.large,
  });

  final Achievement achievement;
  final bool isEarned;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEarned ? 1.0 : 0.38,
      child: size == BadgeSize.large
          ? _LargeBadge(achievement: achievement)
          : _SmallBadge(achievement: achievement),
    );
  }
}

// ---------------------------------------------------------------------------
// Large badge — 80 px hexagon
// ---------------------------------------------------------------------------

class _LargeBadge extends StatelessWidget {
  const _LargeBadge({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ClipPath(
        clipper: const _HexClipper(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                achievement.color.withOpacity(0.9),
                achievement.color.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(achievement.icon, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small badge — 40 px circle
// ---------------------------------------------------------------------------

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: achievement.color.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: achievement.color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(achievement.icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hexagon clip path
// ---------------------------------------------------------------------------

class _HexClipper extends CustomClipper<Path> {
  const _HexClipper();

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const sides = 6;
    final path = Path();

    for (int i = 0; i < sides; i++) {
      // Flat-top hexagon: start angle -30 degrees
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HexClipper old) => false;
}

// ---------------------------------------------------------------------------
// Convenience tile: badge + label
// ---------------------------------------------------------------------------

/// Stacks an [AchievementBadge] with its title below — useful in grids.
class AchievementBadgeTile extends StatelessWidget {
  const AchievementBadgeTile({
    super.key,
    required this.achievement,
    required this.isEarned,
    this.size = BadgeSize.large,
  });

  final Achievement achievement;
  final bool isEarned;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AchievementBadge(
          achievement: achievement,
          isEarned: isEarned,
          size: size,
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: isEarned ? 1.0 : 0.45,
          child: Text(
            achievement.title,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
