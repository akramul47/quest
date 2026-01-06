import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import '../../widgets/add_task_field.dart';
import 'todo_list_section.dart';

class TodoSection extends StatelessWidget {
  final String title;
  final List<Todo> todos;
  final TodoPriority priority;
  final TextEditingController controller;
  final bool showAddField;
  final bool isDragging;
  final TodoPriority? draggingFromPriority;
  final Function(bool isDragging, TodoPriority? priority) onDragStateChanged;
  final VoidCallback onSave;
  final Function(String message, VoidCallback onUndo) onUndo;

  const TodoSection({
    Key? key,
    required this.title,
    required this.todos,
    required this.priority,
    required this.controller,
    this.showAddField = true,
    required this.isDragging,
    required this.draggingFromPriority,
    required this.onDragStateChanged,
    required this.onSave,
    required this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                priority.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.sectionHeaderStyle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (showAddField)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AddTaskField(
              controller: controller,
              hintText: priority == TodoPriority.mainQuest
                  ? 'Add main quest'
                  : 'Add side quest',
              onAdd: () {
                if (controller.text.isNotEmpty) {
                  context.read<TodoList>().addTodo(
                    controller.text,
                    priority: priority,
                  );
                  controller.clear();
                  onSave();
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<TodoList>().addTodo(value, priority: priority);
                  controller.clear();
                  onSave();
                }
              },
            ),
          ),
        TodoListSection(
          todos: todos,
          priority: priority,
          title: title,
          isDragging: isDragging,
          draggingFromPriority: draggingFromPriority,
          onDragStateChanged: onDragStateChanged,
          onSave: onSave,
          onUndo: onUndo,
        ),
      ],
    );
  }
}
