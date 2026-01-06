import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/habit_row.dart';
import '../../widgets/window_controls_bar.dart';
import 'habit_detail.dart';

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
      if (controller.hasClients && 
          (controller.offset - offset).abs() > 0.5) {
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
                WindowControlsBar(sidebarWidth: sidebarWidth, showDragIndicator: true),
              
              // Header with title, archive toggle, and add button (full width)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    // Archive toggle button
                    IconButton(
                      icon: Icon(
                        _showArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                        color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
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
                    child: _buildDateHeader(visibleDates, isDark),
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
                          return _buildEmptyState(isDark, isMobile);
                        }

                        // Create scroll controllers for each habit row
                        while (_habitScrollControllers.length < habits.length) {
                          final controller = ScrollController();
                          _habitScrollControllers.add(controller);
                        }
                        // Remove excess controllers
                        while (_habitScrollControllers.length > habits.length) {
                          _habitScrollControllers.removeLast().dispose();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollUpdateNotification) {
                                  _syncScroll(notification.metrics.pixels);
                                }
                                return false;
                              },
                              child: HabitRow(
                                habit: habit,
                                weekDates: visibleDates,
                                scrollController: _habitScrollControllers[index],
                                onDayTap: (date) {
                                if (habit.type == HabitType.boolean) {
                                  habitList.toggleHabitDay(habit.id, date);
                                } else {
                                  _showValueInputDialog(habit, date);
                                }
                                _saveHabits();
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HabitDetailScreen(
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

  Widget _buildDateHeader(List<DateTime> visibleDates, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.4)
            : AppTheme.glassBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Spacer for icon + habit name column
          const SizedBox(width: 44),
          
          Expanded(
            flex: 2,
            child: const SizedBox(), // Space for habit names
          ),

          const SizedBox(width: 6),

          // Date cells - infinitely scrollable
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: _dateScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: visibleDates.map((date) {
                final isToday = _isToday(date);
                return Container(
                  width: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday
                              ? (isDark
                                  ? AppTheme.primaryColorDark
                                  : AppTheme.primaryColor)
                              : (isDark
                                  ? AppTheme.textLightDark
                                  : AppTheme.textLight),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d').format(date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                          color: isToday
                              ? (isDark
                                  ? AppTheme.primaryColorDark
                                  : AppTheme.primaryColor)
                              : (isDark
                                  ? AppTheme.textMediumDark
                                  : AppTheme.textMedium),
                        ),
                      ),
                    ],
                  ),
                );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showArchived ? Icons.archive_outlined : Icons.track_changes,
            size: isMobile ? 80 : 100,
            color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                .withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            _showArchived ? 'No archived habits' : 'No habits yet',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _showArchived
                  ? 'Archived habits will appear here'
                  : 'Start building better habits today',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 16 : 18,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ),
          if (!_showArchived) ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddHabitDialog(),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Create your first habit',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddHabitDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _AddHabitScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      _saveHabits();
    });
  }

  void _showValueInputDialog(Habit habit, DateTime date) {
    final controller = TextEditingController(
      text: habit.getValueForDate(date)?.toString() ?? '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitListProvider = Provider.of<HabitList>(context, listen: false);

    void saveValue(String value) {
      final parsedValue = double.tryParse(value.trim());
      if (parsedValue != null && parsedValue >= 0) {
        habitListProvider.recordHabitValue(habit.id, date, parsedValue);
        _saveHabits();
        Navigator.of(context).pop();
      } else {
        // Show error if invalid input
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid positive number',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: habit.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                habit.icon,
                color: habit.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter ${habit.unit}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    habit.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.inter(
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., 5.0',
                suffixText: habit.unit,
                suffixStyle: GoogleFonts.inter(
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: GoogleFonts.inter(
                  color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: habit.color, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade300,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (value) => saveValue(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => saveValue(controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: habit.color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// ============================================================================
// ADD HABIT SCREEN - Production Ready Full-Page Experience
// ============================================================================

class _AddHabitScreen extends StatefulWidget {
  const _AddHabitScreen();

  @override
  State<_AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<_AddHabitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _goalController = TextEditingController();
  final _questionController = TextEditingController();
  
  HabitType _selectedType = HabitType.boolean;
  Color _selectedColor = AppTheme.primaryColor;
  IconData _selectedIcon = Icons.favorite;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showGoalField = false;
  bool _showQuestionField = false;
  
  // Icon grid for selection
  final List<IconData> _availableIcons = [
    Icons.favorite, Icons.fitness_center, Icons.book, Icons.water_drop,
    Icons.bedtime, Icons.restaurant, Icons.directions_run, Icons.self_improvement,
    Icons.music_note, Icons.brush, Icons.school, Icons.work,
    Icons.coffee, Icons.pets, Icons.nature, Icons.sunny,
    Icons.medication, Icons.psychology, Icons.spa, Icons.family_restroom,
    Icons.celebration, Icons.emoji_events, Icons.lightbulb, Icons.palette,
  ];
  
  // Predefined colors
  final List<Color> _colors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFEE5A6F), // Pink
    const Color(0xFFC56CF0), // Purple
    const Color(0xFF9B59B6), // Deep Purple
    const Color(0xFF667EEA), // Indigo
    const Color(0xFF4FACFE), // Blue
    const Color(0xFF00D2FF), // Cyan
    const Color(0xFF06BEB6), // Teal
    const Color(0xFF11998E), // Dark Teal
    const Color(0xFF38EF7D), // Green
    const Color(0xFFFFA726), // Orange
    const Color(0xFFFFD93D), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _goalController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isDesktop = deviceType == DeviceType.desktop;
    
    // Calculate max width for desktop/tablet
    final maxContentWidth = isDesktop ? 700.0 : (isMobile ? double.infinity : 600.0);
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppTheme.backgroundGradientStartDark 
          : AppTheme.backgroundGradientStart,
      body: Column(
        children: [
          // Windows title bar safe area (only on desktop platforms)
          if (isDesktop && !kIsWeb && Platform.isWindows)
            const SizedBox(height: 32), // Space for Windows title bar
          Expanded(
            child: SafeArea(
              top: !(isDesktop && !kIsWeb && Platform.isWindows), // Don't apply top safe area if we already have title bar space
              child: Column(
                children: [
                  _buildAppBar(isDark, isMobile),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              key: _formKey,
                              child: ListView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 32,
                                  vertical: isMobile ? 8 : 16,
                                ),
                                children: [
                                  _buildPreviewCard(isDark, isMobile),
                                  SizedBox(height: isMobile ? 32 : 40),
                                  _buildNameField(isDark, isMobile),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  _buildTypeSelector(isDark, isMobile),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  _buildIconSelector(isDark, isMobile),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  _buildColorSelector(isDark, isMobile),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  _buildAdvancedOptions(isDark, isMobile),
                                  SizedBox(height: isMobile ? 32 : 40),
                                  _buildCreateButton(isDark, isMobile, maxContentWidth),
                                  SizedBox(height: isMobile ? 24 : 32),
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
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Habit',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Build a better you, one day at a time',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedColor.withOpacity(0.2),
            _selectedColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _selectedIcon,
              size: isMobile ? 40 : 48,
              color: _selectedColor,
            ),
          ),
          SizedBox(width: isMobile ? 20 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? 'Your Habit' : _nameController.text,
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  _selectedType == HabitType.measurable
                      ? 'Track ${_unitController.text.isEmpty ? 'values' : _unitController.text}'
                      : 'Yes/No tracking',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 16,
                    color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Name',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        TextFormField(
          controller: _nameController,
          autofocus: !isMobile, // Only autofocus on desktop
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 17,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Morning Meditation',
            hintStyle: GoogleFonts.inter(
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                : AppTheme.glassBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a habit name';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking Type',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                isDark,
                HabitType.boolean,
                Icons.check_circle_outline,
                'Yes/No',
                'Simple daily check-in',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                isDark,
                HabitType.measurable,
                Icons.show_chart,
                'Measurable',
                'Track numeric values',
              ),
            ),
          ],
        ),
        if (_selectedType == HabitType.measurable) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _unitController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Unit of Measurement',
              hintText: 'e.g., miles, pages, minutes, cups',
              hintStyle: GoogleFonts.inter(
                color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
              ),
              prefixIcon: Icon(Icons.straighten, color: _selectedColor),
              filled: true,
              fillColor: isDark
                  ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                  : AppTheme.glassBackground.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _selectedColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: (value) {
              if (_selectedType == HabitType.measurable && 
                  (value == null || value.trim().isEmpty)) {
                return 'Please enter a unit (e.g., miles, pages)';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeOption(bool isDark, HabitType type, IconData icon, String title, String subtitle) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedColor.withOpacity(0.15)
              : (isDark
                  ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                  : AppTheme.glassBackground.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? _selectedColor : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? _selectedColor : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Icon',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                : AppTheme.glassBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 6 : 8,
              crossAxisSpacing: isMobile ? 8 : 12,
              mainAxisSpacing: isMobile ? 8 : 12,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = _selectedIcon == icon;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withOpacity(0.2)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 24 : 28,
                    color: isSelected ? _selectedColor : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a Color',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        Wrap(
          spacing: isMobile ? 12 : 16,
          runSpacing: isMobile ? 12 : 16,
          children: _colors.map((color) {
            final isSelected = _selectedColor.value == color.value;
            final colorSize = isMobile ? 48.0 : 56.0;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: colorSize,
                height: colorSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, color: Colors.white, size: isMobile ? 24 : 28)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Options',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        
        // Goal field toggle
        if (_selectedType == HabitType.measurable)
          _buildAdvancedOption(
            isDark,
            Icons.flag_outlined,
            'Daily Goal',
            'Set a target to reach each day',
            _showGoalField,
            (value) => setState(() => _showGoalField = value),
          ),
        
        if (_showGoalField && _selectedType == HabitType.measurable) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _goalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Daily Goal',
              hintText: 'e.g., 5',
              suffix: Text(
                _unitController.text.isEmpty ? 'units' : _unitController.text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
              ),
              prefixIcon: Icon(Icons.flag, color: _selectedColor),
              filled: true,
              fillColor: isDark
                  ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                  : AppTheme.glassBackground.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _selectedColor, width: 2),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Question field toggle
        _buildAdvancedOption(
          isDark,
          Icons.quiz_outlined,
          'Custom Question',
          'Add a motivational question',
          _showQuestionField,
          (value) => setState(() => _showQuestionField = value),
        ),
        
        if (_showQuestionField) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _questionController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Question',
              hintText: 'e.g., Did you meditate today?',
              prefixIcon: Icon(Icons.quiz, color: _selectedColor),
              filled: true,
              fillColor: isDark
                  ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                  : AppTheme.glassBackground.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _selectedColor, width: 2),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedOption(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.3)
            : AppTheme.glassBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: _selectedColor,
        title: Row(
          children: [
            Icon(icon, size: 20, color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(bool isDark, bool isMobile, double maxContentWidth) {
    return Container(
      width: double.infinity,
      height: isMobile ? 56 : 60,
      child: FilledButton(
        onPressed: _createHabit,
        style: FilledButton.styleFrom(
          backgroundColor: _selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: _selectedColor.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Create Habit',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 18 : 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final habitList = Provider.of<HabitList>(context, listen: false);
    
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      type: _selectedType,
      unit: _selectedType == HabitType.measurable
          ? _unitController.text.trim()
          : '',
      createdAt: DateTime.now(),
      question: _showQuestionField && _questionController.text.trim().isNotEmpty
          ? _questionController.text.trim()
          : null,
    );
    
    habitList.addHabit(newHabit);
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: _selectedColor),
            const SizedBox(width: 12),
            Text(
              'Habit created successfully!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
}
