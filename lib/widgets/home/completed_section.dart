import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import '../../widgets/glass_task_card.dart';

class CompletedSection extends StatefulWidget {
  final List<Todo> completedTodos;
  final VoidCallback onSave;

  const CompletedSection({
    Key? key,
    required this.completedTodos,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<CompletedSection> {
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.completedTodos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.03),
            Theme.of(context).colorScheme.primary.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Always visible - clickable to toggle)
          InkWell(
            onTap: () {
              setState(() {
                _isCompletedExpanded = !_isCompletedExpanded;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Completed',
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.completedTodos.length}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isCompletedExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (Expandable) - No ScrollView, shows all tasks
          if (_isCompletedExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.completedTodos
                    .map(
                      (todo) => GlassTaskCard(
                        todo: todo,
                        isCompleted: true,
                        onToggle: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.toggleTodo(todo.id);
                          widget.onSave();
                        },
                        onEdit: (todo, newTask) {
                          final todoList = context.read<TodoList>();
                          todoList.editTodo(todo.id, newTask);
                          widget.onSave();
                        },
                        onDelete: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.deleteTodo(todo.id);
                          widget.onSave();
                        },
                        onArchive: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.archiveTodo(todo.id);
                          widget.onSave();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
