import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to generate and persist a unique device identifier (UDID).
/// Used for anonymous tracking of likes per device.
class UdidService {
  static final UdidService _instance = UdidService._internal();
  factory UdidService() => _instance;
  UdidService._internal();

  static const String _udidKey = 'app_udid';
  String? _cachedUdid;

  /// Get or generate the device UDID.
  /// First checks in-memory cache, then SharedPreferences,
  /// and finally generates a new one if needed.
  Future<String> getUdid() async {
    // Return cached UDID if available
    if (_cachedUdid != null) {
      return _cachedUdid!;
    }

    // Try to load from shared preferences
    final prefs = await SharedPreferences.getInstance();
    String? storedUdid = prefs.getString(_udidKey);

    if (storedUdid != null && storedUdid.isNotEmpty) {
      _cachedUdid = storedUdid;
      debugPrint('[UdidService] Loaded existing UDID: $storedUdid');
      return storedUdid;
    }

    // Generate new UDID
    final deviceInfo = DeviceInfoPlugin();
    String udid;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        udid = androidInfo.id; // Android ID
        debugPrint('[UdidService] Generated Android UDID: $udid');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        udid = iosInfo.identifierForVendor ?? 'unknown-ios-${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('[UdidService] Generated iOS UDID: $udid');
      } else {
        udid = 'unknown-platform-${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('[UdidService] Generated fallback UDID: $udid');
      }
    } catch (e) {
      debugPrint('[UdidService] Error getting device ID: $e');
      udid = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Store and cache
    await prefs.setString(_udidKey, udid);
    _cachedUdid = udid;
    debugPrint('[UdidService] Stored new UDID: $udid');
    return udid;
  }

  /// Clear the stored UDID (for testing purposes only).
  /// Forces regeneration on next getUdid() call.
  Future<void> clearUdid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_udidKey);
    _cachedUdid = null;
    debugPrint('[UdidService] Cleared UDID');
  }
}
