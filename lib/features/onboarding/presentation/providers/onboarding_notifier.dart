import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_state.dart';

/// Manages local onboarding form state.
///
/// This is a plain [StateNotifier] — no async loading needed because data is
/// stored in-memory until the user taps "Get Started", at which point
/// [OnboardingPage] triggers the Supabase write via [supabaseClientProvider].
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  void setPage(int page) => state = state.copyWith(currentPage: page);

  void nextPage() {
    if (state.currentPage < 2) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void selectGoal(String goal) {
    // Toggle: tapping the same goal again deselects it.
    final next = state.selectedGoal == goal ? null : goal;
    state = state.copyWith(selectedGoal: next);
  }

  void toggleTopic(String topic) {
    final current = List<String>.from(state.selectedTopics);
    if (current.contains(topic)) {
      current.remove(topic);
    } else {
      current.add(topic);
    }
    state = state.copyWith(selectedTopics: current);
  }

  void setDailyGoal(int minutes) =>
      state = state.copyWith(dailyGoalMinutes: minutes);
}

/// Provider for [OnboardingNotifier].
///
/// Auto-disposed — no need to keep state after onboarding is complete.
final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingData>(
  (_) => OnboardingNotifier(),
  name: 'onboardingProvider',
);
