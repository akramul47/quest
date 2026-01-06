import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api/api_client.dart';
import 'api/auth_service.dart';
import 'api/socket_service.dart';
import 'cache/daos/settings_dao.dart';

/// Premium feature keys for feature gating
class PremiumFeatures {
  static const String unlimitedHabits = 'unlimited_habits';
  static const String advancedStats = 'advanced_stats';
  static const String customThemes = 'custom_themes';
  static const String cloudSync = 'cloud_sync';
  static const String focusMusic = 'focus_music';
  static const String teamCollaboration = 'team_collaboration';
  static const String prioritySupport = 'priority_support';
}

/// Premium feature info for UI display
class FeatureInfo {
  final String key;
  final String name;
  final String description;
  final bool isPremium;

  const FeatureInfo({
    required this.key,
    required this.name,
    required this.description,
    this.isPremium = true,
  });
}

/// List of all premium features for upgrade screen
const List<FeatureInfo> allPremiumFeatures = [
  FeatureInfo(
    key: PremiumFeatures.unlimitedHabits,
    name: 'Unlimited Habits',
    description: 'Create as many habits as you want',
  ),
  FeatureInfo(
    key: PremiumFeatures.advancedStats,
    name: 'Advanced Statistics',
    description: 'Deep insights into your productivity',
  ),
  FeatureInfo(
    key: PremiumFeatures.customThemes,
    name: 'Custom Themes',
    description: 'Personalize your Quest experience',
  ),
  FeatureInfo(
    key: PremiumFeatures.cloudSync,
    name: 'Cloud Sync',
    description: 'Access your data across all devices',
  ),
  FeatureInfo(
    key: PremiumFeatures.focusMusic,
    name: 'Focus Music',
    description: 'Ambient sounds for deep concentration',
  ),
  FeatureInfo(
    key: PremiumFeatures.teamCollaboration,
    name: 'Team Collaboration',
    description: 'Share goals with friends and family',
  ),
];

/// Premium service for managing premium features.
///
/// Features:
/// - **Offline support**: Premium status persisted locally
/// - Soft blocking with upgrade prompts
/// - Feature flag management
/// - Real-time premium updates via Socket.IO (optional)
class PremiumService extends ChangeNotifier {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  final ApiClient _apiClient = ApiClient.instance;
  final AuthService _authService = AuthService.instance;
  final SocketService _socketService = SocketService.instance;
  final SettingsDao _settingsDao = SettingsDao();

  // Local cache keys
  static const String _cachedPremiumStatusKey = 'premium_status_cached';
  static const String _cachedPremiumExpiresKey = 'premium_expires_cached';
  static const String _cachedFeaturesKey = 'premium_features_cached';

  bool _isLoading = false;
  List<String> _enabledFeatures = [];

  // Locally cached premium status (works offline)
  bool _cachedIsPremium = false;
  DateTime? _cachedExpiresAt;

  bool get isLoading => _isLoading;

  /// Premium status - uses cached value if available (works offline)
  bool get isPremium {
    // First check auth service (fresh from server)
    final authPremium = _authService.user?.hasPremiumAccess;
    if (authPremium != null) return authPremium;

    // Fall back to cached value (works offline)
    if (_cachedIsPremium && _cachedExpiresAt != null) {
      return DateTime.now().isBefore(_cachedExpiresAt!);
    }
    return _cachedIsPremium;
  }

  bool get showPremiumBadge => isPremium;

  DateTime? get premiumExpiresAt =>
      _authService.user?.premiumExpiresAt ?? _cachedExpiresAt;

  /// Initialize premium service - loads cached status first
  Future<void> init() async {
    // Load cached premium status immediately (works offline)
    await _loadCachedStatus();

    // Listen for premium updates via Socket.IO (optional, when online)
    _socketService.subscribe(SocketChannels.premium, _onPremiumEvent);

    // Fetch fresh status if authenticated (background, non-blocking)
    if (_authService.isAuthenticated && !_authService.isGuest) {
      // Don't await - let it run in background
      fetchFeatureFlags().catchError((_) {
        debugPrint('💎 Feature fetch failed, using cached status');
      });
    }

    debugPrint(
      '💎 PremiumService initialized (cached premium: $_cachedIsPremium)',
    );
  }

