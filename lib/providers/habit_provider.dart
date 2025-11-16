import 'package:flutter/foundation.dart';
import '../models/habit.dart';

/// Provider for managing the list of habits with persistence
class HabitList extends ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  /// Get active (non-archived) habits
  List<Habit> get activeHabits =>
      _habits.where((habit) => !habit.isArchived).toList();

  /// Get archived habits
  List<Habit> get archivedHabits =>
      _habits.where((habit) => habit.isArchived).toList();

  /// Get habits sorted by current streak (for leaderboard view)
  List<Habit> get habitsByStreak {
    final active = activeHabits;
    active.sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));
    return active;
  }

  /// Set habits (used when loading from storage)
  void setHabits(List<Habit> habits) {
    _habits = habits;
    notifyListeners();
  }

  /// Add a new habit
  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  /// Update an existing habit
  void updateHabit(String id, Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();
    }
  }

  /// Delete a habit permanently
  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  /// Archive a habit (soft delete)
  void archiveHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isArchived: true);
      notifyListeners();
    }
  }

  /// Unarchive a habit
  void unarchiveHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isArchived: false);
      notifyListeners();
    }
  }

  /// Toggle a boolean habit for a specific date
  void toggleHabitDay(String id, DateTime date) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].toggleDay(date);
      notifyListeners();
    }
  }

  /// Record a measurable value for a habit on a specific date
  void recordHabitValue(String id, DateTime date, double value) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].recordValue(date, value);
      notifyListeners();
    }
  }

  /// Get a habit by ID
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total habits count
  int get totalHabitsCount => _habits.length;

  /// Get active habits count
  int get activeHabitsCount => activeHabits.length;

  /// Get total completion rate for today across all active habits
  double getTodayCompletionRate() {
    final active = activeHabits;
    if (active.isEmpty) return 0;

    final today = DateTime.now();
    int completed = 0;

    for (var habit in active) {
      if (habit.isCompletedOn(today)) {
        completed++;
      }
    }

    return completed / active.length;
  }

  /// Get habits completed today
  List<Habit> getHabitsCompletedToday() {
    final today = DateTime.now();
    return activeHabits.where((h) => h.isCompletedOn(today)).toList();
  }

  /// Get habits not completed today
  List<Habit> getHabitsNotCompletedToday() {
    final today = DateTime.now();
    return activeHabits.where((h) => !h.isCompletedOn(today)).toList();
  }

  /// Get weekly overview (completion rate for each day of the week)
  Map<DateTime, double> getWeeklyOverview() {
    final now = DateTime.now();
    final overview = <DateTime, double>{};
    final active = activeHabits;

    if (active.isEmpty) return overview;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int completed = 0;

      for (var habit in active) {
        if (habit.isCompletedOn(date)) {
          completed++;
        }
      }

      overview[date] = completed / active.length;
    }

    return overview;
  }

  /// Get average streak across all active habits
  double getAverageStreak() {
    final active = activeHabits;
    if (active.isEmpty) return 0;

    final totalStreak = active.fold<int>(
      0,
      (sum, habit) => sum + habit.getCurrentStreak(),
    );

    return totalStreak / active.length;
  }

  /// Get best performing habit (longest current streak)
  Habit? getBestHabit() {
    final active = activeHabits;
    if (active.isEmpty) return null;

    return active.reduce((a, b) =>
        a.getCurrentStreak() > b.getCurrentStreak() ? a : b);
  }

  /// Export habits to JSON
  List<Map<String, dynamic>> toJson() {
    return _habits.map((habit) => habit.toJson()).toList();
  }

  /// Import habits from JSON
  void fromJson(List<dynamic> json) {
    _habits = json.map((item) => Habit.fromJson(item)).toList();
    notifyListeners();
  }

  /// Clear all habits (with confirmation in UI)
  void clearAllHabits() {
    _habits.clear();
    notifyListeners();
  }
}
