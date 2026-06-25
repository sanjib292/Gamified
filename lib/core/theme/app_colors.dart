import 'package:flutter/material.dart';

/// Centralised colour palette for MindQuest.
///
/// All values are `static const` so they are compiled as constants.
/// Gradient helpers are `static final` because [LinearGradient] is not const.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF8B7CF8);
  static const Color accent = Color(0xFFA29BFE);

  // ---------------------------------------------------------------------------
  // Light theme surfaces
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EEFF);

  // ---------------------------------------------------------------------------
  // Light theme text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textHint = Color(0xFFAAAAAA);

  // ---------------------------------------------------------------------------
  // Semantic / status colours
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Gamification
  // ---------------------------------------------------------------------------

  static const Color xpGold = Color(0xFFF59E0B);
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color correct = Color(0xFF22C55E);
  static const Color wrong = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // Level tier colours
  // ---------------------------------------------------------------------------

  /// Levels 1–5
  static const Color tierExplorer = Colors.blueGrey;

  /// Levels 6–10
  static const Color tierScholar = Color(0xFF3B82F6);

  /// Levels 11–15
  static const Color tierMaster = Color(0xFF6C5CE7);

  /// Levels 16+
  static const Color tierLegend = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Dark theme variants
  // ---------------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF0E0E1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkTextPrimary = Color(0xFFF2F2FF);
  static const Color darkTextSecondary = Color(0xFFAAAACC);
  static const Color darkTextHint = Color(0xFF666688);

  // ---------------------------------------------------------------------------
  // Gradient helpers
  // ---------------------------------------------------------------------------

  /// Primary brand gradient used on hero cards and CTA buttons.
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary, accent],
    stops: const [0.0, 0.55, 1.0],
  );

  /// Subtle gradient for content cards.
  static final LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceVariant],
  );

  /// Dark-mode card gradient.
  static final LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkSurfaceVariant],
  );

  /// XP / gold shimmer gradient.
  static final LinearGradient xpGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [xpGold, const Color(0xFFFFD166)],
  );

  /// Streak gradient (fire orange → red).
  static final LinearGradient streakGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [streakFire, const Color(0xFFFF3E5E)],
  );

  // ---------------------------------------------------------------------------
  // Shimmer skeleton
  // ---------------------------------------------------------------------------

  static const Color shimmerBase = Color(0xFFE8E8F0);
  static const Color shimmerHighlight = Color(0xFFF4F4FC);

  // ---------------------------------------------------------------------------
  // Overlay / scrim
  // ---------------------------------------------------------------------------

  static const Color scrim = Color(0x80000000);
  static const Color divider = Color(0xFFE8E8F0);
  static const Color darkDivider = Color(0xFF2A2A40);
}
