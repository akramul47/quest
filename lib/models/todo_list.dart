import 'package:flutter/foundation.dart';
import 'todo.dart';

class TodoList extends ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

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

  void setTodos(List<Todo> todos) {
    _todos = todos;
    notifyListeners();
  }

  void addTodo(String task, {TodoPriority priority = TodoPriority.sideQuest}) {
    _todos.add(
      Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        task: task,
        createdAt: DateTime.now(),
        priority: priority,
      ),
    );
    notifyListeners();
  }

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
        completedAt: _todos[todoIndex].isCompleted ? null : DateTime.now(),
      );
      notifyListeners();
    }
  }

  void reorderTodo(TodoPriority priority, int oldIndex, int newIndex) {
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
  }

  void changeTodoPriority(String id, TodoPriority newPriority) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(priority: newPriority);
      notifyListeners();
    }
  }

  void editTodo(String id, String newTask) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(task: newTask);
      notifyListeners();
    }
  }

  void updateTodo(Todo updatedTodo) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (todoIndex != -1) {
      _todos[todoIndex] = updatedTodo;
      notifyListeners();
    } else {
      // If not found, add it (for new tasks)
      _todos.add(updatedTodo);
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void archiveTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(isArchived: true);
      notifyListeners();
    }
  }

  void unarchiveTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(isArchived: false);
      notifyListeners();
    }
  }
}
