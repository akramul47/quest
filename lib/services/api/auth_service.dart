import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import 'api_client.dart';
import 'socket_service.dart';

/// Authentication states
enum AuthState {
  /// Initial state, checking for stored tokens
  unknown,

  /// User is authenticated
  authenticated,

  /// User is not authenticated (guest mode)
  unauthenticated,

  /// Authentication in progress
  loading,
}

/// Authentication service for user login/logout.
///
/// Features:
/// - Guest mode support (offline-only)
/// - JWT token management
/// - Auto-login from stored tokens
/// - Socket.IO authentication integration
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  AuthState _state = AuthState.unknown;
  User? _user;
  String? _error;

  AuthState get state => _state;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isGuest => _user?.id == 'guest';

  /// Initialize auth service - check for stored tokens
  Future<void> init() async {
    _setState(AuthState.loading);

    try {
      final hasTokens = await _apiClient.hasTokens();

      if (hasTokens) {
        // Try to get user profile with stored token
        await _fetchUserProfile();
      } else {
        // No tokens - use guest mode
        _setGuestMode();
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
      _setGuestMode();
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      // Save tokens
      await _apiClient.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String?,
      );

      // Parse user
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _setState(AuthState.authenticated);

      // Connect to Socket.IO with auth
      await _connectSocket();

      debugPrint('✅ Login successful: ${_user?.email}');
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setState(AuthState.unauthenticated);
      debugPrint('❌ Login failed: ${e.message}');
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      // Save tokens
      await _apiClient.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String?,
      );

      // Parse user
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _setState(AuthState.authenticated);

      // Connect to Socket.IO with auth
      await _connectSocket();

      debugPrint('✅ Registration successful: ${_user?.email}');
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setState(AuthState.unauthenticated);
      debugPrint('❌ Registration failed: ${e.message}');
      return false;
    }
  }

  /// Sign in with Google
  ///
  /// The Google Sign-In flow happens client-side, then we send the
  /// ID token to our Laravel backend for verification and user creation/login.
  Future<bool> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'id_token': idToken, 'access_token': accessToken},
      );

      final data = response.data as Map<String, dynamic>;

      // Save tokens
      await _apiClient.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String?,
      );

      // Parse user (includes Google avatar)
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _setState(AuthState.authenticated);

      // Connect to Socket.IO with auth
      await _connectSocket();

      debugPrint('✅ Google sign-in successful: ${_user?.email}');
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setState(AuthState.unauthenticated);
      debugPrint('❌ Google sign-in failed: ${e.message}');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Notify server
      await _apiClient.post('/auth/logout');
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    }

    // Clear local state
    await _apiClient.clearTokens();
    _socketService.disconnect();
    _setGuestMode();

    debugPrint('✅ Logged out');
  }

  /// Continue as guest (offline mode)
  void continueAsGuest() {
    _setGuestMode();
    debugPrint('✅ Continuing as guest');
  }

  /// Fetch current user profile
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final data = response.data as Map<String, dynamic>;

      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _setState(AuthState.authenticated);

      // Connect to Socket.IO
      await _connectSocket();

      debugPrint('✅ User profile loaded: ${_user?.email}');
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Token expired/invalid
        await _apiClient.clearTokens();
        _setGuestMode();
      } else {
        _error = e.message;
        _setGuestMode();
      }
    }
  }

  /// Update user profile
  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    if (_user == null || isGuest) return false;

    try {
      final response = await _apiClient.patch(
        '/auth/profile',
        data: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );

      final data = response.data as Map<String, dynamic>;
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Connect to Socket.IO with authentication
  Future<void> _connectSocket() async {
    final token = await _apiClient.getAccessToken();
    if (token != null) {
      await _socketService.connect(
        serverUrl: ApiConfig.baseUrl.replaceAll('/api', ''),
        authToken: token,
      );
    }
  }

  void _setGuestMode() {
    _user = User.guest();
    _setState(AuthState.unauthenticated);
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
