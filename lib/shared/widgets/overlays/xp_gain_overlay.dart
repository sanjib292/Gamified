import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Floating "+N XP" toast shown when the user earns experience points.
///
/// Displayed via [OverlayEntry] so it floats above all other content.
/// Auto-dismisses after 2 seconds with a slide-up + fade-out animation.
///
/// Usage:
/// ```dart
/// XpGainOverlay.show(context, 50);
/// ```
class XpGainOverlay extends StatefulWidget {
  const XpGainOverlay._({
    required this.amount,
    required this.onDone,
  });

  final int amount;
  final VoidCallback onDone;

  /// Inserts the overlay into the widget tree above [context].
  static void show(BuildContext context, int amount) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => XpGainOverlay._(
        amount: amount,
        onDone: () => entry?.remove(),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  @override
  State<XpGainOverlay> createState() => _XpGainOverlayState();
}

class _XpGainOverlayState extends State<XpGainOverlay> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _visible = false);
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Centre horizontally, upper-mid area vertically
      top: MediaQuery.of(context).size.height * 0.22,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: _XpChip(amount: widget.amount)
                .animate()
                .slideY(
                  begin: 0.2,
                  end: -0.6,
                  duration: 1800.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 300.ms),
          ),
        ),
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.xpGradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.xpGold.withOpacity(0.45),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              '+$amount XP',
              style: AppTextStyles.xpOverlay.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
