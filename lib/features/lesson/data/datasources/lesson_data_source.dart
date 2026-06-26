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
          .select('id, title, learning_path_id, book_id, sort_order, estimated_minutes, xp_reward')
          .eq('id', lessonId)
          .single(),
      _supabase
          .from('lesson_content')
          .select('content_type, content')
          .eq('lesson_id', lessonId)
          .maybeSingle(),
    ]);

    final lessonRow = results[0] as Map<String, dynamic>;
    final contentRow = results[1] as Map<String, dynamic>? ?? {};

    final type = contentRow['content_type'] as String? ?? 'quiz';
    final contentJson =
        contentRow['content'] as Map<String, dynamic>? ?? {};
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
        'status': 'completed',
        'score_pct': score,
        'xp_earned': xpEarned,
        'last_attempted_at': now,
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
        'score_pct': score,
        'xp_earned': xpEarned,
        'duration_seconds': durationSeconds,
        'completed': true,
        'created_at': now,
      }),
    ]);
  }
}
