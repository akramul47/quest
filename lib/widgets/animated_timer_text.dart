import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedTimerText extends StatefulWidget {
  final String timeText;
  final Color color;
  final double fontSize;
  final bool isRunning;

  const AnimatedTimerText({
    Key? key,
    required this.timeText,
    required this.color,
    this.fontSize = 56,
    this.isRunning = false,
  }) : super(key: key);

  @override
  State<AnimatedTimerText> createState() => _AnimatedTimerTextState();
}

class _AnimatedTimerTextState extends State<AnimatedTimerText>
    with TickerProviderStateMixin {
  String _previousTime = '';
  late AnimationController _minuteController;
  late AnimationController _secondController;
  late AnimationController _fadeController;
  late Animation<int> _minuteAnimation;
  late Animation<int> _secondAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasCountedUp = false;
  bool _isCountingUp = false;
  bool _isFadingOut = false;
  bool _wasEverPaused = false; // Track if timer was paused before

  @override
  void initState() {
    super.initState();
    _previousTime = widget.timeText;
    
    // Quick fade out/in controller for smooth transition
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150), // Very quick fade
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Separate controllers for minutes and seconds
    _minuteController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Until wave reaches start point
      vsync: this,
    );
    
    _secondController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Match wave animation exactly
      vsync: this,
    );
    
    _setupCountUpAnimation();
  }

  void _setupCountUpAnimation() {
    final parts = widget.timeText.split(':');
    final startMinutes = int.tryParse(parts[0]) ?? 0;
    
    // Minutes: 0 to (current - 1) in 1000ms
    // Ultra slow start - 1, 2, 3, 4 are clearly visible to users
    final targetMinutes = (startMinutes - 1).clamp(0, 99);
    _minuteAnimation = IntTween(
      begin: 0,
      end: targetMinutes,
    ).animate(CurvedAnimation(
      parent: _minuteController,
      curve: const Cubic(0.4, 0.0, 0.6, 1.0), // Ultra slow start, gentle throughout
    ));
    
    // Seconds: 0 to 58 in two phases
    // Phase 1 (0-50%): 0 to 5 extremely slowly - each number visible
    // Phase 2 (50%-100%): 5 to 58 with acceleration
    _secondAnimation = TweenSequence<int>([
      TweenSequenceItem(
        tween: IntTween(begin: 0, end: 5)
            .chain(CurveTween(curve: const Cubic(0.3, 0.0, 0.7, 1.0))), // Extremely slow and smooth 0→5
        weight: 50.0, // First 50% of time (1750ms)
      ),
      TweenSequenceItem(
        tween: IntTween(begin: 5, end: 58)
            .chain(CurveTween(curve: Curves.easeInCubic)), // Accelerating 5→58
        weight: 50.0, // Last 50% of time (1750ms)
      ),
    ]).animate(_secondController);
  }

  @override
  void didUpdateWidget(AnimatedTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Track if timer was ever paused
    if (oldWidget.isRunning && !widget.isRunning) {
      _wasEverPaused = true;
    }
    
    // Trigger fade-out and count-up animation when timer starts
    if (widget.isRunning && !oldWidget.isRunning && !_hasCountedUp) {
      // If resuming from pause, skip count-up animation
      if (_wasEverPaused) {
        setState(() {
          _hasCountedUp = true; // Mark as done to use countdown animation
        });
        return;
      }
      
      // First start: show count-up animation
      setState(() {
        _isFadingOut = true;
      });
      
      // Quick fade out the old timer (150ms)
      _fadeController.forward(from: 0.0).then((_) {
        // Immediately start count-up animation (fully visible)
        setState(() {
          _isFadingOut = false;
          _isCountingUp = true;
        });
        
        _setupCountUpAnimation();
        
        // Start both count animations simultaneously
        _minuteController.forward(from: 0.0);
        _secondController.forward(from: 0.0).then((_) {
          // When second animation completes, switch to countdown mode
          setState(() {
            _hasCountedUp = true;
            _isCountingUp = false;
          });
        });
      });
    }
    
    // Reset when timer is stopped
    if (!widget.isRunning && oldWidget.isRunning) {
      _hasCountedUp = false;
      _isCountingUp = false;
      _isFadingOut = false;
      _minuteController.reset();
      _secondController.reset();
      _fadeController.reset();
    }
    
    // Full reset when timer is completely stopped (back to initial state)
    if (!widget.isRunning && oldWidget.timeText != widget.timeText) {
      _wasEverPaused = false;
    }
    
    if (oldWidget.timeText != widget.timeText) {
      _previousTime = oldWidget.timeText;
    }
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    // During fade-out phase (old timer fading away)
    if (_isFadingOut) {
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              widget.timeText,
              style: GoogleFonts.outfit(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w200,
                letterSpacing: 0,
                color: widget.color,
                height: 1,
              ),
            ),
          );
        },
      );
    }
    
    // During count-up animation phase (fully visible, no fade)
    if (_isCountingUp) {
      return AnimatedBuilder(
        animation: Listenable.merge([_minuteController, _secondController]),
        builder: (context, child) {
          final displayTime = '${_formatNumber(_minuteAnimation.value)}:${_formatNumber(_secondAnimation.value)}';
          return _buildCountUpDisplay(displayTime);
        },
      );
    }
    
    // Normal countdown with reverse animation
    return _buildCountdownDisplay(widget.timeText, _previousTime);
  }

  Widget _buildCountUpDisplay(String timeText) {
    // Simple static display during count-up - no sliding animation
    // Match exact structure of countdown display for pixel-perfect alignment
    final characters = timeText.split('');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(characters.length, (index) {
        final char = characters[index];
        final isColon = char == ':';

        if (isColon) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.fontSize * 0.1),
            child: Text(
              ':',
              style: GoogleFonts.outfit(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w200,
                letterSpacing: 0,
                color: widget.color,
                height: 1.0,
              ),
            ),
          );
        }

        return SizedBox(
          width: widget.fontSize * 0.6,
          height: widget.fontSize * 1.2,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: widget.fontSize * 0.1, // Match countdown offset
                child: Center(
                  child: Text(
                    char,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 0,
                      color: widget.color,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCountdownDisplay(String currentTime, String previousTime) {
    final characters = currentTime.split('');
    final previousCharacters = previousTime.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(characters.length, (index) {
        final currentChar = characters[index];
        final previousChar = index < previousCharacters.length 
            ? previousCharacters[index] 
            : currentChar;
        
        final isColon = currentChar == ':';
        // Always animate when character changes
        final hasChanged = currentChar != previousChar && !isColon;

        return _AnimatedDigit(
          key: ValueKey('countdown-$index-$currentChar'),
          currentChar: currentChar,
          previousChar: previousChar,
          hasChanged: hasChanged,
          isColon: isColon,
          isCountdown: true, // Countdown animation: previous down, new from above
          color: widget.color,
          fontSize: widget.fontSize,
        );
      }),
    );
  }
}

class _AnimatedDigit extends StatefulWidget {
  final String currentChar;
  final String previousChar;
  final bool hasChanged;
  final bool isColon;
  final bool isCountdown;
  final Color color;
  final double fontSize;

  const _AnimatedDigit({
    Key? key,
    required this.currentChar,
    required this.previousChar,
    required this.hasChanged,
    required this.isColon,
    this.isCountdown = false,
    required this.color,
    required this.fontSize,
  }) : super(key: key);

  @override
  State<_AnimatedDigit> createState() => _AnimatedDigitState();
}

class _AnimatedDigitState extends State<_AnimatedDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  String? _displayingPrevious;
  String? _displayingCurrent;

  @override
  void initState() {
    super.initState();
    _displayingCurrent = widget.currentChar;
    _displayingPrevious = widget.previousChar;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    
    // Start animation if changed on init
    if (widget.hasChanged) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(_AnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasChanged && widget.currentChar != _displayingCurrent) {
      _displayingPrevious = oldWidget.currentChar;
      _displayingCurrent = widget.currentChar;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isColon) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.fontSize * 0.1),
        child: Text(
          ':',
          style: GoogleFonts.outfit(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w200,
            letterSpacing: 0,
            color: widget.color,
            height: 1.0,
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.fontSize * 0.6,
      height: widget.fontSize * 1.2,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            final showAnimation = widget.hasChanged && _controller.isAnimating;
            
            if (widget.isCountdown) {
              // COUNTDOWN ANIMATION (reverse): Previous falls down, new comes from above
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Previous digit falling down and fading out
                  if (showAnimation && _displayingPrevious != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: (widget.fontSize * 1.2 * _slideAnimation.value) + (widget.fontSize * 0.1),
                      child: Opacity(
                        opacity: 1.0 - _slideAnimation.value,
                        child: Center(
                          child: Text(
                            _displayingPrevious!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 0,
                              color: widget.color,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // New digit coming from above and fading in
                  Positioned(
                    left: 0,
                    right: 0,
                    top: showAnimation
                        ? (-widget.fontSize * 1.2 * (1.0 - _slideAnimation.value)) + (widget.fontSize * 0.1)
                        : widget.fontSize * 0.1,
                    child: Opacity(
                      opacity: showAnimation 
                          ? _slideAnimation.value 
                          : 1.0,
                      child: Center(
                        child: Text(
                          _displayingCurrent ?? widget.currentChar,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 0,
                            color: widget.color,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // COUNT-UP ANIMATION: Previous goes up, new comes from bottom
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Previous digit sliding up and fading out
                  if (showAnimation && _displayingPrevious != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: (-widget.fontSize * 1.2 * _slideAnimation.value) + (widget.fontSize * 0.1),
                      child: Opacity(
                        opacity: 1.0 - _slideAnimation.value,
                        child: Center(
                          child: Text(
                            _displayingPrevious!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 0,
                              color: widget.color,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Current digit sliding up from bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    top: showAnimation
                        ? (widget.fontSize * 1.2 * (1.0 - _slideAnimation.value)) + (widget.fontSize * 0.1)
                        : widget.fontSize * 0.1,
                    child: Opacity(
                      opacity: showAnimation 
                          ? _slideAnimation.value 
                          : 1.0,
                      child: Center(
                        child: Text(
                          _displayingCurrent ?? widget.currentChar,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 0,
                            color: widget.color,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
