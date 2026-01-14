import 'dart:math';

/// Represents a habit's score for a specific date.
///
/// Uses exponential moving average (EMA) for natural score decay.
/// Score values range from 0.0 (never completed) to 1.0 (perfect).
class HabitScore {
  final DateTime date;
  final double value;

  const HabitScore({required this.date, required this.value});

  /// Compute the new score based on frequency and completion.
  ///
  /// [frequency] - Habit frequency as ratio (e.g., 3 times per week = 3/7 = 0.428)
  /// [previousScore] - Score from the previous day (0.0 to 1.0)
  /// [checkmarkValue] - Completion value for today (0.0 to 1.0)
  ///
  /// The formula uses EMA with frequency-based decay:
  /// - Daily habits (frequency=1.0) decay faster
  /// - Weekly habits (frequency≈0.14) decay slower
  static double compute({
    required double frequency,
    required double previousScore,
    required double checkmarkValue,
  }) {
    // Multiplier determines decay rate based on frequency
    // Higher frequency = faster decay (daily habits need consistent completion)
    // Lower frequency = slower decay (weekly habits are more forgiving)
    final multiplier = pow(0.5, sqrt(frequency) / 13.0);

    // EMA formula: blend previous score with current completion
    final score =
        previousScore * multiplier + checkmarkValue * (1 - multiplier);

    return score.clamp(0.0, 1.0);
  }

  /// Get score as percentage (0-100)
  int get percentage => (value * 100).round();

  /// Get score rating
  ScoreRating get rating {
    if (value >= 0.8) return ScoreRating.excellent;
    if (value >= 0.6) return ScoreRating.good;
    if (value >= 0.4) return ScoreRating.fair;
    if (value >= 0.2) return ScoreRating.poor;
    return ScoreRating.none;
  }

  @override
  String toString() =>
      'HabitScore(date: $date, value: ${value.toStringAsFixed(3)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitScore &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          value == other.value;

  @override
  int get hashCode => date.hashCode ^ value.hashCode;
}

/// Score rating levels for UI display
enum ScoreRating {
  excellent, // 80-100%
  good, // 60-79%
  fair, // 40-59%
  poor, // 20-39%
  none, // 0-19%
}
