import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import '../models/todo.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../widgets/window_controls_bar.dart';
import '../widgets/task_detail/priority_selector.dart';
import '../widgets/task_detail/description_field.dart';
import '../widgets/task_detail/date_time_section.dart';
import '../widgets/task_detail/subtask_section.dart';

class TaskDetailScreen extends StatefulWidget {
  final Todo? todo;
  final TodoPriority? initialPriority;
  final Function(Todo) onSave;

  const TaskDetailScreen({
    Key? key,
    this.todo,
    this.initialPriority,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TodoPriority _selectedPriority;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  List<Subtask> _subtasks = [];
  DateTime? _selectedDateTime;
  DateTime? _selectedDeadline;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Prevent duplicate saves
  bool _isSaving = false;
  // Track if task has been saved (via keyboard tick)
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    // Generate stable ID for new tasks upfront to prevent duplicates
    _newTaskId = DateTime.now().millisecondsSinceEpoch.toString();

    _titleController = TextEditingController(text: widget.todo?.task ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _selectedPriority =
        widget.todo?.priority ??
        widget.initialPriority ??
        TodoPriority.mainQuest;
    _subtasks = widget.todo?.subtasks ?? [];
    _selectedDateTime = widget.todo?.dateTime;
    _selectedDeadline = widget.todo?.deadline;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _animationController.forward();
    });

    if (widget.todo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Stable ID for new tasks - generated once
  late final String _newTaskId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _autoSaveTodo() {
    if (_titleController.text.trim().isEmpty) return;
    if (_hasSaved) return; // Already saved, don't save again

    // For new tasks, use the stable ID; for existing tasks, use existing ID
    final taskId = widget.todo?.id ?? _newTaskId;

    final todo = Todo(
      id: taskId,
      task: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      priority: _selectedPriority,
      subtasks: _subtasks,
      dateTime: _selectedDateTime,
      deadline: _selectedDeadline,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
      isCompleted: widget.todo?.isCompleted ?? false,
      completedAt: widget.todo?.completedAt,
      isArchived: widget.todo?.isArchived ?? false,
    );

    widget.onSave(todo);
    _hasSaved = true; // Mark as saved to prevent duplicate saves
  }

  void _saveTodo() {
    if (_isSaving) return;
    _isSaving = true;

    // If already saved (via keyboard tick), just close the page
    if (_hasSaved) {
      Navigator.pop(context);
      return;
    }

    // Validate title before saving
    if (_titleController.text.trim().isEmpty) {
      _isSaving = false; // Reset flag to allow retry
      final deviceType = ResponsiveLayout.getDeviceType(context);
      final isMobile = deviceType == DeviceType.mobile;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          width: isMobile ? null : 400,
          margin: isMobile ? const EdgeInsets.all(8) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    _autoSaveTodo();
    Navigator.pop(context);
  }

  void _markAsCompleted() {
    if (widget.todo != null) {
      final completedTodo = widget.todo!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      widget.onSave(completedTodo);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNewTask = widget.todo == null;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;
    final isMobile = deviceType == DeviceType.mobile;
    final bool showWindowControls =
        (isTablet || isDesktop) && !kIsWeb && Platform.isWindows;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFFAFAFA),
      // Only show AppBar on mobile or non-Windows platforms
      appBar: !showWindowControls
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // For new tasks, show a save/check button
                if (isNewTask)
                  IconButton(
                    icon: Icon(
                      Icons.check,
                      color: isDark
                          ? AppTheme.primaryColorDark
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _saveTodo,
                    tooltip: 'Save and close',
                  ),
                // For existing tasks, show star and more options
                if (!isNewTask) ...[
                  IconButton(
                    icon: Icon(
                      Icons.star_outline,
                      color: isDark
                          ? AppTheme.primaryColorDark
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () {},
                  ),
                ],
              ],
            )
          : null,
      body: Column(
        children: [
          // Window controls bar for tablet/desktop Windows
          if (showWindowControls)
            WindowControlsBar(showBackButton: true, showDragIndicator: false),
          if (showWindowControls) const SizedBox(height: 30),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Stack(
                  children: [
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: (isTablet || isDesktop) ? 100 : 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PrioritySelector(
                                selectedPriority: _selectedPriority,
                                onPriorityChanged: (priority) {
                                  setState(() => _selectedPriority = priority);
                                  _autoSaveTodo();
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  focusNode: _titleFocusNode,
                                  textInputAction: TextInputAction.done,
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Quest title',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          (isDark
                                                  ? Colors.white
                                                  : Colors.black87)
                                              .withOpacity(0.3),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                .withOpacity(0.2),
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppTheme.primaryColorDark
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        width: 2.0,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: null,
                                  onSubmitted: (_) {
                                    // Save task and move to description field (The Why section)
                                    _autoSaveTodo();
                                    _descriptionFocusNode.requestFocus();
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: DescriptionField(
                                  controller: _descriptionController,
                                  focusNode: _descriptionFocusNode,
                                  onSubmitted: () {
                                    _autoSaveTodo();
                                    FocusScope.of(context).unfocus();
                                  },
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DateTimeSection(
                                label: 'Add deadline',
                                icon: Icons.radio_button_checked,
                                selectedDate: _selectedDeadline,
                                onChanged: (date) {
                                  setState(() => _selectedDeadline = date);
                                  _autoSaveTodo();
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              DateTimeSection(
                                label: 'Add date/time',
                                icon: Icons.access_time,
                                selectedDate: _selectedDateTime,
                                onChanged: (date) {
                                  setState(() => _selectedDateTime = date);
                                  _autoSaveTodo();
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              SubtaskSection(
                                subtasks: _subtasks,
                                onSubtasksChanged: (subtasks) {
                                  setState(() => _subtasks = subtasks);
                                  _autoSaveTodo();
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Position "Mark completed" button relative to centered content on tablet/desktop
                    if (!isNewTask && !isKeyboardVisible && !isMobile)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: InkWell(
                            onTap: _markAsCompleted,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.primaryColorDark
                                    : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? AppTheme.primaryColorDark
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary)
                                            .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mark completed',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // "Mark completed" button for mobile on existing tasks
                    if (!isNewTask && !isKeyboardVisible && isMobile)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FadeTransition(
                              opacity: _opacityAnimation,
                              child: InkWell(
                                onTap: _markAsCompleted,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.primaryColorDark
                                        : Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isDark
                                                    ? AppTheme.primaryColorDark
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.primary)
                                                .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mark completed',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // No save FAB - tasks are saved on Enter/done keyboard action
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // No save FAB - tasks are saved on Enter/done keyboard action
    );
  }
}
