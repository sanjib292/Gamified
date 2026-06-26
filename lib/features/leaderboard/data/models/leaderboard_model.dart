import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindquest/core/constants/enums.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String id,
    @JsonKey(
      name: 'period_type',
      fromJson: PeriodType.fromJson,
      toJson: _periodTypeToJson,
    )
    required PeriodType periodType,
    @JsonKey(name: 'period_key') required String periodKey,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'xp_earned') @Default(0) int xpEarned,
    @Default(0) int rank,
    @JsonKey(name: 'snapshot_at') required DateTime snapshotAt,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

String _periodTypeToJson(PeriodType pt) => pt.toJson();
