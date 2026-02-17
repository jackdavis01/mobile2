import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'app.dart';
import 'parameters/ads_config.dart';
import 'platform/platform_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that SystemChrome settings are applied

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Allow only portrait mode
  ]);

  // Request App Tracking Transparency permission on iOS (regardless of ads state)
  // This ensures permission is requested even if ads are temporarily disabled
  if (PlatformInfo.isIOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('ATT Status: $status');
      
      // Request permission if not yet determined
      if (status == TrackingStatus.notDetermined) {
        final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT Permission Requested. New Status: $newStatus');
      }
    } catch (e) {
      debugPrint('Error requesting ATT permission: $e');
    }
  }

  // Only initialize Mobile Ads SDK if ads are enabled
  if (AdsConfig.areAdsEnabled) {
    MobileAds.instance.initialize().then((_) {
      debugPrint('Mobile Ads SDK initialized successfully');
    }).catchError((e) {
      debugPrint('Mobile Ads SDK initialization failed: $e');
    });
  } else {
    debugPrint('Mobile Ads SDK initialization skipped (ads disabled)');
  }

  runApp(const DogListApp());
}
