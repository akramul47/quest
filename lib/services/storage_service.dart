import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quest/models/todo.dart';
import 'package:quest/models/timer_state.dart';
import 'package:quest/models/habit.dart';

class StorageService {
  static const String _todosKey = 'todos';
  static const String _windowWidthKey = 'window_width';
  static const String _windowHeightKey = 'window_height';
  static const String _windowXKey = 'window_x';
  static const String _windowYKey = 'window_y';
  static const String _windowMaximizedKey = 'window_maximized';
  static const String _windowAlwaysOnTopKey = 'window_always_on_top';

  // Save window state
  Future<void> saveWindowState({
    required double width,
    required double height,
    required double x,
    required double y,
    required bool isMaximized,
    required bool isAlwaysOnTop,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_windowWidthKey, width);
    await prefs.setDouble(_windowHeightKey, height);
    await prefs.setDouble(_windowXKey, x);
    await prefs.setDouble(_windowYKey, y);
    await prefs.setBool(_windowMaximizedKey, isMaximized);
    await prefs.setBool(_windowAlwaysOnTopKey, isAlwaysOnTop);
  }

  // Load window state
  Future<Map<String, dynamic>?> loadWindowState() async {
    final prefs = await SharedPreferences.getInstance();
    final width = prefs.getDouble(_windowWidthKey);
    final height = prefs.getDouble(_windowHeightKey);
    final x = prefs.getDouble(_windowXKey);
    final y = prefs.getDouble(_windowYKey);
    final isMaximized = prefs.getBool(_windowMaximizedKey);
    final isAlwaysOnTop = prefs.getBool(_windowAlwaysOnTopKey);

    if (width == null || height == null) return null;

    return {
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'isMaximized': isMaximized ?? false,
      'isAlwaysOnTop': isAlwaysOnTop ?? true,
    };
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = json.encode(
      todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_todosKey, todosJson);
  }

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_todosKey);
    if (todosJson == null) return [];

    final List<dynamic> todosList = json.decode(todosJson);
    return todosList.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> archiveCompletedTasks(List<Todo> completedTodos) async {
    final directory = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${directory.path}/todo_archives');
    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }

    final date = DateTime.now();
    final fileName = '${date.year}-${date.month}-${date.day}.json';
    final file = File('${archiveDir.path}/$fileName');

    final archiveData = {
      'date': date.toIso8601String(),
      'tasks': completedTodos.map((todo) => todo.toJson()).toList(),
    };

    await file.writeAsString(json.encode(archiveData));
  }

  Future<Map<String, List<Todo>>> loadArchivedTasks() async {
    final directory = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${directory.path}/todo_archives');
    if (!await archiveDir.exists()) {
      return {};
    }

    final Map<String, List<Todo>> archives = {};
    final List<FileSystemEntity> files = await archiveDir.list().toList();

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        final data = json.decode(content);
        final tasks =
            (data['tasks'] as List).map((task) => Todo.fromJson(task)).toList();
        archives[data['date']] = tasks;
      }
    }

    return archives;
  }

  // Focus Timer Settings
  static const String _focusSettingsKey = 'focus_settings';
  static const String _focusSessionsKey = 'focus_sessions_today';
  static const String _focusTotalTimeKey = 'focus_total_time_today';
  static const String _focusLastResetKey = 'focus_last_reset_date';

  Future<void> saveFocusSettings(TimerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_focusSettingsKey, json.encode(settings.toJson()));
  }

  Future<TimerSettings> loadFocusSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_focusSettingsKey);
    if (settingsJson == null) return const TimerSettings();
    
    return TimerSettings.fromJson(json.decode(settingsJson));
  }

  Future<void> saveFocusSessionData({
    required int completedSessions,
    required int totalTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    await prefs.setInt(_focusSessionsKey, completedSessions);
    await prefs.setInt(_focusTotalTimeKey, totalTime);
    await prefs.setString(_focusLastResetKey, today);
  }

  Future<Map<String, int>> loadFocusSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastReset = prefs.getString(_focusLastResetKey);
    
    // Reset if it's a new day
    if (lastReset != today) {
      await prefs.setInt(_focusSessionsKey, 0);
      await prefs.setInt(_focusTotalTimeKey, 0);
      await prefs.setString(_focusLastResetKey, today);
      return {'sessions': 0, 'totalTime': 0};
    }
    
    return {
      'sessions': prefs.getInt(_focusSessionsKey) ?? 0,
      'totalTime': prefs.getInt(_focusTotalTimeKey) ?? 0,
    };
  }

  // Habits Storage
  static const String _habitsKey = 'habits';

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsJson = json.encode(
      habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString(_habitsKey, habitsJson);
  }

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);
    if (habitsJson == null) return [];

    final List<dynamic> habitsList = json.decode(habitsJson);
    return habitsList.map((json) => Habit.fromJson(json)).toList();
  }
}
