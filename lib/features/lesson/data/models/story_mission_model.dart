import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_mission_model.freezed.dart';
part 'story_mission_model.g.dart';

@freezed
class StoryChoice with _$StoryChoice {
  const factory StoryChoice({
    required String id,
    required String text,
    @JsonKey(name: 'next_node_id') String? nextNodeId,
    @JsonKey(name: 'is_optimal') @Default(false) bool isOptimal,
    @JsonKey(name: 'xp_bonus') @Default(0) int xpBonus,
  }) = _StoryChoice;

  factory StoryChoice.fromJson(Map<String, dynamic> json) =>
      _$StoryChoiceFromJson(json);
}

@freezed
class StoryNode with _$StoryNode {
  const factory StoryNode({
    required String id,
    required String type,
    required String text,
    @Default([]) List<StoryChoice> choices,
  }) = _StoryNode;

  factory StoryNode.fromJson(Map<String, dynamic> json) =>
      _$StoryNodeFromJson(json);
}

@freezed
class StoryMission with _$StoryMission {
  const factory StoryMission({
    required String id,
    @JsonKey(name: 'lesson_id') required String lessonId,
    required String title,
    @JsonKey(name: 'start_node_id') required String startNodeId,
    @Default([]) List<StoryNode> nodes,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
  }) = _StoryMission;

  factory StoryMission.fromJson(Map<String, dynamic> json) =>
      _$StoryMissionFromJson(json);
}
