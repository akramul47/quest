import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Utils/app_theme.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/glass_task_card.dart';
import '../../screens/task_detail_screen.dart';

class DraggableTodoItem extends StatefulWidget {
  final Todo todo;
  final TodoPriority currentSectionPriority;
  final Function(bool isDragging, TodoPriority? priority) onDragStateChanged;
  final VoidCallback onSave;
  final Function(String message, VoidCallback onUndo) onUndo;

  const DraggableTodoItem({
    Key? key,
    required this.todo,
    required this.currentSectionPriority,
    required this.onDragStateChanged,
    required this.onSave,
    required this.onUndo,
  }) : super(key: key);

  @override
  State<DraggableTodoItem> createState() => _DraggableTodoItemState();
}

class _DraggableTodoItemState extends State<DraggableTodoItem> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Todo>(
      key: ValueKey(widget.todo.id),
      onWillAccept: (data) => data != null && data.id != widget.todo.id,
      onAccept: (draggedTodo) {
        widget.onDragStateChanged(false, null);
        final todoList = context.read<TodoList>();
        if (draggedTodo.priority == widget.currentSectionPriority) {
          // Reordering within the same section
          final todos = widget.currentSectionPriority == TodoPriority.mainQuest
              ? todoList.mainQuestTodos
              : todoList.sideQuestTodos;
          final oldIndex = todos.indexWhere((t) => t.id == draggedTodo.id);
          final newIndex = todos.indexWhere((t) => t.id == widget.todo.id);
          if (oldIndex != -1 && newIndex != -1) {
            todoList.reorderTodo(
              widget.currentSectionPriority,
              oldIndex,
              newIndex,
            );
            widget.onSave();
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Column(
          children: [
            if (isHovering &&
                candidateData.first?.priority == widget.currentSectionPriority)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            LongPressDraggable<Todo>(
              data: widget.todo,
              delay: const Duration(milliseconds: 300),
              hapticFeedbackOnStart: true,
              onDragStarted: () {
                widget.onDragStateChanged(true, widget.currentSectionPriority);
              },
              onDragEnd: (details) {
                widget.onDragStateChanged(false, null);
              },
              onDraggableCanceled: (velocity, offset) {
                widget.onDragStateChanged(false, null);
              },
              feedback: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.5),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).cardColor.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.todo.task,
                          style: AppTheme.taskTextStyle.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.2,
                child: GlassTaskCard(
                  todo: widget.todo,
                  isCompleted: false,
                  onToggle: (todo) {},
                  onEdit: (todo, newTask) {},
                  onDelete: (todo) {},
                  onArchive: (todo) {},
                ),
              ),
              child: GlassTaskCard(
                todo: widget.todo,
                isCompleted: false,
                onToggle: (todo) {
                  context.read<TodoList>().toggleTodo(todo.id);
                  widget.onSave();
                },
                onEdit: (updatedTodo, newTask) {
                  context.read<TodoList>().updateTodo(updatedTodo);
                  widget.onSave();
                },
                onDelete: (todo) {
                  final todoList = context.read<TodoList>();
                  todoList.deleteTodo(todo.id);
                  widget.onSave();
                  widget.onUndo('Task deleted', () {
                    todoList.addTodo(todo.task, priority: todo.priority);
                    widget.onSave();
                  });
                },
                onArchive: (todo) {
                  final todoList = context.read<TodoList>();
                  todoList.archiveTodo(todo.id);
                  widget.onSave();
                  widget.onUndo('Task archived', () {
                    todoList.unarchiveTodo(todo.id);
                    widget.onSave();
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    RightToLeftRoute(
                      page: TaskDetailScreen(
                        todo: widget.todo,
                        onSave: (updatedTodo) {
                          context.read<TodoList>().updateTodo(updatedTodo);
                          widget.onSave();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
