/// Pure domain function to calculate current recovery streak from check-in dates.
///
/// If [referenceDate] is omitted, defaults to the current date.
/// Returns the number of consecutive days up to today or yesterday.
int calculateStreak(List<DateTime> checkinDates, [DateTime? referenceDate]) {
  if (checkinDates.isEmpty) return 0;

  final localRef = (referenceDate ?? DateTime.now()).toLocal();
  final today = DateTime.utc(localRef.year, localRef.month, localRef.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Normalize dates to local calendar dates, then wrap in UTC (year, month, day)
  // to eliminate DST and timezone offset artifacts when computing day differences.
  final normalizedDates =
      checkinDates
          .map((d) {
            final local = d.toLocal();
            return DateTime.utc(local.year, local.month, local.day);
          })
          .where((d) => !d.isAfter(today))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Descending: newest first

  if (normalizedDates.isEmpty) return 0;

  // If latest check-in is older than yesterday, streak is broken.
  if (normalizedDates.first.isBefore(yesterday)) {
    return 0;
  }

  // The latest check-in is either today or yesterday, so streak starts at 1.
  int streak = 1;

  for (int i = 0; i < normalizedDates.length - 1; i++) {
    if (normalizedDates[i].difference(normalizedDates[i + 1]).inDays == 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

/// Helper function to calculate streak directly from ISO 8601 date strings.
int calculateStreakFromStrings(
  List<String> dateStrings, [
  DateTime? referenceDate,
]) {
  final dates = <DateTime>[];
  for (final s in dateStrings) {
    final parsed = DateTime.tryParse(s);
    if (parsed != null) {
      dates.add(parsed);
    }
  }
  return calculateStreak(dates, referenceDate);
}
