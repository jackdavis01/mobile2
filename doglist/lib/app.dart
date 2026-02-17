import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feature_discovery/feature_discovery.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'platform/platform_info.dart';
import 'businesslogic/user_preferences_bloc_cubit.dart';
import 'businesslogic/settings_bloc_cubit.dart';
import 'businesslogic/like_bloc_cubit.dart';
import 'pages/listpage.dart';
import 'pages/detailspage.dart';
import 'pages/filter_page_wrapper.dart';
import 'pages/breed_info_page.dart';
import 'pages/settingspage.dart';
import 'pages/infopage.dart';
import 'pages/onboarding_page.dart';
import 'pages/top_dogs_page.dart';
import 'repositories/onboarding_repository.dart';
import 'services/like_cache_service.dart';

class DogListApp extends StatefulWidget {
  const DogListApp({super.key});

  @override
  State<DogListApp> createState() => _DogListAppState();
}

class _DogListAppState extends State<DogListApp> {
  final OnboardingRepository _onboardingRepository = OnboardingRepository();
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize like cache service with persistent storage
    await LikeCacheService().initialize();
    
    // Check onboarding status
    await _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasSeenOnboarding = await _onboardingRepository.hasSeenOnboarding();
    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    // Show loading while checking onboarding status
    if (_hasSeenOnboarding == null) {
      return MaterialApp(
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserPreferencesCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => LikeCubit()),
      ],
      child: FeatureDiscovery(
        child: MaterialApp(
          debugShowCheckedModeBanner: true,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: appLocalizations.materialAppTitle,
          theme: ThemeData(primarySwatch: Colors.blue),
          initialRoute: _hasSeenOnboarding! 
              ? (PlatformInfo.isWeb ? '/list' : '/top-dogs') 
              : '/onboarding-first',
          routes: {
            '/top-dogs': (context) => const TopDogsPage(),
            '/list': (context) => ListPage(),
            '/details': (context) => DetailsPage(),
            '/filter': (context) => FilterPageWrapper(),
            '/breed-info': (context) => BreedInfoPage(),
            '/settings': (context) => const SettingsPage(),
            '/info': (context) => const InfoPage(),
            '/onboarding': (context) => const OnboardingPage(fromFirstLaunch: false),
            '/onboarding-first': (context) => const OnboardingPage(fromFirstLaunch: true),
          },
        ),
      ),
    );
  }
}
