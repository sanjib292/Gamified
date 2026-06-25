import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Extension methods on [Widget] providing reusable animation presets
/// for MindQuest UI components.
///
/// Usage:
/// ```dart
/// MyWidget().cardEntrance()
/// MyWidget().correctFlash()
/// MyWidget().wrongShake()
/// MyWidget().pulsingGlow()
/// ```
extension AnimationPresets on Widget {
  // ---------------------------------------------------------------------------
  // Card entrance
  // ---------------------------------------------------------------------------

  /// Fades in and slides up from a slight offset — used for list/grid cards
  /// entering the viewport.
  ///
  /// Duration 300 ms, begin offset 0.15 of its own height downward.
  Animate cardEntrance({
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 300.ms,
          curve: curve,
        );
  }

  // ---------------------------------------------------------------------------
  // Correct answer flash
  // ---------------------------------------------------------------------------

  /// Scales up briefly then back down with a green tint — played when the
  /// user selects a correct answer.
  ///
  /// 150 ms scale-up → 150 ms scale-back + green tint overlay.
  Animate correctFlash() {
    return animate()
        .scaleXY(
          begin: 1.0,
          end: 1.1,
          duration: 150.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scaleXY(
          begin: 1.1,
          end: 1.0,
          duration: 150.ms,
          curve: Curves.easeIn,
        )
        .tint(
          color: const Color(0xFF22C55E),
          duration: 120.ms,
        )
        .then()
        .tint(
          color: Colors.transparent,
          duration: 200.ms,
        );
  }

  // ---------------------------------------------------------------------------
  // Wrong answer shake
  // ---------------------------------------------------------------------------

  /// Sinusoidal horizontal shake — played when the user selects a wrong answer.
  ///
  /// Shifts x in a dampened oscillation over 500 ms.
  Animate wrongShake() {
    return animate().custom(
      duration: 500.ms,
      builder: (context, value, child) {
        // Sinusoidal shake with exponential damping: x(t) = A * sin(f*t) * e^(-d*t)
        const amplitude = 12.0;
        const frequency = 4.0;
        const damping = 6.0;
        final offset = amplitude *
            math.sin(frequency * value * math.pi * 2) *
            math.exp(-damping * value);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Pulsing glow (infinite)
  // ---------------------------------------------------------------------------

  /// Scales slightly up and back on a loop — used for active lesson nodes
  /// and highlight states.
  ///
  /// [period] controls one complete oscillation. Loops indefinitely.
  Animate pulsingGlow({
    Duration period = const Duration(milliseconds: 1000),
  }) {
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scaleXY(
      begin: 1.0,
      end: 1.05,
      duration: period,
      curve: Curves.easeInOut,
    );
  }
}

// ---------------------------------------------------------------------------
// AnimateList extension
// ---------------------------------------------------------------------------

extension AnimateListPresets on AnimateList {
  /// Staggers children by [stagger] delay intervals — applied on top of any
  /// existing animate calls.
  AnimateList staggeredEntrance({
    Duration stagger = const Duration(milliseconds: 60),
  }) {
    return interval(stagger);
  }
}
