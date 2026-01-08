import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../models/todo.dart';
import '../../models/todo_list.dart';
import '../services/storage_service.dart';
import '../widgets/add_task_field.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/window_controls_bar.dart';
import '../widgets/streak_display.dart';
import 'archives_screen.dart';
import 'task_detail_screen.dart';
import '../utils/page_transitions.dart';

import '../widgets/home/todo_section.dart';
import '../widgets/home/todo_list_section.dart';
import '../widgets/home/completed_section.dart';
import '../widgets/home/split_completed_section.dart';
import '../widgets/home/profile_panel.dart';

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

  Widget _buildMobileLayout(TodoList todoList) {
    return ListView(
      padding: ResponsiveLayout.responsivePadding(context),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        TodoSection(
          title: 'Main Quest',
          todos: todoList.mainQuestTodos,
          priority: TodoPriority.mainQuest,
          controller: _mainQuestController,
          isDragging: _isDragging,
          draggingFromPriority: _draggingFromPriority,
          onDragStateChanged: (isDragging, priority) {
            setState(() {
              _isDragging = isDragging;
              _draggingFromPriority = priority;
            });
          },
          onSave: _saveTodos,
          onUndo: _showUndoSnackBar,
        ),
        const SizedBox(height: 24),
        TodoSection(
          title: 'Side Quest',
          todos: todoList.sideQuestTodos,
          priority: TodoPriority.sideQuest,
          controller: _sideQuestController,
          isDragging: _isDragging,
          draggingFromPriority: _draggingFromPriority,
          onDragStateChanged: (isDragging, priority) {
            setState(() {
              _isDragging = isDragging;
              _draggingFromPriority = priority;
            });
          },
          onSave: _saveTodos,
          onUndo: _showUndoSnackBar,
        ),
        CompletedSection(
          completedTodos: todoList.completedTodos,
          onSave: _saveTodos,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

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
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
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
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(alpha: 0.1),
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
                                          .withValues(alpha: 0.15),
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withValues(alpha: 0.08),
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
                              TodoListSection(
                                todos: todoList.mainQuestTodos,
                                priority: TodoPriority.mainQuest,
                                title: 'Main Quest',
                                isDragging: _isDragging,
                                draggingFromPriority: _draggingFromPriority,
                                onDragStateChanged: (isDragging, priority) {
                                  setState(() {
                                    _isDragging = isDragging;
                                    _draggingFromPriority = priority;
                                  });
                                },
                                onSave: _saveTodos,
                                onUndo: _showUndoSnackBar,
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
                              AppTheme.primaryColorDark.withValues(alpha: 0.12),
                              AppTheme.primaryColorDark.withValues(alpha: 0.25),
                              AppTheme.primaryColorDark.withValues(alpha: 0.12),
                              Colors.transparent,
                            ]
                          : [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.25),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                      stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppTheme.primaryColorDark.withValues(alpha: 0.15)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
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
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.4),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
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
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(alpha: 0.1),
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
                                          .withValues(alpha: 0.15),
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary)
                                          .withValues(alpha: 0.08),
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
                              TodoListSection(
                                todos: todoList.sideQuestTodos,
                                priority: TodoPriority.sideQuest,
                                title: 'Side Quest',
                                isDragging: _isDragging,
                                draggingFromPriority: _draggingFromPriority,
                                onDragStateChanged: (isDragging, priority) {
                                  setState(() {
                                    _isDragging = isDragging;
                                    _draggingFromPriority = priority;
                                  });
                                },
                                onSave: _saveTodos,
                                onUndo: _showUndoSnackBar,
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
          SplitCompletedSection(
            completedMainQuest: completedMainQuest,
            completedSideQuest: completedSideQuest,
            totalCount: todoList.completedTodos.length,
            onSave: _saveTodos,
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
        // Streak Display
        const StreakDisplayWidget(compact: true),
        const SizedBox(width: 16),
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const Stack(
          children: [
            Positioned(
              top: 60, // Position below the header
              right: 20, // Align with right edge
              child: Material(
                color: Colors.transparent,
                child: ProfilePanel(),
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
