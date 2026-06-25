import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/book_card.dart';
import '../models/featured_content.dart';

/// Data source for home-screen content.
///
/// Maps raw Supabase JSON into lightweight domain objects.
class HomeDataSource {
  const HomeDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches everything needed to render the home screen in a single batch.
  Future<FeaturedContent> fetchFeaturedContent() async {
    // Fetch featured book (marked is_featured = true, limit 1)
    final featuredRows = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty, is_featured')
        .eq('is_featured', true)
        .limit(1);

    final featuredBook = featuredRows.isNotEmpty
        ? _rowToBook(featuredRows.first)
        : _placeholderBook();

    // Fetch categories
    final categoryRows = await _supabase
        .from('categories')
        .select('id, name')
        .order('display_order', ascending: true);

    // Fetch books grouped by category (join)
    final bookRows = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty, category_id')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(50);

    // Group books by category
    final booksByCategory = <String, List<Book>>{};
    for (final row in bookRows) {
      final catId = row['category_id'] as String?;
      if (catId == null) continue;
      booksByCategory.putIfAbsent(catId, () => []).add(_rowToBook(row));
    }

    final categories = categoryRows
        .map<BookCategory>((row) {
          final id = row['id'] as String;
          return BookCategory(
            id: id,
            name: row['name'] as String,
            books: booksByCategory[id] ?? [],
          );
        })
        .where((c) => c.books.isNotEmpty)
        .toList();

    // New books — most recently added across all categories
    final newBooks = bookRows
        .take(10)
        .map<Book>(_rowToBook)
        .toList();

    return FeaturedContent(
      featuredBook: featuredBook,
      categories: categories,
      continueReading: const [],
      newBooks: newBooks,
    );
  }

  /// Fetches books the user has started but not completed, sorted by the most
  /// recently accessed lesson.
  Future<List<Book>> fetchContinueReading(String userId) async {
    final rows = await _supabase
        .from('user_progress')
        .select(
          'book_id, last_accessed_at, books(id, title, author, cover_url, difficulty)',
        )
        .eq('user_id', userId)
        .gt('progress_percent', 0)
        .lt('progress_percent', 100)
        .order('last_accessed_at', ascending: false)
        .limit(10);

    return rows.map<Book>((row) {
      final bookMap = row['books'] as Map<String, dynamic>;
      return _rowToBook(bookMap);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Book _rowToBook(Map<String, dynamic> row) {
    final difficultyStr = (row['difficulty'] as String?)?.toLowerCase() ?? '';
    final difficulty = switch (difficultyStr) {
      'beginner' => BookDifficulty.beginner,
      'advanced' => BookDifficulty.advanced,
      _ => BookDifficulty.intermediate,
    };

    return Book(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? 'Untitled',
      author: row['author'] as String? ?? '',
      coverUrl: row['cover_url'] as String? ?? '',
      difficulty: difficulty,
      progressPercent: (row['progress_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Book _placeholderBook() => const Book(
        id: 'placeholder',
        title: 'The Psychology of Money',
        author: 'Morgan Housel',
        coverUrl: '',
        difficulty: BookDifficulty.beginner,
      );
}
