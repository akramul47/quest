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
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _showArchived = false;
  int _daysToShow = 14;
  final ScrollController _dateScrollController = ScrollController();
  final List<ScrollController> _habitScrollControllers = [];

  // Add habit modal state & controllers
  bool _isAddHabitVisible = false;
  AnimationController? _rotationController;

  // Lifted state from AddHabitScreen
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _goalController = TextEditingController();
  final _questionController = TextEditingController();
  final _addHabitScrollController = ScrollController();

  // Edit mode state
  String? _editingHabitId;

  HabitType _selectedType = HabitType.boolean;
  Color _selectedColor = AppTheme.primaryColor;
  IconData _selectedIcon = Icons.favorite;
  bool _showGoalField = false;
  bool _showQuestionField = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _dateScrollController.addListener(_onScroll);
    _initRotationController();
  }

  void _initRotationController() {
    _rotationController ??= AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initRotationController();
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _rotationController?.dispose();
    for (var controller in _habitScrollControllers) {
      controller.dispose();
    }

    // Dispose form controllers
    _nameController.dispose();
    _unitController.dispose();
    _goalController.dispose();
    _questionController.dispose();
    _addHabitScrollController.dispose();
    super.dispose();
  }

  // resets form to defaults
  void _resetForm() {
    _nameController.clear();
    _unitController.clear();
    _goalController.clear();
    _questionController.clear();
    if (_addHabitScrollController.hasClients) {
      _addHabitScrollController.jumpTo(0);
    }
    setState(() {
      _selectedType = HabitType.boolean;
      _selectedColor = AppTheme.primaryColor;
      _selectedIcon = Icons.favorite;
      _showGoalField = false;
      _showQuestionField = false;
    });
  }

  void _createHabit() {
    if (_formKey.currentState!.validate()) {
      final habitList = Provider.of<HabitList>(context, listen: false);

      final goalValue = _showGoalField && _goalController.text.isNotEmpty
          ? double.tryParse(_goalController.text)
          : null;

      if (_editingHabitId != null) {
        // Update existing habit
        final originalHabit = habitList.getHabitById(_editingHabitId!);
        if (originalHabit != null) {
          final updatedHabit = Habit(
            id: _editingHabitId!,
            name: _nameController.text,
            type: _selectedType,
            color: _selectedColor,
            icon: _selectedIcon,
            unit: _selectedType == HabitType.measurable
                ? _unitController.text
                : '',
            createdAt: originalHabit.createdAt,
            history: originalHabit.history, // Preserve history
            isArchived: originalHabit.isArchived, // Preserve archive status
            question: _showQuestionField && _questionController.text.isNotEmpty
                ? _questionController.text
                : null,
          );

          habitList.updateHabit(_editingHabitId!, updatedHabit);
        }
      } else {
        // Create new habit
        final newHabit = Habit(
          id: DateTime.now().toString(),
          name: _nameController.text,
          type: _selectedType,
          color: _selectedColor,
          icon: _selectedIcon,
          unit: _selectedType == HabitType.measurable
              ? _unitController.text
              : '',
          createdAt: DateTime.now(),
          question: _showQuestionField && _questionController.text.isNotEmpty
              ? _questionController.text
              : null,
        );

        habitList.addHabit(newHabit);
      }

      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final snackBarWidth = screenWidth > 400 ? 400.0 : screenWidth - 32;
      final horizontalMargin = (screenWidth - snackBarWidth) / 2;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: _selectedColor),
              const SizedBox(width: 12),
              Text(
                _editingHabitId != null
                    ? 'Habit updated successfully!'
                    : 'Habit created successfully!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 24,
            left: horizontalMargin,
            right: horizontalMargin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          duration: const Duration(seconds: 2),
        ),
      );

      _toggleAddHabit();
      _saveHabits();
    }
  }

  void _syncScroll(double offset) {
    if (_dateScrollController.hasClients &&
        (_dateScrollController.offset - offset).abs() > 0.5) {
      _dateScrollController.jumpTo(offset);
    }
    for (var controller in _habitScrollControllers) {
      if (controller.hasClients && (controller.offset - offset).abs() > 0.5) {
        controller.jumpTo(offset);
      }
    }
  }

  void _onScroll() {
    if (_dateScrollController.position.pixels <= 100) {
      setState(() {
        _daysToShow += 7;
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
    for (int i = 0; i < _daysToShow; i++) {
      dates.add(now.subtract(Duration(days: i)));
    }
    return dates;
  }

  void _toggleAddHabit([Habit? habit]) {
    setState(() {
      if (habit != null) {
        // Edit mode
        _isAddHabitVisible = true;
        _editingHabitId = habit.id;

        _nameController.text = habit.name;
        _unitController.text = habit.unit;
        _questionController.text = habit.question ?? '';

        _selectedType = habit.type;
        _selectedColor = habit.color;
        _selectedIcon = habit.icon;
        _showQuestionField =
            habit.question != null && habit.question!.isNotEmpty;
        _showGoalField = false; // Goal not currently stored in Habit model
      } else {
        // Toggle mode (New or Close)
        _isAddHabitVisible = !_isAddHabitVisible;
        if (!_isAddHabitVisible) {
          _resetForm();
          _editingHabitId = null;
        } else {
          _editingHabitId = null;
          _resetForm();
        }
      }

      if (_rotationController != null) {
        if (_isAddHabitVisible) {
          _rotationController!.forward();
        } else {
          _rotationController!.reverse();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;
    final visibleDates = _getVisibleDates();
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
          top: isMobile,
          bottom: false,
          child: Column(
            children: [
              if ((isTablet || isDesktop) && !kIsWeb && Platform.isWindows)
                WindowControlsBar(
                  sidebarWidth: sidebarWidth,
                  showDragIndicator: true,
                ),

              Container(
                height: 70, // Fixed height for consistent switching
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8, // Reduced padding to allow text to fit
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
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isAddHabitVisible
                            ? _buildAddHabitHeader(isDark, isMobile)
                            : Row(
                                key: const ValueKey('normal_header'),
                                children: [
                                  Text(
                                    _showArchived
                                        ? 'Archived Habits'
                                        : 'Habits',
                                    style: GoogleFonts.outfit(
                                      fontSize: isMobile ? 22 : 26,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.textDarkMode
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                  const Spacer(),
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
                                    tooltip: _showArchived
                                        ? 'Show Active'
                                        : 'Show Archived',
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_showArchived || _isAddHabitVisible)
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.125).animate(
                          CurvedAnimation(
                            parent:
                                _rotationController ??
                                AnimationController(vsync: this),
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: _toggleAddHabit,
                          tooltip: _isAddHabitVisible ? 'Close' : 'Add Habit',
                          style: IconButton.styleFrom(
                            backgroundColor: _isAddHabitVisible
                                ? (isDark ? Colors.grey[800] : Colors.grey[300])
                                : (isDark
                                      ? AppTheme.primaryColorDark
                                      : AppTheme.primaryColor),
                            foregroundColor: _isAddHabitVisible
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    // Main Content
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              const SizedBox(height: 8),
                              NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification
                                      is ScrollUpdateNotification) {
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
                                        onAddHabit: _toggleAddHabit,
                                      );
                                    }

                                    while (_habitScrollControllers.length <
                                        habits.length) {
                                      _habitScrollControllers.add(
                                        ScrollController(),
                                      );
                                    }
                                    while (_habitScrollControllers.length >
                                        habits.length) {
                                      _habitScrollControllers
                                          .removeLast()
                                          .dispose();
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                      ),
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
                                              if (habit.type ==
                                                  HabitType.boolean) {
                                                habitList.toggleHabitDay(
                                                  habit.id,
                                                  date,
                                                );
                                              } else {
                                                _showValueInputDialog(
                                                  habit,
                                                  date,
                                                );
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
                                            onLongPress: () =>
                                                _toggleAddHabit(habit),
                                            onArchive: () {
                                              if (habit.isArchived) {
                                                habitList.unarchiveHabit(
                                                  habit.id,
                                                );
                                                _saveHabits();
                                                final screenWidth =
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width;
                                                final snackBarWidth =
                                                    screenWidth > 400
                                                    ? 400.0
                                                    : screenWidth - 32;
                                                final horizontalMargin =
                                                    (screenWidth -
                                                        snackBarWidth) /
                                                    2;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .unarchive_outlined,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Habit restored',
                                                          style:
                                                              GoogleFonts.inter(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFF333333),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin: EdgeInsets.only(
                                                      bottom: 24,
                                                      left: horizontalMargin,
                                                      right: horizontalMargin,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
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

                    // Bottom Modal for Add Habit
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      left: 16,
                      right: 16,
                      top: _isAddHabitVisible
                          ? 8 // Slightly reduced top padding
                          : MediaQuery.of(context).size.height,
                      bottom: _isAddHabitVisible
                          ? 0
                          : -MediaQuery.of(context).size.height,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF000000)
                              : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            // PROMINENT GLOW
                            BoxShadow(
                              color:
                                  (isDark
                                          ? AppTheme.primaryColorDark
                                          : AppTheme.primaryColor)
                                      .withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 1,
                              offset: const Offset(0, -4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.4 : 0.15,
                              ),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          child: AddHabitFormContent(
                            isEmbedded: true,
                            formKey: _formKey,
                            nameController: _nameController,
                            unitController: _unitController,
                            goalController: _goalController,
                            questionController: _questionController,
                            selectedType: _selectedType,
                            selectedColor: _selectedColor,
                            selectedIcon: _selectedIcon,
                            showGoalField: _showGoalField,
                            showQuestionField: _showQuestionField,
                            onTypeChanged: (val) =>
                                setState(() => _selectedType = val),
                            onColorChanged: (val) =>
                                setState(() => _selectedColor = val),
                            onIconChanged: (val) =>
                                setState(() => _selectedIcon = val),
                            onShowGoalChanged: (val) =>
                                setState(() => _showGoalField = val),
                            onShowQuestionChanged: (val) =>
                                setState(() => _showQuestionField = val),
                            onCreate: _createHabit,
                            scrollController: _addHabitScrollController,
                            onClose: _toggleAddHabit,
                            isEditing: _editingHabitId != null,
                          ),
                        ),
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

  Widget _buildAddHabitHeader(bool isDark, bool isMobile) {
    return Container(
      key: const ValueKey('add_habit_header'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Icon(_selectedIcon, size: 24, color: _selectedColor),
          ),
          const SizedBox(width: 12),
          // Text Details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, _) {
                    return Text(
                      value.text.isEmpty ? 'New Habit' : value.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                    );
                  },
                ),
                Text(
                  _selectedType == HabitType.measurable
                      ? 'Measurable'
                      : 'Yes/No',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _selectedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_editingHabitId != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
              onPressed: () {
                final habitList = Provider.of<HabitList>(
                  context,
                  listen: false,
                );

                // Re-fetch to be safe inside callback
                final habit = habitList.getHabitById(_editingHabitId!);
                final isCurrentlyArchived = habit?.isArchived ?? false;

                if (isCurrentlyArchived) {
                  habitList.deleteHabit(_editingHabitId!);
                } else {
                  habitList.archiveHabit(_editingHabitId!);
                }

                _saveHabits();
                _toggleAddHabit();

                final screenWidth = MediaQuery.of(context).size.width;
                final snackBarWidth = screenWidth > 400
                    ? 400.0
                    : screenWidth - 32;
                final horizontalMargin = (screenWidth - snackBarWidth) / 2;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCurrentlyArchived
                              ? Icons.delete_forever_rounded
                              : Icons.archive_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCurrentlyArchived
                              ? 'Habit deleted permanently'
                              : 'Habit moved to archives',
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                );
              },
              tooltip: 'Delete Habit',
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
        ],
      ),
    );
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
