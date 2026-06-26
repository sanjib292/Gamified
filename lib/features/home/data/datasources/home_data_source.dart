import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/book_card.dart';
import '../models/featured_content.dart';

class HomeDataSource {
  const HomeDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<FeaturedContent> fetchFeaturedContent() async {
    final featuredRows = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty')
        .eq('is_featured', true)
        .eq('is_published', true)
        .limit(1);

    final featuredBook = featuredRows.isNotEmpty
        ? _rowToBook(featuredRows.first)
        : _placeholderBook();

    final categoryRows = await _supabase
        .from('categories')
        .select('id, name')
        .order('sort_order', ascending: true);

    final bookRows = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(50);

    // Build id → Book map for O(1) lookup
    final bookMap = {
      for (final r in bookRows) r['id'] as String: _rowToBook(r),
    };

    // Fetch book→category associations
    final bookCatRows = await _supabase
        .from('book_categories')
        .select('book_id, category_id');

    final booksByCategory = <String, List<Book>>{};
    for (final bc in bookCatRows) {
      final catId = bc['category_id'] as String;
      final book = bookMap[bc['book_id'] as String];
      if (book != null) {
        booksByCategory.putIfAbsent(catId, () => []).add(book);
      }
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

    final newBooks = bookRows.take(10).map<Book>(_rowToBook).toList();

    return FeaturedContent(
      featuredBook: featuredBook,
      categories: categories,
      continueReading: const [],
      newBooks: newBooks,
    );
  }

  Future<List<Book>> fetchContinueReading(String userId) async {
    final rows = await _supabase
        .from('user_progress')
        .select(
            'lessons(book_id, books(id, title, author, cover_url, difficulty))')
        .eq('user_id', userId)
        .inFilter('status', ['not_started', 'in_progress'])
        .order('last_attempted_at', ascending: false)
        .limit(10);

    final seenIds = <String>{};
    return rows.expand<Book>((row) {
      final lessonRow = row['lessons'] as Map<String, dynamic>?;
      final bookRow = lessonRow?['books'] as Map<String, dynamic>?;
      if (bookRow == null) return const [];
      final id = bookRow['id'] as String;
      if (!seenIds.add(id)) return const [];
      return [_rowToBook(bookRow)];
    }).toList();
  }

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
