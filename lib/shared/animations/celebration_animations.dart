import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/overlays/level_up_overlay.dart';
import '../widgets/overlays/streak_overlay.dart';
import '../widgets/overlays/xp_gain_overlay.dart';

/// Central façade for all celebration effects in MindQuest.
///
/// Coordinates overlay display, sound effects, and haptic feedback so that
/// every call site uses a single, consistent API.
abstract final class CelebrationAnimations {
  // ---------------------------------------------------------------------------
  // XP burst
  // ---------------------------------------------------------------------------

  /// Shows the floating "+N XP" overlay at [context].
  static void showXpBurst(BuildContext context, int amount) {
    XpGainOverlay.show(context, amount);
  }

  // ---------------------------------------------------------------------------
  // Level up
  // ---------------------------------------------------------------------------

  /// Shows the full-screen level-up celebration for [level] with [title].
  static void showLevelUp(
    BuildContext context, {
    required int level,
    required String title,
  }) {
    LevelUpOverlay.show(context, newLevel: level, title: title);
  }

  // ---------------------------------------------------------------------------
  // Streak milestone
  // ---------------------------------------------------------------------------

  /// Shows the streak milestone bottom-sheet overlay for [days] days.
  static void showStreakMilestone(BuildContext context, int days) {
    StreakOverlay.show(context, days: days);
  }

  // ---------------------------------------------------------------------------
  // Correct answer
  // ---------------------------------------------------------------------------

  /// Plays the correct-answer SFX and triggers a light haptic.
  ///
  /// Callers are responsible for applying [AnimationPresets.correctFlash()]
  /// to the relevant widget; this method handles only the feedback layer.
  static Future<void> showCorrectAnswer(BuildContext context) async {
    await Future.wait([
      _playSfx('audio/correct.mp3'),
      HapticFeedback.lightImpact(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Wrong answer
  // ---------------------------------------------------------------------------

  /// Plays the wrong-answer SFX and triggers an error haptic (medium impact).
  ///
  /// Callers are responsible for applying [AnimationPresets.wrongShake()]
  /// to the relevant widget.
  static Future<void> showWrongAnswer(BuildContext context) async {
    await Future.wait([
      _playSfx('audio/wrong.mp3'),
      HapticFeedback.mediumImpact(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static Future<void> _playSfx(String assetPath) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(assetPath));
      // Auto-disposes after playback completes
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (_) {
      // Audio failure is non-fatal — swallow silently so the UI is unaffected
    }
  }
}
