import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/habits/habit_preview_card.dart';
import '../widgets/habits/habit_name_field.dart';
import '../widgets/habits/habit_type_selector.dart';
import '../widgets/habits/habit_icon_selector.dart';
import '../widgets/habits/habit_color_selector.dart';
import '../widgets/habits/habit_advanced_options.dart';
import '../widgets/habits/habit_create_button.dart';

class AddHabitScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onClose;

  const AddHabitScreen({Key? key, this.isEmbedded = false, this.onClose})
    : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _goalController = TextEditingController();
  final _questionController = TextEditingController();

  HabitType _selectedType = HabitType.boolean;
  Color _selectedColor = AppTheme.primaryColor;
  IconData _selectedIcon = Icons.favorite;
  bool _showGoalField = false;
  bool _showQuestionField = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _goalController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _createHabit() {
    if (_formKey.currentState!.validate()) {
      final habitList = Provider.of<HabitList>(context, listen: false);

      final goalValue = _showGoalField && _goalController.text.isNotEmpty
          ? double.tryParse(_goalController.text)
          : null;

      final newHabit = Habit(
        id: DateTime.now().toString(),
        name: _nameController.text,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        unit: _selectedType == HabitType.measurable ? _unitController.text : '',
        createdAt: DateTime.now(),
        question: _showQuestionField && _questionController.text.isNotEmpty
            ? _questionController.text
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      if (widget.isEmbedded && widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddHabitFormContent(
      isEmbedded: widget.isEmbedded,
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
      onTypeChanged: (val) => setState(() => _selectedType = val),
      onColorChanged: (val) => setState(() => _selectedColor = val),
      onIconChanged: (val) => setState(() => _selectedIcon = val),
      onShowGoalChanged: (val) => setState(() => _showGoalField = val),
      onShowQuestionChanged: (val) => setState(() => _showQuestionField = val),
      onCreate: _createHabit,
      onClose: widget.isEmbedded
          ? widget.onClose
          : () => Navigator.pop(context),
    );
  }
}

class AddHabitFormContent extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController goalController;
  final TextEditingController questionController;

  final HabitType selectedType;
  final Color selectedColor;
  final IconData selectedIcon;
  final bool showGoalField;
  final bool showQuestionField;

  final ValueChanged<HabitType> onTypeChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<IconData> onIconChanged;
  final ValueChanged<bool> onShowGoalChanged;
  final ValueChanged<bool> onShowQuestionChanged;
  final VoidCallback onCreate;
  final VoidCallback? onClose;

  const AddHabitFormContent({
    Key? key,
    required this.isEmbedded,
    required this.formKey,
    required this.nameController,
    required this.unitController,
    required this.goalController,
    required this.questionController,
    required this.selectedType,
    required this.selectedColor,
    required this.selectedIcon,
    required this.showGoalField,
    required this.showQuestionField,
    required this.onTypeChanged,
    required this.onColorChanged,
    required this.onIconChanged,
    required this.onShowGoalChanged,
    required this.onShowQuestionChanged,
    required this.onCreate,
    this.scrollController,
    this.onClose,
    this.isEditing = false,
  }) : super(key: key);

  final ScrollController? scrollController;
  final bool isEditing;

  @override
  State<AddHabitFormContent> createState() => _AddHabitFormContentState();
}

class _AddHabitFormContentState extends State<AddHabitFormContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isDesktop = deviceType == DeviceType.desktop;

    // Calculate max width for desktop/tablet
    final maxContentWidth = isDesktop
        ? 700.0
        : (isMobile ? double.infinity : 600.0);

    return Scaffold(
      backgroundColor: widget.isEmbedded
          ? Colors.transparent
          : (isDark
                ? AppTheme.backgroundGradientStartDark
                : AppTheme.backgroundGradientStart),
      body: Column(
        children: [
          // Windows title bar safe area
          if (!widget.isEmbedded && isDesktop && !kIsWeb && Platform.isWindows)
            const SizedBox(height: 32),
          Expanded(
            child: SafeArea(
              top:
                  !widget.isEmbedded &&
                  !(isDesktop && !kIsWeb && Platform.isWindows),
              child: Column(
                children: [
                  if (!widget.isEmbedded) _buildAppBar(isDark, isMobile),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              key: widget.formKey,
                              child: ListView(
                                controller: widget.scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 32,
                                  vertical: isMobile ? 8 : 16,
                                ),
                                children: [
                                  // Hide preview card if embedded (it's in the app bar)
                                  if (!widget.isEmbedded) ...[
                                    HabitPreviewCard(
                                      selectedColor: widget.selectedColor,
                                      selectedIcon: widget.selectedIcon,
                                      nameController: widget.nameController,
                                      selectedType: widget.selectedType,
                                      unitController: widget.unitController,
                                      isDark: isDark,
                                      isMobile: isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 32 : 40),
                                  ] else
                                    const SizedBox(height: 24),

                                  HabitNameField(
                                    nameController: widget.nameController,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                    selectedColor: widget.selectedColor,
                                    onChanged: () => setState(() {}),
                                  ),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  HabitTypeSelector(
                                    selectedType: widget.selectedType,
                                    onTypeChanged: widget.onTypeChanged,
                                    unitController: widget.unitController,
                                    selectedColor: widget.selectedColor,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                    onChanged: () => setState(() {}),
                                  ),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  HabitIconSelector(
                                    selectedIcon: widget.selectedIcon,
                                    onIconChanged: widget.onIconChanged,
                                    selectedColor: widget.selectedColor,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  HabitColorSelector(
                                    selectedColor: widget.selectedColor,
                                    onColorChanged: widget.onColorChanged,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  HabitAdvancedOptions(
                                    selectedType: widget.selectedType,
                                    showGoalField: widget.showGoalField,
                                    onShowGoalChanged: widget.onShowGoalChanged,
                                    goalController: widget.goalController,
                                    unitController: widget.unitController,
                                    selectedColor: widget.selectedColor,
                                    showQuestionField: widget.showQuestionField,
                                    onShowQuestionChanged:
                                        widget.onShowQuestionChanged,
                                    questionController:
                                        widget.questionController,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 32 : 40),
                                  HabitCreateButton(
                                    onCreate: widget.onCreate,
                                    selectedColor: widget.selectedColor,
                                    isEditing: widget.isEditing,
                                    isMobile: isMobile,
                                  ),
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
        color: widget.isEmbedded
            ? Colors.transparent
            : (isDark
                  ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
                  : AppTheme.glassBackground.withValues(alpha: 0.3)),
        border: widget.isEmbedded
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onClose,
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
                  widget.isEditing ? 'Edit Habit' : 'Create New Habit',
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
}
