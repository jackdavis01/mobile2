import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'onboarding_feature_item.dart';
import 'scrollable_with_bar.dart';

class OnboardingScreen3Filter extends StatelessWidget {
  const OnboardingScreen3Filter({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return ScrollableWithBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.tune, size: 120, color: Theme.of(context).primaryColor),
                const SizedBox(height: 26),
                Text(
                  appLocalizations.onboardingScreen3Title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  appLocalizations.onboardingScreen3Description,
                  style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                OnboardingFeatureItem(icon: Icons.search, text: appLocalizations.onboardingScreen3Feature1),
                OnboardingFeatureItem(icon: Icons.straighten, text: appLocalizations.onboardingScreen3Feature2),
                OnboardingFeatureItem(icon: Icons.mood, text: appLocalizations.onboardingScreen3Feature3),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }

}
