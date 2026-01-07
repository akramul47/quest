import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../Utils/app_theme.dart';
import '../models/todo.dart';

class GlassTaskCard extends StatefulWidget {
  final Todo todo;
  final bool isCompleted;
  final Function(Todo) onToggle;
  final Function(Todo, String) onEdit;
  final Function(Todo) onDelete;
  final Function(Todo) onArchive;
  final VoidCallback? onTap;

  const GlassTaskCard({
    Key? key,
    required this.todo,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    this.onTap,
  }) : super(key: key);

  @override
  _GlassTaskCardState createState() => _GlassTaskCardState();
}

class _GlassTaskCardState extends State<GlassTaskCard>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  late TextEditingController _editingController;
  late ConfettiController _confettiController;
  AnimationController? _checkboxAnimationController;
  AnimationController? _successAnimationController;
  AnimationController? _cardFadeController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _successScaleAnimation;
  Animation<double>? _successOpacityAnimation;
  Animation<double>? _cardFadeAnimation;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.todo.task);
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );

    // Checkbox bounce animation
    _checkboxAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _checkboxAnimationController!,
        curve: Curves.elasticOut,
      ),
    );

    // Success overlay animation
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _successAnimationController!,
        curve: Curves.easeOutBack,
      ),
    );
    _successOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _successAnimationController!,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Card fade animation for completion
    _cardFadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardFadeController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    _confettiController.dispose();
    _checkboxAnimationController?.dispose();
    _successAnimationController?.dispose();
    _cardFadeController?.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _finishEditing() {
    if (_editingController.text.trim().isNotEmpty) {
      widget.onEdit(widget.todo, _editingController.text.trim());
    }
    setState(() {
      _isEditing = false;
    });
  }

  /// Plays the full completion animation sequence for marking a task as done
  void _playCompletionAnimation() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // 1. Start confetti explosion
    _confettiController.play();

    // 2. Checkbox bounce animation
    _checkboxAnimationController?.forward().then((_) {
      _checkboxAnimationController?.reverse();
    });

    // 3. Show and animate success overlay
    setState(() {
      _showSuccessOverlay = true;
    });
    _successAnimationController?.forward();

    // Wait for success overlay to reach peak (400ms)
    await Future.delayed(const Duration(milliseconds: 400));

    // 4. Start card fade out
    _cardFadeController?.forward();

    // Wait for card to fade out (600ms)
    await Future.delayed(const Duration(milliseconds: 600));

    // 5. Move task to completed section
    widget.onToggle(widget.todo);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  Widget _buildDateTimeChip(DateTime? dateTime, bool isDeadline, bool isDark) {
    if (dateTime == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDeadline
            ? Colors.red.withOpacity(0.1)
            : (isDark ? Colors.white : Colors.black87).withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDeadline
              ? Colors.red.withOpacity(0.3)
              : (isDark ? Colors.white : Colors.black87).withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDeadline ? Icons.radio_button_checked : Icons.access_time,
            size: 10,
            color: isDeadline
                ? Colors.red.shade700
                : (isDark ? Colors.white70 : Colors.black87).withOpacity(0.7),
          ),
          const SizedBox(width: 3),
          Text(
            _formatDateTime(dateTime),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDeadline
                  ? Colors.red.shade700
                  : (isDark ? Colors.white70 : Colors.black87).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.todo.id),
      background: _buildDismissibleBackground(
        context,
        DismissDirection.startToEnd,
      ),
      secondaryBackground: _buildDismissibleBackground(
        context,
        DismissDirection.endToStart,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Mark task as done
          if (!widget.isCompleted) {
            // Return false first to snap the card back to position,
            // then play animations after the card is back in place
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _playCompletionAnimation();
            });
          } else {
            HapticFeedback.lightImpact();
            widget.onToggle(widget.todo);
          }
          return false;
        } else {
          // Swipe left: Archive the task
          widget.onArchive(widget.todo);
          return true;
        }
      },
      child: Stack(
        children: [
          FadeTransition(
            opacity: _cardFadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: isDark
                  ? AppTheme.taskCardEffectDark
                  : AppTheme.taskCardEffect,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isCompleted
                      ? null
                      : ((widget.onTap != null)
                            ? widget.onTap
                            : (_isEditing ? null : _startEditing)),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: widget.todo.subtasks.isNotEmpty
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: widget.todo.subtasks.isNotEmpty
                              ? const EdgeInsets.only(top: 3)
                              : EdgeInsets.zero,
                          child: _buildCheckbox(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: (_isEditing && !widget.isCompleted)
                              ? TextField(
                                  controller: _editingController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Edit task',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                      color:
                                          (isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey)
                                              .withOpacity(0.6),
                                    ),
                                  ),
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    height: 1.5,
                                    decoration: widget.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: widget.isCompleted
                                        ? (isDark
                                                  ? Colors.grey.shade500
                                                  : Colors.grey)
                                              .withOpacity(0.65)
                                        : (isDark
                                              ? AppTheme.textDarkMode
                                              : const Color(0xFF1a1a1a)),
                                  ),
                                  onSubmitted: (_) => _finishEditing(),
                                  onEditingComplete: _finishEditing,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title row with date/time and star
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.todo.task,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.2,
                                              height: 1.4,
                                              decoration: widget.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              decorationColor:
                                                  widget.isCompleted
                                                  ? (isDark
                                                            ? Colors
                                                                  .grey
                                                                  .shade500
                                                            : Colors.grey)
                                                        .withOpacity(0.6)
                                                  : null,
                                              decorationThickness: 2,
                                              color: widget.isCompleted
                                                  ? (isDark
                                                            ? Colors
                                                                  .grey
                                                                  .shade500
                                                            : Colors.grey)
                                                        .withOpacity(0.65)
                                                  : (isDark
                                                        ? AppTheme.textDarkMode
                                                        : const Color(
                                                            0xFF1a1a1a,
                                                          )),
                                            ),
                                          ),
                                        ),
                                        // Date/Time chip (if exists)
                                        if (widget.todo.dateTime != null ||
                                            widget.todo.deadline != null) ...[
                                          const SizedBox(width: 6),
                                          _buildDateTimeChip(
                                            widget.todo.deadline ??
                                                widget.todo.dateTime,
                                            widget.todo.deadline != null,
                                            isDark,
                                          ),
                                        ],
                                        // Star icon (always show)
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.star_border,
                                          size: 18,
                                          color:
                                              (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                  .withOpacity(0.4),
                                        ),
                                      ],
                                    ),
                                    // Description (if exists)
                                    if (widget.todo.description != null &&
                                        widget
                                            .todo
                                            .description!
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '- ${widget.todo.description!}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                          color:
                                              (isDark
                                                      ? Colors.white70
                                                      : Colors.black87)
                                                  .withOpacity(0.6),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    // Subtasks (compact, no connecting lines)
                                    if (widget.todo.subtasks.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...widget.todo.subtasks.take(3).map((
                                        subtask,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                            left: 2,
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  final newSubtasks =
                                                      List<Subtask>.from(
                                                        widget.todo.subtasks,
                                                      );
                                                  final idx = newSubtasks
                                                      .indexWhere(
                                                        (s) =>
                                                            s.id == subtask.id,
                                                      );
                                                  if (idx != -1) {
                                                    newSubtasks[idx] = subtask
                                                        .copyWith(
                                                          isCompleted: !subtask
                                                              .isCompleted,
                                                        );
                                                    final updatedTodo = widget
                                                        .todo
                                                        .copyWith(
                                                          subtasks: newSubtasks,
                                                        );
                                                    widget.onEdit(
                                                      updatedTodo,
                                                      updatedTodo.task,
                                                    );
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: subtask.isCompleted
                                                          ? (isDark
                                                                ? AppTheme
                                                                      .primaryColorDark
                                                                : Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary)
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                        color:
                                                            subtask.isCompleted
                                                            ? (isDark
                                                                  ? AppTheme
                                                                        .primaryColorDark
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary)
                                                            : (isDark
                                                                      ? Colors
                                                                            .white
                                                                      : Colors
                                                                            .black87)
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: subtask.isCompleted
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 12,
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  subtask.title,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w400,
                                                    decoration:
                                                        subtask.isCompleted
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                    color:
                                                        (isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black87)
                                                            .withOpacity(
                                                              subtask.isCompleted
                                                                  ? 0.4
                                                                  : 0.65,
                                                            ),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (widget.todo.subtasks.length > 3)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                            left: 20,
                                          ),
                                          child: Text(
                                            '+${widget.todo.subtasks.length - 3} more',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  (isDark
                                                          ? AppTheme
                                                                .primaryColorDark
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .primary)
                                                      .withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Success overlay animation
          if (_showSuccessOverlay)
            Positioned.fill(
              child: FadeTransition(
                opacity:
                    _successOpacityAnimation ??
                    const AlwaysStoppedAnimation(1.0),
                child: ScaleTransition(
                  scale:
                      _successScaleAnimation ??
                      const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.lightGreen.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Confetti positioned at checkbox
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 0,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.02,
            numberOfParticles: 25,
            maxBlastForce: 25,
            minBlastForce: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.lightGreen,
              Colors.blue,
              Colors.lightBlue,
              Colors.pink,
              Colors.orange,
              Colors.amber,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
        // Checkbox button
        ScaleTransition(
          scale: _scaleAnimation ?? AlwaysStoppedAnimation(1.0),
          child: InkWell(
            onTap: () async {
              // Play confetti and animation when marking task as complete
              if (!widget.isCompleted) {
                // Haptic feedback
                HapticFeedback.mediumImpact();

                // 1. Start confetti explosion
                _confettiController.play();

                // 2. Checkbox bounce animation
                _checkboxAnimationController?.forward().then((_) {
                  _checkboxAnimationController?.reverse();
                });

                // 3. Show and animate success overlay
                setState(() {
                  _showSuccessOverlay = true;
                });
                _successAnimationController?.forward();

                // Wait for success overlay to reach peak (400ms)
                await Future.delayed(const Duration(milliseconds: 400));

                // 4. Start card fade out
                _cardFadeController?.forward();

                // Wait for card to fade out (600ms)
                await Future.delayed(const Duration(milliseconds: 600));

                // 5. Move task to completed section
                widget.onToggle(widget.todo);
              } else {
                HapticFeedback.lightImpact();
                widget.onToggle(widget.todo);
              }
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.green.withOpacity(0.3),
            highlightColor: Colors.green.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCompleted
                    ? Colors.green.withOpacity(0.9)
                    : Colors.transparent,
                border: Border.all(
                  color: widget.isCompleted
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: widget.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleBackground(
    BuildContext context,
    DismissDirection direction,
  ) {
    // Swipe right (startToEnd) = Done action, Swipe left (endToStart) = Archive action
    final isDoneAction = direction == DismissDirection.startToEnd;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDoneAction
              ? [Colors.blue.shade400, Colors.blue.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDoneAction ? Colors.blue : Colors.orange).withOpacity(
              0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: isDoneAction ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDoneAction ? Icons.check_circle : Icons.archive,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            isDoneAction ? 'Done' : 'Archive',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
