import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/mq_primary_button.dart';

/// Full-screen lesson completion card shown after the user finishes a lesson.
///
/// Triggers a confetti burst on mount and displays the XP earned + score.
class LessonCompleteWidget extends StatefulWidget {
  const LessonCompleteWidget({
    super.key,
    required this.xpEarned,
    required this.score,
    required this.onNextLesson,
  });

  final int xpEarned;
  final int score;
  final VoidCallback onNextLesson;

  @override
  State<LessonCompleteWidget> createState() =>
      _LessonCompleteWidgetState();
}

class _LessonCompleteWidgetState extends State<LessonCompleteWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Fire confetti on the next frame.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _confettiController.play());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti burst
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          colors: const [
            AppColors.primary,
            AppColors.xpGold,
            AppColors.success,
            AppColors.streakFire,
          ],
        ),

        // Content
        Center(
          child: Padding(
            padding: AppSpacing.paddingXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.xpGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.xpGold.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 56),
                )
                    .animate()
                    .scale(begin: const Offset(0.5, 0.5), duration: 500.ms,
                        curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.lg),

                Text('Lesson Complete!',
                    style: AppTextStyles.headlineSmall)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: AppSpacing.xl),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatPill(
                      icon: Icons.star_rounded,
                      label: '+${widget.xpEarned} XP',
                      color: AppColors.xpGold,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _StatPill(
                      icon: Icons.percent_rounded,
                      label: '${widget.score}% Score',
                      color: AppColors.success,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: AppSpacing.xxl),

                MqPrimaryButton(
                  label: 'Next Lesson',
                  onPressed: widget.onNextLesson,
                  width: double.infinity,
                  icon: Icons.arrow_forward_rounded,
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
