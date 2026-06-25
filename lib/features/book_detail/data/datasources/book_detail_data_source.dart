import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/cards/achievement_badge.dart';
import '../../../../shared/widgets/cards/book_card.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../models/book_detail_model.dart';

/// Fetches all data needed to render the book detail screen.
///
/// Combines book metadata, learning paths with nested lessons, available
/// achievements, and (optionally) user progress in a small number of
/// Supabase queries run concurrently.
class BookDetailDataSource {
  const BookDetailDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<BookDetail> fetchBookDetail(String bookId, String? userId) async {
    // Run queries concurrently.
    final results = await Future.wait([
      _fetchBook(bookId),
      _fetchPaths(bookId),
      _fetchAchievements(bookId),
      if (userId != null) _fetchUserProgress(bookId, userId),
    ]);

    final book = results[0] as Book;
    final paths = results[1] as List<LearningPath>;
    final achievements = results[2] as List<Achievement>;
    final userProgress =
        (results.length > 3 ? results[3] : null) as UserProgress?;

    // Count totals across all paths.
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<Book> _fetchBook(String bookId) async {
    final row = await _supabase
        .from('books')
        .select('id, title, author, cover_url, difficulty, estimated_minutes, key_concepts')
        .eq('id', bookId)
        .single();
    return _rowToBook(row);
  }

  Future<List<LearningPath>> _fetchPaths(String bookId) async {
    final pathRows = await _supabase
        .from('learning_paths')
        .select('id, book_id, title, description, display_order')
        .eq('book_id', bookId)
        .order('display_order');

    final List<LearningPath> paths = [];
    for (final pathRow in pathRows) {
      final lessonRows = await _supabase
          .from('lessons')
          .select('id, title, type, display_order, estimated_minutes')
          .eq('path_id', pathRow['id'] as String)
          .order('display_order');

      final lessons = lessonRows.map<Lesson>(_rowToLesson).toList();

      paths.add(LearningPath(
        id: pathRow['id'] as String,
        bookId: pathRow['book_id'] as String,
        title: pathRow['title'] as String,
        description: pathRow['description'] as String? ?? '',
        displayOrder: (pathRow['display_order'] as num).toInt(),
        lessons: lessons,
      ));
    }
    return paths;
  }

  Future<List<Achievement>> _fetchAchievements(String bookId) async {
    final rows = await _supabase
        .from('achievements')
        .select('id, title, description, icon_name, color_hex')
        .eq('book_id', bookId);

    return rows.map<Achievement>(_rowToAchievement).toList();
  }

  Future<UserProgress?> _fetchUserProgress(
      String bookId, String userId) async {
    final rows = await _supabase
        .from('user_progress')
        .select(
            'user_id, book_id, progress_percent, completed_lessons, last_accessed_at')
        .eq('book_id', bookId)
        .eq('user_id', userId)
        .limit(1);

    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProgress(
      userId: row['user_id'] as String,
      bookId: row['book_id'] as String,
      progressPercent:
          (row['progress_percent'] as num?)?.toDouble() ?? 0.0,
      completedLessons: (row['completed_lessons'] as num?)?.toInt() ?? 0,
      lastAccessedAt: DateTime.tryParse(
              row['last_accessed_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Row mappers
  // ---------------------------------------------------------------------------

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
    final typeStr = (row['type'] as String?)?.toLowerCase() ?? '';
    final type = switch (typeStr) {
      'quiz' => LessonType.quiz,
      'flashcard' => LessonType.flashcard,
      'challenge' => LessonType.challenge,
      'summary' => LessonType.summary,
      _ => LessonType.reading,
    };
    return Lesson(
      id: row['id'] as String,
      title: row['title'] as String,
      type: type,
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
