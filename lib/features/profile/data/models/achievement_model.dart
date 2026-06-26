import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindquest/core/constants/enums.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String slug,
    required String title,
    String? description,
    @JsonKey(
      name: 'category',
      fromJson: AchievementCategory.fromJson,
      toJson: _achievementCategoryToJson,
    )
    required AchievementCategory category,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'badge_color') String? badgeColor,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    @JsonKey(name: 'is_secret') @Default(false) bool isSecret,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}

String _achievementCategoryToJson(AchievementCategory cat) => cat.toJson();

@freezed
class UserAchievementModel with _$UserAchievementModel {
  const factory UserAchievementModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'achievement_id') required String achievementId,
    AchievementModel? achievement,
    @JsonKey(name: 'earned_at') required DateTime earnedAt,
  }) = _UserAchievementModel;

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementModelFromJson(json);
}
