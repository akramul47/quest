/// Authentication provider types
enum AuthProvider { email, google, apple }

/// User model for authentication and premium status.
///
/// Represents the authenticated user with their profile and subscription info.
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? googleAvatarUrl; // Original Google profile pic
  final AuthProvider authProvider;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final List<String> enabledFeatures;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Location fields for weather widget
  final double? latitude;
  final double? longitude;
  final bool locationEnabled;
  final String? timezone;

  // Streak fields (synced from streak service)
  final int currentStreak;
  final int longestStreak;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.googleAvatarUrl,
    this.authProvider = AuthProvider.email,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.enabledFeatures = const [],
    required this.createdAt,
    this.lastLoginAt,
    // Location
    this.latitude,
    this.longitude,
    this.locationEnabled = false,
    this.timezone,
    // Streak
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// Get display avatar (custom if set, otherwise Google, otherwise null)
  String? get displayAvatarUrl => avatarUrl ?? googleAvatarUrl;

  /// Check if using custom avatar (not Google default)
  bool get hasCustomAvatar => avatarUrl != null && avatarUrl != googleAvatarUrl;

  /// Check if user should show premium badge
  bool get showPremiumBadge => isPremium && !_isPremiumExpired;

  /// Check if user has access to a specific premium feature
  bool hasFeature(String featureKey) {
    if (isPremium && !_isPremiumExpired) return true;
    return enabledFeatures.contains(featureKey);
  }

  bool get _isPremiumExpired {
    if (premiumExpiresAt == null) return false;
    return DateTime.now().isAfter(premiumExpiresAt!);
  }

  /// Check if premium is active (not expired)
  bool get hasPremiumAccess => isPremium && !_isPremiumExpired;

  /// Check if location is set and enabled
  bool get hasLocation =>
      locationEnabled && latitude != null && longitude != null;

  User copyWith({
    String? name,
    String? avatarUrl,
    String? googleAvatarUrl,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    List<String>? enabledFeatures,
    DateTime? lastLoginAt,
    double? latitude,
    double? longitude,
    bool? locationEnabled,
    String? timezone,
    int? currentStreak,
    int? longestStreak,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      googleAvatarUrl: googleAvatarUrl ?? this.googleAvatarUrl,
      authProvider: authProvider,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      timezone: timezone ?? this.timezone,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'googleAvatarUrl': googleAvatarUrl,
      'authProvider': authProvider.name,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'enabledFeatures': enabledFeatures,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      // Location
      'latitude': latitude,
      'longitude': longitude,
      'locationEnabled': locationEnabled,
      'timezone': timezone,
      // Streak
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      googleAvatarUrl: json['googleAvatarUrl'] as String?,
      authProvider: AuthProvider.values.firstWhere(
        (e) => e.name == json['authProvider'],
        orElse: () => AuthProvider.email,
      ),
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'] as String)
          : null,
      enabledFeatures:
          (json['enabledFeatures'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      // Location
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationEnabled: json['locationEnabled'] as bool? ?? false,
      timezone: json['timezone'] as String?,
      // Streak
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  /// Create a guest user (offline-only mode)
  factory User.guest() {
    return User(
      id: 'guest',
      email: 'guest@local',
      name: 'Guest',
      authProvider: AuthProvider.email,
      isPremium: false,
      enabledFeatures: [],
      createdAt: DateTime.now(),
      locationEnabled: false,
      currentStreak: 0,
      longestStreak: 0,
    );
  }
}
