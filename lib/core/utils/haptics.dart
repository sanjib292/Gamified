import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] that provides semantically named
/// methods for common interaction patterns.
///
/// All methods silently no-op on platforms that don't support haptics
/// (e.g., web, most desktop targets).
abstract final class HapticsService {
  // ---------------------------------------------------------------------------
  // Impact intensities
  // ---------------------------------------------------------------------------

  /// Light tap — use for selection changes, button presses, scroll snaps.
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  /// Medium tap — use for confirming an action, card dismissals.
  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  /// Heavy tap — use for destructive actions, hard stops.
  static Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  // ---------------------------------------------------------------------------
  // Notification feedback
  // ---------------------------------------------------------------------------

  /// Double-tap pattern — use when the user earns XP, completes a lesson,
  /// unlocks an achievement, or any other positive outcome.
  static Future<void> successNotification() =>
      HapticFeedback.mediumImpact().then(
        (_) => Future.delayed(
          const Duration(milliseconds: 80),
          HapticFeedback.mediumImpact,
        ),
      );

  /// Warning buzz — use for incorrect quiz answers, validation failures.
  static Future<void> errorNotification() => HapticFeedback.heavyImpact();

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  /// Subtle tick — use for list-item selection, toggle changes, character input.
  static Future<void> selectionClick() => HapticFeedback.selectionClick();

  /// Vibration pattern for streak milestone (three rapid pulses).
  static Future<void> streakMilestone() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.heavyImpact();
  }

  /// Single long vibration — use for level-up celebrations.
  static Future<void> levelUp() => HapticFeedback.heavyImpact();
}
