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
  final Function(Todo)? onDelete;
  final Function(Todo)? onArchive;

  const TaskDetailScreen({
    Key? key,
    this.todo,
    this.initialPriority,
    required this.onSave,
    this.onDelete,
    this.onArchive,
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

  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSubtasks = _subtasks.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Quest',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this quest?',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              if (hasSubtasks) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_subtasks.length} subtask${_subtasks.length > 1 ? 's' : ''} will also be deleted.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteTodo();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo() {
    if (widget.todo == null || widget.onDelete == null) return;

    final deletedTodo = widget.todo!;
    final onSaveCallback = widget.onSave; // Capture callback before navigation
    widget.onDelete!(deletedTodo);

    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final scaffoldMessenger = ScaffoldMessenger.of(
      context,
    ); // Capture before navigation

    // Pop first, then show snackbar
    Navigator.pop(context);

    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Quest deleted', style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        width: isMobile ? null : 400,
        margin: isMobile ? const EdgeInsets.all(8) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Re-add the deleted todo using captured callback
            onSaveCallback(deletedTodo);
          },
        ),
      ),
    );
  }

  void _archiveTodo() {
    if (widget.todo == null || widget.onArchive == null) return;

    widget.onArchive!(widget.todo!);

    // Calculate snackbar positioning for centered display
    final screenWidth = MediaQuery.of(context).size.width;
    final snackBarWidth = screenWidth > 400 ? 400.0 : screenWidth - 32;
    final horizontalMargin = (screenWidth - snackBarWidth) / 2;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.archive_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Quest archived',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 24,
          left: horizontalMargin,
          right: horizontalMargin,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                // Main content - rendered first so buttons appear on top
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top:
                            72, // Add top padding for buttons with extra spacing
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
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: TextField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              textInputAction: TextInputAction.done,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Quest title',
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      (isDark ? Colors.white : Colors.black87)
                                          .withOpacity(0.3),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        (isDark ? Colors.white : Colors.black87)
                                            .withOpacity(0.2),
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppTheme.primaryColorDark
                                        : Theme.of(context).colorScheme.primary,
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
                            constraints: const BoxConstraints(maxWidth: 600),
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
                // Back button - positioned at top-left of content area
                Positioned(
                  top: 16,
                  left: 16,
                  child: _HoverButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                    isDark: isDark,
                    isPrimary: false,
                  ),
                ),
                // Right side buttons - positioned at top-right
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // For new tasks, show tick button
                      if (isNewTask)
                        _HoverButton(
                          icon: Icons.check,
                          onPressed: _saveTodo,
                          isDark: isDark,
                          isPrimary: true,
                          primaryColor: isDark
                              ? AppTheme.primaryColorDark
                              : Theme.of(context).colorScheme.primary,
                        ),
                      // For existing tasks, show star and dropdown menu
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
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          position: PopupMenuPosition.under,
                          offset: const Offset(0, 8),
                          color: isDark
                              ? const Color(0xFF2D2D2D)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteConfirmation();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              enabled: widget.onDelete != null,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: widget.onDelete != null
                                        ? Colors.red
                                        : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: GoogleFonts.inter(
                                      color: widget.onDelete != null
                                          ? Colors.red
                                          : (isDark
                                                ? Colors.white38
                                                : Colors.black38),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom hover button widget with visible hover effects
class _HoverButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isPrimary;
  final Color? primaryColor;

  const _HoverButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    this.isPrimary = false,
    this.primaryColor,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isPrimary
        ? (widget.primaryColor ?? Theme.of(context).colorScheme.primary)
        : (widget.isDark ? Colors.white : Colors.black87);

    final backgroundColor = widget.isPrimary
        ? baseColor.withValues(alpha: _isHovered ? 0.2 : 0.1)
        : (widget.isDark
              ? Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.08)
              : Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.08));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                widget.icon,
                color: widget.isPrimary ? baseColor : baseColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
