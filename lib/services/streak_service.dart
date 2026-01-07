import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/streak.dart';
import 'api/api_client.dart';
import 'api/auth_service.dart';
import 'api/socket_service.dart';
import 'cache/daos/streak_dao.dart';
import 'premium_service.dart';

/// Global streak service for managing user engagement streaks.
///
/// Features:
/// - Tracks consecutive active days across todos, habits, focus sessions
/// - Freeze days to preserve streak on break days
/// - Auto-generated restore tokens
/// - Premium tier benefits (more freeze days, faster token generation)
/// - Real-time sync via Socket.IO
class StreakService extends ChangeNotifier {
  StreakService._();
  static final StreakService instance = StreakService._();

  final StreakDao _streakDao = StreakDao();
  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final AuthService _authService = AuthService.instance;
  final PremiumService _premiumService = PremiumService.instance;

  GlobalStreak? _streak;
  DailyActivity? _todayActivity;
  bool _isInitialized = false;
  bool _isSyncing = false;

  Timer? _midnightTimer;

  // Getters
  GlobalStreak? get streak => _streak;
  DailyActivity? get todayActivity => _todayActivity;
  bool get isInitialized => _isInitialized;
  int get currentStreak => _streak?.currentStreak ?? 0;
  int get longestStreak => _streak?.longestStreak ?? 0;
  int get restoreTokens => _streak?.restoreTokens ?? 0;
  int get freezeDaysAvailable => _streak?.freezeDaysAvailable ?? 0;
  bool get isFrozenToday => _streak?.isFrozenToday ?? false;
  bool get isActiveToday => _todayActivity?.isActive ?? false;

  // Premium-adjusted limits
  int get maxFreezeDays => _premiumService.isPremium ? 5 : 2;
  int get tokenGenerationRate => _premiumService.isPremium ? 2 : 1; // per week
  int get maxTokens => _premiumService.isPremium ? 5 : 3;

  /// Initialize streak service
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Load cached streak state
      _streak = await _streakDao.getOrCreateStreak();
      _todayActivity = await _streakDao.getTodayActivity();

      // Calculate daily streak (handles day rollover)
      await _calculateDailyStreak();

      // Check for token generation
      await _checkAndGenerateTokens();

      // Schedule midnight recalculation
      _scheduleMidnightRecalculation();

      // Setup Socket.IO listeners
      _setupSocketListeners();

      // Try to sync with server if online
      await _syncWithServer();

      _isInitialized = true;
      notifyListeners();