  /// Load cached premium status from local storage
  Future<void> _loadCachedStatus() async {
    try {
      _cachedIsPremium = await _settingsDao.getBool(_cachedPremiumStatusKey);
      _cachedExpiresAt = await _settingsDao.getDateTime(
        _cachedPremiumExpiresKey,
      );

      final featuresJson = await _settingsDao.getString(_cachedFeaturesKey);
      if (featuresJson != null) {
        _enabledFeatures = (jsonDecode(featuresJson) as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }

      debugPrint(
        '💎 Loaded cached premium: $_cachedIsPremium, expires: $_cachedExpiresAt',
      );
    } catch (e) {
      debugPrint('💎 Failed to load cached status: $e');
    }
  }

  /// Save premium status to local cache
  Future<void> _saveCachedStatus({
    required bool isPremium,
    DateTime? expiresAt,
    List<String>? features,
  }) async {
    try {
      await _settingsDao.setBool(_cachedPremiumStatusKey, isPremium);
      if (expiresAt != null) {
        await _settingsDao.setDateTime(_cachedPremiumExpiresKey, expiresAt);
      }
      if (features != null) {
        await _settingsDao.setString(_cachedFeaturesKey, jsonEncode(features));
      }

      _cachedIsPremium = isPremium;
      _cachedExpiresAt = expiresAt;
      if (features != null) _enabledFeatures = features;

      debugPrint('💎 Saved premium status to cache');
    } catch (e) {
      debugPrint('💎 Failed to save cached status: $e');
    }
  }

  /// Check if user has access to a feature (works offline)
  bool hasFeature(String featureKey) {
    // Premium users have all features
    if (isPremium) return true;

    // Check individually enabled features
    return _enabledFeatures.contains(featureKey);
  }

  /// Check with soft block - returns whether feature is available
  FeatureAccess checkFeature(String featureKey) {
    if (hasFeature(featureKey)) {
      return FeatureAccess(isAvailable: true);
    }

    return FeatureAccess(
      isAvailable: false,
      featureKey: featureKey,
      requiredPlan: 'Premium',
    );
  }

  /// Fetch feature flags from server and cache locally
  Future<void> fetchFeatureFlags() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/premium/features');
      final data = response.data as Map<String, dynamic>;

      final features =
          (data['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      final serverPremium = data['isPremium'] as bool? ?? false;
      final expiresAtStr = data['expiresAt'] as String?;
      final expiresAt = expiresAtStr != null
          ? DateTime.parse(expiresAtStr)
          : null;

      // Save to local cache for offline use
      await _saveCachedStatus(
        isPremium: serverPremium,
        expiresAt: expiresAt,
        features: features,
      );

      debugPrint('💎 Feature flags fetched and cached: $features');
    } catch (e) {
      debugPrint('💎 Failed to fetch feature flags: $e');
      // Keep using cached values - no rethrow
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle real-time premium updates (when online)
  void _onPremiumEvent(dynamic data) {
    debugPrint('💎 Premium event received: $data');

    if (data is Map<String, dynamic>) {
      // Premium status changed
      if (data['type'] == 'status_changed') {
        final newPremium = data['isPremium'] as bool? ?? false;
        final expiresAtStr = data['expiresAt'] as String?;
        final expiresAt = expiresAtStr != null
            ? DateTime.parse(expiresAtStr)
            : null;

        // Update cache
        _saveCachedStatus(isPremium: newPremium, expiresAt: expiresAt);

        // Also refresh auth
        _authService.init();
      }

      // Features updated
      if (data['type'] == 'features_updated') {
        final features =
            (data['features'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        _saveCachedStatus(isPremium: _cachedIsPremium, features: features);
        notifyListeners();
      }
    }
  }

  /// Get days remaining on premium subscription
  int? get daysRemaining {
    if (!isPremium || premiumExpiresAt == null) return null;
    return premiumExpiresAt!.difference(DateTime.now()).inDays;
  }

  /// Check if premium is expiring soon (within 7 days)
  bool get isExpiringSoon {
    final days = daysRemaining;
    return days != null && days <= 7;
  }

  /// Clear cached premium status (on logout)
  Future<void> clearCache() async {
    await _settingsDao.delete(_cachedPremiumStatusKey);
    await _settingsDao.delete(_cachedPremiumExpiresKey);
    await _settingsDao.delete(_cachedFeaturesKey);
    _cachedIsPremium = false;
    _cachedExpiresAt = null;
    _enabledFeatures = [];
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _socketService.unsubscribe(SocketChannels.premium, _onPremiumEvent);
    super.dispose();
  }
}

/// Result of feature access check
class FeatureAccess {
  final bool isAvailable;
  final String? featureKey;
  final String? requiredPlan;

  FeatureAccess({
    required this.isAvailable,
    this.featureKey,
    this.requiredPlan,
  });

  /// Show upgrade prompt if feature is not available
  void showUpgradePromptIfNeeded(
    void Function(String featureKey) onShowPrompt,
  ) {
    if (!isAvailable && featureKey != null) {
      onShowPrompt(featureKey!);
    }
  }
}
