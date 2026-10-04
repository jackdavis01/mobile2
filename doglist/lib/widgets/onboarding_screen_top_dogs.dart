import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'onboarding_feature_item.dart';
import 'scrollable_with_bar.dart';

class OnboardingScreenTopDogs extends StatelessWidget {
  const OnboardingScreenTopDogs({super.key});

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
              Icon(Icons.emoji_events, size: 120, color: Theme.of(context).primaryColor),
              const SizedBox(height: 26),
              Text(
                appLocalizations.onboardingTopDogsTitle,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                appLocalizations.onboardingTopDogsDescription,
                style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              OnboardingFeatureItem(icon: Icons.thumb_up_outlined, text: appLocalizations.onboardingTopDogsFeature1),
              OnboardingFeatureItem(icon: Icons.touch_app_outlined, text: appLocalizations.onboardingTopDogsFeature2),
              OnboardingFeatureItem(icon: Icons.filter_alt_outlined, text: appLocalizations.onboardingTopDogsFeature3),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

}