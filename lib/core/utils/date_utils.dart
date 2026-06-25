/// Date and duration utility functions for MindQuest.
///
/// Named [MqDateUtils] to avoid shadowing Flutter's own `DateUtils` class.
abstract final class MqDateUtils {
  // ---------------------------------------------------------------------------
  // Day comparison helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when [d] falls on the same calendar day as today (local).
  static bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Returns `true` when [d] falls on the calendar day immediately before today.
  static bool isYesterday(DateTime d) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
  }

  /// Returns how many full calendar days ago [d] was relative to today.
  ///
  /// Returns `0` for today, `1` for yesterday, etc.
  static int daysAgo(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    return today.difference(target).inDays;
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  /// Formats a [Duration] as a concise human-readable string.
  ///
  /// Examples:
  /// - 45 seconds → `'<1m'`
  /// - 5 minutes → `'5m'`
  /// - 90 minutes → `'1h 30m'`
  /// - 120 minutes → `'2h'`
  static String formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes < 1) return '<1m';
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Formats seconds as a MM:SS countdown string.
  ///
  /// Example: 75 → `'1:15'`
  static String formatCountdown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Key generators
  // ---------------------------------------------------------------------------

  /// Returns an ISO 8601 week key for [d] in the form `'YYYY-Www'`.
  ///
  /// Uses ISO week numbering (week starts on Monday).
  /// Example: 2024-01-08 → `'2024-W02'`
  static String weekKey(DateTime d) {
    final isoWeek = _isoWeekNumber(d);
    final year = _isoWeekYear(d);
    return '$year-W${isoWeek.toString().padLeft(2, '0')}';
  }

  /// Returns a month key for [d] in the form `'YYYY-MM'`.
  ///
  /// Example: 2024-03-15 → `'2024-03'`
  static String monthKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  /// Returns a day key for [d] in the form `'YYYY-MM-DD'`.
  ///
  /// Example: 2024-03-05 → `'2024-03-05'`
  static String dayKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Streak helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when the streak is still active given [lastActivityDate].
  ///
  /// A streak is active if [lastActivityDate] is today or yesterday.
  static bool isStreakActive(DateTime lastActivityDate) =>
      isToday(lastActivityDate) || isYesterday(lastActivityDate);

  /// Clamps a [DateTime] to midnight (start of day) in local time.
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns a [DateTime] for midnight at the start of the week (Monday) that
  /// contains [d].
  static DateTime startOfWeek(DateTime d) {
    final weekday = d.weekday; // 1=Mon … 7=Sun
    return startOfDay(d.subtract(Duration(days: weekday - 1)));
  }

  // ---------------------------------------------------------------------------
  // ISO week number internals
  // ---------------------------------------------------------------------------

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = _dayOfYear(date);
    final weekday = date.weekday; // 1=Mon … 7=Sun
    final week = ((dayOfYear - weekday + 10) / 7).floor();
    if (week < 1) {
      return _isoWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    if (week > 52) {
      final dec31Weekday = DateTime(date.year, 12, 31).weekday;
      if (dec31Weekday < 4) return 1;
    }
    return week;
  }

  static int _isoWeekYear(DateTime date) {
    final week = _isoWeekNumber(date);
    if (week >= 52 && date.month == 1) return date.year - 1;
    if (week == 1 && date.month == 12) return date.year + 1;
    return date.year;
  }

  static int _dayOfYear(DateTime date) {
    final firstOfYear = DateTime(date.year, 1, 1);
    return date.difference(firstOfYear).inDays + 1;
  }
}
