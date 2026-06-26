import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../../data/datasources/lesson_data_source.dart';
import '../../domain/entities/content_block.dart';
import '../../../book_detail/data/models/book_detail_model.dart';

// ---------------------------------------------------------------------------
// Domain state
// ---------------------------------------------------------------------------

class LessonState {
  const LessonState({
    required this.lesson,
    required this.content,
    this.isComplete = false,
    this.score = 0,
    this.xpEarned = 0,
  });

  final Lesson lesson;
  final ContentBlock content;
  final bool isComplete;
  final int score;
  final int xpEarned;

  LessonState copyWith({
    Lesson? lesson,
    ContentBlock? content,
    bool? isComplete,
    int? score,
    int? xpEarned,
  }) =>
      LessonState(
        lesson: lesson ?? this.lesson,
        content: content ?? this.content,
        isComplete: isComplete ?? this.isComplete,
        score: score ?? this.score,
        xpEarned: xpEarned ?? this.xpEarned,
      );
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _lessonDataSourceProvider = Provider<LessonDataSource>(
  (ref) => LessonDataSource(ref.watch(supabaseClientProvider)),
);

// ---------------------------------------------------------------------------
// Notifier — family on lessonId
// ---------------------------------------------------------------------------

class LessonNotifier extends FamilyAsyncNotifier<LessonState, String> {
  DateTime? _startTime;

  @override
  FutureOr<LessonState> build(String lessonId) async {
    _startTime = DateTime.now();
    final ds = ref.watch(_lessonDataSourceProvider);
    final data = await ds.fetchLesson(lessonId);

    final lessonRow = data['lesson'] as Map<String, dynamic>;
    final content = data['content'] as ContentBlock;

    final lesson = Lesson(
      id: lessonRow['id'] as String,
      title: lessonRow['title'] as String,
      type: LessonType.reading,
    );

    return LessonState(lesson: lesson, content: content);
  }

  /// Called when the user completes the lesson.
  Future<void> completeLesson({
    required int score,
    required int xpEarned,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final durationSecs = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    final ds = ref.read(_lessonDataSourceProvider);
    await ds.submitProgress(
      userId: userId,
      lessonId: arg,
      score: score,
      xpEarned: xpEarned,
      durationSeconds: durationSecs,
    );

    state = AsyncData(
      state.requireValue.copyWith(
        isComplete: true,
        score: score,
        xpEarned: xpEarned,
      ),
    );
  }

}

final lessonProvider =
    AsyncNotifierProviderFamily<LessonNotifier, LessonState, String>(
  LessonNotifier.new,
  name: 'lessonProvider',
);
