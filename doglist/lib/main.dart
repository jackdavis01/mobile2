import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';
import 'pages/filterpage.dart';
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

class DogListApp extends StatelessWidget {
  const DogListApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: appLocalizations.materialAppTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/list',
      routes: {
        '/list': (context) => ListPage(),
        '/details': (context) => DetailsPage(),
        '/filter': (context) => FilterPage(),
      },
    );
  }
}
