import 'package:flutter/material.dart';
import '../utils/habit_icons.dart';

/// Type of habit tracking: boolean (yes/no) or measurable (numeric value)
enum HabitType {
  boolean,
  measurable;

  String get displayName {
    switch (this) {
      case HabitType.boolean:
        return 'Yes/No';
      case HabitType.measurable:
        return 'Measurable';
    }
  }
}

/// Represents a single habit that can be tracked over time
class Habit {
  final String id;
  String name;
  Color color;
  IconData icon;
  HabitType type;
  String unit; // For measurable habits (e.g., "miles", "pages", "minutes")
  Map<String, dynamic> history; // Date (ISO string) -> value (bool or num)
  DateTime createdAt;
  bool isArchived;
  String? question; // Optional question text (e.g., "Did you meditate?")
  TimeOfDay? reminderTime; // Optional reminder time

  Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.type = HabitType.boolean,
    this.unit = '',
    Map<String, dynamic>? history,
    required this.createdAt,
    this.isArchived = false,
    this.question,
    this.reminderTime,
  }) : history = history ?? {};

  /// Toggle a boolean habit for a specific date
  void toggleDay(DateTime date) {
    if (type != HabitType.boolean) return;
    final dateKey = _dateToKey(date);
    history[dateKey] = !(history[dateKey] as bool? ?? false);
  }

  /// Record a measurable value for a specific date
  void recordValue(DateTime date, double value) {
    if (type != HabitType.measurable) return;
    final dateKey = _dateToKey(date);
    history[dateKey] = value;
  }

  /// Get value for a specific date (bool or num)
  dynamic getValueForDate(DateTime date) {
    final dateKey = _dateToKey(date);
    return history[dateKey];
  }

  /// Check if habit was completed on a specific date
  bool isCompletedOn(DateTime date) {
    final value = getValueForDate(date);
    if (value == null) return false;

    // Handle both boolean and numeric values regardless of current type
    // This handles cases where habit type was changed but history has mixed data
    if (value is bool) {
      return value;
    } else if (value is num) {
      return value > 0;
    }
    return false;
  }

  /// Calculate current streak (consecutive days completed)
  int getCurrentStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      if (isCompletedOn(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow for today not being completed yet
        if (streak == 0 && _isToday(checkDate)) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak ever
  int getLongestStreak() {
    if (history.isEmpty) return 0;

    // Get all dates sorted
    final dates =
        history.keys
            .map((key) => DateTime.parse(key))
            .where((date) => isCompletedOn(date))
            .toList()
          ..sort();

    if (dates.isEmpty) return 0;

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final daysDiff = dates[i].difference(dates[i - 1]).inDays;
      if (daysDiff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  /// Get completion rate for a specific period (last N days)
  double getCompletionRate(int days) {
    int completed = 0;
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (isCompletedOn(date)) {
        completed++;
      }
    }

    return completed / days;
  }

  /// Get total count of completed days
  int getTotalCompletedDays() {
    return history.values.where((value) {
      // Handle both boolean and numeric values regardless of current type
      if (value is bool) {
        return value;
      } else if (value is num) {
        return value > 0;
      }
      return false;
    }).length;
  }

  /// Get total sum for measurable habits
  double getTotalValue() {
    if (type != HabitType.measurable) return 0;
    return history.values.whereType<num>().fold(
      0,
      (sum, value) => sum + value.toDouble(),
    );
  }

  /// Get weekly summary (last 7 days)
  List<MapEntry<DateTime, dynamic>> getWeeklySummary() {
    final now = DateTime.now();
    final summary = <MapEntry<DateTime, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = getValueForDate(date);
      summary.add(MapEntry(date, value));
    }

    return summary;
  }

  /// Copy with modified fields
  Habit copyWith({
    String? name,
    Color? color,
    IconData? icon,
    HabitType? type,
    String? unit,
    Map<String, dynamic>? history,
    bool? isArchived,
    String? question,
    TimeOfDay? reminderTime,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      history: history ?? Map.from(this.history),
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
      question: question ?? this.question,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'type': type.index,
      'unit': unit,
      'history': history,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'question': question,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: HabitIcons.fromCodePoint(json['icon']),
      type: HabitType.values[json['type'] ?? 0],
      unit: json['unit'] ?? '',
      history: Map<String, dynamic>.from(json['history'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      isArchived: json['isArchived'] ?? false,
      question: json['question'],
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: json['reminderTime']['hour'],
              minute: json['reminderTime']['minute'],
            )
          : null,
    );
  }

  // Helper methods
  static String _dateToKey(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T')[0];
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
