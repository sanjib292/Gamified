import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../book_detail/data/models/book_detail_model.dart';
import '../../../../shared/widgets/cards/lesson_node_card.dart';

part 'learning_path_model.freezed.dart';
part 'learning_path_model.g.dart';

@freezed
class LearningPathModel with _$LearningPathModel {
  const factory LearningPathModel({
    required String id,
    @JsonKey(name: 'book_id') required String bookId,
    required String title,
    String? description,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'estimated_minutes') @Default(0) int estimatedMinutes,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
  }) = _LearningPathModel;

  factory LearningPathModel.fromJson(Map<String, dynamic> json) =>
      _$LearningPathModelFromJson(json);
}

/// View-model returned by the learning path provider.
/// Aggregates the path metadata, its lessons, and the user's progress map.
class LearningPathDetail {
  const LearningPathDetail({
    required this.path,
    required this.lessons,
    required this.progressMap,
  });

  final LearningPath path;
  final List<Lesson> lessons;
  final Map<String, LessonStatus> progressMap;
}
