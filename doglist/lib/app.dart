import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';
import 'pages/filterpage.dart';
import 'pages/breed_info_page.dart';

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
        '/breed-info': (context) => BreedInfoPage(),
      },
    );
  }
}
