import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/responsive_layout.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import 'draggable_todo_item.dart';

class TodoListSection extends StatefulWidget {
  final List<Todo> todos;
  final TodoPriority priority;
  final String title;
  final bool isDragging;
  final TodoPriority? draggingFromPriority;
  final Function(bool isDragging, TodoPriority? priority) onDragStateChanged;
  final VoidCallback onSave;
  final Function(String message, VoidCallback onUndo)? onUndo;

  const TodoListSection({
    Key? key,
    required this.todos,
    required this.priority,
    required this.title,
    required this.isDragging,
    required this.draggingFromPriority,
    required this.onDragStateChanged,
    required this.onSave,
    this.onUndo,
  }) : super(key: key);

  @override
  State<TodoListSection> createState() => _TodoListSectionState();
}

class _TodoListSectionState extends State<TodoListSection> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Todo>(
      builder: (context, candidateData, rejectedData) {
        final bool isHovering =
            candidateData.isNotEmpty &&
            candidateData.first?.priority != widget.priority;
        final bool showDropZone =
            widget.isDragging &&
            widget.draggingFromPriority != null &&
            widget.draggingFromPriority != widget.priority;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: isHovering
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : showDropZone
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                  : showDropZone
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: isHovering
                  ? 2.5
                  : showDropZone
                  ? 2
                  : 0,
            ),
          ),
          child: Column(
            children: [
              if (showDropZone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(isHovering ? 0.4 : 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isHovering
                          ? 'Release to add here'
                          : 'Drag here to add to ${widget.title}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isHovering
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(isHovering ? 1 : 0.7),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              if (widget.todos.isNotEmpty)
                Column(
                  children: widget.todos
                      .map(
                        (todo) => DraggableTodoItem(
                          todo: todo,
                          currentSectionPriority: widget.priority,
                          onDragStateChanged: widget.onDragStateChanged,
                          onSave: widget.onSave,
                          onUndo: widget.onUndo ?? (m, u) {},
                        ),
                      )
                      .toList(),
                ),
              if (widget.todos.isEmpty && !showDropZone)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.08),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.04),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.priority.icon,
                            size: 56,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.35),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No ${widget.title.toLowerCase()} yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      onWillAccept: (data) => data != null && data.priority != widget.priority,
      onAccept: (Todo todo) {
        widget.onDragStateChanged(false, null);
        final todoList = context.read<TodoList>();
        todoList.changeTodoPriority(todo.id, widget.priority);
        widget.onSave();

        // Show centered snackbar for task moved
        final deviceType = ResponsiveLayout.getDeviceType(context);
        final isMobile = deviceType == DeviceType.mobile;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Moved to ${widget.title}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            width: isMobile ? null : 400,
            margin: isMobile ? const EdgeInsets.all(8) : null,
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
