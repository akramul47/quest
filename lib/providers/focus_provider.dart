import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import '../services/cache/daos/focus_session_dao.dart';

class FocusProvider extends ChangeNotifier {
  final FocusSessionDao _focusSessionDao = FocusSessionDao();

  TimerStatus _status = TimerStatus.idle;
  SessionType _currentSessionType = SessionType.focus;
  TimerSettings _settings = const TimerSettings();

  int _remainingSeconds = 25 * 60; // Default 25 minutes
  int _completedFocusSessions = 0;
  int _totalFocusTimeToday = 0; // in seconds
  DateTime? _sessionStartTime;
  DateTime? _lastTickTime;

  Timer? _timer;
  List<FocusSession> _todaySessions = [];
  bool _showCelebration = false;

  // Getters
  TimerStatus get status => _status;
  SessionType get currentSessionType => _currentSessionType;
  TimerSettings get settings => _settings;
  int get remainingSeconds => _remainingSeconds;
  int get completedFocusSessions => _completedFocusSessions;
  int get totalFocusTimeToday => _totalFocusTimeToday;
  List<FocusSession> get todaySessions => _todaySessions;
  bool get showCelebration => _showCelebration;

  double get progress {
    final totalSeconds = _getCurrentSessionDuration() * 60;
    if (totalSeconds <= 0) return 0;

    // Add smooth interpolation for sub-second progress
    if (_status == TimerStatus.running && _lastTickTime != null) {
      final now = DateTime.now();
      final millisSinceLastTick = now.difference(_lastTickTime!).inMilliseconds;
      final subSecondProgress = millisSinceLastTick / 1000.0;
      final smoothRemaining = _remainingSeconds - subSecondProgress;
      return (smoothRemaining / totalSeconds).clamp(0.0, 1.0);
    }

    return (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeLabel {
    switch (_currentSessionType) {
      case SessionType.focus:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  int _getCurrentSessionDuration() {
    switch (_currentSessionType) {
      case SessionType.focus:
        return _settings.focusDuration;
      case SessionType.shortBreak:
        return _settings.shortBreakDuration;
      case SessionType.longBreak:
        return _settings.longBreakDuration;
    }
  }

  void startTimer() {
    if (_status == TimerStatus.idle) {
      _sessionStartTime = DateTime.now();
    }
    _lastTickTime = DateTime.now();

    _status = TimerStatus.running;
    _timer?.cancel();

    // Update every 100ms for smooth animation, but only decrement seconds when needed
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTickTime!).inSeconds;

      if (elapsed >= 1) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _lastTickTime = now;
        } else {
          _onTimerComplete();
        }
      }
      notifyListeners(); // Notify every 100ms for smooth progress animation
    });

    notifyListeners();
  }

  void pauseTimer() {
    _status = TimerStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    _status = TimerStatus.idle;
    _timer?.cancel();
    _resetTimer();
    _sessionStartTime = null;
    notifyListeners();
  }

  void skipToBreak() {
    // Count as completed session if setting is enabled
    if (_settings.countSkippedSessions &&
        _currentSessionType == SessionType.focus) {
      _completedFocusSessions++;
      final elapsedMinutes =
          (_getCurrentSessionDuration() * 60 - _remainingSeconds) ~/ 60;
      if (elapsedMinutes > 0) {
        _totalFocusTimeToday += elapsedMinutes * 60;
      }

      final session = FocusSession(
        startTime: _sessionStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationMinutes: elapsedMinutes,
        type: SessionType.focus,
        completed: false, // Skipped, not completed
      );
      _todaySessions.add(session);
      _saveSession(session);

      _saveFocusData();
    }

    stopTimer();
    _startBreak();
  }

  void skipBreak() {
    stopTimer();
    _currentSessionType = SessionType.focus;
    _resetTimer();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _status = TimerStatus.completed;

    // Record session
    if (_currentSessionType == SessionType.focus) {
      _completedFocusSessions++;
      _totalFocusTimeToday += _settings.focusDuration * 60;

      final session = FocusSession(
        startTime: _sessionStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationMinutes: _settings.focusDuration,
        type: SessionType.focus,
        completed: true,
      );
      _todaySessions.add(session);
      _saveSession(session);

      // Save session data
      _saveFocusData();

      // Show celebration animation
      _showCelebration = true;
      notifyListeners();

      // Hide celebration after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _showCelebration = false;
        notifyListeners();
      });
    }

    notifyListeners();

    // Auto-start next session
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentSessionType == SessionType.focus) {
        _startBreak();
      } else {
        // Break completed, start next focus session
        _currentSessionType = SessionType.focus;
        _resetTimer();
        if (_settings.autoStartFocus) {
          startTimer();
        } else {
          _status = TimerStatus.idle;
          notifyListeners();
        }
      }
    });
  }

  void _startBreak() {
    // Determine if it's time for a long break
    if (_completedFocusSessions > 0 &&
        _completedFocusSessions % _settings.sessionsUntilLongBreak == 0) {
      _currentSessionType = SessionType.longBreak;
    } else {
      _currentSessionType = SessionType.shortBreak;
    }

    _resetTimer();

    if (_settings.autoStartBreaks) {
      startTimer();
    }
  }

  void _resetTimer() {
    _remainingSeconds = _getCurrentSessionDuration() * 60;
  }

  void updateSettings(TimerSettings newSettings) {
    final wasRunning = _status == TimerStatus.running;
    if (wasRunning) {
      pauseTimer();
    }

    _settings = newSettings;
    _resetTimer();
    _saveSettings();

    if (wasRunning) {
      startTimer();
    } else {
      notifyListeners();
    }
  }

  void setFocusDuration(int minutes) {
    updateSettings(_settings.copyWith(focusDuration: minutes));
  }

  void resetDailyStats() {
    _completedFocusSessions = 0;
    _totalFocusTimeToday = 0;
    _todaySessions.clear();
    _saveFocusData();
    notifyListeners();
  }

  // Persistence methods
  Future<void> loadSettings() async {
    _settings = await _focusSessionDao.loadSettings();
    _resetTimer();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _focusSessionDao.saveSettings(_settings);
  }

  Future<void> loadSessionData() async {
    final data = await _focusSessionDao.loadFocusSessionData();
    _completedFocusSessions = data['sessions'] ?? 0;
    _totalFocusTimeToday = data['totalTime'] ?? 0;

    // Also load today's sessions from database
    _todaySessions = await _focusSessionDao.getToday();
    notifyListeners();
  }

  Future<void> _saveFocusData() async {
    await _focusSessionDao.saveFocusSessionData(
      completedSessions: _completedFocusSessions,
      totalTime: _totalFocusTimeToday,
    );
  }

  /// Save a completed focus session to the database
  Future<void> _saveSession(FocusSession session) async {
    await _focusSessionDao.insert(session);
  }

  Future<void> initialize() async {
    await loadSettings();
    await loadSessionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
