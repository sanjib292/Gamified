import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../buttons/mq_primary_button.dart';
import '../buttons/mq_secondary_button.dart';

/// Full-screen celebration overlay shown when the user levels up.
///
/// Blurs the content behind it, plays confetti, and presents the new level
/// number plus title. Provides "Awesome!" (dismiss) and "Share" (stub) CTAs.
///
/// Usage:
/// ```dart
/// LevelUpOverlay.show(context, newLevel: 5, title: 'Scholar');
/// ```
class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay._({
    required this.newLevel,
    required this.title,
    required this.onDone,
  });

  final int newLevel;
  final String title;
  final VoidCallback onDone;

  static void show(
    BuildContext context, {
    required int newLevel,
    required String title,
  }) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => LevelUpOverlay._(
        newLevel: newLevel,
        title: title,
        onDone: () => entry?.remove(),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
      duration: const Duration(seconds: 4),
    )..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blur backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: ColoredBox(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // Confetti cannon — fires from top-centre
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 28,
              colors: const [
                AppColors.primary,
                AppColors.xpGold,
                AppColors.accent,
                Colors.white,
                AppColors.success,
              ],
              gravity: 0.35,
              emissionFrequency: 0.06,
            ),
          ),

          // Central card
          Center(
            child: _LevelUpCard(
              newLevel: widget.newLevel,
              title: widget.title,
              onDismiss: widget.onDone,
              onShare: () {
                // Share stub — integrate with platform share sheet
                widget.onDone();
              },
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 450.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );
  }
}

class _LevelUpCard extends StatelessWidget {
  const _LevelUpCard({
    required this.newLevel,
    required this.title,
    required this.onDismiss,
    required this.onShare,
  });

  final int newLevel;
  final String title;
  final VoidCallback onDismiss;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level-up label
          Text(
            'LEVEL UP!',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Lottie placeholder — swap with actual Lottie asset
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Center(
              child: Text(
                '$newLevel',
                style: AppTextStyles.statLarge.copyWith(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.04,
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: AppSpacing.md),

          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You\'ve reached level $newLevel. Keep learning!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // CTAs
          MqPrimaryButton(
            label: 'Awesome!',
            onPressed: onDismiss,
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.sm),
          MqSecondaryButton(
            label: 'Share',
            onPressed: onShare,
            icon: Icons.share_rounded,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
