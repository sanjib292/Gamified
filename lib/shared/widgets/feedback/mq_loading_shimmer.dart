import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Wraps any widget in a [Shimmer.fromColors] loading skeleton.
///
/// Convenience factory constructors cover the most common use-cases:
///
/// ```dart
/// MqLoadingShimmer.card(width: 160, height: 220)
/// MqLoadingShimmer.listTile()
/// ```
class MqLoadingShimmer extends StatelessWidget {
  /// Wraps an arbitrary [child] widget in the shimmer effect.
  const MqLoadingShimmer({
    super.key,
    required this.child,
  });

  /// A rounded rectangle placeholder of the given dimensions.
  factory MqLoadingShimmer.card({
    Key? key,
    required double width,
    required double height,
    double borderRadius = AppSpacing.radiusLg,
  }) {
    return MqLoadingShimmer(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// A horizontal list-tile shaped placeholder (full width × 72 px).
  factory MqLoadingShimmer.listTile({Key? key}) {
    return MqLoadingShimmer(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}
