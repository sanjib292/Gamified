import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/xp_calculator.dart';

/// Animated horizontal XP progress bar.
///
/// Displays the current level on the left and the next level on the right.
/// The fill uses a primary→secondary gradient and glows when progress exceeds
/// 80%. Animates to new values over 600 ms with an ease-out curve.
class XpProgressBar extends StatefulWidget {
  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.level,
  });

  final int currentXp;
  final int level;

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  double _targetProgress = 0.0;
  double _previousProgress = 0.0;

  static const double _barHeight = 12.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _targetProgress = _computeProgress();
    _progressAnim =
        Tween<double>(begin: _targetProgress, end: _targetProgress)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(XpProgressBar old) {
    super.didUpdateWidget(old);
    if (old.currentXp != widget.currentXp || old.level != widget.level) {
      _previousProgress = _progressAnim.value;
      _targetProgress = _computeProgress();
      _progressAnim = Tween<double>(
        begin: _previousProgress,
        end: _targetProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _computeProgress() {
    final xpForCurrent = XpCalculator.xpForLevel(widget.level);
    final xpForNext = XpCalculator.xpForLevel(widget.level + 1);
    if (xpForNext <= xpForCurrent) return 1.0;
    final progress =
        (widget.currentXp - xpForCurrent) / (xpForNext - xpForCurrent);
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) {
        final progress = _progressAnim.value;
        final isGlowing = progress >= 0.8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv. ${widget.level}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Lv. ${widget.level + 1}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Bar
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusFull),
              child: Stack(
                children: [
                  // Track
                  Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: _barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull),
                        boxShadow: isGlowing
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.55),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // XP label
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.currentXp} XP',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
