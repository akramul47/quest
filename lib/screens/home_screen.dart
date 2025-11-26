import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../models/todo.dart';
import '../models/todo_list.dart';
import '../services/storage_service.dart';
import '../widgets/add_task_field.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/window_controls_bar.dart';
import 'archives_screen.dart';
import 'settings_screen.dart';
import 'task_detail_screen.dart';
import '../widgets/glass_task_card.dart';
import '../utils/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mainQuestController = TextEditingController();
  final _sideQuestController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDragging = false;
  TodoPriority? _draggingFromPriority;
  bool _isCompletedExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final storageService = context.read<StorageService>();
    final todoList = context.read<TodoList>();
    final todos = await storageService.loadTodos();
    todoList.setTodos(todos);
  }

  Future<void> _saveTodos() async {
    final storageService = context.read<StorageService>();
    final todoList = context.read<TodoList>();
    await storageService.saveTodos(todoList.todos);
  }

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        width: isMobile ? null : 400,
        margin: isMobile ? const EdgeInsets.all(8) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
      ),
    );
  }

  Widget _buildTodoSection(
    String title,
    List<Todo> todos,
    TodoPriority priority,
    TextEditingController controller, {
    bool showAddField = true,
  }) {
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
                  _saveTodos();
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<TodoList>().addTodo(value, priority: priority);
                  controller.clear();
                  _saveTodos();
                }
              },
            ),
          ),
        DragTarget<Todo>(
          builder: (context, candidateData, rejectedData) {
            final bool isHovering =
                candidateData.isNotEmpty &&
                candidateData.first?.priority != priority;
            final bool showDropZone =
                _isDragging &&
                _draggingFromPriority != null &&
                _draggingFromPriority != priority;

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
                  // Show drop zone message when dragging from another section
                  if (showDropZone)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withOpacity(isHovering ? 0.4 : 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isHovering
                              ? 'Release to add here'
                              : 'Drag here to add to $title',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isHovering
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(isHovering ? 1 : 0.7),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  // Show tasks
                  if (todos.isNotEmpty)
                    Column(
                      children: todos
                          .map((todo) => _buildDraggableTask(todo, priority))
                          .toList(),
                    ),
                  // Empty state
                  if (todos.isEmpty && !showDropZone)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 35),
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
                                priority.icon,
                                size: 56,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.35),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No ${title.toLowerCase()} yet',
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
          onWillAccept: (data) => data != null && data.priority != priority,
          onAccept: (Todo todo) {
            setState(() {
              _isDragging = false;
              _draggingFromPriority = null;
            });
            final todoList = context.read<TodoList>();
            todoList.changeTodoPriority(todo.id, priority);
            _saveTodos();

            // Show centered snackbar for task moved
            final deviceType = ResponsiveLayout.getDeviceType(context);
            final isMobile = deviceType == DeviceType.mobile;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Moved to $title',
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
        ),
      ],
    );
  }

  Widget _buildDraggableTask(Todo todo, TodoPriority priority) {
    return DragTarget<Todo>(
      key: ValueKey(todo.id),
      onWillAccept: (data) => data != null && data.id != todo.id,
      onAccept: (draggedTodo) {
        setState(() {
          _isDragging = false;
          _draggingFromPriority = null;
        });
        final todoList = context.read<TodoList>();
        if (draggedTodo.priority == priority) {
          // Reordering within the same section
          final todos = priority == TodoPriority.mainQuest
              ? todoList.mainQuestTodos
              : todoList.sideQuestTodos;
          final oldIndex = todos.indexWhere((t) => t.id == draggedTodo.id);
          final newIndex = todos.indexWhere((t) => t.id == todo.id);
          if (oldIndex != -1 && newIndex != -1) {
            todoList.reorderTodo(priority, oldIndex, newIndex);
            _saveTodos();
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Column(
          children: [
            if (isHovering && candidateData.first?.priority == priority)
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
              data: todo,
              delay: const Duration(milliseconds: 300),
              hapticFeedbackOnStart: true,
              onDragStarted: () {
                setState(() {
                  _isDragging = true;
                  _draggingFromPriority = priority;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                  _draggingFromPriority = null;
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _isDragging = false;
                  _draggingFromPriority = null;
                });
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
                          todo.task,
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
                  todo: todo,
                  isCompleted: false,
                  onToggle: (todo) {},
                  onEdit: (todo, newTask) {},
                  onDelete: (todo) {},
                  onArchive: (todo) {},
                ),
              ),
              child: GlassTaskCard(
                todo: todo,
                isCompleted: false,
                onToggle: (todo) {
                  context.read<TodoList>().toggleTodo(todo.id);
                  _saveTodos();
                },
                onEdit: (todo, newTask) {
                  context.read<TodoList>().editTodo(todo.id, newTask);
                  _saveTodos();
                },
                onDelete: (todo) {
                  final todoList = context.read<TodoList>();
                  todoList.deleteTodo(todo.id);
                  _saveTodos();
                  _showUndoSnackBar('Task deleted', () {
                    todoList.addTodo(todo.task, priority: todo.priority);
                    _saveTodos();
                  });
                },
                onArchive: (todo) {
                  final todoList = context.read<TodoList>();
                  todoList.archiveTodo(todo.id);
                  _saveTodos();
                  _showUndoSnackBar('Task archived', () {
                    todoList.unarchiveTodo(todo.id);
                    _saveTodos();
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    RightToLeftRoute(
                      page: TaskDetailScreen(
                        todo: todo,
                        onSave: (updatedTodo) {
                          context.read<TodoList>().updateTodo(updatedTodo);
                          _saveTodos();
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

  // Helper method to build just the tasks list (for scrollable content)
  Widget _buildTasksList(
    List<Todo> todos,
    TodoPriority priority,
    String title,
  ) {
    return DragTarget<Todo>(
      builder: (context, candidateData, rejectedData) {
        final bool isHovering =
            candidateData.isNotEmpty &&
            candidateData.first?.priority != priority;
        final bool showDropZone =
            _isDragging &&
            _draggingFromPriority != null &&
            _draggingFromPriority != priority;

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
                          : 'Drag here to add to $title',
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
              if (todos.isNotEmpty)
                Column(
                  children: todos
                      .map((todo) => _buildDraggableTask(todo, priority))
                      .toList(),
                ),
              if (todos.isEmpty && !showDropZone)
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
                            priority.icon,
                            size: 56,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.35),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No ${title.toLowerCase()} yet',
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
      onWillAccept: (data) => data != null && data.priority != priority,
      onAccept: (Todo todo) {
        setState(() {
          _isDragging = false;
          _draggingFromPriority = null;
        });
        final todoList = context.read<TodoList>();
        todoList.changeTodoPriority(todo.id, priority);
        _saveTodos();

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
                  'Moved to $title',
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

  // Collapsible completed section
  Widget _buildCollapsibleCompletedSection(
    List<Todo> completedMainQuest,
    List<Todo> completedSideQuest,
    int totalCount,
  ) {
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
                        '$totalCount',
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
                                if (completedMainQuest.isEmpty)
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
                                  ...completedMainQuest.map(
                                    (todo) => GlassTaskCard(
                                      todo: todo,
                                      isCompleted: true,
                                      onToggle: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.toggleTodo(todo.id);
                                        _saveTodos();
                                      },
                                      onEdit: (todo, newTask) {
                                        final todoList = context.read<TodoList>();
                                        todoList.editTodo(todo.id, newTask);
                                        _saveTodos();
                                      },
                                      onDelete: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.deleteTodo(todo.id);
                                        _saveTodos();
                                      },
                                      onArchive: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.archiveTodo(todo.id);
                                        _saveTodos();
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
                                if (completedSideQuest.isEmpty)
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
                                  ...completedSideQuest.map(
                                    (todo) => GlassTaskCard(
                                      todo: todo,
                                      isCompleted: true,
                                      onToggle: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.toggleTodo(todo.id);
                                        _saveTodos();
                                      },
                                      onEdit: (todo, newTask) {
                                        final todoList = context.read<TodoList>();
                                        todoList.editTodo(todo.id, newTask);
                                        _saveTodos();
                                      },
                                      onDelete: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.deleteTodo(todo.id);
                                        _saveTodos();
                                      },
                                      onArchive: (todo) {
                                        final todoList = context.read<TodoList>();
                                        todoList.archiveTodo(todo.id);
                                        _saveTodos();
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

  Widget _buildCompletedSection(List<Todo> completedTodos) {
    if (completedTodos.isEmpty) return const SizedBox.shrink();

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
                      '${completedTodos.length}',
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
                children: completedTodos
                    .map(
                      (todo) => GlassTaskCard(
                        todo: todo,
                        isCompleted: true,
                        onToggle: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.toggleTodo(todo.id);
                          _saveTodos();
                        },
                        onEdit: (todo, newTask) {
                          final todoList = context.read<TodoList>();
                          todoList.editTodo(todo.id, newTask);
                          _saveTodos();
                        },
                        onDelete: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.deleteTodo(todo.id);
                          _saveTodos();
                        },
                        onArchive: (todo) {
                          final todoList = context.read<TodoList>();
                          todoList.archiveTodo(todo.id);
                          _saveTodos();
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

  // Mobile layout - single column
  Widget _buildMobileLayout(TodoList todoList) {
    return ListView(
      padding: ResponsiveLayout.responsivePadding(context),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTodoSection(
          'Main Quest',
          todoList.mainQuestTodos,
          TodoPriority.mainQuest,
          _mainQuestController,
        ),
        const SizedBox(height: 24),
        _buildTodoSection(
          'Side Quest',
          todoList.sideQuestTodos,
          TodoPriority.sideQuest,
          _sideQuestController,
        ),
        _buildCompletedSection(todoList.completedTodos),
        const SizedBox(height: 32),
      ],
    );
  }

  // Tablet/Desktop layout - side by side
  Widget _buildTabletDesktopLayout(TodoList todoList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Separate completed tasks by priority
    final completedMainQuest = todoList.completedTodos
        .where((todo) => todo.priority == TodoPriority.mainQuest)
        .toList();
    final completedSideQuest = todoList.completedTodos
        .where((todo) => todo.priority == TodoPriority.sideQuest)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildHeader(),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Quest column
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ]
                            : [
                                Colors.white.withOpacity(0.7),
                                Colors.white.withOpacity(0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header and Add Field (Fixed)
                        Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withOpacity(0.15),
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  TodoPriority.mainQuest.icon,
                                  size: 20,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Main Quest',
                                style: AppTheme.sectionHeaderStyle.copyWith(
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AddTaskField(
                            controller: _mainQuestController,
                            hintText: 'Add main quest',
                            onAdd: () {
                              if (_mainQuestController.text.isNotEmpty) {
                                context.read<TodoList>().addTodo(
                                  _mainQuestController.text,
                                  priority: TodoPriority.mainQuest,
                                );
                                _mainQuestController.clear();
                                _saveTodos();
                              }
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                context.read<TodoList>().addTodo(
                                  value,
                                  priority: TodoPriority.mainQuest,
                                );
                                _mainQuestController.clear();
                                _saveTodos();
                              }
                            },
                          ),
                        ),
                        // Tasks (Scrollable)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(right: 4, top: 4),
                            children: [
                              _buildTasksList(
                                todoList.mainQuestTodos,
                                TodoPriority.mainQuest,
                                'Main Quest',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Beautiful divider with enhanced visibility
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.transparent,
                              AppTheme.primaryColorDark.withOpacity(0.12),
                              AppTheme.primaryColorDark.withOpacity(0.25),
                              AppTheme.primaryColorDark.withOpacity(0.12),
                              Colors.transparent,
                            ]
                          : [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.25),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                              Colors.transparent,
                            ],
                      stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppTheme.primaryColorDark.withOpacity(0.15)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Side Quest column
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ]
                            : [
                                Colors.white.withOpacity(0.7),
                                Colors.white.withOpacity(0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header and Add Field (Fixed)
                        Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withOpacity(0.15),
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  TodoPriority.sideQuest.icon,
                                  size: 20,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Side Quest',
                                style: AppTheme.sectionHeaderStyle.copyWith(
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AddTaskField(
                            controller: _sideQuestController,
                            hintText: 'Add side quest',
                            onAdd: () {
                              if (_sideQuestController.text.isNotEmpty) {
                                context.read<TodoList>().addTodo(
                                  _sideQuestController.text,
                                  priority: TodoPriority.sideQuest,
                                );
                                _sideQuestController.clear();
                                _saveTodos();
                              }
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                context.read<TodoList>().addTodo(
                                  value,
                                  priority: TodoPriority.sideQuest,
                                );
                                _sideQuestController.clear();
                                _saveTodos();
                              }
                            },
                          ),
                        ),
                        // Tasks (Scrollable)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(right: 4, top: 4),
                            children: [
                              _buildTasksList(
                                todoList.sideQuestTodos,
                                TodoPriority.sideQuest,
                                'Side Quest',
                              ),
                            ],
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
        // Completed tasks at the bottom - collapsible
        if (todoList.completedTodos.isNotEmpty)
          _buildCollapsibleCompletedSection(
            completedMainQuest,
            completedSideQuest,
            todoList.completedTodos.length,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          'Quest',
          style: AppTheme.headerStyle.copyWith(
            fontSize: ResponsiveLayout.responsiveFontSize(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          iconSize: ResponsiveLayout.responsiveValue<double>(
            context,
            mobile: 24,
            tablet: 26,
            desktop: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ArchivesScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return TaskAnimations.slideIn(animation, child);
                    },
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Profile Avatar with popup panel
        Builder(
          builder: (context) {
            return ProfileAvatar(
              onTap: () => _showProfilePanel(context),
              size: 40, // Consistent size matching add habit button
            );
          },
        ),
      ],
    );
  }

  void _showProfilePanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 60, // Position below the header
              right: 20, // Align with right edge
              child: Material(
                color: Colors.transparent,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      alignment: Alignment.topRight,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                            : [Colors.white, const Color(0xFFFAFAFA)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.7 : 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile section with avatar and tier
                        Row(
                          children: [
                            // Avatar - using ProfileAvatar widget for consistency
                            const ProfileAvatar(size: 52),
                            const SizedBox(width: 14),
                            // Tier info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppTheme.textDarkMode
                                          : AppTheme.textDark,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFFD700,
                                          ).withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.diamond_rounded,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Crystal Gold',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Settings button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                const Color(0xFF000000),
                                                const Color(0xFF0A0A0A),
                                              ]
                                            : [
                                                Colors.blue.shade50,
                                                Colors.purple.shade50,
                                              ],
                                      ),
                                    ),
                                    child: const SettingsScreen(),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withOpacity(0.08),
                                          Colors.white.withOpacity(0.04),
                                        ]
                                      : [
                                          Colors.black.withOpacity(0.04),
                                          Colors.black.withOpacity(0.02),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          (isDark
                                              ? AppTheme.primaryColorDark
                                              : AppTheme.primaryColor),
                                          (isDark
                                                  ? AppTheme.primaryColorDark
                                                  : AppTheme.primaryColor)
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (isDark
                                                      ? AppTheme
                                                            .primaryColorDark
                                                      : AppTheme.primaryColor)
                                                  .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.settings_rounded,
                                      color: isDark
                                          ? Colors.black
                                          : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Settings',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppTheme.textDarkMode
                                            : AppTheme.textDark,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 15,
                                    color: isDark
                                        ? AppTheme.textMediumDark
                                        : AppTheme.textMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final bool isTabletOrDesktop =
        deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
    final bool showWindowControls =
        !kIsWeb && Platform.isWindows && isTabletOrDesktop;
    // Sidebar width: 220 for desktop, 72 for tablet
    final double sidebarWidth = deviceType == DeviceType.desktop ? 220 : 72;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.backgroundGradientStartDark,
                  AppTheme.backgroundGradientEndDark,
                ]
              : [Colors.blue.shade50, Colors.purple.shade50],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Window controls bar for Windows tablet/desktop
            if (showWindowControls)
              WindowControlsBar(
                sidebarWidth: sidebarWidth,
                showDragIndicator: true,
              ),
            // Main content
            Expanded(
              child: SafeArea(
                top:
                    !showWindowControls, // No top safe area on Windows tablet/desktop (controls handle it)
                bottom: true,
                left: false,
                right: false,
                child: Consumer<TodoList>(
                  builder: (context, todoList, child) {
                    // Use responsive layout based on screen size
                    return ResponsiveLayout.isTabletOrDesktop(context)
                        ? _buildTabletDesktopLayout(todoList)
                        : _buildMobileLayout(todoList);
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              RightToLeftRoute(
                page: TaskDetailScreen(
                  initialPriority: TodoPriority.mainQuest,
                  onSave: (newTodo) {
                    context.read<TodoList>().updateTodo(newTodo);
                    _saveTodos();
                  },
                ),
              ),
            );
          },
          backgroundColor: isDark
              ? AppTheme.primaryColorDark
              : Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainQuestController.dispose();
    _sideQuestController.dispose();
    super.dispose();
  }
}
