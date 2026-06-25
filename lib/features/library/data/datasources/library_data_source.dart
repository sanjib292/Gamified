import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/book_card.dart';
import '../models/book_filter.dart';

/// Category stub — only id + name needed for filter chips.
class CategoryStub {
  const CategoryStub({required this.id, required this.name});

  final String id;
  final String name;
}

/// Data source for library browse and search.
class LibraryDataSource {
  const LibraryDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ---------------------------------------------------------------------------
  // Books
  // ---------------------------------------------------------------------------

  /// Returns a paginated list of [Book]s matching [filter].
  ///
  /// [page] is zero-based; [pageSize] defaults to 20.
  Future<List<Book>> searchBooks(
    BookFilter filter, {
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty, is_premium')
        .eq('is_published', true);

    // Full-text search on title and author
    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      final q = '%${filter.query!.trim()}%';
      query = query.or('title.ilike.$q,author.ilike.$q');
    }

    // Category filter
    if (filter.categoryId != null) {
      query = query.eq('category_id', filter.categoryId!);
    }

    // Difficulty filter
    if (filter.difficulty != null) {
      query = query.eq('difficulty', filter.difficulty!.dbValue);
    }

    // Premium filter
    if (filter.premiumOnly) {
      query = query.eq('is_premium', true);
    }

    final rows = await query
        .order('title', ascending: true)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return rows.map<Book>(_rowToBook).toList();
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<List<CategoryStub>> fetchCategories() async {
    final rows = await _supabase
        .from('categories')
        .select('id, name')
        .order('display_order', ascending: true);

    return rows
        .map<CategoryStub>((row) => CategoryStub(
              id: row['id'] as String,
              name: row['name'] as String,
            ))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Helper
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
    );
  }
}
