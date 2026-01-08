import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

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

  // Icon grid for selection
  final List<IconData> _availableIcons = [
    Icons.favorite,
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.restaurant,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.music_note,
    Icons.brush,
    Icons.school,
    Icons.work,
    Icons.coffee,
    Icons.pets,
    Icons.nature,
    Icons.sunny,
    Icons.medication,
    Icons.psychology,
    Icons.spa,
    Icons.family_restroom,
    Icons.celebration,
    Icons.emoji_events,
    Icons.lightbulb,
    Icons.palette,
  ];

  // Predefined colors
  final List<Color> _colors = [
    const Color(0xFFFF6B6B),
    const Color(0xFFEE5A6F),
    const Color(0xFFC56CF0),
    const Color(0xFF9B59B6),
    const Color(0xFF667EEA),
    const Color(0xFF4FACFE),
    const Color(0xFF00D2FF),
    const Color(0xFF06BEB6),
    const Color(0xFF11998E),
    const Color(0xFF38EF7D),
    const Color(0xFFFFA726),
    const Color(0xFFFFD93D),
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
                                    _buildPreviewCard(isDark, isMobile),
                                    SizedBox(height: isMobile ? 32 : 40),
                                  ] else
                                    const SizedBox(height: 24),

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
                                  _buildCreateButton(
                                    isDark,
                                    isMobile,
                                    maxContentWidth,
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
                  ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                  : AppTheme.glassBackground.withOpacity(0.3)),
        border: widget.isEmbedded
            ? null
            : Border(
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

  Widget _buildPreviewCard(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.selectedColor.withOpacity(0.2),
            widget.selectedColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.selectedColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: widget.selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.selectedIcon,
              size: isMobile ? 40 : 48,
              color: widget.selectedColor,
            ),
          ),
          SizedBox(width: isMobile ? 20 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.nameController,
                  builder: (context, value, _) {
                    return Text(
                      value.text.isEmpty ? 'Your Habit' : value.text,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                    );
                  },
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  widget.selectedType == HabitType.measurable
                      ? 'Track ${widget.unitController.text.isEmpty ? 'values' : widget.unitController.text}'
                      : 'Yes/No tracking',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 16,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
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
          controller: widget.nameController,
          autofocus: !isMobile,
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
              borderSide: BorderSide(color: widget.selectedColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
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
        if (widget.selectedType == HabitType.measurable) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.unitController,
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
              prefixIcon: Icon(Icons.straighten, color: widget.selectedColor),
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
                borderSide: BorderSide(color: widget.selectedColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (widget.selectedType == HabitType.measurable &&
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

  Widget _buildTypeOption(
    bool isDark,
    HabitType type,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = widget.selectedType == type;

    return GestureDetector(
      onTap: () => widget.onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.selectedColor.withOpacity(0.15)
              : (isDark
                    ? AppTheme.glassBackgroundDark.withOpacity(0.3)
                    : AppTheme.glassBackground.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? widget.selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? widget.selectedColor
                  : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? widget.selectedColor
                    : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
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
              final isSelected = widget.selectedIcon == icon;

              return GestureDetector(
                onTap: () => widget.onIconChanged(icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.selectedColor.withOpacity(0.2)
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? widget.selectedColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 24 : 28,
                    color: isSelected
                        ? widget.selectedColor
                        : (isDark
                              ? AppTheme.textMediumDark
                              : AppTheme.textMedium),
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
            final isSelected = widget.selectedColor.value == color.value;
            final colorSize = isMobile ? 48.0 : 56.0;

            return GestureDetector(
              onTap: () => widget.onColorChanged(color),
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
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: isMobile ? 24 : 28,
                      )
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
        if (widget.selectedType == HabitType.measurable)
          _buildAdvancedOption(
            isDark,
            Icons.flag_outlined,
            'Daily Goal',
            'Set a target to reach each day',
            widget.showGoalField,
            widget.onShowGoalChanged,
          ),

        if (widget.showGoalField &&
            widget.selectedType == HabitType.measurable) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.goalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Daily Goal',
              hintText: 'e.g., 5',
              suffix: Text(
                widget.unitController.text.isEmpty
                    ? 'units'
                    : widget.unitController.text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
              ),
              prefixIcon: Icon(Icons.flag, color: widget.selectedColor),
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
                borderSide: BorderSide(color: widget.selectedColor, width: 2),
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
          widget.showQuestionField,
          widget.onShowQuestionChanged,
        ),

        if (widget.showQuestionField) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.questionController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Question',
              hintText: 'e.g., Did you meditate today?',
              prefixIcon: Icon(Icons.quiz, color: widget.selectedColor),
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
                borderSide: BorderSide(color: widget.selectedColor, width: 2),
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
        activeColor: widget.selectedColor,
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            ),
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

  Widget _buildCreateButton(
    bool isDark,
    bool isMobile,
    double maxContentWidth,
  ) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 56 : 60,
      child: FilledButton(
        onPressed: widget.onCreate,
        style: FilledButton.styleFrom(
          backgroundColor: widget.selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: widget.selectedColor.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isEditing ? Icons.save_rounded : Icons.add_rounded,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isEditing ? 'Update Habit' : 'Create Habit',
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
}
