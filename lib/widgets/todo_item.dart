import 'package:flutter/material.dart';
import 'package:quest/models/todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final bool isCompleted;
  final Function(Todo) onToggle;
  final Function(Todo, String) onEdit;
  final Function(Todo) onDelete;
  final Function(Todo) onArchive;

  const TodoItem({
    super.key,
    required this.todo,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool _isEditing = false;
  late TextEditingController _editingController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.todo.task);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _finishEditing();
      }
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editingController.text = widget.todo.task;
    });
    _focusNode.requestFocus();
  }

  void _finishEditing() {
    if (_editingController.text.trim().isNotEmpty) {
      widget.onEdit(widget.todo, _editingController.text.trim());
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id),
      background: _buildDismissBackground(context, DismissDirection.startToEnd),
      secondaryBackground: _buildDismissBackground(context, DismissDirection.endToStart),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete(widget.todo);
        } else {
          widget.onArchive(widget.todo);
        }
        return true;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.todo.isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                key: ValueKey(widget.todo.isCompleted),
                color: widget.todo.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            onPressed: () => widget.onToggle(widget.todo),
          ),
          title: _isEditing
              ? TextField(
                  controller: _editingController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _finishEditing(),
                )
              : Text(
                  widget.todo.task,
                  style: TextStyle(
                    decoration: widget.todo.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: widget.todo.isCompleted
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
          trailing: !_isEditing && !widget.todo.isCompleted
              ? IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: _startEditing,
                  color: Theme.of(context).colorScheme.outline,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context, DismissDirection direction) {
    final isArchive = direction == DismissDirection.startToEnd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isArchive
            ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
            : Theme.of(context).colorScheme.error.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment:
            isArchive ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isArchive) ...[
            Icon(
              Icons.archive,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 8),
            Text(
              'Archive',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ] else ...[
            Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}