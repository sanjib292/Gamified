import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/book_detail_data_source.dart';
import '../../data/models/book_detail_model.dart';

// ---------------------------------------------------------------------------
// Data-source provider
// ---------------------------------------------------------------------------

final _bookDetailDataSourceProvider = Provider<BookDetailDataSource>(
  (ref) => BookDetailDataSource(ref.watch(supabaseClientProvider)),
  name: '_bookDetailDataSourceProvider',
);

// ---------------------------------------------------------------------------
// Notifier — family on bookId
// ---------------------------------------------------------------------------

/// Loads all data for a single book detail screen.
///
/// Use [bookDetailProvider(bookId)] to obtain the notifier for a specific book.
class BookDetailNotifier extends FamilyAsyncNotifier<BookDetail, String> {
  @override
  FutureOr<BookDetail> build(String bookId) async {
    final ds = ref.watch(_bookDetailDataSourceProvider);
    final userId = ref.watch(currentUserIdProvider);
    return ds.fetchBookDetail(bookId, userId);
  }

  /// Refreshes all data for this book.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final bookDetailProvider =
    AsyncNotifierProviderFamily<BookDetailNotifier, BookDetail, String>(
  BookDetailNotifier.new,
  name: 'bookDetailProvider',
);
