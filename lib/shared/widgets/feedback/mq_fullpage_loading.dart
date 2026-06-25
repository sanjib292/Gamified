import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Full-page shimmer skeleton used as a loading placeholder.
///
/// Renders a stack of pill-shaped shimmer blocks to approximate a typical
/// content screen while data is loading.
class MqFullPageLoading extends StatelessWidget {
  const MqFullPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(height: 200, radius: AppSpacing.radiusXl),
            const SizedBox(height: AppSpacing.md),
            _block(height: 24, width: 200),
            const SizedBox(height: AppSpacing.sm),
            _block(height: 16, width: 140),
            const SizedBox(height: AppSpacing.md),
            _block(height: 80),
            const SizedBox(height: AppSpacing.md),
            _block(height: 16, width: 240),
            const SizedBox(height: AppSpacing.sm),
            _block(height: 100),
            const SizedBox(height: AppSpacing.md),
            _block(height: 52, radius: AppSpacing.radiusFull),
          ],
        ),
      ),
    );
  }

  Widget _block({
    double height = 16,
    double? width,
    double radius = AppSpacing.radiusMd,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Simple text error display with optional retry button.
///
/// Wraps the message in a minimal error card — use in place of
/// [MqErrorWidget] when you only have a raw string (no [AppException]).
class MqSimpleError extends StatelessWidget {
  const MqSimpleError({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
