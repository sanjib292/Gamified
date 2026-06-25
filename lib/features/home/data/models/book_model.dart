import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindquest/core/constants/enums.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
@JsonSerializable()
class BookModel with _$BookModel {
  const factory BookModel({
    required String id,
    required String title,
    String? subtitle,
    required String author,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? description,
    @JsonKey(name: 'total_lessons') required int totalLessons,
    @JsonKey(name: 'estimated_minutes') required int estimatedMinutes,
    @JsonKey(
      name: 'difficulty',
      fromJson: DifficultyLevel.fromJson,
      toJson: _difficultyToJson,
    )
    required DifficultyLevel difficulty,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
    @Default([]) List<String> tags,
    @Default([]) List<String> categories,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
}

String _difficultyToJson(DifficultyLevel level) => level.toJson();
