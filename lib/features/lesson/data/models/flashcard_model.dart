import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class Flashcard with _$Flashcard {
  const factory Flashcard({
    required String id,
    @JsonKey(name: 'front_text') required String frontText,
    @JsonKey(name: 'front_image_url') String? frontImageUrl,
    @JsonKey(name: 'back_text') required String backText,
    @JsonKey(name: 'back_explanation') String? backExplanation,
    @Default([]) List<String> tags,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _Flashcard;

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);
}

@freezed
class FlashcardDeck with _$FlashcardDeck {
  const factory FlashcardDeck({
    required String id,
    @JsonKey(name: 'lesson_id') required String lessonId,
    required String title,
    @JsonKey(name: 'study_mode') required String studyMode,
    @Default([]) List<Flashcard> cards,
  }) = _FlashcardDeck;

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDeckFromJson(json);
}
