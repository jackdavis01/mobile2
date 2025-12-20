import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'parameters/ads_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that SystemChrome settings are applied

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Allow only portrait mode
  ]);

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
