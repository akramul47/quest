import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
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
import '../widgets/update_modal.dart';
import '../providers/update_provider.dart';
import 'package:flutter/services.dart' show SystemNavigator;

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

  // Update modal visibility state
  bool _isUpdateModalVisible = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    // Check for updates after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    // Trigger update check on hot reload for testing
    if (kDebugMode) {
      // Small delay to ensure frame is ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          final provider = context.read<UpdateProvider>();
          if (kIsWeb) {
            provider.checkForWebUpdates();
          } else {
            provider.checkForUpdates();
          }
        }
      });
    }
  }

  void _checkForUpdates() {
    final updateProvider = context.read<UpdateProvider>();
    // Listen for update ready state
    updateProvider.addListener(_onUpdateStateChanged);

    // For web, check with delay to ensure loading matches user request
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          updateProvider.checkForWebUpdates();
        }
      });
    }
  }

  void _onUpdateStateChanged() {
    if (!mounted) return;
    final updateProvider = context.read<UpdateProvider>();
    if (updateProvider.shouldShowModal && !_isUpdateModalVisible) {
      setState(() {
        _isUpdateModalVisible = true;
      });
      updateProvider.markModalShown();
    }
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
                                    : Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.1),
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
                                    : Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.1),
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
    final primaryColor = isDark
        ? AppTheme.primaryColorDark
        : Theme.of(context).colorScheme.primary;

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
        const SizedBox(width: 8),
        // Archive button with circular background
        _ArchiveButton(primaryColor: primaryColor, isDark: isDark),
        const SizedBox(width: 8),
        // Profile Avatar with popup panel
        Builder(
          builder: (context) {
            return ProfileAvatar(
              onTap: () => _showProfilePanel(context),
              size: 40,
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
              child: Material(color: Colors.transparent, child: ProfilePanel()),
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
        body: PopScope(
          canPop: !_isUpdateModalVisible,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _isUpdateModalVisible) {
              setState(() => _isUpdateModalVisible = false);
              context.read<UpdateProvider>().dismissUpdate();
            }
          },
          child: Stack(
            children: [
              // Main content
              Column(
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

              // Update modal overlay with semi-transparent backdrop
              if (_isUpdateModalVisible)
                GestureDetector(
                  onTap: () {
                    // Dismiss on backdrop tap
                    setState(() => _isUpdateModalVisible = false);
                    context.read<UpdateProvider>().dismissUpdate();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),

              // Animated update modal
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                top: _isUpdateModalVisible
                    ? MediaQuery.of(context).padding.top +
                          70 +
                          (showWindowControls ? 32 : 0)
                    : MediaQuery.of(context).size.height,
                bottom: _isUpdateModalVisible
                    ? 0
                    : -MediaQuery.of(context).size.height,
                child: UpdateModal(
                  patchVersion: context
                      .watch<UpdateProvider>()
                      .availablePatchNumber,
                  appVersion: context.watch<UpdateProvider>().appVersion,
                  onDismiss: () {
                    setState(() => _isUpdateModalVisible = false);
                    if (kIsWeb) {
                      context.read<UpdateProvider>().dismissWebUpdate();
                    } else {
                      context.read<UpdateProvider>().dismissUpdate();
                    }
                  },
                  onRestart:
                      context.read<UpdateProvider>().availablePatchNumber ==
                          null
                      ? null
                      : () {
                          // Close the app to apply update on next launch
                          SystemNavigator.pop();
                        },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isUpdateModalVisible
            ? null
            : FloatingActionButton(
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
    // Remove update listener
    try {
      context.read<UpdateProvider>().removeListener(_onUpdateStateChanged);
    } catch (_) {}
    _mainQuestController.dispose();
    _sideQuestController.dispose();
    super.dispose();
  }
}

class _ArchiveButton extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _ArchiveButton({required this.primaryColor, required this.isDark});

  @override
  State<_ArchiveButton> createState() => _ArchiveButtonState();
}

class _ArchiveButtonState extends State<_ArchiveButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: _isHovered
              ? Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.15),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
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
            child: Center(
              child: Icon(
                Icons.archive_outlined,
                size: 16,
                color: widget.primaryColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
