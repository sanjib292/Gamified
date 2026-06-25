import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindquest/core/constants/enums.dart';

part 'user_progress_model.freezed.dart';
part 'user_progress_model.g.dart';

@freezed
@JsonSerializable()
class UserProgressModel with _$UserProgressModel {
  const factory UserProgressModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'lesson_id') required String lessonId,
    @JsonKey(
      name: 'status',
      fromJson: LessonStatus.fromJson,
      toJson: _lessonStatusToJson,
    )
    required LessonStatus status,
    @JsonKey(name: 'score_pct') double? scorePct,
    @JsonKey(name: 'xp_earned') @Default(0) int xpEarned,
    @JsonKey(name: 'attempts_count') @Default(0) int attemptsCount,
    @JsonKey(name: 'best_score_pct') double? bestScorePct,
    @JsonKey(name: 'srs_state') @Default({}) Map<String, dynamic> srsState,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'last_attempted_at') DateTime? lastAttemptedAt,
  }) = _UserProgressModel;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);
}

String _lessonStatusToJson(LessonStatus status) => status.toJson();
