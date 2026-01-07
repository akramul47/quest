import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../models/streak.dart';
import '../database_helper.dart';
import '../database_schema.dart';

/// Data Access Object for streak-related database operations.
///
/// Handles persistence for:
/// - Global streak state
/// - Daily activity records
/// - Restore tokens
class StreakDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database? get _db => _dbHelper.database;

  // ============== Global Streak ==============

  /// Get the current global streak state
  Future<GlobalStreak?> getStreak() async {
    final db = _db;
    if (db == null) return null;

    final results = await db.query('streak', where: 'id = 1');

    if (results.isEmpty) {
      return null;
    }

    return _mapToStreak(results.first);
  }

  /// Create or update the global streak
  Future<void> saveStreak(GlobalStreak streak) async {
    final db = _db;
    if (db == null) return;

    final data = _streakToMap(streak);

    await db.insert(
      'streak',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Initialize streak if it doesn't exist
  Future<GlobalStreak> getOrCreateStreak() async {
    var streak = await getStreak();
    if (streak == null) {
      streak = GlobalStreak.initial();
      await saveStreak(streak);
    }
    return streak;
  }

  // ============== Daily Activity ==============

  /// Get activity for a specific date
  Future<DailyActivity?> getDailyActivity(DateTime date) async {
    final db = _db;
    if (db == null) return null;

    final dateKey = _dateToKey(date);
    final results = await db.query(
      'daily_activity',
      where: 'date = ?',
      whereArgs: [dateKey],
    );

    if (results.isEmpty) {
      return null;
    }

    return _mapToActivity(results.first);
  }

  /// Get activity for today
  Future<DailyActivity?> getTodayActivity() async {
    return getDailyActivity(DateTime.now());
  }

  /// Get activities for a date range
  Future<List<DailyActivity>> getActivitiesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = _db;
    if (db == null) return [];

    final startKey = _dateToKey(start);
    final endKey = _dateToKey(end);

    final results = await db.query(
      'daily_activity',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startKey, endKey],
      orderBy: 'date DESC',
    );

    return results.map(_mapToActivity).toList();
  }

  /// Record or update daily activity
  Future<void> saveDailyActivity(DailyActivity activity) async {
    final db = _db;
    if (db == null) return;

    final data = _activityToMap(activity);

    await db.insert(
      'daily_activity',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Record an activity type for today
  Future<DailyActivity> recordActivity(StreakActivityType type) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var activity = await getDailyActivity(today);
    activity ??= DailyActivity.today();

    // Update the specific activity type
    switch (type) {
      case StreakActivityType.todo:
        activity = activity.copyWith(completedTodo: true);
        break;
      case StreakActivityType.habit:
        activity = activity.copyWith(loggedHabit: true);
        break;
      case StreakActivityType.focus:
        activity = activity.copyWith(trackedFocus: true);
        break;
    }

    await saveDailyActivity(activity);
    return activity;
  }

  // ============== Restore Tokens ==============

  /// Get all restore tokens
  Future<List<StreakRestoreToken>> getAllTokens() async {
    final db = _db;
    if (db == null) return [];

    final results = await db.query(
      'restore_tokens',
      orderBy: 'generated_at DESC',
    );

    return results.map(_mapToToken).toList();
  }

  /// Get available (unused, non-expired) tokens
  Future<List<StreakRestoreToken>> getAvailableTokens() async {
    final db = _db;
    if (db == null) return [];

    final now = DateTime.now().toIso8601String();

    final results = await db.query(
      'restore_tokens',
      where: 'is_used = 0 AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [now],
      orderBy: 'generated_at ASC',
    );

    return results.map(_mapToToken).toList();
  }

  /// Get count of available tokens
  Future<int> getAvailableTokenCount() async {
    final tokens = await getAvailableTokens();
    return tokens.length;
  }

  /// Add a new restore token
  Future<void> addToken(StreakRestoreToken token) async {
    final db = _db;
    if (db == null) return;

    await db.insert('restore_tokens', _tokenToMap(token));
  }

  /// Mark a token as used
  Future<void> useToken(String tokenId) async {
    final db = _db;
    if (db == null) return;

    final now = DateTime.now();

    await db.update(
      'restore_tokens',
      {
        'is_used': 1,
        'used_at': now.toIso8601String(),
        'last_modified': now.toIso8601String(),
        'sync_status': SyncStatus.pending,
      },
      where: 'id = ?',
      whereArgs: [tokenId],
    );
  }

  /// Delete expired tokens (cleanup)
  Future<int> deleteExpiredTokens() async {
    final db = _db;
    if (db == null) return 0;

    final now = DateTime.now().toIso8601String();

    return await db.delete(
      'restore_tokens',
      where: 'expires_at IS NOT NULL AND expires_at < ? AND is_used = 1',
      whereArgs: [now],
    );
  }

  // ============== Sync Support ==============

  /// Get pending sync items for streak
  Future<Map<String, dynamic>> getPendingSyncItems() async {
    final db = _db;
    if (db == null) return {};

    final streak = await db.query(
      'streak',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending],
    );

    final activities = await db.query(
      'daily_activity',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending],
    );

    final tokens = await db.query(
      'restore_tokens',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending],
    );

    return {
      'streak': streak.isNotEmpty ? _mapToStreak(streak.first) : null,
      'activities': activities.map(_mapToActivity).toList(),
      'tokens': tokens.map(_mapToToken).toList(),
    };
  }

  /// Mark streak as synced
  Future<void> markStreakSynced() async {
    final db = _db;
    if (db == null) return;

    await db.update('streak', {
      'sync_status': SyncStatus.synced,
    }, where: 'id = 1');
  }

  // ============== Helpers ==============

  String _dateToKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  GlobalStreak _mapToStreak(Map<String, dynamic> map) {
    return GlobalStreak(
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      lastActiveDate: map['last_active_date'] != null
          ? DateTime.parse(map['last_active_date'] as String)
          : null,
      streakStartDate: map['streak_start_date'] != null
          ? DateTime.parse(map['streak_start_date'] as String)
          : null,
      freezeDaysUsed: map['freeze_days_used'] as int? ?? 0,
      freezeDaysAvailable: map['freeze_days_available'] as int? ?? 2,
      restoreTokens: map['restore_tokens'] as int? ?? 0,
      isFrozenToday: (map['is_frozen_today'] as int? ?? 0) == 1,
      lastModified: DateTime.parse(map['last_modified'] as String),
    );
  }

  Map<String, dynamic> _streakToMap(GlobalStreak streak) {
    return {
      'id': 1,
      'current_streak': streak.currentStreak,
      'longest_streak': streak.longestStreak,
      'last_active_date': streak.lastActiveDate?.toIso8601String(),
      'streak_start_date': streak.streakStartDate?.toIso8601String(),
      'freeze_days_used': streak.freezeDaysUsed,
      'freeze_days_available': streak.freezeDaysAvailable,
      'restore_tokens': streak.restoreTokens,
      'is_frozen_today': streak.isFrozenToday ? 1 : 0,
      'last_modified': streak.lastModified.toIso8601String(),
      'sync_status': SyncStatus.pending,
    };
  }

  DailyActivity _mapToActivity(Map<String, dynamic> map) {
    return DailyActivity(
      date: DateTime.parse(map['date'] as String),
      completedTodo: (map['completed_todo'] as int? ?? 0) == 1,
      loggedHabit: (map['logged_habit'] as int? ?? 0) == 1,
      trackedFocus: (map['tracked_focus'] as int? ?? 0) == 1,
      isFreezeDay: (map['is_freeze_day'] as int? ?? 0) == 1,
      lastModified: DateTime.parse(map['last_modified'] as String),
    );
  }

  Map<String, dynamic> _activityToMap(DailyActivity activity) {
    return {
      'date': activity.dateKey,
      'completed_todo': activity.completedTodo ? 1 : 0,
      'logged_habit': activity.loggedHabit ? 1 : 0,
      'tracked_focus': activity.trackedFocus ? 1 : 0,
      'is_active': activity.isActive ? 1 : 0,
      'is_freeze_day': activity.isFreezeDay ? 1 : 0,
      'last_modified': activity.lastModified.toIso8601String(),
      'sync_status': SyncStatus.pending,
    };
  }

  StreakRestoreToken _mapToToken(Map<String, dynamic> map) {
    return StreakRestoreToken(
      id: map['id'] as String,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      isUsed: (map['is_used'] as int? ?? 0) == 1,
      usedAt: map['used_at'] != null
          ? DateTime.parse(map['used_at'] as String)
          : null,
      serverId: map['server_id'] as String?,
      lastModified: DateTime.parse(map['last_modified'] as String),
    );
  }

  Map<String, dynamic> _tokenToMap(StreakRestoreToken token) {
    return {
      'id': token.id,
      'generated_at': token.generatedAt.toIso8601String(),
      'expires_at': token.expiresAt?.toIso8601String(),
      'is_used': token.isUsed ? 1 : 0,
      'used_at': token.usedAt?.toIso8601String(),
      'server_id': token.serverId,
      'last_modified': token.lastModified.toIso8601String(),
      'sync_status': SyncStatus.pending,
    };
  }
}
