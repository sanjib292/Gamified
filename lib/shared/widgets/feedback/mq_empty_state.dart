import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Centred empty-state placeholder for lists and content areas.
///
/// Accepts an optional [illustration] widget (e.g. a Lottie animation or SVG)
/// and an optional [action] widget (e.g. a button to create first content).
class MqEmptyState extends StatelessWidget {
  const MqEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustration,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? illustration;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              SizedBox(
                width: 180,
                height: 180,
                child: illustration,
              ),
              const SizedBox(height: AppSpacing.lg),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: AppColors.textHint,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
