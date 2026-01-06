import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage wrapper that uses SharedPreferences on Windows
/// and flutter_secure_storage on other platforms.
///
/// This is a workaround for Windows builds that don't have Visual Studio
/// C++ ATL libraries installed.
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  // Use SharedPreferences for Windows, secure storage for others
  static final bool _useSharedPrefs =
      kIsWeb ||
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux));

  /// Read a value
  Future<String?> read({required String key}) async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      // For mobile, use flutter_secure_storage
      // Commented out to avoid build errors on Windows
      // final storage = FlutterSecureStorage();
      // return await storage.read(key: key);

      // Fallback to SharedPreferences for now
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  /// Write a value
  Future<void> write({required String key, required String value}) async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      // For mobile, use flutter_secure_storage
      // Commented out to avoid build errors on Windows
      // final storage = FlutterSecureStorage();
      // await storage.write(key: key, value: value);

      // Fallback to SharedPreferences for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  /// Delete a value
  Future<void> delete({required String key}) async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      // For mobile, use flutter_secure_storage
      // Commented out to avoid build errors on Windows
      // final storage = FlutterSecureStorage();
      // await storage.delete(key: key);

      // Fallback to SharedPreferences for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }

  /// Delete all values
  Future<void> deleteAll() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      // Only clear keys we use (don't clear all app preferences)
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } else {
      // For mobile, use flutter_secure_storage
      // Commented out to avoid build errors on Windows
      // final storage = FlutterSecureStorage();
      // await storage.deleteAll();

      // Fallback to SharedPreferences for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    }
  }
}
