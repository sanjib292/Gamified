import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Display mode for [BookCard].
enum CardMode {
  /// 280×380 parallax-ready featured card with gradient overlay.
  featured,

  /// 160×220 compact grid tile.
  grid,

  /// Horizontal 80px tall list row with thumbnail, title, author, progress.
  list,
}

/// Minimal Book model surface used by [BookCard].
/// Replace with the real domain model from your data layer.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.difficulty = BookDifficulty.intermediate,
    this.progressPercent = 0.0,
  });

  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final BookDifficulty difficulty;

  /// 0.0 – 1.0
  final double progressPercent;
}

enum BookDifficulty { beginner, intermediate, advanced }

extension _BookDifficultyExt on BookDifficulty {
  String get label => switch (this) {
        BookDifficulty.beginner => 'Beginner',
        BookDifficulty.intermediate => 'Intermediate',
        BookDifficulty.advanced => 'Advanced',
      };

  Color get color => switch (this) {
        BookDifficulty.beginner => AppColors.success,
        BookDifficulty.intermediate => AppColors.warning,
        BookDifficulty.advanced => AppColors.error,
      };
}

/// Versatile book card component supporting three display modes.
///
/// Uses a [Hero] widget keyed on `'book-${book.id}'` to enable shared-element
/// transitions to the detail screen.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.mode,
    required this.onTap,
  });

  final Book book;
  final CardMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => switch (mode) {
        CardMode.featured => _FeaturedCard(book: book, onTap: onTap),
        CardMode.grid => _GridCard(book: book, onTap: onTap),
        CardMode.list => _ListCard(book: book, onTap: onTap),
      };
}

// ---------------------------------------------------------------------------
// Featured card — 280×380
// ---------------------------------------------------------------------------

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 280,
        height: 380,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'book-${book.id}',
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _CoverPlaceholder(title: book.title),
                  errorWidget: (_, __, ___) =>
                      _CoverPlaceholder(title: book.title),
                ),
              ),
              // Bottom gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),
              ),
              // Difficulty badge — top right
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: _DifficultyBadge(difficulty: book.difficulty),
              ),
              // Title + author — bottom
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      book.author,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid card — 160×220
// ---------------------------------------------------------------------------

class _GridCard extends StatelessWidget {
  const _GridCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        height: 220,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'book-${book.id}',
                    child: CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _CoverPlaceholder(title: book.title),
                      errorWidget: (_, __, ___) =>
                          _CoverPlaceholder(title: book.title),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: AppTextStyles.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List card — horizontal 80px
// ---------------------------------------------------------------------------

class _ListCard extends StatelessWidget {
  const _ListCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 80,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusMd),
                  bottomLeft: Radius.circular(AppSpacing.radiusMd),
                ),
                child: Hero(
                  tag: 'book-${book.id}',
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        SizedBox(width: 60, child: _CoverPlaceholder(title: book.title)),
                    errorWidget: (_, __, ___) =>
                        SizedBox(width: 60, child: _CoverPlaceholder(title: book.title)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title + author + progress
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _ProgressChip(progress: book.progressPercent),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final BookDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: difficulty.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        child: Text(
          difficulty.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$pct%',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
