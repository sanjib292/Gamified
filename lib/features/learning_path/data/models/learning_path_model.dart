import 'package:freezed_annotation/freezed_annotation.dart';

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
