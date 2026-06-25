import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bottom-sheet style streak milestone overlay.
///
/// Shown when the user hits a 7, 14, or 30-day streak. Displays the streak
/// count prominently with a flame animation. Auto-dismisses after 3 seconds.
///
/// Usage:
/// ```dart
/// StreakOverlay.show(context, days: 7);
/// ```
class StreakOverlay extends StatefulWidget {
  const StreakOverlay._({
    required this.days,
    required this.onDone,
  });

  final int days;
  final VoidCallback onDone;

  static void show(BuildContext context, {required int days}) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => StreakOverlay._(
        days: days,
        onDone: () => entry?.remove(),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  @override
  State<StreakOverlay> createState() => _StreakOverlayState();
}

class _StreakOverlayState extends State<StreakOverlay> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _visible = false);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_visible,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: _StreakSheet(days: widget.days),
          ),
        ),
      ),
    );
  }
}

class _StreakSheet extends StatelessWidget {
  const _StreakSheet({required this.days});
  final int days;

  String get _milestoneLabel {
    if (days >= 30) return '30-Day Streak Legend';
    if (days >= 14) return '2-Week Streak';
    return 'Week Warrior';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.streakFire,
              const Color(0xFFFF3E5E),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.streakFire.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flame icon — Lottie placeholder
            _FlameWidget()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.12,
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(width: AppSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$days day streak!',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _milestoneLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Streak count badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$days',
                  style: AppTextStyles.statLarge.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for the Lottie flame animation.
/// Replace the [Icon] with a [Lottie.asset] when the animation file is available.
class _FlameWidget extends StatelessWidget {
  const _FlameWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 52,
      height: 52,
      child: Center(
        child: Text(
          '🔥',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
