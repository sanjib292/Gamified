import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../models/book_detail_model.dart';

class BookDetailDataSource {
  const BookDetailDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<BookDetail> fetchBookDetail(String bookId, String? userId) async {
    final results = await Future.wait([
      _fetchBook(bookId),
      _fetchPaths(bookId),
      _fetchAchievements(),
      if (userId != null) _fetchUserProgress(bookId, userId),
    ]);

    final book = results[0] as Book;
    final paths = results[1] as List<LearningPath>;
    final achievements = results[2] as List<Achievement>;
    final userProgress =
        (results.length > 3 ? results[3] : null) as UserProgress?;

    final totalLessons = paths.fold<int>(0, (sum, p) => sum + p.lessons.length);
    final completedLessons = userProgress?.completedLessons ?? 0;

    return BookDetail(
      book: book,
      paths: paths,
      availableAchievements: achievements,
      userProgress: userProgress,
      completedLessons: completedLessons,
      totalLessons: totalLessons,
    );
  }

  Future<Book> _fetchBook(String bookId) async {
    final row = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty, estimated_minutes')
        .eq('id', bookId)
        .single();
    return _rowToBook(row);
  }

  Future<List<LearningPath>> _fetchPaths(String bookId) async {
    final pathRows = await _supabase
        .from('learning_paths')
        .select('id, book_id, title, description, sort_order')
        .eq('book_id', bookId)
        .order('sort_order');

    final List<LearningPath> paths = [];
    for (final pathRow in pathRows) {
      final lessonRows = await _supabase
          .from('lessons')
          .select('id, title, sort_order, estimated_minutes, is_free_preview')
          .eq('learning_path_id', pathRow['id'] as String)
          .eq('is_published', true)
          .order('sort_order');

      final lessons = lessonRows.map<Lesson>(_rowToLesson).toList();

      paths.add(LearningPath(
        id: pathRow['id'] as String,
        bookId: pathRow['book_id'] as String,
        title: pathRow['title'] as String,
        description: pathRow['description'] as String? ?? '',
        displayOrder: (pathRow['sort_order'] as num?)?.toInt() ?? 0,
        lessons: lessons,
      ));
    }
    return paths;
  }

  Future<List<Achievement>> _fetchAchievements() async {
    final rows = await _supabase
        .from('achievements')
        .select('id, title, description, icon_name, color_hex')
        .order('sort_order')
        .limit(10);

    return rows.map<Achievement>(_rowToAchievement).toList();
  }

  Future<UserProgress?> _fetchUserProgress(
      String bookId, String userId) async {
    // Get published lesson IDs for this book
    final lessonRows = await _supabase
        .from('lessons')
        .select('id')
        .eq('book_id', bookId)
        .eq('is_published', true);

    if (lessonRows.isEmpty) return null;

    final lessonIds = lessonRows.map((r) => r['id'] as String).toList();

    // Count completed lessons
    final result = await _supabase
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .inFilter('lesson_id', lessonIds)
        .count(CountOption.exact);

    final completedCount = result.count;
    if (completedCount == 0) return null;

    return UserProgress(
      userId: userId,
      bookId: bookId,
      progressPercent: completedCount / lessonIds.length * 100,
      completedLessons: completedCount,
      lastAccessedAt: DateTime.now(),
    );
  }

  Book _rowToBook(Map<String, dynamic> row) {
    final difficultyStr =
        (row['difficulty'] as String?)?.toLowerCase() ?? '';
    final difficulty = switch (difficultyStr) {
      'beginner' => BookDifficulty.beginner,
      'advanced' => BookDifficulty.advanced,
      _ => BookDifficulty.intermediate,
    };
    return Book(
      id: row['id'] as String,
      title: row['title'] as String,
      author: row['author'] as String? ?? '',
      coverUrl: row['cover_url'] as String? ?? '',
      difficulty: difficulty,
    );
  }

  Lesson _rowToLesson(Map<String, dynamic> row) {
    return Lesson(
      id: row['id'] as String,
      title: row['title'] as String,
      type: LessonType.reading,
    );
  }

  Achievement _rowToAchievement(Map<String, dynamic> row) {
    final colorHex = row['color_hex'] as String? ?? '#6C5CE7';
    final color = _hexToColor(colorHex);
    return Achievement(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      icon: _iconForName(row['icon_name'] as String? ?? 'star'),
      color: color,
    );
  }

  static Color _hexToColor(String hex) => hexToColor(hex);

  static IconData _iconForName(String name) =>
      const IconData(0xe5f9, fontFamily: 'MaterialIcons');
}
