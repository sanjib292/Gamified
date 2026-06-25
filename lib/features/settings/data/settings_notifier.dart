import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Settings state
// ---------------------------------------------------------------------------

class AppSettings {
  const AppSettings({
    this.displayName = '',
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.dailyGoalLessons = 3,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.isPremium = false,
  });

  final String displayName;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final int dailyGoalLessons;
  final int reminderHour;
  final int reminderMinute;
  final bool isPremium;

  AppSettings copyWith({
    String? displayName,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    int? dailyGoalLessons,
    int? reminderHour,
    int? reminderMinute,
    bool? isPremium,
  }) =>
      AppSettings(
        displayName: displayName ?? this.displayName,
        darkMode: darkMode ?? this.darkMode,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        dailyGoalLessons: dailyGoalLessons ?? this.dailyGoalLessons,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        isPremium: isPremium ?? this.isPremium,
      );
}

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------

abstract final class _K {
  static const displayName = 'settings.displayName';
  static const darkMode = 'settings.darkMode';
  static const notifications = 'settings.notifications';
  static const sound = 'settings.sound';
  static const dailyGoal = 'settings.dailyGoal';
  static const reminderHour = 'settings.reminderHour';
  static const reminderMinute = 'settings.reminderMinute';
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    // Load from prefs asynchronously; start with defaults.
    _loadFromPrefs();
    return const AppSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      displayName: prefs.getString(_K.displayName) ?? '',
      darkMode: prefs.getBool(_K.darkMode) ?? false,
      notificationsEnabled: prefs.getBool(_K.notifications) ?? true,
      soundEnabled: prefs.getBool(_K.sound) ?? true,
      dailyGoalLessons: prefs.getInt(_K.dailyGoal) ?? 3,
      reminderHour: prefs.getInt(_K.reminderHour) ?? 9,
      reminderMinute: prefs.getInt(_K.reminderMinute) ?? 0,
    );
  }

  void setDisplayName(String name) => _update(
        state.copyWith(displayName: name),
        (prefs) => prefs.setString(_K.displayName, name),
      );

  void setDarkMode(bool value) => _update(
        state.copyWith(darkMode: value),
        (prefs) => prefs.setBool(_K.darkMode, value),
      );

  void setNotifications(bool value) => _update(
        state.copyWith(notificationsEnabled: value),
        (prefs) => prefs.setBool(_K.notifications, value),
      );

  void setSoundEnabled(bool value) => _update(
        state.copyWith(soundEnabled: value),
        (prefs) => prefs.setBool(_K.sound, value),
      );

  void setDailyGoal(int lessons) => _update(
        state.copyWith(dailyGoalLessons: lessons),
        (prefs) => prefs.setInt(_K.dailyGoal, lessons),
      );

  void setReminderTime(int hour, int minute) => _update(
        state.copyWith(reminderHour: hour, reminderMinute: minute),
        (prefs) async {
          await prefs.setInt(_K.reminderHour, hour);
          await prefs.setInt(_K.reminderMinute, minute);
        },
      );

  void _update(
      AppSettings newState, Future<void> Function(SharedPreferences) persist) {
    state = newState;
    SharedPreferences.getInstance().then(persist);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
  name: 'settingsProvider',
);
