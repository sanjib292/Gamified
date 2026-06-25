import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../data/models/featured_content.dart';

/// A labelled horizontal scrolling list of [BookCard.grid] widgets.
///
/// Used for each category row on the home screen
/// (e.g. "Personal Finance", "Psychology").
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.category,
  });

  final BookCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: AppTextStyles.titleLarge,
              ),
              TextButton(
                onPressed: () => context.push(RouteNames.library),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Horizontal book list
        SizedBox(
          height: 222,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: category.books.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final book = category.books[i];
              return BookCard(
                book: book,
                mode: CardMode.grid,
                onTap: () =>
                    context.push(RouteNames.bookDetailPath(book.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Horizontal "Continue Reading" row — uses [CardMode.list] layout.
class ContinueReadingRow extends StatelessWidget {
  const ContinueReadingRow({
    super.key,
    required this.books,
  });

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Continue Reading',
            style: AppTextStyles.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final book = books[i];
              return SizedBox(
                width: 280,
                child: BookCard(
                  book: book,
                  mode: CardMode.list,
                  onTap: () =>
                      context.push(RouteNames.bookDetailPath(book.id)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
