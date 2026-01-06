import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import '../../widgets/glass_task_card.dart';

class SplitCompletedSection extends StatefulWidget {
  final List<Todo> completedMainQuest;
  final List<Todo> completedSideQuest;
  final int totalCount;
  final VoidCallback onSave;

  const SplitCompletedSection({
    Key? key,
    required this.completedMainQuest,
    required this.completedSideQuest,
    required this.totalCount,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SplitCompletedSection> createState() => _SplitCompletedSectionState();
}

class _SplitCompletedSectionState extends State<SplitCompletedSection> {
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(maxHeight: _isCompletedExpanded ? 220 : 64),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                        '${widget.totalCount}',
                        style: GoogleFonts.inter(
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
            // Content (Expandable)
            if (_isCompletedExpanded)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Completed Main Quest
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                if (widget.completedMainQuest.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      'No completed main quests',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...widget.completedMainQuest.map(
                                    (todo) => GlassTaskCard(
                                      todo: todo,
                                      isCompleted: true,
                                      onToggle: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.toggleTodo(todo.id);
                                        widget.onSave();
                                      },
                                      onEdit: (todo, newTask) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.editTodo(todo.id, newTask);
                                        widget.onSave();
                                      },
                                      onDelete: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.deleteTodo(todo.id);
                                        widget.onSave();
                                      },
                                      onArchive: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.archiveTodo(todo.id);
                                        widget.onSave();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.12),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        // Completed Side Quest
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                if (widget.completedSideQuest.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      'No completed side quests',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...widget.completedSideQuest.map(
                                    (todo) => GlassTaskCard(
                                      todo: todo,
                                      isCompleted: true,
                                      onToggle: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.toggleTodo(todo.id);
                                        widget.onSave();
                                      },
                                      onEdit: (todo, newTask) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.editTodo(todo.id, newTask);
                                        widget.onSave();
                                      },
                                      onDelete: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.deleteTodo(todo.id);
                                        widget.onSave();
                                      },
                                      onArchive: (todo) {
                                        final todoList = context
                                            .read<TodoList>();
                                        todoList.archiveTodo(todo.id);
                                        widget.onSave();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
