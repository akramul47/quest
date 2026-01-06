import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

/// Data Access Object for app settings.
///
/// Handles generic key-value settings storage with sync support.
class SettingsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database get _db => _dbHelper.database;

  /// Get a string setting
  Future<String?> getString(String key) async {
    final results = await _db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  /// Set a string setting
  Future<void> setString(String key, String value) async {
    await _db.insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get a boolean setting
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await getString(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  /// Set a boolean setting
  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  /// Get an integer setting
  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Set an integer setting
  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// Get a double setting
  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Set a double setting
  Future<void> setDouble(String key, double value) async {
    await setString(key, value.toString());
  }

  /// Get a JSON object setting
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  /// Set a JSON object setting
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setString(key, jsonEncode(value));
  }

  /// Get a DateTime setting
  Future<DateTime?> getDateTime(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Set a DateTime setting
  Future<void> setDateTime(String key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  /// Delete a setting
  Future<void> delete(String key) async {
    await _db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  /// Get all settings
  Future<Map<String, String>> getAll() async {
    final results = await _db.query('settings');
    return {
      for (final row in results) row['key'] as String: row['value'] as String,
    };
  }

  /// Get all settings with a prefix
  Future<Map<String, String>> getWithPrefix(String prefix) async {
    final results = await _db.query(
      'settings',
      where: 'key LIKE ?',
      whereArgs: ['$prefix%'],
    );
    return {
      for (final row in results) row['key'] as String: row['value'] as String,
    };
  }

  /// Clear all settings
  Future<void> clearAll() async {
    await _db.delete('settings');
  }

  /// Clear settings with a prefix
  Future<void> clearWithPrefix(String prefix) async {
    await _db.delete('settings', where: 'key LIKE ?', whereArgs: ['$prefix%']);
  }
}

/// Common settings keys
class SettingsKeys {
  // Theme
  static const String themeMode = 'theme_mode';
  static const String accentColor = 'accent_color';

  // Notifications
  static const String notificationsEnabled = 'notifications_enabled';
  static const String habitReminders = 'habit_reminders';
  static const String focusReminders = 'focus_reminders';

  // Sync
  static const String lastSyncAt = 'last_sync_at';
  static const String syncEnabled = 'sync_enabled';

  // User preferences
  static const String onboardingComplete = 'onboarding_complete';
  static const String defaultPriority = 'default_priority';
  static const String weekStartsOn = 'week_starts_on';

  // Premium
  static const String premiumCachedStatus = 'premium_cached_status';
  static const String premiumExpiresAt = 'premium_expires_at';
}
