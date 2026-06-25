import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
@JsonSerializable()
class QuizOption with _$QuizOption {
  const factory QuizOption({
    required String id,
    required String text,
    @JsonKey(name: 'is_correct') @Default(false) bool isCorrect,
  }) = _QuizOption;

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionFromJson(json);
}

@freezed
@JsonSerializable()
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @Default([]) List<QuizOption> options,
    @JsonKey(name: 'correct_option_ids') @Default([]) List<String> correctOptionIds,
    String? explanation,
    String? hint,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}

@freezed
@JsonSerializable()
class Quiz with _$Quiz {
  const factory Quiz({
    required String id,
    @JsonKey(name: 'lesson_id') required String lessonId,
    required String title,
    @JsonKey(name: 'passing_score_pct') @Default(70) int passingScorePct,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    @JsonKey(name: 'xp_perfect_reward') @Default(0) int xpPerfectReward,
    @JsonKey(name: 'time_limit_seconds') int? timeLimitSeconds,
    @Default([]) List<QuizQuestion> questions,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
}
