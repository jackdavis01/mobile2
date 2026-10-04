import 'package:flutter/material.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import 'onboarding_feature_item.dart';
import 'scrollable_with_bar.dart';

class OnboardingScreenCompare extends StatelessWidget {
  const OnboardingScreenCompare({super.key});

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
              Icon(Icons.compare_arrows, size: 120, color: Theme.of(context).primaryColor),
              const SizedBox(height: 26),
              Text(
                appLocalizations.onboardingCompareTitle,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                appLocalizations.onboardingCompareDescription,
                style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              OnboardingFeatureItem(icon: Icons.push_pin_outlined, text: appLocalizations.onboardingCompareFeature1),
              OnboardingFeatureItem(icon: Icons.sort, text: appLocalizations.onboardingCompareFeature2),
              OnboardingFeatureItem(icon: Icons.photo_library_outlined, text: appLocalizations.onboardingCompareFeature3),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

}