      debugPrint('✅ StreakService initialized: streak=$currentStreak');
    } catch (e) {
      debugPrint('❌ StreakService init failed: $e');
    }
  }

  // ============== Activity Recording ==============

  /// Record a completed todo
  Future<void> recordTodoCompleted() async {
    await _recordActivity(StreakActivityType.todo);
  }

  /// Record a logged habit
  Future<void> recordHabitLogged() async {
    await _recordActivity(StreakActivityType.habit);
  }

  /// Record a completed focus session
  Future<void> recordFocusSession() async {
    await _recordActivity(StreakActivityType.focus);
  }

  /// Record an activity and update streak
  Future<void> _recordActivity(StreakActivityType type) async {
    // Record in local database
    _todayActivity = await _streakDao.recordActivity(type);

    // If this is the first activity today, update streak
    if (_todayActivity!.isActive && !_wasActiveYesterday()) {
      await _incrementStreak();
    }

    notifyListeners();

    // Sync with server
    _syncActivityToServer(type);
  }

  // ============== Streak Calculation ==============

  /// Calculate streak state on day change
  Future<void> _calculateDailyStreak() async {
    if (_streak == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = _streak!.lastActiveDate;

    if (lastActive == null) {
      // First time user, no action needed
      return;
    }

    final lastActiveDay = DateTime(
      lastActive.year,
      lastActive.month,
      lastActive.day,
    );
    final daysDiff = today.difference(lastActiveDay).inDays;

    if (daysDiff == 0) {
      // Same day, no change
      return;
    } else if (daysDiff == 1) {
      // Yesterday was last active - streak continues if active today or frozen
      // Reset frozen status for new day
      if (_streak!.isFrozenToday) {
        _streak = _streak!.copyWith(isFrozenToday: false);
        await _streakDao.saveStreak(_streak!);
      }
    } else if (daysDiff > 1) {
      // Missed days - streak broken unless restored
      await _breakStreak();
    }

    // Reset freeze day tracking at start of month
    if (now.day == 1 && _streak!.freezeDaysUsed > 0) {
      _streak = _streak!.copyWith(
        freezeDaysUsed: 0,
        freezeDaysAvailable: maxFreezeDays,
      );
      await _streakDao.saveStreak(_streak!);
    }
  }

  /// Increment streak by 1
  Future<void> _incrementStreak() async {
    if (_streak == null) return;

    final now = DateTime.now();
    final newStreak = _streak!.currentStreak + 1;
    final newLongest = newStreak > _streak!.longestStreak
        ? newStreak
        : _streak!.longestStreak;

    _streak = _streak!.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActiveDate: now,
      streakStartDate: _streak!.streakStartDate ?? now,
    );

    await _streakDao.saveStreak(_streak!);
    notifyListeners();

    debugPrint('🔥 Streak increased to $newStreak');
  }

  /// Break the streak (reset to 0)
  Future<void> _breakStreak() async {
    if (_streak == null || _streak!.currentStreak == 0) return;

    _streak = _streak!.copyWith(currentStreak: 0, streakStartDate: null);

    await _streakDao.saveStreak(_streak!);
    notifyListeners();

    debugPrint('💔 Streak broken');
  }

  // ============== Freeze Days ==============

  /// Use a freeze day to preserve streak
  Future<bool> freezeToday() async {
    if (_streak == null) return false;
    if (!canFreezeToday()) return false;

    _streak = _streak!.copyWith(
      isFrozenToday: true,
      freezeDaysUsed: _streak!.freezeDaysUsed + 1,
      freezeDaysAvailable: _streak!.freezeDaysAvailable - 1,
      lastActiveDate: DateTime.now(), // Counts as "active"
    );

    // Mark today as freeze day
    final today = DailyActivity.today().copyWith(isFreezeDay: true);
    await _streakDao.saveDailyActivity(today);
    await _streakDao.saveStreak(_streak!);

    notifyListeners();

    // Sync with server
    _syncFreezeToServer();

    debugPrint('❄️ Today frozen, streak preserved at $currentStreak');
    return true;
  }

  /// Check if user can freeze today
  bool canFreezeToday() {
    if (_streak == null) return false;
    if (_streak!.isFrozenToday) return false;
    if (_streak!.freezeDaysAvailable <= 0) return false;
    if (_todayActivity?.isActive == true) return false; // Already active
    return true;
  }

  // ============== Restore Tokens ==============

  /// Use a restore token to revive broken streak
  Future<bool> useRestoreToken() async {
    if (_streak == null) return false;
    if (_streak!.restoreTokens <= 0) return false;

    // Get the oldest available token
    final tokens = await _streakDao.getAvailableTokens();
    if (tokens.isEmpty) return false;

    final token = tokens.first;
    await _streakDao.useToken(token.id);

    // Restore streak (set to previous longest if higher than 1)
    final restoredStreak = _streak!.longestStreak > 1
        ? _streak!.longestStreak
        : 1;

    _streak = _streak!.copyWith(
      currentStreak: restoredStreak,
      restoreTokens: _streak!.restoreTokens - 1,
      streakStartDate: DateTime.now(),
      lastActiveDate: DateTime.now(),
    );

    await _streakDao.saveStreak(_streak!);
    notifyListeners();

    // Sync with server
    _syncRestoreToServer(token.id);

    debugPrint('♻️ Streak restored to $restoredStreak');
    return true;
  }

  /// Check and auto-generate tokens based on activity
  Future<void> _checkAndGenerateTokens() async {
    if (_streak == null) return;
    if (_streak!.restoreTokens >= maxTokens) return;

    // Token generation logic:
    // - Generate 1 token per week of consecutive streak (up to rate limit)
    // - Premium users get tokens faster
    final weeksActive = (currentStreak / 7).floor();
    final tokensToGenerate =
        (weeksActive * tokenGenerationRate) - _streak!.restoreTokens;

    if (tokensToGenerate > 0) {
      final tokensToAdd = tokensToGenerate.clamp(
        0,
        maxTokens - _streak!.restoreTokens,
      );

      for (int i = 0; i < tokensToAdd; i++) {
        final token = StreakRestoreToken(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(
            const Duration(days: 30),
          ), // 30-day expiry
          lastModified: DateTime.now(),
        );

        await _streakDao.addToken(token);
      }

      _streak = _streak!.copyWith(
        restoreTokens: _streak!.restoreTokens + tokensToAdd,
      );

      await _streakDao.saveStreak(_streak!);
      debugPrint('🎁 Generated $tokensToAdd restore token(s)');
    }
  }

  // ============== Helpers ==============

  bool _wasActiveYesterday() {
    if (_streak?.lastActiveDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastActive = _streak!.lastActiveDate!;

    return lastActive.year == yesterday.year &&
        lastActive.month == yesterday.month &&
        lastActive.day == yesterday.day;
  }

  void _scheduleMidnightRecalculation() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      _calculateDailyStreak();
      _todayActivity = null; // Reset today's activity
      notifyListeners();
      _scheduleMidnightRecalculation(); // Schedule next
    });
  }

  // ============== Socket.IO Integration ==============

  void _setupSocketListeners() {
    _socketService.subscribe(SocketChannels.sync, _onSyncEvent);
  }

  void _onSyncEvent(dynamic data) {
    if (data is Map && data['type'] == 'streak') {
      // Handle server-side streak update
      _handleServerStreakUpdate(data['data'] as Map<String, dynamic>);
    }
  }

  void _handleServerStreakUpdate(Map<String, dynamic> data) {
    // Update local streak from server
    _streak = GlobalStreak.fromJson(data);
    _streakDao.saveStreak(_streak!);
    notifyListeners();

    debugPrint('🔄 Streak synced from server: $currentStreak');
  }

  // ============== Server Sync ==============

  Future<void> _syncWithServer() async {
    if (!_authService.isAuthenticated || _authService.isGuest) return;
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final response = await _apiClient.get('/streak');
      final data = response.data as Map<String, dynamic>;

      if (data['streak'] != null) {
        final serverStreak = GlobalStreak.fromJson(
          data['streak'] as Map<String, dynamic>,
        );

        // Use server data if it has higher streak
        if (serverStreak.currentStreak > currentStreak) {
          _streak = serverStreak;
          await _streakDao.saveStreak(_streak!);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Streak sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void _syncActivityToServer(StreakActivityType type) async {
    if (!_authService.isAuthenticated || _authService.isGuest) return;

    try {
      await _apiClient.post(
        '/streak/activity',
        data: {'type': type.name, 'date': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      debugPrint('Activity sync failed: $e');
    }
  }

  void _syncFreezeToServer() async {
    if (!_authService.isAuthenticated || _authService.isGuest) return;

    try {
      await _apiClient.post(
        '/streak/freeze',
        data: {'date': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      debugPrint('Freeze sync failed: $e');
    }
  }

  void _syncRestoreToServer(String tokenId) async {
    if (!_authService.isAuthenticated || _authService.isGuest) return;

    try {
      await _apiClient.post(
        '/streak/restore',
        data: {'tokenId': tokenId, 'date': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      debugPrint('Restore sync failed: $e');
    }
  }

  // ============== Stats ==============

  /// Get streak statistics
  Future<Map<String, dynamic>> getStats() async {
    final activities = await _streakDao.getActivitiesInRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    final activeDays = activities.where((a) => a.isActive).length;
    final freezeDays = activities.where((a) => a.isFreezeDay).length;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'activeDaysLast30': activeDays,
      'freezeDaysUsed': freezeDays,
      'restoreTokens': restoreTokens,
      'freezeDaysAvailable': freezeDaysAvailable,
    };
  }

  /// Force refresh streak from server
  Future<void> refresh() async {
    await _syncWithServer();
  }

  /// Dispose resources
  void dispose() {
    _midnightTimer?.cancel();
    _socketService.unsubscribe(SocketChannels.sync, _onSyncEvent);
  }
}
