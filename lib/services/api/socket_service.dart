import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Socket.IO connection states
enum SocketConnectionState { disconnected, connecting, connected, reconnecting }

/// Real-time event channels
class SocketChannels {
  static const String todos = 'todos';
  static const String habits = 'habits';
  static const String focus = 'focus';
  static const String premium = 'premium';
  static const String sync = 'sync';
}

/// Socket.IO service for real-time communication.
///
/// Features:
/// - Auto-reconnect with exponential backoff
/// - Event subscription management
/// - Connection state tracking
/// - Authentication integration
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;

  final _connectionStateController =
      StreamController<SocketConnectionState>.broadcast();
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;

  /// Stream of connection state changes
  Stream<SocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Current connection state
  SocketConnectionState get currentState => _connectionState;

  /// Check if connected
  bool get isConnected => _connectionState == SocketConnectionState.connected;

  // Event callbacks
  final Map<String, List<void Function(dynamic)>> _eventListeners = {};

  /// Initialize and connect to Socket.IO server
  Future<void> connect({required String serverUrl, String? authToken}) async {
    _updateConnectionState(SocketConnectionState.connecting);

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': authToken})
          .build(),
    );

    _setupEventHandlers();

    debugPrint('🔌 Socket.IO: Connecting to $serverUrl');
  }

  void _setupEventHandlers() {
    _socket?.onConnect((_) {
      debugPrint('🔌 Socket.IO: Connected');
      _updateConnectionState(SocketConnectionState.connected);
    });

    _socket?.onDisconnect((_) {
      debugPrint('🔌 Socket.IO: Disconnected');
      _updateConnectionState(SocketConnectionState.disconnected);
    });

    _socket?.onConnectError((error) {
      debugPrint('🔌 Socket.IO: Connection error - $error');
      _updateConnectionState(SocketConnectionState.disconnected);
    });

    _socket?.onReconnecting((_) {
      debugPrint('🔌 Socket.IO: Reconnecting...');
      _updateConnectionState(SocketConnectionState.reconnecting);
    });

    _socket?.onReconnect((_) {
      debugPrint('🔌 Socket.IO: Reconnected');
      _updateConnectionState(SocketConnectionState.connected);
    });

    _socket?.onError((error) {
      debugPrint('🔌 Socket.IO: Error - $error');
    });

    // Setup channel listeners
    _setupChannelListeners();
  }

  void _setupChannelListeners() {
    // Listen to all registered channels
    for (final channel in [
      SocketChannels.todos,
      SocketChannels.habits,
      SocketChannels.focus,
      SocketChannels.premium,
      SocketChannels.sync,
    ]) {
      _socket?.on(channel, (data) {
        debugPrint('🔌 Socket.IO: Received on $channel: $data');
        _notifyListeners(channel, data);
      });
    }
  }

  void _updateConnectionState(SocketConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _notifyListeners(String channel, dynamic data) {
    final listeners = _eventListeners[channel];
    if (listeners != null) {
      for (final listener in listeners) {
        listener(data);
      }
    }
  }

  /// Subscribe to a channel for real-time updates
  void subscribe(String channel, void Function(dynamic data) callback) {
    _eventListeners.putIfAbsent(channel, () => []);
    _eventListeners[channel]!.add(callback);
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channel, void Function(dynamic data) callback) {
    _eventListeners[channel]?.remove(callback);
  }

  /// Emit an event to the server
  void emit(String event, dynamic data) {
    if (!isConnected) {
      debugPrint('🔌 Socket.IO: Cannot emit - not connected');
      return;
    }

    debugPrint('🔌 Socket.IO: Emitting $event: $data');
    _socket?.emit(event, data);
  }

  /// Emit with acknowledgement callback
  void emitWithAck(
    String event,
    dynamic data,
    void Function(dynamic response) ack,
  ) {
    if (!isConnected) {
      debugPrint('🔌 Socket.IO: Cannot emit - not connected');
      return;
    }

    debugPrint('🔌 Socket.IO: Emitting (with ack) $event: $data');
    _socket?.emitWithAck(event, data, ack: ack);
  }

  /// Update auth token (e.g., after token refresh)
  void updateAuthToken(String token) {
    _socket?.io.options?['auth'] = {'token': token};
  }

  /// Disconnect from server
  void disconnect() {
    debugPrint('🔌 Socket.IO: Disconnecting');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _updateConnectionState(SocketConnectionState.disconnected);
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _eventListeners.clear();
  }
}
