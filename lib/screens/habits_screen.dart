import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/storage_service.dart';
import '../widgets/habit_row.dart';
import '../widgets/window_controls_bar.dart';
import 'habit_detail.dart';

import '../widgets/habits/habit_date_header.dart';
import '../widgets/habits/habit_empty_state.dart';
import '../widgets/habits/habit_value_input_dialog.dart';
import '../widgets/habits/add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _isLoading = true;
  bool _showArchived = false;
  int _daysToShow = 14; // Start with 14 days visible
  final ScrollController _dateScrollController = ScrollController();
  final List<ScrollController> _habitScrollControllers = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _dateScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    for (var controller in _habitScrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncScroll(double offset) {
    // Sync header
    if (_dateScrollController.hasClients &&
        (_dateScrollController.offset - offset).abs() > 0.5) {
      _dateScrollController.jumpTo(offset);
    }

    // Sync all habit rows
    for (var controller in _habitScrollControllers) {
      if (controller.hasClients && (controller.offset - offset).abs() > 0.5) {
        controller.jumpTo(offset);
      }
    }
  }

  void _onScroll() {
    // Load more days when scrolling to the left (beginning)
    if (_dateScrollController.position.pixels <= 100) {
      setState(() {
        _daysToShow += 7; // Load 7 more days
      });
    }
  }

  Future<void> _loadHabits() async {
    final habitList = Provider.of<HabitList>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);

    final habits = await storageService.loadHabits();
    habitList.setHabits(habits);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveHabits() async {
    final habitList = Provider.of<HabitList>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    await storageService.saveHabits(habitList.habits);
  }

  List<DateTime> _getVisibleDates() {
    final now = DateTime.now();
    final List<DateTime> dates = [];
    // Show latest date first (today on the left)
    for (int i = 0; i < _daysToShow; i++) {
      dates.add(now.subtract(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;
    final visibleDates = _getVisibleDates();
    // Sidebar width: 220 for desktop, 72 for tablet
    final double sidebarWidth = isDesktop ? 220 : 72;

    return Stack(
      children: [
        // Background gradient
        Container(
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
                      AppTheme.backgroundGradientStart,
                      AppTheme.backgroundGradientEnd,
                    ],
            ),
          ),
        ),
        // Content with headers
        SafeArea(
          // Only apply SafeArea on mobile, not on desktop/tablet with window controls
          top: isMobile,
          bottom: false,
          child: Column(
            children: [
              // Window controls bar for tablet/desktop Windows
              if ((isTablet || isDesktop) && !kIsWeb && Platform.isWindows)
                WindowControlsBar(
                  sidebarWidth: sidebarWidth,
                  showDragIndicator: true,
                ),

              // Header with title, archive toggle, and add button (full width)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                      : AppTheme.glassBackground.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _showArchived ? 'Archived Habits' : 'My Habits',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    // Archive toggle button
                    IconButton(
                      icon: Icon(
                        _showArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _showArchived = !_showArchived;
                        });
                      },
                      tooltip: _showArchived ? 'Show Active' : 'Show Archived',
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add habit button
                    if (!_showArchived)
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: _showAddHabitDialog,
                        tooltip: 'Add Habit',
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          const SizedBox(height: 8),

                          // Date header (scrollable)
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification) {
                                _syncScroll(notification.metrics.pixels);
                              }
                              return false;
                            },
                            child: HabitDateHeader(
                              visibleDates: visibleDates,
                              scrollController: _dateScrollController,
                              isDark: isDark,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Habits list
                          Expanded(
                            child: Consumer<HabitList>(
                              builder: (context, habitList, child) {
                                final habits = _showArchived
                                    ? habitList.archivedHabits
                                    : habitList.activeHabits;

                                if (habits.isEmpty) {
                                  return HabitEmptyState(
                                    isDark: isDark,
                                    isMobile: isMobile,
                                    showArchived: _showArchived,
                                    onAddHabit: _showAddHabitDialog,
                                  );
                                }

                                // Create scroll controllers for each habit row
                                while (_habitScrollControllers.length <
                                    habits.length) {
                                  final controller = ScrollController();
                                  _habitScrollControllers.add(controller);
                                }
                                // Remove excess controllers
                                while (_habitScrollControllers.length >
                                    habits.length) {
                                  _habitScrollControllers
                                      .removeLast()
                                      .dispose();
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: habits.length,
                                  itemBuilder: (context, index) {
                                    final habit = habits[index];
                                    return NotificationListener<
                                      ScrollNotification
                                    >(
                                      onNotification: (notification) {
                                        if (notification
                                            is ScrollUpdateNotification) {
                                          _syncScroll(
                                            notification.metrics.pixels,
                                          );
                                        }
                                        return false;
                                      },
                                      child: HabitRow(
                                        habit: habit,
                                        weekDates: visibleDates,
                                        scrollController:
                                            _habitScrollControllers[index],
                                        onDayTap: (date) {
                                          if (habit.type == HabitType.boolean) {
                                            habitList.toggleHabitDay(
                                              habit.id,
                                              date,
                                            );
                                          } else {
                                            _showValueInputDialog(habit, date);
                                          }
                                          _saveHabits();
                                        },
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HabitDetailScreen(
                                                    habitId: habit.id,
                                                  ),
                                            ),
                                          );
                                        },
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
            ],
          ),
        ),
      ],
    );
  }

  void _showAddHabitDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      _saveHabits();
    });
  }

  void _showValueInputDialog(Habit habit, DateTime date) {
    showDialog(
      context: context,
      builder: (dialogContext) => HabitValueInputDialog(
        habit: habit,
        date: date,
        onSave: (value) {
          final habitListProvider = Provider.of<HabitList>(
            context,
            listen: false,
          );
          habitListProvider.recordHabitValue(habit.id, date, value);
          _saveHabits();
        },
      ),
    );
  }
}
