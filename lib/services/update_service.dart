import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Enum representing the current update status
enum UpdateStatus {
  checking,
  upToDate,
  downloading,
  readyToInstall,
  error,
  unsupported, // For web/desktop platforms
}

/// Service for handling Shorebird code push updates
/// Singleton pattern for global access
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  static UpdateService get instance => _instance;

  UpdateService._internal();

  final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  UpdateStatus _status = UpdateStatus.checking;
  UpdateStatus get status => _status;

  String? _currentPatchNumber;
  String? get currentPatchNumber => _currentPatchNumber;

  String? _availablePatchNumber;
  String? get availablePatchNumber => _availablePatchNumber;

  /// Check if current platform supports Shorebird (Android/iOS only)
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Check if Shorebird is available on this device
  Future<bool> isShorebirdAvailable() async {
    if (!isPlatformSupported) return false;
    return _shorebirdCodePush.isShorebirdAvailable();
  }

  /// Check for available updates
  /// Returns true if an update is available
  Future<bool> checkForUpdate() async {
    if (!isPlatformSupported) {
      _status = UpdateStatus.unsupported;
      return false;
    }

    try {
      _status = UpdateStatus.checking;

      final isAvailable = await _shorebirdCodePush.isShorebirdAvailable();
      if (!isAvailable) {
        _status = UpdateStatus.unsupported;
        return false;
      }

      // Get current patch number
      final currentPatch = await _shorebirdCodePush.currentPatchNumber();
      _currentPatchNumber = currentPatch?.toString();

      // Check if update is available
      final isUpdateAvailable = await _shorebirdCodePush
          .isNewPatchAvailableForDownload();

      if (isUpdateAvailable) {
        _status = UpdateStatus.downloading;
        return true;
      } else {
        _status = UpdateStatus.upToDate;
        return false;
      }
    } catch (e) {
      _status = UpdateStatus.error;
      return false;
    }
  }

  /// Download the available update
  /// Returns true if download was successful
  Future<bool> downloadUpdate() async {
    if (!isPlatformSupported) return false;

    try {
      _status = UpdateStatus.downloading;

      await _shorebirdCodePush.downloadUpdateIfAvailable();

      // Check if a new patch is ready to install
      final isReadyToInstall = await _shorebirdCodePush
          .isNewPatchReadyToInstall();

      if (isReadyToInstall) {
        _status = UpdateStatus.readyToInstall;

        // Get the new patch number
        final nextPatch = await _shorebirdCodePush.nextPatchNumber();
        _availablePatchNumber = nextPatch?.toString();

        return true;
      } else {
        _status = UpdateStatus.upToDate;
        return false;
      }
    } catch (e) {
      _status = UpdateStatus.error;
      return false;
    }
  }

  /// Check for update and download if available (combined flow)
  /// Returns true if an update was downloaded and is ready to install
  Future<bool> checkAndDownloadUpdate() async {
    if (!isPlatformSupported) {
      _status = UpdateStatus.unsupported;
      return false;
    }

    try {
      final isAvailable = await _shorebirdCodePush.isShorebirdAvailable();
      if (!isAvailable) {
        _status = UpdateStatus.unsupported;
        return false;
      }

      _status = UpdateStatus.checking;

      // Download update if available (this checks and downloads in one call)
      await _shorebirdCodePush.downloadUpdateIfAvailable();

      // Check if patch is ready to install
      final isReady = await _shorebirdCodePush.isNewPatchReadyToInstall();

      if (isReady) {
        _status = UpdateStatus.readyToInstall;
        final nextPatch = await _shorebirdCodePush.nextPatchNumber();
        _availablePatchNumber = nextPatch?.toString();
        return true;
      } else {
        _status = UpdateStatus.upToDate;
        return false;
      }
    } catch (e) {
      _status = UpdateStatus.error;
      return false;
    }
  }
}
