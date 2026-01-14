/// Represents a continuous streak of habit completions.
///
/// A streak is a range of consecutive days where the habit was completed.
class HabitStreak {
  final DateTime start;
  final DateTime end;

  const HabitStreak({required this.start, required this.end});

  /// Length of the streak in days (inclusive)
  int get length {
    return end.difference(start).inDays + 1;
  }

  /// Check if this streak is currently active (ends today or later)
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return !endDate.isBefore(today);
  }

  /// Check if this streak includes a specific date
  bool containsDate(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return !checkDate.isBefore(startDate) && !checkDate.isAfter(endDate);
  }

  /// Compare by length (longer is "greater")
  int compareLonger(HabitStreak other) {
    if (length != other.length) {
      return length.compareTo(other.length);
    }
    return compareNewer(other);
  }

  /// Compare by end date (newer is "greater")
  int compareNewer(HabitStreak other) {
    return end.compareTo(other.end);
  }

  @override
  String toString() => 'HabitStreak(start: $start, end: $end, length: $length)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStreak &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
