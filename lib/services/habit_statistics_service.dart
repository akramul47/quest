import '../models/habit.dart';
import '../models/habit_score.dart';
import '../models/habit_streak.dart';

/// Summary statistics for a habit.
class HabitSummary {
  final double todayScore;
  final int currentStreak;
  final int longestStreak;
  final double weeklyRate;
  final double monthlyRate;
  final int totalCompletions;
  final double totalValue;

  const HabitSummary({
    required this.todayScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyRate,
    required this.monthlyRate,
    required this.totalCompletions,
    required this.totalValue,
  });
}

/// Service for computing habit statistics, scores, and streaks.
///
/// Provides comprehensive analytics for charts and habit detail screens.
class HabitStatisticsService {
  // Singleton instance
  static final HabitStatisticsService _instance =
      HabitStatisticsService._internal();
  factory HabitStatisticsService() => _instance;
  HabitStatisticsService._internal();

  static HabitStatisticsService get instance => _instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // SCORE COMPUTATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Compute scores for a habit over a date range.
  ///
  /// Returns a list of [HabitScore] from oldest to newest.
  List<HabitScore> computeScores(Habit habit, {DateTime? from, DateTime? to}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final endDate = to ?? today;
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    // Always start computation from the absolute beginning of the habit's history
    // to ensure consistent EMA values regardless of the requested window.
    final earliestDate = _getEarliestDate(habit);
    final historyStart =
        earliestDate ?? today.subtract(const Duration(days: 365));

    // The calculation loop starts from the earliest relevant date
    var currentDate = DateTime(
      historyStart.year,
      historyStart.month,
      historyStart.day,
    );

    // If requested 'from' is even earlier than history, start there (edge case)
    if (from != null && from.isBefore(currentDate)) {
      currentDate = DateTime(from.year, from.month, from.day);
    }

    if (currentDate.isAfter(normalizedEnd)) return [];

    final frequency = _getHabitFrequency(habit);
    final allScores = <HabitScore>[];
    var previousScore = 0.0;

    while (!currentDate.isAfter(normalizedEnd)) {
      final checkmarkValue = _getCheckmarkValue(habit, currentDate);

      previousScore = HabitScore.compute(
        frequency: frequency,
        previousScore: previousScore,
        checkmarkValue: checkmarkValue,
      );

      allScores.add(HabitScore(date: currentDate, value: previousScore));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Filter results to match the requested range
    if (from != null) {
      final normalizedFrom = DateTime(from.year, from.month, from.day);
      return allScores.where((s) => !s.date.isBefore(normalizedFrom)).toList();
    }

    return allScores;
  }

  /// Get today's score for a habit.
  HabitScore getTodayScore(Habit habit) {
    final scores = computeScores(habit);
    if (scores.isEmpty) {
      final now = DateTime.now();
      return HabitScore(
        date: DateTime(now.year, now.month, now.day),
        value: 0.0,
      );
    }
    return scores.last;
  }

  /// Get score history as a map for charting (last N days).
  Map<DateTime, double> getScoreHistory(Habit habit, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(Duration(days: days - 1));

    final scores = computeScores(habit, from: from, to: today);
    return {for (var s in scores) s.date: s.value};
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAK DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all streaks for a habit.
  ///
  /// Returns streaks ordered by end date (newest first).
  List<HabitStreak> getAllStreaks(Habit habit) {
    final completedDates = _getCompletedDates(habit);
    if (completedDates.isEmpty) return [];

    // Sort dates oldest to newest
    completedDates.sort();

    final streaks = <HabitStreak>[];
    var streakStart = completedDates.first;
    var streakEnd = completedDates.first;

    for (var i = 1; i < completedDates.length; i++) {
      final current = completedDates[i];
      final daysDiff = current.difference(streakEnd).inDays;

      if (daysDiff == 1) {
        // Consecutive day - extend streak
        streakEnd = current;
      } else {
        // Gap found - save current streak and start new one
        streaks.add(HabitStreak(start: streakStart, end: streakEnd));
        streakStart = current;
        streakEnd = current;
      }
    }

    // Add the final streak
    streaks.add(HabitStreak(start: streakStart, end: streakEnd));

    // Sort by end date (newest first)
    streaks.sort((a, b) => b.end.compareTo(a.end));

    return streaks;
  }

  /// Get the best streaks by length.
  ///
  /// Returns up to [limit] streaks, sorted by length (longest first).
  List<HabitStreak> getBestStreaks(Habit habit, {int limit = 5}) {
    final allStreaks = getAllStreaks(habit);

    // Sort by length (longest first), then by end date (newest first)
    allStreaks.sort((a, b) => -a.compareLonger(b));

    return allStreaks.take(limit).toList();
  }

  /// Get the current active streak (if any).
  HabitStreak? getCurrentStreak(Habit habit) {
    final streaks = getAllStreaks(habit);
    if (streaks.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Find streak that ends today or yesterday
    for (final streak in streaks) {
      final endDate = DateTime(
        streak.end.year,
        streak.end.month,
        streak.end.day,
      );
      if (endDate == today || endDate == yesterday) {
        return streak;
      }
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPLETION RATES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get completion rate by week for charting.
  Map<DateTime, double> getCompletionByWeek(Habit habit, int weeks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime, double>{};

    for (var w = 0; w < weeks; w++) {
      final weekStart = today.subtract(
        Duration(days: 7 * w + today.weekday - 1),
      );
      var completed = 0;
      var total = 0;

      for (var d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        if (date.isAfter(today)) break;
        total++;
        if (habit.isCompletedOn(date)) completed++;
      }

      if (total > 0) {
        result[weekStart] = completed / total;
      }
    }

    return result;
  }

  /// Get completion rate by month for charting.
  Map<DateTime, double> getCompletionByMonth(Habit habit, int months) {
    final now = DateTime.now();
    final result = <DateTime, double>{};

    for (var m = 0; m < months; m++) {
      final monthStart = DateTime(now.year, now.month - m, 1);
      final monthEnd = DateTime(now.year, now.month - m + 1, 0);
      var completed = 0;
      var total = 0;

      for (
        var d = monthStart;
        !d.isAfter(monthEnd) && !d.isAfter(now);
        d = d.add(const Duration(days: 1))
      ) {
        total++;
        if (habit.isCompletedOn(d)) completed++;
      }

      if (total > 0) {
        result[monthStart] = completed / total;
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get comprehensive summary statistics for a habit.
  HabitSummary getSummary(Habit habit) {
    final todayScore = getTodayScore(habit);
    final currentStreak = getCurrentStreak(habit);
    final bestStreaks = getBestStreaks(habit, limit: 1);

    return HabitSummary(
      todayScore: todayScore.value,
      currentStreak: currentStreak?.length ?? 0,
      longestStreak: bestStreaks.isNotEmpty ? bestStreaks.first.length : 0,
      weeklyRate: habit.getCompletionRate(7),
      monthlyRate: habit.getCompletionRate(30),
      totalCompletions: habit.getTotalCompletedDays(),
      totalValue: habit.type == HabitType.measurable
          ? habit.getTotalValue()
          : 0,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get habit frequency as a ratio (0.0 to 1.0).
  double _getHabitFrequency(Habit habit) {
    // Default to daily (frequency = 1.0)
    // TODO: Add frequency fields to Habit model for custom frequencies
    return 1.0;
  }

  /// Get checkmark value for a date (0.0 to 1.0).
  double _getCheckmarkValue(Habit habit, DateTime date) {
    final value = habit.getValueForDate(date);

    if (value == null) return 0.0;

    if (habit.type == HabitType.boolean) {
      return (value == true) ? 1.0 : 0.0;
    } else {
      // Measurable: normalize based on reasonable target
      // For now, any value > 0 counts as completion
      if (value is num && value > 0) {
        return 1.0;
      }
      return 0.0;
    }
  }

  /// Get all dates where the habit was completed.
  List<DateTime> _getCompletedDates(Habit habit) {
    return habit.history.entries
        .where((entry) {
          final value = entry.value;
          if (value is bool) return value;
          if (value is num) return value > 0;
          return false;
        })
        .map((entry) {
          final date = DateTime.parse(entry.key);
          return DateTime(date.year, date.month, date.day);
        })
        .toList();
  }

  /// Get the earliest date in habit history.
  DateTime? _getEarliestDate(Habit habit) {
    if (habit.history.isEmpty) return null;

    final dates = habit.history.keys.map((key) => DateTime.parse(key)).toList()
      ..sort();

    return dates.isNotEmpty ? dates.first : null;
  }
}
