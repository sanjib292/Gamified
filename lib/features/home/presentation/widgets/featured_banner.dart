import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/mq_primary_button.dart';
import '../../../../shared/widgets/cards/book_card.dart';

/// Full-width hero banner for the featured book.
///
/// Displays a 280-px tall cover image with a bottom-to-top gradient overlay,
/// book title, author chip, and a "Start Learning" CTA.
class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.bookDetailPath(book.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover image
                Hero(
                  tag: 'book-${book.id}',
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _BannerPlaceholder(book: book),
                    errorWidget: (_, __, ___) => _BannerPlaceholder(book: book),
                  ),
                ),

                // Gradient overlay (bottom 60%)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.25, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.88),
                        ],
                      ),
                    ),
                  ),
                ),

                // "Featured" label — top left
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: _FeaturedBadge(),
                ),

                // Content — bottom
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
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.15, end: 0, delay: 200.ms),

                      const SizedBox(height: 4),

                      Text(
                        book.author,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white60,
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                      const SizedBox(height: AppSpacing.md),

                      MqPrimaryButton(
                        label: 'Start Learning',
                        icon: Icons.play_arrow_rounded,
                        width: 180,
                        onPressed: () =>
                            context.push(RouteNames.bookDetailPath(book.id)),
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
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

class _FeaturedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              'FEATURED',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.6),
            AppColors.darkBackground,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            book.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
