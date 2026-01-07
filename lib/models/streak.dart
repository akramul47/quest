/// Global streak system models for tracking user engagement across all activities.
///
/// The streak system rewards consistent engagement with:
/// - Current streak (consecutive active days)
/// - Freeze days (preserve streak on break days)
/// - Restore tokens (revive broken streaks)
library;

/// Represents the user's global streak state
class GlobalStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime? streakStartDate;
  final int freezeDaysUsed;
  final int freezeDaysAvailable;
  final int restoreTokens;
  final bool isFrozenToday;
  final DateTime lastModified;

  const GlobalStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.streakStartDate,
    this.freezeDaysUsed = 0,
    this.freezeDaysAvailable = 2,
    this.restoreTokens = 0,
    this.isFrozenToday = false,
    required this.lastModified,
  });

  /// Create default streak for new users
  factory GlobalStreak.initial() {
    return GlobalStreak(lastModified: DateTime.now());
  }

  /// Check if streak is currently active (not broken)
  bool get isActive => currentStreak > 0;

  /// Check if user can freeze today
  bool get canFreezeToday => !isFrozenToday && freezeDaysAvailable > 0;

  /// Check if user can restore a broken streak
  bool get canRestore => restoreTokens > 0 && currentStreak == 0;

  GlobalStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? streakStartDate,
    int? freezeDaysUsed,
    int? freezeDaysAvailable,
    int? restoreTokens,
    bool? isFrozenToday,
    DateTime? lastModified,
  }) {
    return GlobalStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      freezeDaysUsed: freezeDaysUsed ?? this.freezeDaysUsed,
      freezeDaysAvailable: freezeDaysAvailable ?? this.freezeDaysAvailable,
      restoreTokens: restoreTokens ?? this.restoreTokens,
      isFrozenToday: isFrozenToday ?? this.isFrozenToday,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'streakStartDate': streakStartDate?.toIso8601String(),
      'freezeDaysUsed': freezeDaysUsed,
      'freezeDaysAvailable': freezeDaysAvailable,
      'restoreTokens': restoreTokens,
      'isFrozenToday': isFrozenToday,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory GlobalStreak.fromJson(Map<String, dynamic> json) {
    return GlobalStreak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      streakStartDate: json['streakStartDate'] != null
          ? DateTime.parse(json['streakStartDate'] as String)
          : null,
      freezeDaysUsed: json['freezeDaysUsed'] as int? ?? 0,
      freezeDaysAvailable: json['freezeDaysAvailable'] as int? ?? 2,
      restoreTokens: json['restoreTokens'] as int? ?? 0,
      isFrozenToday: json['isFrozenToday'] as bool? ?? false,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'GlobalStreak(current: $currentStreak, longest: $longestStreak, '
        'tokens: $restoreTokens, frozen: $isFrozenToday)';
  }
}

/// Represents a streak restore token
class StreakRestoreToken {
  final String id;
  final DateTime generatedAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final DateTime? usedAt;
  final String? serverId;
  final DateTime lastModified;

  const StreakRestoreToken({
    required this.id,
    required this.generatedAt,
    this.expiresAt,
    this.isUsed = false,
    this.usedAt,
    this.serverId,
    required this.lastModified,
  });

  /// Check if token is still valid (not used and not expired)
  bool get isValid {
    if (isUsed) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  StreakRestoreToken copyWith({
    bool? isUsed,
    DateTime? usedAt,
    String? serverId,
    DateTime? lastModified,
  }) {
    return StreakRestoreToken(
      id: id,
      generatedAt: generatedAt,
      expiresAt: expiresAt,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
      serverId: serverId ?? this.serverId,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isUsed': isUsed,
      'usedAt': usedAt?.toIso8601String(),
      'serverId': serverId,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory StreakRestoreToken.fromJson(Map<String, dynamic> json) {
    return StreakRestoreToken(
      id: json['id'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isUsed: json['isUsed'] as bool? ?? false,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      serverId: json['serverId'] as String?,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.now(),
    );
  }
}

/// Types of activities that contribute to streak
enum StreakActivityType {
  todo,
  habit,
  focus;

  String get displayName {
    switch (this) {
      case StreakActivityType.todo:
        return 'Completed Todo';
      case StreakActivityType.habit:
        return 'Logged Habit';
      case StreakActivityType.focus:
        return 'Focus Session';
    }
  }
}

/// Represents daily activity for streak calculation
class DailyActivity {
  final DateTime date;
  final bool completedTodo;
  final bool loggedHabit;
  final bool trackedFocus;
  final bool isFreezeDay;
  final DateTime lastModified;

  const DailyActivity({
    required this.date,
    this.completedTodo = false,
    this.loggedHabit = false,
    this.trackedFocus = false,
    this.isFreezeDay = false,
    required this.lastModified,
  });

  /// Check if user was active on this day
  bool get isActive => completedTodo || loggedHabit || trackedFocus;

  /// Get date key for storage (YYYY-MM-DD format)
  String get dateKey => _dateToKey(date);

  static String _dateToKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _keyToDate(String key) {
    return DateTime.parse(key);
  }

  DailyActivity copyWith({
    bool? completedTodo,
    bool? loggedHabit,
    bool? trackedFocus,
    bool? isFreezeDay,
    DateTime? lastModified,
  }) {
    return DailyActivity(
      date: date,
      completedTodo: completedTodo ?? this.completedTodo,
      loggedHabit: loggedHabit ?? this.loggedHabit,
      trackedFocus: trackedFocus ?? this.trackedFocus,
      isFreezeDay: isFreezeDay ?? this.isFreezeDay,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': dateKey,
      'completedTodo': completedTodo,
      'loggedHabit': loggedHabit,
      'trackedFocus': trackedFocus,
      'isFreezeDay': isFreezeDay,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: _keyToDate(json['date'] as String),
      completedTodo: json['completedTodo'] as bool? ?? false,
      loggedHabit: json['loggedHabit'] as bool? ?? false,
      trackedFocus: json['trackedFocus'] as bool? ?? false,
      isFreezeDay: json['isFreezeDay'] as bool? ?? false,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.now(),
    );
  }

  /// Create activity for today
  factory DailyActivity.today() {
    final now = DateTime.now();
    return DailyActivity(
      date: DateTime(now.year, now.month, now.day),
      lastModified: now,
    );
  }
}
