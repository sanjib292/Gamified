import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Immutable state for the onboarding flow.
///
/// Tracks which page the user is on, their selected learning goal, topic
/// interests, and desired daily study commitment.
@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    /// The goal chip the user tapped (e.g. 'Career growth').
    String? selectedGoal,

    /// The topic chips the user tapped (e.g. ['Finance', 'Psychology']).
    @Default([]) List<String> selectedTopics,

    /// Daily learning commitment chosen via the segmented control (minutes).
    @Default(10) int dailyGoalMinutes,

    /// Current PageView page index (0 = welcome, 1 = goals, 2 = daily goal).
    @Default(0) int currentPage,
  }) = _OnboardingData;
}
