import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/update_service.dart';

/// Provider for managing update notification state
class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService = UpdateService.instance;

  bool _isUpdateReady = false;
  bool _isChecking = false;
  bool _hasShownModal = false;
  bool _isDownloading = false;
  String? _lastDismissedPatch;

  /// Whether an update is ready to install
  bool get isUpdateReady => _isUpdateReady;

  /// Whether we're currently checking for updates
  bool get isChecking => _isChecking;

  /// Whether update is being downloaded
  bool get isDownloading => _isDownloading;

  /// Whether the modal should be shown
  /// Shows if update is ready AND user hasn't dismissed this specific patch
  bool get shouldShowModal {
    if (!_isUpdateReady) return false;
    if (_hasShownModal) return false;

    // Don't show if user already dismissed this patch version
    final availablePatch = _updateService.availablePatchNumber;
    if (_lastDismissedPatch != null &&
        availablePatch != null &&
        _lastDismissedPatch == availablePatch) {
      return false;
    }

    return true;
  }

  /// Current update status from service
  UpdateStatus get status => _updateService.status;

  /// Available patch version
  String? get availablePatchNumber => _updateService.availablePatchNumber;

  /// Initialize and check for updates
  Future<void> initialize() async {
    if (!_updateService.isPlatformSupported) return;

    await _loadDismissedPatch();
    await checkForUpdates();
  }

  /// Load the last dismissed patch from storage
  Future<void> _loadDismissedPatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastDismissedPatch = prefs.getString('dismissed_patch_version');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Save dismissed patch to storage
  Future<void> _saveDismissedPatch(String patch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dismissed_patch_version', patch);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check for updates and download if available
  Future<void> checkForUpdates() async {
    if (!_updateService.isPlatformSupported) return;
    if (_isChecking) return;

    _isChecking = true;
    notifyListeners();

    try {
      final hasUpdate = await _updateService.checkAndDownloadUpdate();

      _isUpdateReady = hasUpdate;
      _hasShownModal = false; // Reset so modal can show for new update
    } catch (e) {
      _isUpdateReady = false;
    } finally {
      _isChecking = false;
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Mark the modal as shown (after user interacts)
  void markModalShown() {
    _hasShownModal = true;
    notifyListeners();
  }

  /// Dismiss the update modal for this patch version
  /// User chose "Later" - don't show again until next patch
  void dismissUpdate() {
    _hasShownModal = true;

    final patch = _updateService.availablePatchNumber;
    if (patch != null) {
      _lastDismissedPatch = patch;
      _saveDismissedPatch(patch);
    }

    notifyListeners();
  }

  /// Reset state (e.g., when user actively checks for updates in settings)
  void resetState() {
    _hasShownModal = false;
    _lastDismissedPatch = null;
    notifyListeners();
  }

  // --- Web Update Logic ---

  static const String _currentWebVersion =
      '1.0.1'; // Increment this for new web updates
  String? _lastSeenWebVersion;

  /// Check for web updates (version comparison)
  Future<void> checkForWebUpdates() async {
    if (!kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSeenWebVersion = prefs.getString('last_seen_web_version') ?? '0.0.0';

      // Check if current version matches last seen
      // For testing, we ensure it shows if versions differ
      if (_currentWebVersion != _lastSeenWebVersion) {
        _isUpdateReady = true;
        _hasShownModal = false;
      }
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Mark web update as seen
  Future<void> dismissWebUpdate() async {
    if (!kIsWeb) return;

    _hasShownModal = true;
    _lastSeenWebVersion = _currentWebVersion;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_seen_web_version', _currentWebVersion);
    } catch (e) {
      // Ignore errors
    }
    notifyListeners();
  }
}
