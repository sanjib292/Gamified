import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../domain/entities/content_block.dart';
import '../providers/lesson_notifier.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/lesson_complete_widget.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/simulation_widget.dart';
import '../widgets/story_mission_widget.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({
    super.key,
    required this.bookId,
    required this.pathId,
    required this.lessonId,
  });

  final String bookId;
  final String pathId;
  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  // Running score/xp accumulated during the lesson.
  int _accumulatedScore = 0;
  int _accumulatedXp = 0;
  bool _checkEnabled = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: state.maybeWhen(
          data: (ls) => Text(ls.lesson.title,
              style: AppTextStyles.titleSmall,
              overflow: TextOverflow.ellipsis),
          orElse: () => const SizedBox.shrink(),
        ),
        centerTitle: true,
        actions: [
          // Progress indicator
          state.maybeWhen(
            data: (ls) => Padding(
              padding:
                  const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Text(
                  ls.isComplete ? 'Done' : '1 / 1',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: state.maybeWhen(
            data: (ls) => LinearProgressIndicator(
              value: ls.isComplete ? 1.0 : 0.0,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
            orElse: () => const LinearProgressIndicator(value: null),
          ),
        ),
      ),
      body: state.when(
        loading: () => const MqFullPageLoading(),
        error: (err, _) => MqSimpleError(
          message: err.toString(),
          onRetry: () => ref.invalidate(lessonProvider(widget.lessonId)),
        ),
        data: (lessonState) {
          if (lessonState.isComplete) {
            return LessonCompleteWidget(
              xpEarned: lessonState.xpEarned,
              score: lessonState.score,
              onNextLesson: () => context.pop(),
            );
          }
          return _ContentView(
            block: lessonState.content,
            bookId: widget.bookId,
            pathId: widget.pathId,
            lessonId: widget.lessonId,
            onScoreUpdate: (score, xp) {
              _accumulatedScore = score;
              _accumulatedXp = xp;
              setState(() => _checkEnabled = true);
            },
          );
        },
      ),
      bottomNavigationBar: state.maybeWhen(
        data: (ls) => ls.isComplete
            ? null
            : _BottomBar(
                enabled: _checkEnabled ||
                    ls.content is ArticleBlock,
                onPressed: () {
                  ref
                      .read(lessonProvider(widget.lessonId).notifier)
                      .completeLesson(
                        score: _accumulatedScore,
                        xpEarned: _accumulatedXp > 0
                            ? _accumulatedXp
                            : 15,
                      );
                },
              ),
        orElse: () => null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content view — dispatches on ContentBlock type
// ---------------------------------------------------------------------------

class _ContentView extends StatelessWidget {
  const _ContentView({
    required this.block,
    required this.bookId,
    required this.pathId,
    required this.lessonId,
    required this.onScoreUpdate,
  });

  final ContentBlock block;
  final String bookId;
  final String pathId;
  final String lessonId;
  final void Function(int score, int xp) onScoreUpdate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: switch (block) {
        QuizBlock(:final questions) => Consumer(
            builder: (context, ref, _) => QuizWidget(
              block: QuizBlock(questions: questions),
              onAnswered: (isCorrect, xp) =>
                  onScoreUpdate(isCorrect ? 100 : 50, xp),
            ),
          ),
        FlashcardBlock(:final deck) => Consumer(
            builder: (context, ref, _) => FlashcardWidget(
              block: FlashcardBlock(deck: deck),
              onCompleted: (xp) => onScoreUpdate(80, xp),
            ),
          ),
        StoryMissionBlock(:final mission) => Consumer(
            builder: (context, ref, _) => StoryMissionWidget(
              block: StoryMissionBlock(mission: mission),
              onCompleted: (xp) => onScoreUpdate(90, xp),
            ),
          ),
        SimulationBlock(:final simulation) => Consumer(
            builder: (context, ref, _) => SimulationWidget(
              block: SimulationBlock(simulation: simulation),
              onCompleted: (score, xp) => onScoreUpdate(score, xp),
            ),
          ),
        ChallengeBlock(:final challenge) => Consumer(
            builder: (context, ref, _) => _ChallengeView(
              block: ChallengeBlock(challenge: challenge),
              onCompleted: onScoreUpdate,
            ),
          ),
        ArticleBlock(:final markdown) => _ArticleView(markdown: markdown),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Article view (rendered markdown as plain text for now)
// ---------------------------------------------------------------------------

class _ArticleView extends StatelessWidget {
  const _ArticleView({required this.markdown});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, 120),
      child: Text(
        markdown,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challenge view (rapid-fire quizzes)
// ---------------------------------------------------------------------------

class _ChallengeView extends StatefulWidget {
  const _ChallengeView({
    required this.block,
    required this.onCompleted,
  });

  final ChallengeBlock block;
  final void Function(int score, int xp) onCompleted;

  @override
  State<_ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends State<_ChallengeView> {
  int _current = 0;
  int _correct = 0;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final questions = widget.block.challenge.questions;
    if (_current >= questions.length) {
      final score = (_correct / questions.length * 100).round();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCompleted(score, score ~/ 5 * 5 + 10);
      });
      return const SizedBox.shrink();
    }

    return QuizWidget(
      block: QuizBlock(questions: [questions[_current]]),
      onAnswered: (isCorrect, xp) {
        if (isCorrect) _correct++;
        setState(() {
          _answered = true;
          _current++;
          _answered = false;
        });
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom action bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textHint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusFull),
            ),
            child: const Text('Continue',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
