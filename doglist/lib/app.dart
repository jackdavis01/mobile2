import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'businesslogic/user_preferences_bloc_cubit.dart';
import 'businesslogic/settings_bloc_cubit.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';
import 'pages/filter_page_wrapper.dart';
import 'pages/breed_info_page.dart';
import 'pages/settingspage.dart';
import 'pages/infopage.dart';

class DogListApp extends StatelessWidget {
  const DogListApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserPreferencesCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: MaterialApp(
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
          '/filter': (context) => FilterPageWrapper(),
          '/breed-info': (context) => BreedInfoPage(),
          '/settings': (context) => const SettingsPage(),
          '/info': (context) => const InfoPage(),
        },
      ),
    );
  }
}
