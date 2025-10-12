import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';
import 'pages/filterpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that SystemChrome settings are applied
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Allow only portrait mode
  ]).then((_) {
    runApp(DogListApp());
  });
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
