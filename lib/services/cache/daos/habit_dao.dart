import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/habit.dart';
import '../database_helper.dart';

/// Data Access Object for Habit operations.
///
/// Handles all CRUD operations for habits and their history entries.
class HabitDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database? get _db => _dbHelper.database;

  /// Insert a new habit
  Future<void> insert(Habit habit) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.transaction((txn) async {
        await txn.insert(
          'habits',
          _habitToMap(habit),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert history entries
        for (final entry in habit.history.entries) {
          await txn.insert('habit_entries', {
            'habit_id': habit.id,
            'date': entry.key,
            'value': jsonEncode(entry.value),
            'created_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to direct operations
      await db.insert(
        'habits',
        _habitToMap(habit),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final entry in habit.history.entries) {
        await db.insert('habit_entries', {
          'habit_id': habit.id,
          'date': entry.key,
          'value': jsonEncode(entry.value),
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  /// Update an existing habit
  Future<void> update(Habit habit) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.transaction((txn) async {
        await txn.update(
          'habits',
          _habitToMap(habit),
          where: 'id = ?',
          whereArgs: [habit.id],
        );

        // Delete existing entries and re-insert
        await txn.delete(
          'habit_entries',
          where: 'habit_id = ?',
          whereArgs: [habit.id],
        );

        for (final entry in habit.history.entries) {
          await txn.insert('habit_entries', {
            'habit_id': habit.id,
            'date': entry.key,
            'value': jsonEncode(entry.value),
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to direct operations
      await db.update(
        'habits',
        _habitToMap(habit),
        where: 'id = ?',
        whereArgs: [habit.id],
      );

      await db.delete(
        'habit_entries',
        where: 'habit_id = ?',
        whereArgs: [habit.id],
      );

      for (final entry in habit.history.entries) {
        await db.insert('habit_entries', {
          'habit_id': habit.id,
          'date': entry.key,
          'value': jsonEncode(entry.value),
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  /// Delete a habit and its entries (cascade)
  Future<void> delete(String id) async {
    final db = _db;
    if (db == null) return;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all habits (including archived)
  Future<List<Habit>> getAll() async {
    final db = _db;
    if (db == null) return [];
    final habits = await db.query('habits', orderBy: 'created_at DESC');
    return Future.wait(habits.map((map) => _mapToHabit(map)).toList());
  }

  /// Get active (non-archived) habits
  Future<List<Habit>> getActive() async {
    final db = _db;
    if (db == null) return [];
    final habits = await db.query(
      'habits',
      where: 'is_archived = 0',
      orderBy: 'created_at DESC',
    );
    return Future.wait(habits.map((map) => _mapToHabit(map)).toList());
  }

  /// Get archived habits
  Future<List<Habit>> getArchived() async {
    final db = _db;
    if (db == null) return [];
    final habits = await db.query(
      'habits',
      where: 'is_archived = 1',
      orderBy: 'created_at DESC',
    );
    return Future.wait(habits.map((map) => _mapToHabit(map)).toList());
  }

  /// Get a single habit by ID
  Future<Habit?> getById(String id) async {
    final db = _db;
    if (db == null) return null;
    final results = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return _mapToHabit(results.first);
  }

  /// Record a habit entry for a specific date
  Future<void> recordEntry(String habitId, DateTime date, dynamic value) async {
    final db = _db;
    if (db == null) return;
    final dateKey = _dateToKey(date);

    await db.insert('habit_entries', {
      'habit_id': habitId,
      'date': dateKey,
      'value': jsonEncode(value),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update habit's last_modified and sync_status
    await db.update(
      'habits',
      {'last_modified': DateTime.now().toIso8601String(), 'sync_status': 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Get history for a specific habit
  Future<Map<String, dynamic>> getHistory(String habitId) async {
    final db = _db;
    if (db == null) return {};
    final entries = await db.query(
      'habit_entries',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );

    final history = <String, dynamic>{};
    for (final entry in entries) {
      history[entry['date'] as String] = jsonDecode(entry['value'] as String);
    }
    return history;
  }

  /// Archive a habit
  Future<void> archive(String id) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'habits',
      {
        'is_archived': 1,
        'last_modified': DateTime.now().toIso8601String(),
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Unarchive a habit
  Future<void> unarchive(String id) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'habits',
      {
        'is_archived': 0,
        'last_modified': DateTime.now().toIso8601String(),
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Batch insert multiple habits
  Future<void> batchInsert(List<Habit> habits) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.batch((batch) {
        for (final habit in habits) {
          batch.insert(
            'habits',
            _habitToMap(habit),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          for (final entry in habit.history.entries) {
            batch.insert('habit_entries', {
              'habit_id': habit.id,
              'date': entry.key,
              'value': jsonEncode(entry.value),
              'created_at': DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to sequential inserts
      for (final habit in habits) {
        await insert(habit);
      }
    }
  }

  /// Get habits pending sync
  Future<List<Habit>> getPendingSync() async {
    final db = _db;
    if (db == null) return [];
    final habits = await db.query('habits', where: 'sync_status = 0');
    return Future.wait(habits.map((map) => _mapToHabit(map)).toList());
  }

  /// Mark habit as synced
  Future<void> markSynced(String id, String serverId) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'habits',
      {'server_id': serverId, 'sync_status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all habits (for testing or reset)
  Future<void> clearAll() async {
    final db = _db;
    if (db == null) return;
    await db.delete('habits');
  }

  // Helper: Convert Habit to database map
  Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'color': habit.color.value,
      'icon_code_point': habit.icon.codePoint,
      'icon_font_family': habit.icon.fontFamily,
      'icon_font_package': habit.icon.fontPackage,
      'type': habit.type.index,
      'unit': habit.unit,
      'created_at': habit.createdAt.toIso8601String(),
      'is_archived': habit.isArchived ? 1 : 0,
      'question': habit.question,
      'reminder_hour': habit.reminderTime?.hour,
      'reminder_minute': habit.reminderTime?.minute,
      'last_modified': DateTime.now().toIso8601String(),
      'sync_status': 0,
    };
  }

  // Helper: Convert database map to Habit (with history)
  Future<Habit> _mapToHabit(Map<String, dynamic> map) async {
    final history = await getHistory(map['id'] as String);

    TimeOfDay? reminderTime;
    if (map['reminder_hour'] != null && map['reminder_minute'] != null) {
      reminderTime = TimeOfDay(
        hour: map['reminder_hour'] as int,
        minute: map['reminder_minute'] as int,
      );
    }

    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      icon: IconData(
        map['icon_code_point'] as int,
        fontFamily: map['icon_font_family'] as String? ?? 'MaterialIcons',
        fontPackage: map['icon_font_package'] as String?,
      ),
      type: HabitType.values[map['type'] as int],
      unit: map['unit'] as String? ?? '',
      history: history,
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: (map['is_archived'] as int) == 1,
      question: map['question'] as String?,
      reminderTime: reminderTime,
    );
  }

  // Helper: Convert DateTime to date key (YYYY-MM-DD)
  static String _dateToKey(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T')[0];
  }
}
