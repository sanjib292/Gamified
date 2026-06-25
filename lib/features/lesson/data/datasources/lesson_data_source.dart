import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/content_block.dart';

/// Raw lesson + content block fetching, and progress submission.
class LessonDataSource {
  const LessonDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ---------------------------------------------------------------------------
  // Fetch lesson + its content block
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> fetchLesson(String lessonId) async {
    // Fetch lesson metadata and its content in parallel.
    final results = await Future.wait([
      _supabase
          .from('lessons')
          .select(
              'id, title, type, path_id, display_order, estimated_minutes')
          .eq('id', lessonId)
          .single(),
      _supabase
          .from('lesson_content')
          .select('type, content_json')
          .eq('lesson_id', lessonId)
          .single(),
    ]);

    final lessonRow = results[0] as Map<String, dynamic>;
    final contentRow = results[1] as Map<String, dynamic>;

    final type = contentRow['type'] as String? ?? 'article';
    final contentJson =
        contentRow['content_json'] as Map<String, dynamic>? ?? {};
    final block = ContentBlock.fromJson(contentJson, type);

    return {
      'lesson': lessonRow,
      'content': block,
    };
  }

  // ---------------------------------------------------------------------------
  // Submit progress after completing a lesson
  // ---------------------------------------------------------------------------

  Future<void> submitProgress({
    required String userId,
    required String lessonId,
    required String pathId,
    required String bookId,
    required int score,
    required int xpEarned,
    required int durationSeconds,
  }) async {
    final now = DateTime.now().toIso8601String();
    final attemptId = const Uuid().v4();

    // Run all writes concurrently.
    await Future.wait([
      // Upsert user_progress row.
      _supabase.from('user_progress').upsert({
        'user_id': userId,
        'lesson_id': lessonId,
        'path_id': pathId,
        'book_id': bookId,
        'status': 'completed',
        'score': score,
        'last_accessed_at': now,
        'completed_at': now,
      }, onConflict: 'user_id,lesson_id'),

      // Append XP log entry.
      _supabase.from('xp_logs').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'source': 'lesson_complete',
        'source_id': lessonId,
        'xp_amount': xpEarned,
        'created_at': now,
      }),

      // Record lesson attempt.
      _supabase.from('lesson_attempts').insert({
        'id': attemptId,
        'user_id': userId,
        'lesson_id': lessonId,
        'score': score,
        'xp_earned': xpEarned,
        'duration_seconds': durationSeconds,
        'created_at': now,
      }),
    ]);
  }
}
