import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../models/timer_state.dart';
import '../database_helper.dart';

/// Data Access Object for Focus Session operations.
///
/// Handles all CRUD operations for focus sessions and timer settings.
class FocusSessionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database? get _db => _dbHelper.database;

  /// Insert a new focus session
  Future<void> insert(FocusSession session) async {
    final db = _db;
    if (db == null) return; // Web platform - no database
    await db.insert(
      'focus_sessions',
      _sessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get sessions by date range
  Future<List<FocusSession>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = _db;
    if (db == null) return []; // Web platform
    final results = await db.query(
      'focus_sessions',
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time DESC',
    );
    return results.map((map) => _mapToSession(map)).toList();
  }

  /// Get all sessions for today
  Future<List<FocusSession>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get daily statistics for a specific date
  Future<Map<String, int>> getDailyStats(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = await getByDateRange(startOfDay, endOfDay);

    int completedSessions = 0;
    int totalMinutes = 0;

    for (final session in sessions) {
      if (session.type == SessionType.focus && session.completed) {
        completedSessions++;
        totalMinutes += session.durationMinutes;
      }
    }

    return {
      'sessions': completedSessions,
      'totalTime': totalMinutes * 60, // Convert to seconds
    };
  }

  /// Get all sessions (for export)
  Future<List<FocusSession>> getAll() async {
    final db = _db;
    if (db == null) return []; // Web platform
    final results = await db.query(
      'focus_sessions',
      orderBy: 'start_time DESC',
    );
    return results.map((map) => _mapToSession(map)).toList();
  }

  /// Get sessions pending sync
  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = _db;
    if (db == null) return []; // Web platform
    return db.query('focus_sessions', where: 'sync_status = 0');
  }

  /// Mark session as synced
  Future<void> markSynced(int id, String serverId) async {
    final db = _db;
    if (db == null) return; // Web platform
    await db.update(
      'focus_sessions',
      {'server_id': serverId, 'sync_status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all sessions (for testing or reset)
  Future<void> clearAll() async {
    final db = _db;
    if (db == null) return; // Web platform
    await db.delete('focus_sessions');
  }

  /// Batch insert sessions
  Future<void> batchInsert(List<FocusSession> sessions) async {
    await _dbHelper.batch((batch) {
      for (final session in sessions) {
        batch.insert(
          'focus_sessions',
          _sessionToMap(session),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // =====================
  // Timer Settings Methods
  // =====================

  /// Save timer settings
  Future<void> saveSettings(TimerSettings settings) async {
    final db = _db;
    if (db == null) return; // Web platform
    await db.insert('settings', {
      'key': 'timer_settings',
      'value': jsonEncode(settings.toJson()),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Load timer settings
  Future<TimerSettings> loadSettings() async {
    final db = _db;
    if (db == null)
      return const TimerSettings(); // Web platform - return defaults

    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['timer_settings'],
    );

    if (results.isEmpty) {
      return const TimerSettings();
    }

    final json = jsonDecode(results.first['value'] as String);
    return TimerSettings.fromJson(json);
  }

  /// Save focus session data (completed sessions count, total time for today)
  Future<void> saveFocusSessionData({
    required int completedSessions,
    required int totalTime,
  }) async {
    final db = _db;
    if (db == null) return; // Web platform
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await db.insert('settings', {
      'key': 'focus_data_$today',
      'value': jsonEncode({
        'sessions': completedSessions,
        'totalTime': totalTime,
      }),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Load focus session data
  Future<Map<String, int>> loadFocusSessionData() async {
    final db = _db;
    if (db == null) return {'sessions': 0, 'totalTime': 0}; // Web platform
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['focus_data_$today'],
    );

    if (results.isEmpty) {
      return {'sessions': 0, 'totalTime': 0};
    }

    final json = jsonDecode(results.first['value'] as String);
    return {
      'sessions': json['sessions'] as int,
      'totalTime': json['totalTime'] as int,
    };
  }

  // Helper: Convert FocusSession to database map
  Map<String, dynamic> _sessionToMap(FocusSession session) {
    return {
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime?.toIso8601String(),
      'duration_minutes': session.durationMinutes,
      'session_type': session.type.toString(),
      'completed': session.completed ? 1 : 0,
      'last_modified': DateTime.now().toIso8601String(),
      'sync_status': 0,
    };
  }

  // Helper: Convert database map to FocusSession
  FocusSession _mapToSession(Map<String, dynamic> map) {
    return FocusSession(
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      durationMinutes: map['duration_minutes'] as int,
      type: SessionType.values.firstWhere(
        (e) => e.toString() == map['session_type'],
        orElse: () => SessionType.focus,
      ),
      completed: (map['completed'] as int) == 1,
    );
  }
}
