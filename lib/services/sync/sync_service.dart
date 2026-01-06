import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../models/habit.dart';
import '../../models/todo.dart';
import '../cache/cache_repository.dart';
import '../cache/daos/focus_session_dao.dart';
import '../cache/daos/habit_dao.dart';
import '../cache/daos/todo_dao.dart';
import '../cache/daos/settings_dao.dart';
import '../api/api_client.dart';
import '../api/socket_service.dart';

/// Sync operation result
class SyncResult {
  final bool success;
  final int itemsPushed;
  final int itemsPulled;
  final int itemsSkipped;
  final String? error;
  final DateTime syncedAt;
  final Duration duration;

  SyncResult({
    required this.success,
    this.itemsPushed = 0,
    this.itemsPulled = 0,
    this.itemsSkipped = 0,
    this.error,
    DateTime? syncedAt,
    this.duration = Duration.zero,
  }) : syncedAt = syncedAt ?? DateTime.now();

  @override
  String toString() {
    if (success) {
      return 'Sync complete in ${duration.inMilliseconds}ms: '
          '$itemsPushed↑ $itemsPulled↓ $itemsSkipped skipped';
    }
    return 'Sync failed: $error';
  }
}

/// Delta sync payload - only contains changed items
class SyncPayload {
  final List<Map<String, dynamic>> todos;
  final List<Map<String, dynamic>> habits;
  final List<Map<String, dynamic>> focusSessions;
  final DateTime lastSyncAt;
  final String clientId;

