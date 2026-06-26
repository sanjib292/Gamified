import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../data/datasources/library_data_source.dart';
import '../../data/models/book_filter.dart';

// ---------------------------------------------------------------------------
// Data source provider
// ---------------------------------------------------------------------------

final _libraryDataSourceProvider = Provider<LibraryDataSource>(
  (ref) => LibraryDataSource(ref.watch(supabaseClientProvider)),
  name: '_libraryDataSourceProvider',
);

// ---------------------------------------------------------------------------
// Simple state providers
// ---------------------------------------------------------------------------

/// Current text in the search bar.
final searchQueryProvider = StateProvider.autoDispose<String>(
  (_) => '',
  name: 'searchQueryProvider',
);

/// Active filter (category, difficulty, premium flag).
final activeFilterProvider = StateProvider.autoDispose<BookFilter>(
  (_) => BookFilter.empty(),
  name: 'activeFilterProvider',
);

// ---------------------------------------------------------------------------
// Library notifier
// ---------------------------------------------------------------------------

const _kPageSize = 20;

/// Exposes a paginated, filterable list of books.
///
/// Rebuilt automatically whenever [searchQueryProvider] or [activeFilterProvider]
/// change. The UI can trigger a next-page load via [loadNextPage()].
class LibraryNotifier extends AutoDisposeAsyncNotifier<List<Book>> {
  int _currentPage = 0;
  bool _hasMore = true;

  BookFilter _effectiveFilter() {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(activeFilterProvider);
    return filter.copyWith(query: query.isEmpty ? null : query);
  }

  @override
  FutureOr<List<Book>> build() async {
    // Re-run when query or filter changes — reset pagination.
    _currentPage = 0;
    _hasMore = true;

    final filter = _effectiveFilter();
    final ds = ref.watch(_libraryDataSourceProvider);

    final books = await ds.searchBooks(filter, page: 0, pageSize: _kPageSize);
    _hasMore = books.length == _kPageSize;

    return books;
  }

  /// Appends the next page of results.
  ///
  /// No-op if already loading or no more pages.
  Future<void> loadNextPage() async {
    if (!_hasMore) return;
    if (state.isLoading) return;

    final current = state.valueOrNull ?? [];
    _currentPage++;

    final filter = _effectiveFilter();
    final ds = ref.read(_libraryDataSourceProvider);

    final newBooks = await ds.searchBooks(
      filter,
      page: _currentPage,
      pageSize: _kPageSize,
    );

    _hasMore = newBooks.length == _kPageSize;
    state = AsyncData([...current, ...newBooks]);
  }

  /// Whether more pages are available.
  bool get hasMore => _hasMore;
}

final libraryProvider = AsyncNotifierProvider.autoDispose<LibraryNotifier, List<Book>>(
  LibraryNotifier.new,
  name: 'libraryProvider',
);

// ---------------------------------------------------------------------------
// Categories provider
// ---------------------------------------------------------------------------

/// Fetches all categories once for the filter chip row.
final libraryCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryStub>>(
  (ref) {
    final ds = ref.watch(_libraryDataSourceProvider);
    return ds.fetchCategories();
  },
  name: 'libraryCategoriesProvider',
);
