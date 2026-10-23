import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'onboarding_feature_item.dart';
import 'scrollable_with_bar.dart';

class OnboardingScreen5BreedInfo extends StatelessWidget {
  const OnboardingScreen5BreedInfo({super.key});

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
                Icon(Icons.info_outline, size: 120, color: Theme.of(context).primaryColor),
                const SizedBox(height: 26),
                Text(
                  appLocalizations.onboardingScreen5Title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  appLocalizations.onboardingScreen5Description,
                  style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                OnboardingFeatureItem(icon: Icons.straighten, text: appLocalizations.onboardingScreen5Feature1),
                OnboardingFeatureItem(icon: Icons.psychology, text: appLocalizations.onboardingScreen5Feature2),
                OnboardingFeatureItem(icon: Icons.lightbulb_outline, text: appLocalizations.onboardingScreen5Feature3),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }

}
