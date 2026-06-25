import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../../../book_detail/data/models/book_detail_model.dart';
import '../../data/models/learning_path_model.dart';

// ---------------------------------------------------------------------------
// Notifier — family on pathId
// ---------------------------------------------------------------------------

class LearningPathNotifier
    extends FamilyAsyncNotifier<LearningPathDetail, String> {
  @override
  FutureOr<LearningPathDetail> build(String pathId) async {
    final supabase = ref.watch(supabaseClientProvider);
    final userId = ref.watch(currentUserIdProvider);
    return _loadPathDetail(supabase, pathId, userId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final learningPathProvider = AsyncNotifierProviderFamily<
    LearningPathNotifier, LearningPathDetail, String>(
  LearningPathNotifier.new,
  name: 'learningPathProvider',
);

// ---------------------------------------------------------------------------
// Internal loader
// ---------------------------------------------------------------------------

Future<LearningPathDetail> _loadPathDetail(
    SupabaseClient supabase, String pathId, String? userId) async {
  final pathRow = await supabase
      .from('learning_paths')
      .select('id, book_id, title, description, display_order')
      .eq('id', pathId)
      .single();

  final lessonRows = await supabase
      .from('lessons')
      .select('id, title, type, display_order')
      .eq('path_id', pathId)
      .order('display_order');

  final lessons = lessonRows.map<Lesson>(_rowToLesson).toList();

  Map<String, LessonStatus> progressMap = {};

  if (userId != null && lessons.isNotEmpty) {
    final progressRows = await supabase
        .from('user_progress')
        .select('lesson_id, status')
        .eq('user_id', userId)
        .eq('path_id', pathId);

    for (final row in progressRows) {
      final lessonId = row['lesson_id'] as String;
      final statusStr = row['status'] as String? ?? '';
      progressMap[lessonId] = switch (statusStr) {
        'completed' => LessonStatus.completed,
        'active' => LessonStatus.active,
        'available' => LessonStatus.available,
        _ => LessonStatus.locked,
      };
    }

    // If no progress exists, unlock first lesson.
    if (progressMap.isEmpty && lessons.isNotEmpty) {
      progressMap[lessons.first.id] = LessonStatus.active;
      for (final l in lessons.skip(1)) {
        progressMap[l.id] = LessonStatus.locked;
      }
    } else {
      // Ensure lessons without a record get locked.
      for (final l in lessons) {
        progressMap.putIfAbsent(l.id, () => LessonStatus.locked);
      }
    }
  } else {
    // Unauthenticated: show all as available.
    for (final l in lessons) {
      progressMap[l.id] = LessonStatus.available;
    }
  }

  final path = LearningPath(
    id: pathRow['id'] as String,
    bookId: pathRow['book_id'] as String,
    title: pathRow['title'] as String,
    description: pathRow['description'] as String? ?? '',
    displayOrder: (pathRow['display_order'] as num).toInt(),
    lessons: lessons,
  );

  return LearningPathDetail(
    path: path,
    lessons: lessons,
    progressMap: progressMap,
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
