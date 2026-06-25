import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Status of a lesson node on the learning path map.
enum LessonStatus {
  /// Completed — filled primary colour with a checkmark.
  completed,

  /// Currently active — outlined with a pulsing ambient glow.
  active,

  /// Not yet unlocked — greyed out with a lock icon.
  locked,

  /// Unlocked but not started — outlined, ready to tap.
  available,
}

/// Lesson type — drives the centre icon.
enum LessonType {
  reading,
  quiz,
  flashcard,
  challenge,
  summary,
}

extension _LessonTypeExt on LessonType {
  IconData get icon => switch (this) {
        LessonType.reading => Icons.menu_book_rounded,
        LessonType.quiz => Icons.quiz_rounded,
        LessonType.flashcard => Icons.style_rounded,
        LessonType.challenge => Icons.emoji_events_rounded,
        LessonType.summary => Icons.summarize_rounded,
      };
}

/// Minimal Lesson model surface used by [LessonNodeCard].
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.type,
  });

  final String id;
  final String title;
  final LessonType type;
}

/// Circular node (80 px diameter) used on the learning path map.
///
/// Renders differently for each [LessonStatus] — pulsing glow for [active],
/// greyed-out lock for [locked], etc.
class LessonNodeCard extends StatelessWidget {
  const LessonNodeCard({
    super.key,
    required this.lesson,
    required this.status,
    this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback? onTap;

  static const double _diameter = 80.0;

  @override
  Widget build(BuildContext context) {
    Widget node = _NodeBody(lesson: lesson, status: status);

    // Pulsing glow for active nodes
    if (status == LessonStatus.active) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.06,
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }

    return GestureDetector(
      onTap: status != LessonStatus.locked ? onTap : null,
      child: Tooltip(
        message: lesson.title,
        child: SizedBox(
          width: _diameter,
          height: _diameter,
          child: node,
        ),
      ),
    );
  }
}

class _NodeBody extends StatelessWidget {
  const _NodeBody({required this.lesson, required this.status});
  final Lesson lesson;
  final LessonStatus status;

  @override
  Widget build(BuildContext context) {
    final cfg = _nodeConfig(status);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cfg.fill,
        border: cfg.border,
        boxShadow: cfg.glow != null
            ? [
                BoxShadow(
                  color: cfg.glow!,
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: _centerIcon(status, lesson.type),
      ),
    );
  }

  Widget _centerIcon(LessonStatus status, LessonType type) {
    if (status == LessonStatus.locked) {
      return const Icon(
        Icons.lock_rounded,
        color: AppColors.textHint,
        size: 28,
      );
    }
    if (status == LessonStatus.completed) {
      return const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 30,
      );
    }
    return Icon(
      type.icon,
      color: status == LessonStatus.active
          ? AppColors.primary
          : AppColors.textSecondary,
      size: 28,
    );
  }

  _NodeConfig _nodeConfig(LessonStatus status) => switch (status) {
        LessonStatus.completed => _NodeConfig(
            fill: AppColors.primary,
          ),
        LessonStatus.active => _NodeConfig(
            fill: AppColors.surface,
            border: Border.all(color: AppColors.primary, width: 2.5),
            glow: AppColors.primary.withOpacity(0.4),
          ),
        LessonStatus.locked => _NodeConfig(
            fill: AppColors.surfaceVariant,
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
        LessonStatus.available => _NodeConfig(
            fill: AppColors.surface,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
      };
}

class _NodeConfig {
  const _NodeConfig({
    required this.fill,
    this.border,
    this.glow,
  });
  final Color fill;
  final Border? border;
  final Color? glow;
}
