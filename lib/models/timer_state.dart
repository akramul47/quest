enum TimerStatus {
  idle,
  running,
  paused,
  completed,
}

enum SessionType {
  focus,
  shortBreak,
  longBreak,
}

class TimerSettings {
  final int focusDuration; // in minutes
  final int shortBreakDuration; // in minutes
  final int longBreakDuration; // in minutes
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool countSkippedSessions;
  final bool enableNotifications;
  final bool enableSound;
  final double soundVolume;

  const TimerSettings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.countSkippedSessions = false,
    this.enableNotifications = true,
    this.enableSound = true,
    this.soundVolume = 0.7,
  });

  TimerSettings copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? countSkippedSessions,
    bool? enableNotifications,
    bool? enableSound,
    double? soundVolume,
  }) {
    return TimerSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      countSkippedSessions: countSkippedSessions ?? this.countSkippedSessions,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focusDuration': focusDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsUntilLongBreak': sessionsUntilLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartFocus': autoStartFocus,
      'countSkippedSessions': countSkippedSessions,
      'enableNotifications': enableNotifications,
      'enableSound': enableSound,
      'soundVolume': soundVolume,
    };
  }

  factory TimerSettings.fromJson(Map<String, dynamic> json) {
    return TimerSettings(
      focusDuration: json['focusDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      sessionsUntilLongBreak: json['sessionsUntilLongBreak'] ?? 4,
      autoStartBreaks: json['autoStartBreaks'] ?? false,
      autoStartFocus: json['autoStartFocus'] ?? false,
      countSkippedSessions: json['countSkippedSessions'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      enableSound: json['enableSound'] ?? true,
      soundVolume: json['soundVolume'] ?? 0.7,
    );
  }
}

class FocusSession {
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final SessionType type;
  final bool completed;

  FocusSession({
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.type,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'type': type.toString(),
      'completed': completed,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMinutes: json['durationMinutes'],
      type: SessionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SessionType.focus,
      ),
      completed: json['completed'] ?? false,
    );
  }
}
