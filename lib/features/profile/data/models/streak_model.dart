import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_model.freezed.dart';
part 'streak_model.g.dart';

@freezed
@JsonSerializable()
class StreakModel with _$StreakModel {
  const factory StreakModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
    @JsonKey(name: 'longest_streak') @Default(0) int longestStreak,
    @JsonKey(name: 'last_activity_date') String? lastActivityDate,
    @JsonKey(name: 'freeze_count') @Default(0) int freezeCount,
    @JsonKey(name: 'max_freezes') @Default(3) int maxFreezes,
    @JsonKey(name: 'weekly_activity') @Default({}) Map<String, bool> weeklyActivity,
    @JsonKey(name: 'total_active_days') @Default(0) int totalActiveDays,
  }) = _StreakModel;

  factory StreakModel.fromJson(Map<String, dynamic> json) =>
      _$StreakModelFromJson(json);
}
