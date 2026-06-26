import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';
import '../../data/models/learning_path_model.dart';

/// Draws connecting lines between lesson nodes on the learning path map.
///
/// [nodePositions] is a list of center-Y offsets (in the painter's local
/// coordinate space) for each node, ordered top to bottom.
/// [nodeStatuses] has the same length and drives the line style:
///   - Between two completed nodes → solid primary-coloured line.
///   - All other segments → dashed grey line.
class PathConnectorPainter extends CustomPainter {
  const PathConnectorPainter({
    required this.nodePositions,
    required this.nodeStatuses,
    this.nodeXOffsets,
  });

  /// Center-Y for each node (local coordinates, same length as [nodeStatuses]).
  final List<double> nodePositions;

  /// Status for each node (drives line colour).
  final List<LessonStatus> nodeStatuses;

  /// Center-X for each node. Defaults to canvas midpoint if null.
  final List<double>? nodeXOffsets;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final x1 = nodeXOffsets != null ? nodeXOffsets![i] : size.width / 2;
      final y1 = nodePositions[i];
      final x2 = nodeXOffsets != null ? nodeXOffsets![i + 1] : size.width / 2;
      final y2 = nodePositions[i + 1];

      final isCompleted = nodeStatuses[i] == LessonStatus.completed &&
          nodeStatuses[i + 1] == LessonStatus.completed;

      if (isCompleted) {
        _drawSolidLine(canvas, Offset(x1, y1), Offset(x2, y2));
      } else {
        _drawDashedLine(canvas, Offset(x1, y1), Offset(x2, y2));
      }
    }
  }

  void _drawSolidLine(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashLength = 8.0;
    const gapLength = 5.0;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final totalLength = (Offset(dx, dy)).distance;
    final unitX = dx / totalLength;
    final unitY = dy / totalLength;

    double progress = 0.0;
    bool drawing = true;

    while (progress < totalLength) {
      final segmentLength =
          drawing ? dashLength : gapLength;
      final end =
          (progress + segmentLength).clamp(0.0, totalLength);
      if (drawing) {
        canvas.drawLine(
          Offset(from.dx + unitX * progress, from.dy + unitY * progress),
          Offset(from.dx + unitX * end, from.dy + unitY * end),
          paint,
        );
      }
      progress += segmentLength;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(PathConnectorPainter old) =>
      old.nodePositions != nodePositions ||
      old.nodeStatuses != nodeStatuses;
}
