import 'package:sqflite/sqflite.dart';

import '../../../models/todo.dart';
import '../database_helper.dart';

/// Data Access Object for Todo operations.
///
/// Handles all CRUD operations for todos and their subtasks.
class TodoDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Database? get _db => _dbHelper.database;

  /// Insert a new todo with its subtasks
  Future<void> insert(Todo todo) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.transaction((txn) async {
        await txn.insert(
          'todos',
          _todoToMap(todo),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert subtasks
        for (var i = 0; i < todo.subtasks.length; i++) {
          await txn.insert(
            'subtasks',
            _subtaskToMap(todo.subtasks[i], todo.id, i),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to direct operations
      await db.insert(
        'todos',
        _todoToMap(todo),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var i = 0; i < todo.subtasks.length; i++) {
        await db.insert(
          'subtasks',
          _subtaskToMap(todo.subtasks[i], todo.id, i),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  /// Update an existing todo
  Future<void> update(Todo todo) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.transaction((txn) async {
        await txn.update(
          'todos',
          _todoToMap(todo),
          where: 'id = ?',
          whereArgs: [todo.id],
        );

        // Delete existing subtasks and re-insert
        await txn.delete(
          'subtasks',
          where: 'todo_id = ?',
          whereArgs: [todo.id],
        );

        for (var i = 0; i < todo.subtasks.length; i++) {
          await txn.insert(
            'subtasks',
            _subtaskToMap(todo.subtasks[i], todo.id, i),
          );
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to direct operations
      await db.update(
        'todos',
        _todoToMap(todo),
        where: 'id = ?',
        whereArgs: [todo.id],
      );

      await db.delete('subtasks', where: 'todo_id = ?', whereArgs: [todo.id]);

      for (var i = 0; i < todo.subtasks.length; i++) {
        await db.insert(
          'subtasks',
          _subtaskToMap(todo.subtasks[i], todo.id, i),
        );
      }
    }
  }

  /// Delete a todo and its subtasks (cascade)
  Future<void> delete(String id) async {
    final db = _db;
    if (db == null) return;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all todos (including archived)
  Future<List<Todo>> getAll() async {
    final db = _db;
    if (db == null) return [];
    final todos = await db.query('todos', orderBy: 'created_at DESC');
    return Future.wait(todos.map((map) => _mapToTodo(map)).toList());
  }

  /// Get active (non-archived, non-completed) todos
  Future<List<Todo>> getActive() async {
    final db = _db;
    if (db == null) return [];
    final todos = await db.query(
      'todos',
      where: 'is_archived = 0',
      orderBy: 'created_at DESC',
    );
    return Future.wait(todos.map((map) => _mapToTodo(map)).toList());
  }

  /// Get archived todos
  Future<List<Todo>> getArchived() async {
    final db = _db;
    if (db == null) return [];
    final todos = await db.query(
      'todos',
      where: 'is_archived = 1',
      orderBy: 'created_at DESC',
    );
    return Future.wait(todos.map((map) => _mapToTodo(map)).toList());
  }

  /// Get completed todos
  Future<List<Todo>> getCompleted() async {
    final db = _db;
    if (db == null) return [];
    final todos = await db.query(
      'todos',
      where: 'is_completed = 1 AND is_archived = 0',
      orderBy: 'completed_at DESC',
    );
    return Future.wait(todos.map((map) => _mapToTodo(map)).toList());
  }

  /// Get a single todo by ID
  Future<Todo?> getById(String id) async {
    final db = _db;
    if (db == null) return null;
    final results = await db.query('todos', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return _mapToTodo(results.first);
  }

  /// Archive a todo
  Future<void> archive(String id) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'todos',
      {
        'is_archived': 1,
        'last_modified': DateTime.now().toIso8601String(),
        'sync_status': 0, // Mark as pending sync
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Unarchive a todo
  Future<void> unarchive(String id) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'todos',
      {
        'is_archived': 0,
        'last_modified': DateTime.now().toIso8601String(),
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Batch insert multiple todos
  Future<void> batchInsert(List<Todo> todos) async {
    final db = _db;
    if (db == null) return;

    try {
      await _dbHelper.batch((batch) {
        for (final todo in todos) {
          batch.insert(
            'todos',
            _todoToMap(todo),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          for (var i = 0; i < todo.subtasks.length; i++) {
            batch.insert(
              'subtasks',
              _subtaskToMap(todo.subtasks[i], todo.id, i),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } on UnsupportedError {
      // Web platform - fallback to sequential inserts
      for (final todo in todos) {
        await insert(todo);
      }
    }
  }

  /// Get todos pending sync
  Future<List<Todo>> getPendingSync() async {
    final db = _db;
    if (db == null) return [];
    final todos = await db.query('todos', where: 'sync_status = 0');
    return Future.wait(todos.map((map) => _mapToTodo(map)).toList());
  }

  /// Mark todo as synced
  Future<void> markSynced(String id, String serverId) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'todos',
      {'server_id': serverId, 'sync_status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all todos (for testing or reset)
  Future<void> clearAll() async {
    final db = _db;
    if (db == null) return;
    await db.delete('todos');
  }

  // Helper: Convert Todo to database map
  Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      'id': todo.id,
      'task': todo.task,
      'description': todo.description,
      'is_completed': todo.isCompleted ? 1 : 0,
      'created_at': todo.createdAt.toIso8601String(),
      'completed_at': todo.completedAt?.toIso8601String(),
      'is_archived': todo.isArchived ? 1 : 0,
      'priority': todo.priority.index,
      'date_time': todo.dateTime?.toIso8601String(),
      'deadline': todo.deadline?.toIso8601String(),
      'last_modified': DateTime.now().toIso8601String(),
      'sync_status': 0, // Pending sync by default
    };
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

  // Helper: Convert database map to Todo (with subtasks)
  Future<Todo> _mapToTodo(Map<String, dynamic> map) async {
    final db = _db;
    // Fetch subtasks for this todo
    final subtaskMaps = db == null
        ? <Map<String, dynamic>>[]
        : await db.query(
            'subtasks',
            where: 'todo_id = ?',
            whereArgs: [map['id']],
            orderBy: 'sort_order ASC',
          );

    final subtasks = subtaskMaps
        .map(
          (s) => Subtask(
            id: s['id'] as String,
            title: s['title'] as String,
            isCompleted: (s['is_completed'] as int) == 1,
          ),
        )
        .toList();

    return Todo(
      id: map['id'] as String,
      task: map['task'] as String,
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      isArchived: (map['is_archived'] as int) == 1,
      priority: TodoPriority.values[map['priority'] as int],
      subtasks: subtasks,
      dateTime: map['date_time'] != null
          ? DateTime.parse(map['date_time'] as String)
          : null,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
    );
  }
}
