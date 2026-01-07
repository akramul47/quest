import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/cache/daos/habit_dao.dart';
import '../services/streak_service.dart';

/// Provider for managing the list of habits with SQLite persistence.
///
/// All mutations are automatically persisted to the database.
class HabitList extends ChangeNotifier {
  final HabitDao _habitDao = HabitDao();
  List<Habit> _habits = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

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

  /// Initialize by loading habits from database
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _habitDao.getAll();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to load habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set habits (used for import/migration)
  void setHabits(List<Habit> habits) {
    _habits = habits;
    notifyListeners();
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    notifyListeners();

    await _habitDao.insert(habit);
  }

  /// Update an existing habit
  Future<void> updateHabit(String id, Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();

      await _habitDao.update(updatedHabit);
    }
  }

  /// Delete a habit permanently
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();

    await _habitDao.delete(id);
  }

  /// Archive a habit (soft delete)
  Future<void> archiveHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isArchived: true);
      notifyListeners();

      await _habitDao.archive(id);
    }
  }

  /// Unarchive a habit
  Future<void> unarchiveHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(isArchived: false);
      notifyListeners();

      await _habitDao.unarchive(id);
    }
  }

  /// Toggle a boolean habit for a specific date
  Future<void> toggleHabitDay(String id, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].toggleDay(date);
      notifyListeners();

      // Persist the updated history entry
      final value = _habits[index].getValueForDate(date);
      await _habitDao.recordEntry(id, date, value);

      // Record streak if completed
      if (_habits[index].isCompletedOn(date)) {
        await StreakService.instance.recordHabitLogged();
      }
    }
  }

  /// Record a measurable value for a habit on a specific date
  Future<void> recordHabitValue(String id, DateTime date, double value) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].recordValue(date, value);
      notifyListeners();

      await _habitDao.recordEntry(id, date, value);

      // Record streak if completed
      if (_habits[index].isCompletedOn(date)) {
        await StreakService.instance.recordHabitLogged();
      }
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

    return active.reduce(
      (a, b) => a.getCurrentStreak() > b.getCurrentStreak() ? a : b,
    );
  }

  /// Export habits to JSON
  List<Map<String, dynamic>> toJson() {
    return _habits.map((habit) => habit.toJson()).toList();
  }

  /// Import habits from JSON
  Future<void> fromJson(List<dynamic> json) async {
    _habits = json.map((item) => Habit.fromJson(item)).toList();
    notifyListeners();

    await _habitDao.batchInsert(_habits);
  }

  /// Clear all habits (with confirmation in UI)
  Future<void> clearAllHabits() async {
    _habits.clear();
    notifyListeners();

    await _habitDao.clearAll();
  }

  /// Reload habits from database
  Future<void> refresh() async {
    _habits = await _habitDao.getAll();
    notifyListeners();
  }
}
