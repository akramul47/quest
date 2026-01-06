import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/habit.dart';
import '../../models/timer_state.dart';
import '../../models/todo.dart';
import 'daos/focus_session_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/todo_dao.dart';

/// Service for migrating data from SharedPreferences to SQLite.
///
/// This handles the one-time migration of existing data when upgrading
/// from the old SharedPreferences-based storage to the new SQLite cache.
class MigrationService {
  static const String _migrationCompleteKey = 'sqlite_migration_complete_v1';

  final TodoDao _todoDao = TodoDao();
  final HabitDao _habitDao = HabitDao();
  final FocusSessionDao _focusSessionDao = FocusSessionDao();

  /// Check if migration is needed
  Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationCompleteKey) != true;
  }

  /// Run migration if needed
  Future<MigrationResult> migrateIfNeeded() async {
    if (!await needsMigration()) {
      return MigrationResult(
        performed: false,
        message: 'Migration already complete',
      );
    }

    return migrateFromSharedPreferences();
  }

  /// Migrate all data from SharedPreferences to SQLite
  Future<MigrationResult> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    int todosMigrated = 0;
    int habitsMigrated = 0;
    bool settingsMigrated = false;

    try {
      // Migrate todos
      final todosJson = prefs.getString('todos');
      if (todosJson != null) {
        final todosList = (jsonDecode(todosJson) as List)
            .map((json) => Todo.fromJson(json as Map<String, dynamic>))
            .toList();
        await _todoDao.batchInsert(todosList);
        todosMigrated = todosList.length;
      }

      // Migrate habits
      final habitsJson = prefs.getString('habits');
      if (habitsJson != null) {
        final habitsList = (jsonDecode(habitsJson) as List)
            .map((json) => Habit.fromJson(json as Map<String, dynamic>))
            .toList();
        await _habitDao.batchInsert(habitsList);
        habitsMigrated = habitsList.length;
      }

      // Migrate focus settings
      final focusSettingsJson = prefs.getString('focus_settings');
      if (focusSettingsJson != null) {
        final settings = TimerSettings.fromJson(
          jsonDecode(focusSettingsJson) as Map<String, dynamic>,
        );
        await _focusSessionDao.saveSettings(settings);
        settingsMigrated = true;
      }

      // Migrate today's focus session data
      final focusSessions = prefs.getInt('focus_sessions_today');
      final focusTotalTime = prefs.getInt('focus_total_time_today');
      if (focusSessions != null || focusTotalTime != null) {
        await _focusSessionDao.saveFocusSessionData(
          completedSessions: focusSessions ?? 0,
          totalTime: focusTotalTime ?? 0,
        );
      }

      // Mark migration as complete
      await markMigrationComplete();

      // Optionally clear old SharedPreferences data after successful migration
      // Uncomment if you want to clean up old data:
      // await _clearOldData(prefs);

      return MigrationResult(
        performed: true,
        success: true,
        todosMigrated: todosMigrated,
        habitsMigrated: habitsMigrated,
        settingsMigrated: settingsMigrated,
        message: 'Migration successful',
      );
    } catch (e) {
      return MigrationResult(
        performed: true,
        success: false,
        todosMigrated: todosMigrated,
        habitsMigrated: habitsMigrated,
        settingsMigrated: settingsMigrated,
        message: 'Migration failed: $e',
      );
    }
  }

  /// Mark migration as complete
  Future<void> markMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationCompleteKey, true);
  }

  /// Clear old SharedPreferences data after migration
  Future<void> clearOldData() async {
    final prefs = await SharedPreferences.getInstance();

    // Keys to remove (data now in SQLite)
    final keysToRemove = [
      'todos',
      'habits',
      'focus_settings',
      'focus_sessions_today',
      'focus_total_time_today',
      'focus_last_reset_date',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  /// Reset migration status (for testing)
  Future<void> resetMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationCompleteKey);
  }
}

/// Result of a migration operation
class MigrationResult {
  final bool performed;
  final bool success;
  final int todosMigrated;
  final int habitsMigrated;
  final bool settingsMigrated;
  final String message;

  MigrationResult({
    required this.performed,
    this.success = false,
    this.todosMigrated = 0,
    this.habitsMigrated = 0,
    this.settingsMigrated = false,
    required this.message,
  });

  @override
  String toString() {
    if (!performed) return message;
    if (success) {
      return 'Migration successful: $todosMigrated todos, $habitsMigrated habits, '
          'settings: ${settingsMigrated ? 'yes' : 'no'}';
    }
    return 'Migration failed: $message';
  }
}
