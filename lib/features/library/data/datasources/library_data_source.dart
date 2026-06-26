import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/book_card.dart';
import '../models/book_filter.dart';

class CategoryStub {
  const CategoryStub({required this.id, required this.name});

  final String id;
  final String name;
}

class LibraryDataSource {
  const LibraryDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<List<Book>> searchBooks(
    BookFilter filter, {
    int page = 0,
    int pageSize = 20,
  }) async {
    // Category filter requires a join through book_categories
    List<String>? categoryBookIds;
    if (filter.categoryId != null) {
      final catRows = await _supabase
          .from('book_categories')
          .select('book_id')
          .eq('category_id', filter.categoryId!);
      categoryBookIds = catRows.map((r) => r['book_id'] as String).toList();
      if (categoryBookIds.isEmpty) return [];
    }

    var query = _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty')
        .eq('is_published', true);

    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      final q = '%${filter.query!.trim()}%';
      query = query.or('title.ilike.$q,author.ilike.$q');
    }

    if (categoryBookIds != null) {
      query = query.inFilter('id', categoryBookIds);
    }

    if (filter.difficulty != null) {
      query = query.eq('difficulty', filter.difficulty!.dbValue);
    }

    final rows = await query
        .order('title', ascending: true)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return rows.map<Book>(_rowToBook).toList();
  }

  Future<List<CategoryStub>> fetchCategories() async {
    final rows = await _supabase
        .from('categories')
        .select('id, name')
        .order('sort_order', ascending: true);

    return rows
        .map<CategoryStub>((row) => CategoryStub(
              id: row['id'] as String,
              name: row['name'] as String,
            ))
        .toList();
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
}
