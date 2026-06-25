import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/library_data_source.dart';
import '../../data/models/book_filter.dart';
import '../providers/library_notifier.dart';

/// Horizontally scrolling row of filter chips.
///
/// Shows:
/// - "All" reset chip
/// - One chip per category (fetched async from [libraryCategoriesProvider])
/// - Difficulty level chips (Beginner / Intermediate / Advanced)
class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(activeFilterProvider);
    final categoriesAsync = ref.watch(libraryCategoriesProvider);

    final categories = categoriesAsync.valueOrNull ?? <CategoryStub>[];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            isSelected: activeFilter == BookFilter.empty(),
            onTap: () =>
                ref.read(activeFilterProvider.notifier).state = BookFilter.empty(),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Category chips
          ...categories.map((cat) {
            final isSelected = activeFilter.categoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: cat.name,
                isSelected: isSelected,
                onTap: () {
                  ref.read(activeFilterProvider.notifier).state =
                      activeFilter.copyWith(
                    categoryId: isSelected ? null : cat.id,
                  );
                },
              ),
            );
          }),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: VerticalDivider(
              indent: 8,
              endIndent: 8,
              color: AppColors.divider,
            ),
          ),

          // Difficulty chips
          ...DifficultyLevel.values.map((level) {
            final isSelected = activeFilter.difficulty == level;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: level.label,
                isSelected: isSelected,
                accentColor: _difficultyColor(level),
                onTap: () {
                  ref.read(activeFilterProvider.notifier).state =
                      activeFilter.copyWith(
                    difficulty: isSelected ? null : level,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _difficultyColor(DifficultyLevel level) => switch (level) {
        DifficultyLevel.beginner => AppColors.success,
        DifficultyLevel.intermediate => AppColors.warning,
        DifficultyLevel.advanced => AppColors.error,
      };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  Color get _resolvedColor => accentColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _resolvedColor
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? _resolvedColor : AppColors.divider,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _resolvedColor.withOpacity(0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
