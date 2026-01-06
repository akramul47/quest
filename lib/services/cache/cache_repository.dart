import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/habit.dart';
import '../../models/timer_state.dart';
import '../../models/todo.dart';
import 'daos/focus_session_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/todo_dao.dart';

/// High-level cache repository for export/import operations.
///
/// Provides unified interface for:
/// - Exporting all data to JSON format
/// - Importing data from JSON (with merge or replace options)
/// - File-based export/import for backup
/// - Getting pending sync items
class CacheRepository {
  final TodoDao _todoDao = TodoDao();
  final HabitDao _habitDao = HabitDao();
  final FocusSessionDao _focusSessionDao = FocusSessionDao();

  /// Export all data to a JSON map
  ///
  /// Returns a map containing all cached data:
  /// - `todos`: List of todos with subtasks
  /// - `habits`: List of habits with history
  /// - `focusSessions`: List of focus sessions
  /// - `timerSettings`: Timer configuration
  /// - `exportedAt`: Export timestamp
  /// - `appVersion`: App version for compatibility checking
  Future<Map<String, dynamic>> exportAllData({String? appVersion}) async {
    final todos = await _todoDao.getAll();
    final habits = await _habitDao.getAll();
    final focusSessions = await _focusSessionDao.getAll();
    final timerSettings = await _focusSessionDao.loadSettings();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': appVersion ?? '1.0.0',
      'schemaVersion': 1,
      'todos': todos.map((t) => t.toJson()).toList(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'focusSessions': focusSessions.map((s) => s.toJson()).toList(),
      'timerSettings': timerSettings.toJson(),
    };
  }

  /// Import data from a JSON map
  ///
  /// [data] - The JSON map to import
  /// [replace] - If true, clears existing data before import.
  ///             If false, merges with existing data (updates existing, adds new).
  Future<ImportResult> importData(
    Map<String, dynamic> data, {
    bool replace = false,
  }) async {
    int todosImported = 0;
    int habitsImported = 0;
    int sessionsImported = 0;

    try {
      if (replace) {
        // Clear all existing data first
        await _todoDao.clearAll();
        await _habitDao.clearAll();
        await _focusSessionDao.clearAll();
      }

      // Import todos
      if (data['todos'] != null) {
        final todosList = (data['todos'] as List)
            .map((json) => Todo.fromJson(json as Map<String, dynamic>))
            .toList();
        await _todoDao.batchInsert(todosList);
        todosImported = todosList.length;
      }

      // Import habits
      if (data['habits'] != null) {
        final habitsList = (data['habits'] as List)
            .map((json) => Habit.fromJson(json as Map<String, dynamic>))
            .toList();
        await _habitDao.batchInsert(habitsList);
        habitsImported = habitsList.length;
      }

      // Import focus sessions
      if (data['focusSessions'] != null) {
        final sessionsList = (data['focusSessions'] as List)
            .map((json) => FocusSession.fromJson(json as Map<String, dynamic>))
            .toList();
        await _focusSessionDao.batchInsert(sessionsList);
        sessionsImported = sessionsList.length;
      }

      // Import timer settings
      if (data['timerSettings'] != null) {
        final settings = TimerSettings.fromJson(
          data['timerSettings'] as Map<String, dynamic>,
        );
        await _focusSessionDao.saveSettings(settings);
      }

      return ImportResult(
        success: true,
        todosImported: todosImported,
        habitsImported: habitsImported,
        sessionsImported: sessionsImported,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
        todosImported: todosImported,
        habitsImported: habitsImported,
        sessionsImported: sessionsImported,
      );
    }
  }

  /// Export all data to a JSON file
  ///
  /// [fileName] - Name of the export file (without extension)
  /// Returns the File object of the created export file
  Future<File> exportToFile({String? fileName, String? appVersion}) async {
    final data = await exportAllData(appVersion: appVersion);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/quest_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final name = fileName ?? 'quest_backup_$timestamp';
    final file = File('${exportDir.path}/$name.json');

    await file.writeAsString(jsonString);
    return file;
  }

  /// Import data from a JSON file
  Future<ImportResult> importFromFile(
    String filePath, {
    bool replace = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, error: 'File not found: $filePath');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return importData(data, replace: replace);
    } catch (e) {
      return ImportResult(success: false, error: 'Failed to read file: $e');
    }
  }

  /// Get all items that are pending synchronization
  Future<Map<String, List<dynamic>>> getPendingSyncItems() async {
    final pendingTodos = await _todoDao.getPendingSync();
    final pendingHabits = await _habitDao.getPendingSync();
    final pendingSessions = await _focusSessionDao.getPendingSync();

    return {
      'todos': pendingTodos,
      'habits': pendingHabits,
      'focusSessions': pendingSessions,
    };
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    await _todoDao.clearAll();
    await _habitDao.clearAll();
    await _focusSessionDao.clearAll();
  }

  /// Get export directory path
  Future<String> getExportDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/quest_exports';
  }

  /// List all available export files
  Future<List<File>> listExportFiles() async {
    final exportPath = await getExportDirectoryPath();
    final exportDir = Directory(exportPath);

    if (!await exportDir.exists()) {
      return [];
    }

    final files = await exportDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .map((entity) => entity as File)
        .toList();

    return files;
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String? error;
  final int todosImported;
  final int habitsImported;
  final int sessionsImported;

  ImportResult({
    required this.success,
    this.error,
    this.todosImported = 0,
    this.habitsImported = 0,
    this.sessionsImported = 0,
  });

  int get totalImported => todosImported + habitsImported + sessionsImported;

  @override
  String toString() {
    if (success) {
      return 'Import successful: $todosImported todos, $habitsImported habits, $sessionsImported sessions';
    } else {
      return 'Import failed: $error';
    }
  }
}
