import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'xp_total') @Default(0) int xpTotal,
    @Default(1) int level,
    @JsonKey(name: 'level_title') String? levelTitle,
    @JsonKey(name: 'weak_concepts') @Default([]) List<String> weakConcepts,
    @JsonKey(name: 'learning_goals') @Default([]) List<String> learningGoals,
    @JsonKey(name: 'daily_goal_minutes') @Default(15) int dailyGoalMinutes,
    String? timezone,
    @JsonKey(name: 'is_onboarded') @Default(false) bool isOnboarded,
    @JsonKey(name: 'books_completed') @Default(0) int booksCompleted,
    @JsonKey(name: 'lessons_completed') @Default(0) int lessonsCompleted,
    @JsonKey(name: 'total_study_time_minutes') @Default(0) int totalStudyTimeMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
