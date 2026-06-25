import 'package:flutter/material.dart';

/// Spacing and sizing constants for MindQuest.
///
/// Use these values everywhere instead of hard-coded numbers to keep the
/// layout grid consistent across the app.
abstract final class AppSpacing {
  // ---------------------------------------------------------------------------
  // Base spacing scale (logical pixels)
  // ---------------------------------------------------------------------------

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ---------------------------------------------------------------------------
  // Symmetric EdgeInsets helpers
  // ---------------------------------------------------------------------------

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // ---------------------------------------------------------------------------
  // Horizontal-only EdgeInsets helpers
  // ---------------------------------------------------------------------------

  static const EdgeInsets hPaddingSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets hPaddingMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hPaddingLg = EdgeInsets.symmetric(horizontal: lg);

  // ---------------------------------------------------------------------------
  // Vertical-only EdgeInsets helpers
  // ---------------------------------------------------------------------------

  static const EdgeInsets vPaddingSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vPaddingMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets vPaddingLg = EdgeInsets.symmetric(vertical: lg);

  // ---------------------------------------------------------------------------
  // Page / screen-level padding
  // ---------------------------------------------------------------------------

  /// Standard horizontal padding for full-width screen content.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md);

  /// Padding for content inside a card or sheet.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // ---------------------------------------------------------------------------
  // SizedBox gap helpers
  // ---------------------------------------------------------------------------

  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);

  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);

  // ---------------------------------------------------------------------------
  // Border radii
  // ---------------------------------------------------------------------------

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ---------------------------------------------------------------------------
  // Icon sizes
  // ---------------------------------------------------------------------------

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ---------------------------------------------------------------------------
  // Common component sizes
  // ---------------------------------------------------------------------------

  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double cardElevation = 2.0;
  static const double bottomNavHeight = 64.0;
  static const double appBarHeight = 60.0;
}
