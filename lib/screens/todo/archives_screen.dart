import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../models/todo.dart';
import '../../models/todo_list.dart';
import '../../widgets/window_controls_bar.dart';

class ArchivesScreen extends StatefulWidget {
  const ArchivesScreen({super.key});

  @override
  State<ArchivesScreen> createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  Map<String, List<Todo>> _groupArchivedTodos(List<Todo> archivedTodos) {
    final Map<String, List<Todo>> grouped = {};

    for (var todo in archivedTodos) {
      // Use completedAt date if available, otherwise use createdAt
      final date = todo.completedAt ?? todo.createdAt;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(todo);
    }

    // Sort the map keys in reverse chronological order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;
    final bool showWindowControls = (isTablet || isDesktop) && !kIsWeb && Platform.isWindows;
    
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
              : [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Only show AppBar on mobile or non-Windows platforms
        appBar: !showWindowControls ? AppBar(
          title: Text(
            'Archives',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
          ),
          elevation: 0,
        ) : null,
        body: Column(
          children: [
            // Window controls bar for tablet/desktop Windows
            if (showWindowControls)
              WindowControlsBar(showBackButton: true, showDragIndicator: false),
            
            Expanded(
              child: Consumer<TodoList>(
          builder: (context, todoList, child) {
            final archivedTodos = todoList.archivedTodos;

            if (archivedTodos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 48,
                      color: isDark ? AppTheme.textMediumDark : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No archived tasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppTheme.textMediumDark : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            final groupedTodos = _groupArchivedTodos(archivedTodos);

            return ListView.builder(
              itemCount: groupedTodos.length,
              padding: ResponsiveLayout.responsivePadding(context),
              itemBuilder: (context, index) {
                final dateKey = groupedTodos.keys.elementAt(index);
                final tasks = groupedTodos[dateKey]!;
                final date = DateTime.parse(dateKey);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppTheme.glassBackgroundDark,
                              AppTheme.glassBackgroundDark.withOpacity(0.5),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.4),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              DateFormat.yMMMMd().format(date),
                              style: GoogleFonts.outfit(
                                fontSize: ResponsiveLayout.responsiveFontSize(
                                  context,
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                                ),
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                                style: GoogleFonts.inter(
                                  color: isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, taskIndex) {
                          final todo = tasks[taskIndex];
                          return ListTile(
                            leading: Icon(
                              todo.priority.icon,
                              color: todo.isCompleted
                                  ? (isDark ? Colors.green.shade400 : Colors.green)
                                  : (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(
                              todo.task,
                              style: TextStyle(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                              ),
                            ),
                            subtitle: Text(
                              todo.priority.displayName,
                              style: TextStyle(
                                color: isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.unarchive),
                              color: isDark ? AppTheme.primaryColorDark : null,
                              onPressed: () {
                                // Capture references before showing snackbar
                                final todoList = context.read<TodoList>();
                                final todoId = todo.id;
                                
                                todoList.unarchiveTodo(todoId);

                                // Show centered snackbar
                                final deviceType = ResponsiveLayout.getDeviceType(context);
                                final isMobile = deviceType == DeviceType.mobile;
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.unarchive, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Task unarchived',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    width: isMobile ? null : 400,
                                    margin: isMobile ? const EdgeInsets.all(8) : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isDark
                                        ? AppTheme.primaryColorDark
                                        : Theme.of(context).colorScheme.primary,
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Use captured reference instead of context.read
                                        todoList.archiveTodo(todoId);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
            ),
          ],
        ),
      ),
    );
  }
}
