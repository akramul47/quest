import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/todo.dart';
import '../../Utils/app_theme.dart';

class SubtaskSection extends StatefulWidget {
  final List<Subtask> subtasks;
  final Function(List<Subtask>) onSubtasksChanged;
  final bool isDark;

  const SubtaskSection({
    Key? key,
    required this.subtasks,
    required this.onSubtasksChanged,
    required this.isDark,
  }) : super(key: key);

  @override
  State<SubtaskSection> createState() => _SubtaskSectionState();
}

class _SubtaskSectionState extends State<SubtaskSection> {
  late TextEditingController _subtaskController;
  final FocusNode _subtaskFocusNode = FocusNode();
  bool _showSubtasks = false;

  @override
  void initState() {
    super.initState();
    _subtaskController = TextEditingController();
    _showSubtasks = widget.subtasks.isNotEmpty;
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _subtaskFocusNode.dispose();
    super.dispose();
  }

  void _addSubtask(String value) {
    if (value.trim().isNotEmpty) {
      final newSubtasks = List<Subtask>.from(widget.subtasks);
      newSubtasks.add(
        Subtask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: value.trim(),
        ),
      );
      widget.onSubtasksChanged(newSubtasks);
      _subtaskController.clear();
      _subtaskFocusNode.requestFocus();
    }
  }

  void _toggleSubtask(Subtask subtask) {
    final newSubtasks = List<Subtask>.from(widget.subtasks);
    final index = newSubtasks.indexOf(subtask);
    if (index != -1) {
      newSubtasks[index] = subtask.copyWith(isCompleted: !subtask.isCompleted);
      widget.onSubtasksChanged(newSubtasks);
    }
  }

  void _removeSubtask(Subtask subtask) {
    final newSubtasks = List<Subtask>.from(widget.subtasks);
    newSubtasks.remove(subtask);
    widget.onSubtasksChanged(newSubtasks);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showSubtasks = !_showSubtasks;
              if (_showSubtasks) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _subtaskFocusNode.requestFocus();
                });
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.subdirectory_arrow_right,
                  size: 24,
                  color: (widget.isDark ? Colors.white : Colors.black87)
                      .withOpacity(0.6),
                ),
                const SizedBox(width: 16),
                Text(
                  'Add subtasks',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: (widget.isDark ? Colors.white : Colors.black87)
                        .withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showSubtasks) ...[
          ...widget.subtasks.map((subtask) => _buildSubtaskItem(subtask)),
          Container(
            margin: const EdgeInsets.only(left: 40, top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: widget.isDark
                      ? AppTheme.primaryColorDark
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    focusNode: _subtaskFocusNode,
                    textInputAction: TextInputAction.done,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a subtask',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: (widget.isDark ? Colors.white : Colors.black87)
                            .withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _addSubtask,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtaskItem(Subtask subtask) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => _toggleSubtask(subtask),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted
                    ? (widget.isDark
                          ? AppTheme.primaryColorDark
                          : Theme.of(context).colorScheme.primary)
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? (widget.isDark
                            ? AppTheme.primaryColorDark
                            : Theme.of(context).colorScheme.primary)
                      : (widget.isDark ? Colors.white : Colors.black87)
                            .withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: widget.isDark ? Colors.white70 : Colors.black87,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: widget.isDark ? Colors.white54 : Colors.black54,
            ),
            onPressed: () => _removeSubtask(subtask),
          ),
        ],
      ),
    );
  }
}
