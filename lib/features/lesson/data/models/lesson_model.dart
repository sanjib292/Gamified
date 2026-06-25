import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindquest/core/constants/enums.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
@JsonSerializable()
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    @JsonKey(name: 'learning_path_id') required String learningPathId,
    @JsonKey(name: 'book_id') required String bookId,
    required String title,
    String? subtitle,
    @JsonKey(name: 'key_concepts') @Default([]) List<String> keyConcepts,
    String? summary,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'estimated_minutes') @Default(0) int estimatedMinutes,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    @JsonKey(name: 'is_free_preview') @Default(false) bool isFreePreview,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(
      name: 'content_type',
      fromJson: ContentType.fromJson,
      toJson: _contentTypeToJson,
    )
    required ContentType contentType,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

String _contentTypeToJson(ContentType ct) => ct.toJson();
