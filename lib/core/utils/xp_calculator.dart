import 'dart:math' as math;

/// Utility class for XP and level computations.
///
/// Level formula: level = floor(sqrt(xp / 100)) + 1  (minimum 1)
/// XP required for level N: (N - 1)^2 * 100
abstract final class XpCalculator {
  // ---------------------------------------------------------------------------
  // Level from XP
  // ---------------------------------------------------------------------------

  /// Returns the level (≥ 1) that corresponds to [xp] total XP.
  static int calculateLevel(int xp) {
    if (xp <= 0) return 1;
    return math.max(1, math.sqrt(xp / 100).floor() + 1);
  }

  // ---------------------------------------------------------------------------
  // XP thresholds
  // ---------------------------------------------------------------------------

  /// Minimum cumulative XP required to *reach* [level].
  ///
  /// Level 1 → 0 XP, Level 2 → 100 XP, Level 3 → 400 XP, etc.
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    final n = level - 1;
    return n * n * 100;
  }

  /// Cumulative XP required to reach the *next* level after [currentLevel].
  static int xpForNextLevel(int currentLevel) => xpForLevel(currentLevel + 1);

  // ---------------------------------------------------------------------------
  // Progress within current level
  // ---------------------------------------------------------------------------

  /// Fractional progress (0.0–1.0) within the current level.
  ///
  /// Returns 0.0 when [xp] is exactly at the level threshold,
  /// returns values approaching 1.0 as [xp] nears the next threshold.
  static double levelProgress(int xp) {
    final currentLevel = calculateLevel(xp);
    final currentThreshold = xpForLevel(currentLevel);
    final nextThreshold = xpForNextLevel(currentLevel);
    final span = nextThreshold - currentThreshold;
    if (span <= 0) return 1.0;
    final progress = (xp - currentThreshold) / span;
    return progress.clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // Level title / tier
  // ---------------------------------------------------------------------------

  /// Human-readable title for the given [level].
  static String getLevelTitle(int level) => switch (level) {
        1 => 'Curious Mind',
        2 => 'Eager Learner',
        3 => 'Knowledge Seeker',
        4 => 'Avid Reader',
        5 => 'Explorer',
        6 => 'Curious Scholar',
        7 => 'Diligent Scholar',
        8 => 'Seasoned Scholar',
        9 => 'Scholar',
        10 => 'Distinguished Scholar',
        11 => 'Apprentice Master',
        12 => 'Rising Master',
        13 => 'Master',
        14 => 'Grand Master',
        15 => 'Sage Master',
        16 => 'Legendary Sage',
        17 => 'Legend',
        18 => 'Grand Legend',
        19 => 'Supreme Legend',
        >= 20 => 'Eternal Luminary',
        _ => 'Novice',
      };

  /// Tier name (Explorer / Scholar / Master / Legend) based on [level].
  static String getTierName(int level) => switch (level) {
        <= 5 => 'Explorer',
        <= 10 => 'Scholar',
        <= 15 => 'Master',
        _ => 'Legend',
      };

  // ---------------------------------------------------------------------------
  // XP with bonuses
  // ---------------------------------------------------------------------------

  /// Applies a streak multiplier to a base XP amount.
  ///
  /// [streakDays] is the current day streak.  Multiplier caps at ×3.
  static int withStreakBonus(int baseXp, int streakDays) {
    final multiplier = switch (streakDays) {
      >= 7 => 3.0,
      >= 3 => 2.0,
      _ => 1.0,
    };
    return (baseXp * multiplier).round();
  }

  /// XP needed to reach the next full level from a given [xp] total.
  static int xpUntilNextLevel(int xp) {
    final currentLevel = calculateLevel(xp);
    return xpForNextLevel(currentLevel) - xp;
  }
}
