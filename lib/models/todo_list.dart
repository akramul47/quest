import 'package:flutter/foundation.dart';
import 'todo.dart';
import '../services/cache/daos/todo_dao.dart';

/// TodoList provider that manages todos with SQLite persistence.
///
/// All mutations are automatically persisted to the database.
class TodoList extends ChangeNotifier {
  final TodoDao _todoDao = TodoDao();
  List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  List<Todo> get activeTodos =>
      _todos.where((todo) => !todo.isCompleted && !todo.isArchived).toList();

  List<Todo> get mainQuestTodos => _todos
      .where(
        (todo) =>
            !todo.isCompleted &&
            !todo.isArchived &&
            todo.priority == TodoPriority.mainQuest,
      )
      .toList();

  List<Todo> get sideQuestTodos => _todos
      .where(
        (todo) =>
            !todo.isCompleted &&
            !todo.isArchived &&
            todo.priority == TodoPriority.sideQuest,
      )
      .toList();

  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted && !todo.isArchived).toList();

  List<Todo> get archivedTodos =>
      _todos.where((todo) => todo.isArchived).toList();

  /// Initialize by loading todos from database
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _todoDao.getAll();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to load todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set todos (used for import/migration)
  void setTodos(List<Todo> todos) {
    _todos = todos;
    notifyListeners();
  }

  /// Add a new todo
  Future<void> addTodo(
    String task, {
    TodoPriority priority = TodoPriority.sideQuest,
  }) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
      createdAt: DateTime.now(),
      priority: priority,
    );

    _todos.add(todo);
    notifyListeners();

    // Persist to database
    await _todoDao.insert(todo);
  }

  /// Toggle todo completion status
  Future<void> toggleTodo(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
        completedAt: _todos[todoIndex].isCompleted ? null : DateTime.now(),
      );
      notifyListeners();

      await _todoDao.update(_todos[todoIndex]);
    }
  }

  /// Reorder todos within a priority group
  Future<void> reorderTodo(
    TodoPriority priority,
    int oldIndex,
    int newIndex,
  ) async {
    final todos = priority == TodoPriority.mainQuest
        ? mainQuestTodos
        : sideQuestTodos;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final todo = todos.removeAt(oldIndex);
    todos.insert(newIndex, todo);

    // Update the main _todos list to reflect the new order
    _todos = [
      ..._todos.where(
        (t) => t.priority != priority || t.isCompleted || t.isArchived,
      ),
      ...todos,
    ];

    notifyListeners();

    // Persist all todos (order might have changed)
    await _todoDao.batchInsert(_todos);
  }

  /// Change todo priority
  Future<void> changeTodoPriority(String id, TodoPriority newPriority) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(priority: newPriority);
      notifyListeners();

      await _todoDao.update(_todos[todoIndex]);
    }
  }

  /// Edit todo task text
  Future<void> editTodo(String id, String newTask) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(task: newTask);
      notifyListeners();

      await _todoDao.update(_todos[todoIndex]);
    }
  }

  /// Update a todo with new data
  Future<void> updateTodo(Todo updatedTodo) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (todoIndex != -1) {
      // Update existing todo
      _todos[todoIndex] = updatedTodo;
      notifyListeners();

      await _todoDao.update(updatedTodo);
    } else {
      // Double-check for duplicates before adding (belt-and-suspenders approach)
      final existingIndex = _todos.indexWhere((t) => t.id == updatedTodo.id);
      if (existingIndex != -1) {
        // Already exists, just update instead
        _todos[existingIndex] = updatedTodo;
        notifyListeners();
        await _todoDao.update(updatedTodo);
        return;
      }

      // Truly new task - add it
      _todos.add(updatedTodo);
      notifyListeners();

      await _todoDao.insert(updatedTodo);
    }
  }

  /// Delete a todo permanently
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();

    await _todoDao.delete(id);
  }

  /// Archive a todo
  Future<void> archiveTodo(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(isArchived: true);
      notifyListeners();

      await _todoDao.archive(id);
    }
  }

  /// Unarchive a todo
  Future<void> unarchiveTodo(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(isArchived: false);
      notifyListeners();

      await _todoDao.unarchive(id);
    }
  }

  /// Reload todos from database
  Future<void> refresh() async {
    _todos = await _todoDao.getAll();
    notifyListeners();
  }
}
