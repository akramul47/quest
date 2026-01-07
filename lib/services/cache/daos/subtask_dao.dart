import 'package:sqflite/sqflite.dart';

import '../../../models/todo.dart';
import '../database_helper.dart';

/// Data Access Object for Subtask operations.
///
/// Handles all CRUD operations for subtasks.
class SubtaskDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database? get _db => _dbHelper.database;

  /// Insert a new subtask
  Future<void> insert(Subtask subtask, String todoId, int order) async {
    final db = _db;
    if (db == null) return;

    await db.insert(
      'subtasks',
      _subtaskToMap(subtask, todoId, order),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing subtask
  Future<void> update(Subtask subtask, String todoId, int order) async {
    final db = _db;
    if (db == null) return;

    await db.update(
      'subtasks',
      _subtaskToMap(subtask, todoId, order),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  /// Delete a subtask
  Future<void> delete(String id) async {
    final db = _db;
    if (db == null) return;

    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all subtasks for a specific todo
  Future<List<Subtask>> getByTodoId(String todoId) async {
    final db = _db;
    if (db == null) return [];

    final results = await db.query(
      'subtasks',
      where: 'todo_id = ?',
      whereArgs: [todoId],
      orderBy: 'sort_order ASC',
    );

    return results.map(_mapToSubtask).toList();
  }

  /// Delete all subtasks for a specific todo
  Future<void> deleteByTodoId(String todoId) async {
    final db = _db;
    if (db == null) return;

    await db.delete('subtasks', where: 'todo_id = ?', whereArgs: [todoId]);
  }

  /// Batch insert multiple subtasks
  Future<void> batchInsert(List<Subtask> subtasks, String todoId) async {
    await _dbHelper.batch((batch) {
      for (var i = 0; i < subtasks.length; i++) {
        batch.insert(
          'subtasks',
          _subtaskToMap(subtasks[i], todoId, i),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Toggle subtask completion status
  Future<void> toggleCompletion(String id) async {
    final db = _db;
    if (db == null) return;

    final results = await db.query(
      'subtasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return;

    final currentStatus = (results.first['is_completed'] as int) == 1;
    await db.update(
      'subtasks',
      {'is_completed': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reorder subtasks for a todo
  Future<void> reorder(String todoId, List<String> subtaskIds) async {
    final db = _db;
    if (db == null) return;

    await _dbHelper.transaction((txn) async {
      for (var i = 0; i < subtaskIds.length; i++) {
        await txn.update(
          'subtasks',
          {'sort_order': i},
          where: 'id = ? AND todo_id = ?',
          whereArgs: [subtaskIds[i], todoId],
        );
      }
    });
  }

  /// Clear all subtasks (for testing or reset)
  Future<void> clearAll() async {
    final db = _db;
    if (db == null) return;

    await db.delete('subtasks');
  }

  // Helper: Convert Subtask to database map
  Map<String, dynamic> _subtaskToMap(
    Subtask subtask,
    String todoId,
    int order,
  ) {
    return {
      'id': subtask.id,
      'todo_id': todoId,
      'title': subtask.title,
      'is_completed': subtask.isCompleted ? 1 : 0,
      'sort_order': order,
    };
  }

  // Helper: Convert database map to Subtask
  Subtask _mapToSubtask(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}
