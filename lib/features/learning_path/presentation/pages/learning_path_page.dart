import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../../../../shared/widgets/feedback/mq_fullpage_loading.dart';
import '../../data/models/learning_path_model.dart';
import '../providers/learning_path_notifier.dart';
import '../widgets/path_connector_painter.dart';

class LearningPathPage extends ConsumerWidget {
  const LearningPathPage({
    super.key,
    required this.bookId,
    required this.pathId,
  });

  final String bookId;
  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningPathProvider(pathId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: state.maybeWhen(
          data: (d) => Text(d.path.title, style: AppTextStyles.titleMedium),
          orElse: () => const SizedBox.shrink(),
        ),
        centerTitle: true,
      ),
      body: state.when(
        loading: () => const MqFullPageLoading(),
        error: (error, _) => MqSimpleError(
          message: error.toString(),
          onRetry: () => ref.invalidate(learningPathProvider(pathId)),
        ),
        data: (detail) => _PathMap(
          detail: detail,
          bookId: bookId,
          pathId: pathId,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Path map — Duolingo-style node layout
// ---------------------------------------------------------------------------

class _PathMap extends StatelessWidget {
  const _PathMap({
    required this.detail,
    required this.bookId,
    required this.pathId,
  });

  final LearningPathDetail detail;
  final String bookId;
  final String pathId;

  static const double _nodeSize = 80.0;
  static const double _nodeVerticalGap = 60.0;
  static const double _horizontalAmplitude = 60.0;

  @override
  Widget build(BuildContext context) {
    final lessons = detail.lessons;
    if (lessons.isEmpty) {
      return const Center(child: Text('No lessons in this path yet.'));
    }

    final width = MediaQuery.of(context).size.width;
    final centerX = width / 2;

    // Build list of items: chapter headers + lesson nodes.
    const chapterSize = 3;
    final items = <_MapItem>[];
    for (int i = 0; i < lessons.length; i++) {
      if (i % chapterSize == 0) {
        items.add(_ChapterHeaderItem(
            title: 'Chapter ${(i ~/ chapterSize) + 1}'));
      }
      items.add(_LessonNodeItem(lesson: lessons[i], index: i));
    }

    return _NodeMapCanvas(
      items: items,
      lessons: lessons,
      detail: detail,
      bookId: bookId,
      pathId: pathId,
      centerX: centerX,
      nodeSize: _nodeSize,
      nodeVerticalGap: _nodeVerticalGap,
      amplitude: _horizontalAmplitude,
    );
  }
}

// ---------------------------------------------------------------------------
// Canvas: positions all nodes using a Stack, draws connectors underneath
// ---------------------------------------------------------------------------

class _NodeMapCanvas extends StatelessWidget {
  const _NodeMapCanvas({
    required this.items,
    required this.lessons,
    required this.detail,
    required this.bookId,
    required this.pathId,
    required this.centerX,
    required this.nodeSize,
    required this.nodeVerticalGap,
    required this.amplitude,
  });

  final List<_MapItem> items;
  final List<Lesson> lessons;
  final LearningPathDetail detail;
  final String bookId;
  final String pathId;
  final double centerX;
  final double nodeSize;
  final double nodeVerticalGap;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    const chapterHeaderHeight = 60.0;
    final nodeStep = nodeSize + nodeVerticalGap;

    // Layout pass: assign Y/X to every lesson node.
    final List<double> nodeYCenters = [];
    final List<double> nodeXCenters = [];
    double runningY = AppSpacing.md;

    for (final item in items) {
      if (item is _ChapterHeaderItem) {
        runningY += chapterHeaderHeight;
      } else if (item is _LessonNodeItem) {
        final xOffset = _nodeX(item.index, centerX, amplitude, nodeSize);
        nodeYCenters.add(runningY + nodeSize / 2);
        nodeXCenters.add(xOffset + nodeSize / 2);
        runningY += nodeStep;
      }
    }

    final totalHeight = runningY + AppSpacing.xxl;

    final painterStatuses = lessons
        .map((l) => _toPathPainterStatus(detail.progressMap[l.id]))
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Connector lines.
            Positioned.fill(
              child: CustomPaint(
                painter: PathConnectorPainter(
                  nodePositions: nodeYCenters,
                  nodeStatuses: painterStatuses,
                  nodeXOffsets: nodeXCenters,
                ),
              ),
            ),
            // Items (headers + nodes).
            ..._buildItemWidgets(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemWidgets(BuildContext context) {
    const chapterHeaderHeight = 60.0;
    final nodeStep = nodeSize + nodeVerticalGap;
    double runningY = AppSpacing.md;
    int nodeIndex = 0;

    return items.map((item) {
      Widget widget;

      if (item is _ChapterHeaderItem) {
        widget = Positioned(
          top: runningY,
          left: 0,
          right: 0,
          height: chapterHeaderHeight,
          child: _ChapterHeader(title: item.title),
        );
        runningY += chapterHeaderHeight;
      } else {
        final lessonItem = item as _LessonNodeItem;
        final lesson = lessonItem.lesson;
        final nodeStatus =
            detail.progressMap[lesson.id] ?? LessonStatus.locked;
        final x = _nodeX(lessonItem.index, centerX, amplitude, nodeSize);
        final y = runningY;
        final delay = Duration(milliseconds: nodeIndex * 60);

        widget = Positioned(
          top: y,
          left: x,
          child: Column(
            children: [
              LessonNodeCard(
                lesson: lesson,
                status: nodeStatus,
                onTap: nodeStatus != LessonStatus.locked
                    ? () => context.push(
                        RouteNames.lessonPath(bookId, pathId, lesson.id))
                    : null,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: delay)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      delay: delay),
              const SizedBox(height: 6),
              SizedBox(
                width: nodeSize,
                child: Text(
                  lesson.title,
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

        runningY += nodeStep;
        nodeIndex++;
      }

      return widget;
    }).toList();
  }

  double _nodeX(int index, double center, double amplitude, double size) {
    final offset = (index % 2 == 0 ? -amplitude : amplitude);
    return center - size / 2 + offset;
  }

  LessonStatus _toPathPainterStatus(LessonStatus? status) =>
      status ?? LessonStatus.locked;
}

// ---------------------------------------------------------------------------
// Chapter header
// ---------------------------------------------------------------------------

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map item types
// ---------------------------------------------------------------------------

sealed class _MapItem {
  const _MapItem();
}

class _ChapterHeaderItem extends _MapItem {
  const _ChapterHeaderItem({required this.title});
  final String title;
}

class _LessonNodeItem extends _MapItem {
  const _LessonNodeItem({required this.lesson, required this.index});
  final Lesson lesson;
  final int index;
}
