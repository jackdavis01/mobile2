import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../platform/platform_info.dart';
import '../repositories/onboarding_repository.dart';
import '../widgets/carousel_indicator.dart';
import '../widgets/onboarding_screen_1_welcome.dart';
import '../widgets/onboarding_screen_2_list.dart';
import '../widgets/onboarding_screen_3_filter.dart';
import '../widgets/onboarding_screen_4_details.dart';
import '../widgets/onboarding_screen_5_breed_info.dart';
import '../widgets/onboarding_screen_6_navigation.dart';
import '../widgets/onboarding_screen_7_settings.dart';
import '../widgets/onboarding_screen_8_info.dart';
import '../widgets/onboarding_screen_compare.dart';
import '../widgets/onboarding_screen_top_dogs.dart';

class OnboardingPage extends StatefulWidget {
  final bool fromFirstLaunch;

  const OnboardingPage({super.key, this.fromFirstLaunch = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  List<Widget> get _screens => [
    const OnboardingScreen1Welcome(),
    const OnboardingScreen2List(),
    if (!PlatformInfo.isWeb) const OnboardingScreenTopDogs(),
    const OnboardingScreen3Filter(),
    const OnboardingScreen4Details(),
    const OnboardingScreen5BreedInfo(),
    const OnboardingScreen6Navigation(),
    const OnboardingScreenCompare(),
    const OnboardingScreen7Settings(),
    const OnboardingScreen8Info(),
  ];

  int get _totalPages => _screens.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    await _onboardingRepository.markOnboardingComplete();

    if (!mounted) return;

    if (widget.fromFirstLaunch) {
      // First launch: navigate to appropriate starting page and clear stack
      // Web goes to list, mobile goes to top dogs
      final route = PlatformInfo.isWeb ? '/list' : '/top-dogs';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } else {
      // Manual access from Info page: just go back
      Navigator.of(context).pop();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final screens = _screens;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        appLocalizations.onboardingSkip,
                        style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            // PageView content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: screens,
              ),
            ),
            // Bottom section with indicator and button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CarouselIndicator(totalPages: _totalPages, currentPage: _currentPage),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentPage < _totalPages - 1
                            ? appLocalizations.onboardingNext
                            : appLocalizations.onboardingGetStarted,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
