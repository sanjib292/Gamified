import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../../shared/widgets/feedback/mq_empty_state.dart';
import '../../../../shared/widgets/feedback/mq_error_widget.dart';
import '../../../../shared/widgets/feedback/mq_loading_shimmer.dart';
import '../providers/library_notifier.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(libraryProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text('Library', style: AppTextStyles.headlineLarge),
            ),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SearchBarWidget(
                initialValue: ref.read(searchQueryProvider),
                onChanged: (q) =>
                    ref.read(searchQueryProvider.notifier).state = q,
                onMicPressed: () {
                  // Mic / voice search — stub for now.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice search coming soon.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Filter chips ─────────────────────────────────────────────────
            const FilterChipsRow(),

            const SizedBox(height: AppSpacing.md),

            // ── Book grid ────────────────────────────────────────────────────
            Expanded(
              child: booksAsync.when(
                loading: () => const _LibraryLoadingGrid(),
                error: (err, _) => MqErrorWidget(
                  error: err is AppException
                      ? err
                      : const UnknownException(
                          message: 'Could not load books.',
                        ),
                  onRetry: () => ref.invalidate(libraryProvider),
                ),
                data: (books) {
                  if (books.isEmpty) {
                    return MqEmptyState(
                      title: 'No books found',
                      subtitle:
                          'Try a different search term or clear the filters.',
                      action: TextButton(
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(activeFilterProvider.notifier).state =
                              const BookFilter();
                        },
                        child: const Text('Clear filters'),
                      ),
                    );
                  }

                  return _BookGrid(
                    books: books,
                    scrollController: _scrollController,
                    hasMore: ref.read(libraryProvider.notifier).hasMore,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Staggered book grid
// ---------------------------------------------------------------------------

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.scrollController,
    required this.hasMore,
  });

  final List<Book> books;
  final ScrollController scrollController;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 160 / 220,
      ),
      itemCount: books.length + (hasMore ? 2 : 0),
      itemBuilder: (context, i) {
        if (i >= books.length) {
          // Pagination loading placeholder
          return MqLoadingShimmer.card(width: 160, height: 220);
        }
        final book = books[i];
        return BookCard(
          book: book,
          mode: CardMode.grid,
          onTap: () => context.push(RouteNames.bookDetailPath(book.id)),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _LibraryLoadingGrid extends StatelessWidget {
  const _LibraryLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 160 / 220,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => MqLoadingShimmer.card(width: 160, height: 220),
    );
  }
}