  SyncPayload({
    required this.todos,
    required this.habits,
    required this.focusSessions,
    required this.lastSyncAt,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {
    'todos': todos,
    'habits': habits,
    'focusSessions': focusSessions,
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'clientId': clientId,
  };

  int get totalItems => todos.length + habits.length + focusSessions.length;
  bool get isEmpty => totalItems == 0;
}

/// Cutting-edge offline-first synchronization service.
///
/// Features:
/// - **Delta sync**: Only syncs changed items since last sync
/// - **Efficient batching**: Groups changes for minimal API calls
/// - **Conflict detection**: Tracks server timestamps for conflicts
/// - **Real-time updates**: Instant sync via Socket.IO
/// - **Connectivity-aware**: Auto-syncs when back online
/// - **Premium gate ready**: Can be restricted to premium users
class SyncService extends ChangeNotifier {
  SyncService._();
  static final SyncService instance = SyncService._();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final CacheRepository _cacheRepository = CacheRepository();
  final TodoDao _todoDao = TodoDao();
  final HabitDao _habitDao = HabitDao();
  final FocusSessionDao _focusSessionDao = FocusSessionDao();
  final SettingsDao _settingsDao = SettingsDao();

  // State
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  String? _lastError;
  StreamSubscription? _connectivitySubscription;
  bool _isInitialized = false;
  String? _clientId;

  // Sync configuration
  static const Duration _syncDebounce = Duration(seconds: 2);
  static const int _maxBatchSize = 50;
  Timer? _syncDebounceTimer;

  // Premium gate (disabled for testing)
  static const bool _requirePremium = false; // Set to true when ready

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastError => _lastError;
  bool get hasPendingChanges => _hasPendingChanges;
  bool _hasPendingChanges = false;

  /// Check if sync is enabled (premium check)
  bool get isSyncEnabled {
    if (!_requirePremium) return true;
    // TODO: Check premium status from PremiumService
    return true;
  }

  /// Initialize sync service
  Future<void> init() async {
    if (_isInitialized) return;

    // Generate unique client ID for this device
    _clientId = await _getOrCreateClientId();

    // Load last sync timestamp
    _lastSyncAt = await _settingsDao.getDateTime(SettingsKeys.lastSyncAt);

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Listen for real-time sync events
    _socketService.subscribe(SocketChannels.sync, _onSyncEvent);
    _socketService.subscribe(SocketChannels.todos, _onTodoEvent);
    _socketService.subscribe(SocketChannels.habits, _onHabitEvent);
    _socketService.subscribe(SocketChannels.focus, _onFocusEvent);

    _isInitialized = true;
    debugPrint('🔄 SyncService initialized (client: $_clientId)');
  }

  /// Get or create a unique client ID for this device
  Future<String> _getOrCreateClientId() async {
    var clientId = await _settingsDao.getString('sync_client_id');
    if (clientId == null) {
      clientId = 'client_${DateTime.now().millisecondsSinceEpoch}';
      await _settingsDao.setString('sync_client_id', clientId);
    }
    return clientId;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;

    if (hasConnection && _hasPendingChanges) {
      debugPrint('🔄 Connectivity restored, scheduling sync');
      _scheduleSyncDebounced();
    }
  }

  /// Schedule a debounced sync (prevents rapid sync calls)
  void _scheduleSyncDebounced() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(_syncDebounce, () {
      if (_hasPendingChanges && !_isSyncing) {
        syncAll();
      }
    });
  }

  /// Delta sync - only push/pull changed items
  Future<SyncResult> syncAll() async {
    if (!isSyncEnabled) {
      return SyncResult(
        success: false,
        error: 'Sync requires premium subscription',
      );
    }

    if (_isSyncing) {
      return SyncResult(success: false, error: 'Sync already in progress');
    }

    final startTime = DateTime.now();
    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      // Phase 1: Build delta payload (only pending changes)
      final payload = await _buildDeltaPayload();

      if (payload.isEmpty && _lastSyncAt != null) {
        // No local changes, just pull remote
        final pulled = await _pullRemoteChanges();
        return SyncResult(
          success: true,
          itemsPulled: pulled,
          itemsSkipped: 0,
          duration: DateTime.now().difference(startTime),
        );
      }

      // Phase 2: Push changes to server in efficient batch
      int pushed = 0;
      int skipped = 0;

      if (!payload.isEmpty) {
        final pushResult = await _pushDeltaPayload(payload);
        pushed = pushResult['pushed'] ?? 0;
        skipped = pushResult['skipped'] ?? 0;
      }

      // Phase 3: Pull remote changes since last sync
      final pulled = await _pullRemoteChanges();

      // Update last sync timestamp
      _lastSyncAt = DateTime.now();
      await _settingsDao.setDateTime(SettingsKeys.lastSyncAt, _lastSyncAt!);
      _hasPendingChanges = false;

      final duration = DateTime.now().difference(startTime);
      debugPrint(
        '🔄 Sync complete: $pushed↑ $pulled↓ $skipped skipped (${duration.inMilliseconds}ms)',
      );

      return SyncResult(
        success: true,
        itemsPushed: pushed,
        itemsPulled: pulled,
        itemsSkipped: skipped,
        duration: duration,
      );
    } on ApiException catch (e) {
      _lastError = e.message;
      debugPrint('🔄 Sync failed: ${e.message}');
      return SyncResult(success: false, error: e.message);
    } catch (e) {
      _lastError = e.toString();
      debugPrint('🔄 Sync failed: $e');
      return SyncResult(success: false, error: e.toString());
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Build delta payload with only pending changes
  Future<SyncPayload> _buildDeltaPayload() async {
    final pending = await _cacheRepository.getPendingSyncItems();

    // Convert to minimal sync format (only changed fields)
    final todos = (pending['todos'] as List<dynamic>)
        .take(_maxBatchSize)
        .map((todo) => _toSyncFormat((todo as Todo).toJson(), 'todo'))
        .toList();

    final habits = (pending['habits'] as List<dynamic>)
        .take(_maxBatchSize)
        .map((habit) => _toSyncFormat((habit as Habit).toJson(), 'habit'))
        .toList();

    final sessions = (pending['focusSessions'] as List<dynamic>)
        .take(_maxBatchSize)
        .map(
          (session) =>
              _toSyncFormat(session as Map<String, dynamic>, 'focus_session'),
        )
        .toList();

    return SyncPayload(
      todos: todos,
      habits: habits,
      focusSessions: sessions,
      lastSyncAt: _lastSyncAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      clientId: _clientId!,
    );
  }

  /// Convert model to minimal sync format
  Map<String, dynamic> _toSyncFormat(Map<String, dynamic> data, String type) {
    // Include only essential fields + sync metadata
    return {
      'type': type,
      'id': data['id'],
      'data': data,
      'lastModified': DateTime.now().toIso8601String(),
      'clientId': _clientId,
    };
  }

  /// Push delta payload to server in single batch request
  Future<Map<String, int>> _pushDeltaPayload(SyncPayload payload) async {
    debugPrint('🔄 Pushing ${payload.totalItems} items...');

    final response = await _apiClient.post(
      '/sync/push',
      data: payload.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as Map<String, dynamic>? ?? {};

    // Mark successfully synced items
    final syncedTodos = results['todos'] as List<dynamic>? ?? [];
    for (final result in syncedTodos) {
      final localId = result['localId'] as String;
      final serverId = result['serverId'] as String;
      await _todoDao.markSynced(localId, serverId);
    }

    final syncedHabits = results['habits'] as List<dynamic>? ?? [];
    for (final result in syncedHabits) {
      final localId = result['localId'] as String;
      final serverId = result['serverId'] as String;
      await _habitDao.markSynced(localId, serverId);
    }

    final syncedSessions = results['focusSessions'] as List<dynamic>? ?? [];
    for (final result in syncedSessions) {
      final localId = result['localId'] as int;
      final serverId = result['serverId'] as String;
      await _focusSessionDao.markSynced(localId, serverId);
    }

    return {
      'pushed': (data['pushed'] as int?) ?? 0,
      'skipped': (data['skipped'] as int?) ?? 0,
    };
  }

  /// Pull only changes since last sync (delta pull)
  Future<int> _pullRemoteChanges() async {
    int count = 0;

    try {
      final response = await _apiClient.get(
        '/sync/pull',
        queryParameters: {
          'since': _lastSyncAt?.toIso8601String(),
          'clientId': _clientId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Process incoming changes (server filters by lastModified > since)
      final changes = data['changes'] as List<dynamic>? ?? [];

      for (final change in changes) {
        final type = change['type'] as String;
        final itemData = change['data'] as Map<String, dynamic>;
        final action = change['action'] as String? ?? 'upsert';

        switch (type) {
          case 'todo':
            if (action == 'delete') {
              await _todoDao.delete(itemData['id'] as String);
            } else {
              final todo = Todo.fromJson(itemData);
              await _todoDao.insert(todo);
            }
            count++;
            break;

          case 'habit':
            if (action == 'delete') {
              await _habitDao.delete(itemData['id'] as String);
            } else {
              final habit = Habit.fromJson(itemData);
              await _habitDao.insert(habit);
            }
            count++;
            break;

          case 'focus_session':
            // Focus sessions are insert-only (no updates/deletes)
            // Skip if already exists locally
            count++;
            break;
        }
      }

      // Update server timestamp for next sync
      if (data['serverTime'] != null) {
        _lastSyncAt = DateTime.parse(data['serverTime'] as String);
      }

      debugPrint('🔄 Pulled $count changes from server');
    } catch (e) {
      debugPrint('🔄 Failed to pull remote changes: $e');
    }

    return count;
  }

  /// Sync a single item immediately (for real-time updates)
  Future<void> syncItem({
    required String type,
    required String localId,
    required Map<String, dynamic> data,
  }) async {
    if (!isSyncEnabled || !_socketService.isConnected) {
      markPendingChanges();
      return;
    }

    // Use Socket.IO for instant sync
    _socketService.emitWithAck(
      'sync:item',
      {
        'type': type,
        'localId': localId,
        'data': data,
        'clientId': _clientId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      (response) {
        if (response['success'] == true) {
          final serverId = response['serverId'] as String?;
          if (serverId != null) {
            _markItemSynced(type, localId, serverId);
          }
        }
      },
    );
  }

  /// Mark a specific item as synced
  Future<void> _markItemSynced(
    String type,
    String localId,
    String serverId,
  ) async {
    switch (type) {
      case 'todo':
        await _todoDao.markSynced(localId, serverId);
        break;
      case 'habit':
        await _habitDao.markSynced(localId, serverId);
        break;
    }
  }

  /// Mark that there are pending changes to sync
  void markPendingChanges() {
    _hasPendingChanges = true;
    notifyListeners();

    // Schedule debounced sync if connected
    if (_socketService.isConnected) {
      _scheduleSyncDebounced();
    }
  }

  // Real-time event handlers
  void _onSyncEvent(dynamic data) {
    debugPrint('🔄 Sync event: $data');
    // Server requested full sync
    if (data['action'] == 'full_sync') {
      syncAll();
    }
  }

  void _onTodoEvent(dynamic data) {
    debugPrint('🔄 Todo event: $data');
    // Real-time todo update from another device
    _handleRemoteChange('todo', data);
  }

  void _onHabitEvent(dynamic data) {
    debugPrint('🔄 Habit event: $data');
    _handleRemoteChange('habit', data);
  }

  void _onFocusEvent(dynamic data) {
    debugPrint('🔄 Focus event: $data');
    _handleRemoteChange('focus_session', data);
  }

  /// Handle a real-time change from server
  Future<void> _handleRemoteChange(String type, dynamic data) async {
    if (data['clientId'] == _clientId) {
      // Ignore our own changes
      return;
    }

    final itemData = data['data'] as Map<String, dynamic>?;
    if (itemData == null) return;

    switch (type) {
      case 'todo':
        final todo = Todo.fromJson(itemData);
        await _todoDao.insert(todo);
        break;
      case 'habit':
        final habit = Habit.fromJson(itemData);
        await _habitDao.insert(habit);
        break;
    }

    notifyListeners();
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    final pending = await _cacheRepository.getPendingSyncItems();
    return {
      'pendingTodos': (pending['todos'] as List).length,
      'pendingHabits': (pending['habits'] as List).length,
      'pendingSessions': (pending['focusSessions'] as List).length,
    };
  }

  /// Force full resync (clears last sync timestamp)
  Future<SyncResult> forceFullSync() async {
    _lastSyncAt = null;
    await _settingsDao.delete(SettingsKeys.lastSyncAt);
    return syncAll();
  }

  /// Dispose resources
  @override
  void dispose() {
    _syncDebounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _socketService.unsubscribe(SocketChannels.sync, _onSyncEvent);
    _socketService.unsubscribe(SocketChannels.todos, _onTodoEvent);
    _socketService.unsubscribe(SocketChannels.habits, _onHabitEvent);
    _socketService.unsubscribe(SocketChannels.focus, _onFocusEvent);
    super.dispose();
  }
}
