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
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete(widget.todo);
        } else {
          widget.onArchive(widget.todo);
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
                      children: [
                        _buildCheckbox(),
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
                                    Text(
                                      widget.todo.task,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                        height: 1.5,
                                        decoration: widget.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: widget.isCompleted
                                            ? (isDark
                                                      ? Colors.grey.shade500
                                                      : Colors.grey)
                                                  .withOpacity(0.6)
                                            : null,
                                        decorationThickness: 2,
                                        color: widget.isCompleted
                                            ? (isDark
                                                      ? Colors.grey.shade500
                                                      : Colors.grey)
                                                  .withOpacity(0.65)
                                            : (isDark
                                                  ? AppTheme.textDarkMode
                                                  : const Color(0xFF1a1a1a)),
                                        shadows: widget.isCompleted
                                            ? null
                                            : [
                                                Shadow(
                                                  color:
                                                      (isDark
                                                              ? Colors.white
                                                              : Colors.black)
                                                          .withOpacity(0.03),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  (isDark
                                                          ? AppTheme
                                                                .primaryColorDark
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .primary)
                                                      .withOpacity(0.12),
                                                  (isDark
                                                          ? AppTheme
                                                                .primaryColorDark
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .primary)
                                                      .withOpacity(0.08),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  widget.todo.priority.icon,
                                                  size: 13,
                                                  color:
                                                      (isDark
                                                              ? AppTheme
                                                                    .primaryColorDark
                                                              : Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary)
                                                          .withOpacity(0.85),
                                                ),
                                                const SizedBox(width: 5),
                                                Flexible(
                                                  child: Text(
                                                    widget
                                                        .todo
                                                        .priority
                                                        .displayName,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.4,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.85),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 8),
                        // Star icon on the right - hide for completed tasks
                        if (!widget.isCompleted)
                          Icon(
                            Icons.star_outline,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.6),
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
    final isDeleteAction = direction == DismissDirection.endToStart;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDeleteAction
              ? [Colors.red.shade400, Colors.red.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDeleteAction ? Colors.red : Colors.orange).withOpacity(
              0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: isDeleteAction ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDeleteAction ? Icons.delete : Icons.archive,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            isDeleteAction ? 'Delete' : 'Archive',
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
