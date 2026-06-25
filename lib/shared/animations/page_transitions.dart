import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom [GoRouter] page transition builders for MindQuest.
///
/// Each builder wraps a [CustomTransitionPage] and can be used directly in
/// GoRouter route definitions:
///
/// ```dart
/// GoRoute(
///   path: '/lesson/:id',
///   pageBuilder: (context, state) => slideUpTransition(
///     context: context,
///     state: state,
///     child: const LessonPlayerScreen(),
///   ),
/// ),
/// ```

// ---------------------------------------------------------------------------
// Slide-up transition — lesson player
// ---------------------------------------------------------------------------

/// Slides the incoming page up from the bottom of the screen.
///
/// Used for the lesson player, which feels modal / immersive relative to the
/// content map.
CustomTransitionPage<void> slideUpTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: const Interval(0.0, 0.4)));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Shared-axis Z transition — book detail
// ---------------------------------------------------------------------------

/// Fade-through on the Z axis — the outgoing screen fades and scales down
/// slightly while the incoming screen fades and scales up.
///
/// Used for the book detail screen, creating a sense of depth when drilling
/// into content.
CustomTransitionPage<void> sharedAxisZTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      // Incoming: fade in + scale from 0.92 → 1.0
      final incomingFade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      );
      final incomingScale = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );

      // Outgoing: fade out + scale from 1.0 → 1.06
      final outgoingFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );
      final outgoingScale = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        ),
      );

      return ScaleTransition(
        scale: outgoingFade.value < 1.0 ? outgoingScale : incomingScale,
        child: FadeTransition(
          opacity: secondaryAnimation.status == AnimationStatus.dismissed
              ? incomingFade
              : outgoingFade,
          child: child,
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Fade transition — modals
// ---------------------------------------------------------------------------

/// Simple cross-fade transition for modal / dialog-style routes.
CustomTransitionPage<void> fadeTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    opaque: false,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
