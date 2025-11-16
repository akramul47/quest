import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';

class AddTaskField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onSubmitted;
  final String hintText;

  const AddTaskField({
    Key? key,
    required this.controller,
    required this.onAdd,
    required this.onSubmitted,
    this.hintText = 'Add a task',
  }) : super(key: key);

  @override
  State<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  bool _isExpanded = false;
  bool _isHovered = false;
  final FocusNode _focusNode = FocusNode();

  void _focusListener() {
    if (mounted) {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    }
  }

  void _textListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);
    widget.controller.addListener(_textListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    widget.controller.removeListener(_textListener);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(String value) {
    widget.onSubmitted(value);
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
    _focusNode.unfocus();
  }

  void _handleAdd() {
    widget.onAdd();
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
    _focusNode.unfocus();
  }

  void _expand() {
    if (mounted) {
      setState(() {
        _isExpanded = true;
      });
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: _isExpanded ? null : _expand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            gradient: _isExpanded || _isHovered
                ? LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.05),
                          ]
                        : [
                            Colors.white.withOpacity(0.98),
                            Colors.white.withOpacity(0.92),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.65),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(_isExpanded ? 18 : 14),
            border: Border.all(
              color: _isExpanded
                  ? (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.5)
                  : _isHovered
                      ? (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.3)
                      : (isDark ? Colors.white : Colors.white).withOpacity(0.4),
              width: _isExpanded ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (_isExpanded || _isHovered)
                BoxShadow(
                  color: (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.15),
                  blurRadius: _isExpanded ? 20 : 12,
                  spreadRadius: _isExpanded ? 3 : 1,
                  offset: const Offset(0, 5),
                ),
              if (_isExpanded)
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              if (!_isExpanded && _isHovered)
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _isExpanded ? 16 : 14,
            vertical: _isExpanded ? 10 : 11,
          ),
          child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
        ),
      ),
    );
  }

  Widget _buildCollapsedView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(
          Icons.add_task,
          color: _isHovered
              ? (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary)
              : (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.6),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.hintText,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              color: _isHovered
                  ? (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.9)
                  : (isDark ? AppTheme.textMediumDark : Colors.black).withOpacity(0.55),
              fontWeight: _isHovered ? FontWeight.w500 : FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (_isHovered)
          Icon(
            Icons.keyboard_arrow_right,
            color: (isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary).withOpacity(0.6),
            size: 18,
          ),
      ],
    );
  }

  Widget _buildExpandedView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.add_task,
          color: isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.inter(
                  color: (isDark ? AppTheme.textMediumDark : Colors.black).withOpacity(0.4),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.inter(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                height: 1.5,
                color: isDark ? AppTheme.textDarkMode : Colors.black87,
              ),
              onSubmitted: _handleSubmit,
              textInputAction: TextInputAction.done,
              cursorColor: isDark ? AppTheme.primaryColorDark : Theme.of(context).colorScheme.primary,
              cursorWidth: 2.5,
              cursorHeight: 22,
              cursorRadius: const Radius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Add button with enhanced interaction
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.controller.text.isNotEmpty
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: widget.controller.text.isNotEmpty
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleAdd,
              borderRadius: BorderRadius.circular(28),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add_circle,
                  color: widget.controller.text.isNotEmpty
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
